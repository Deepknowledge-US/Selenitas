require 'Engine.utilities.utl_main'
local cs 	= require 'Resources.models.Evacuation.files.create_scenario'
local fs 	= require 'Resources.models.Evacuation.files.fuzzy_sets'
local iw 	= require 'Resources.models.Evacuation.files.interface_windows'
local add_peacefuls_functions 	= require 'Resources.models.Evacuation.files.peacefuls_functions'
local add_violents_functions  	= require 'Resources.models.Evacuation.files.violents_functions'


-------------------------------------
------  Model Global variables ------
-------------------------------------
global_vars = {
    app_not_alerted     = 0,
    app_accident        = 0,
    app_killed          = 0,
    app_rescued         = 0,
    app_secure_room     = 0,
    not_app_not_alerted = 0,
    not_app_accident    = 0,
    not_app_killed      = 0,
    not_app_rescued     = 0,
    not_app_secure_room = 0,
    total_not_alerted   = 0,
    total_accident      = 0,
    total_killed        = 0,
    total_rescued       = 0,
    total_secure_room   = 0,
	violents_killed		= 0,
	app_is_triggered    = false
}

-- Global variables to search routes
g 	= graph.create(0,true) -- Initial number of nodes = 0. true means the graph is directed
djk	= dijkstra.create()


local reset_global_vars = function()
	for k,_ in pairs(global_vars) do
		global_vars[k] = 0
	end
end

-- This method will create the interface params (See ./files/interface_window.lua).
get = iw.create_interface()

-- A map "id -> internal_id". It will be populated by the "create_scenario function"
id_map = {}



-------------------------------------
--------------  SETUP  --------------
-------------------------------------

SETUP = function()

    -- Reset the simulation and the global_vars of our model
	Simulation:reset()
	reset_global_vars()

	-- Families must be declared after the "Simulation:reset()" command
    declare_FamilyCell('Nodes')
    declare_FamilyRel('Visibs')
    declare_FamilyRel('Transits')
    declare_FamilyRel('Sounds')
    declare_FamilyMobile('Violents')
    declare_FamilyMobile('Peacefuls')
    Nodes.z_order, Peacefuls.z_order, Violents.z_order = 3,4,5

    -- It is possible to use code of other files. This function adds some methods to Peacefuls and Violents families
	add_peacefuls_functions()
	add_violents_functions()

    -- Populates "id_map" and Nodes family
	cs.create_scenario(id_map)

	-- Create graph in luagraph
	for _,l in sorted(Transits)do
		g:addEdge(l.source.__id, l.target.__id, l.dist)
	end




	-- local nodes = {3,4,5}

    for i=1,get.num_peace() do

        local lead = math.random() < get.leaders_perc()
        local a_node = one_of(Nodes:with( function(x) return x.capacity > x.my_agents.count end ) )

        local new_peaceful = Peacefuls:new({
            attacker_heard      = 0,
            attacker_sighted    = 0,
            fire_heard          = 0,
            fire_sighted        = 0,
            bomb_heard          = 0,
            bomb_sighted        = 0,
            scream_heard        = 0,
            corpse_sighted      = 0,
            police_sighted      = 0,
			leader_sighted      = nil,
			bad_area 			= nil,
            running_people      = 0,
            percived_risk       = 0,
            p_timer             = 0,
            fear                = 0,
            pos                 = copy(a_node.pos),
            shape               = 'person',
            color               = lead and {0,1,0,1} or {1,1,1,1},
            app                 = math.random() < get.app_perc() and true or false,
            sensibility         = gaussian( get.sensib_med(), get.sensib_dev() ) * 100,
            leadership          = lead and math.random() + 0.1 or 0,
            panic_level         = 0,
            hidden              = false,
            last_locations      = {a_node},
            location            = a_node,
            next_location       = a_node,
            route               = {},
            base_speed          = gaussian(get.med_speed(), get.med_speed_dev()) / 2,
            speed               = get.n_a_speed(),
            state               = 'not_alerted',
            nearest_danger      = 100

		})
		new_peaceful.location:come_in(new_peaceful)
		if new_peaceful.sensibility > 100 then new_peaceful.sensibility = 100 end
    end


    for i=1, get.num_violents() do
        local a_node = one_of(Nodes:with( function(x) return x.capacity > x.my_agents.count end ) )

        local new_violent = Violents:new({
            pos             = copy(a_node.pos ),
            location        = a_node,
            next_location   = a_node,
            scale           = 1.5,
            shape           = 'person',
            state           = 'aggressive_behaviour',
            color           = {1,0,0,1},
            efectivity      = get.success_rate(),
            speed           = get.attacker_speed(),
            detected        = true,
            police_sighted  = 0,
            route           = { Nodes.agents[17],Nodes.agents[16],Nodes.agents[4],Nodes.agents[3],Nodes.agents[2],Nodes.agents[1] },
            last_locations  = {a_node}

		})
		if new_violent.detected then
			new_violent.location.num_violents = new_violent.location.num_violents + 1
		end

    end


end



-------------------------------------
--------------  STEP  --------------
-------------------------------------

STEP = function()

    local sum = 0

	---------------
    -- WORLD
	---------------

	-- Update links flow
    for _,link in sorted(Transits)do
        local aux = link.flow_counter + link.flow
        link.flow_counter = aux <= link.flow and aux or link.flow
    end

    -- Reset nodes' ephemeral signs.
    for _,node in sorted(Nodes)do
        node.fire_v         = 0
        node.fire_s         = 0
        node.attacker_v     = 0
        node.attacker_s     = 0
        node.bomb_v         = 0
        node.bomb_s         = 0
        node.scream         = 0
        node.running_people = 0
        node.leaders        = 0
		node.police         = 0
		node.nearest_danger	= 50
    end

    -- Update signals produced by violents
    for _,violent in sorted(Violents)do
		if violent.detected then
			local loc       = violent.location
			loc.attacker_v  = violent.efectivity
			loc.nearest_danger = violent:dist_euc_to(loc)

			for id, list_of_links in pairs(loc.out_neighs) do
				for _, link in pairs(list_of_links)do
					if link.family == Visibs then
						local node, dist = Nodes:get(id), violent:dist_euc_to(Nodes:get(id))
						node.nearest_danger = dist < node.nearest_danger and dist or node.nearest_danger
						node.attacker_v = node.attacker_v + violent.efectivity * link:current_value()
						if node.attacker_v > 1 then node.attacker_v = 1 end
					end
				end
			end
		end
	end



	---------------
	-- APP
	---------------

	-- The app will trigger with first blood, when a crowd is running away, or both.
	if global_vars.app_is_triggered == 0 and get.app_info() then
		if get.first_blood() and global_vars.app_killed + global_vars.not_app_killed > 0 then
			global_vars.app_is_triggered = 1
		end
		if get.crowd_running() and Peacefuls:with(function(x) return x.speed ~= get.n_a_speed() end).count > get.crowd_number() then
			global_vars.app_is_triggered = 1
		end
	end



	---------------
    -- VIOLENTS
	---------------

	for _,v in shuffled(Violents)do
        v:belive()
        v:desire()
		v:intention()
    end


	---------------
	-- PEACEFULS
	---------------

	for _,p in shuffled(Peacefuls)do
		if p.__alive and p.state ~= 'at_save' then
			if p.state ~= 'not_alerted' and p:in_exit() then p:rescue()	end

			p.leader_sighted = p:any_leader()
			if p.leadership == 0 and p.leader_sighted then
				p.percived_risk = p.leader_sighted.percived_risk
				if p.leader_sighted.location == p.location then
					p.route = copy(p.leader_sighted.route) 		-- Leaders will share the route with agents who are in the same node
				else
					p.route = p:path_to(g,p.location.__id, p.leader_sighted.location.__id) -- A route to the leader
				end
				p.state = 'with_leader'
			else
				p:belive()
				p:desire()
			end
			p:intention()

			p:casualty_risk()

			if p.fear >= 1 then p.fear = p.fear - 1 end
		end
	end


	purge_agents(Peacefuls)


    if Peacefuls.count < 1 then Simulation:stop() end
end


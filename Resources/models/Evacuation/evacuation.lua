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

	print('\n\n\n\n NEW')

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

	Peacefuls:add_method('belive', function(self)
		local signals = 0
		if self:app_pack() then
			signals = 1
		else
			self:update_signals()
			signals = self.attacker_sighted + self.fire_sighted   + self.bomb_sighted
					+ self.attacker_heard   + self.fire_heard     + self.bomb_heard
					+ self.scream_heard     + self.corpse_sighted + self.running_people
			if signals > 1 then signals = 1 end
		end

		if signals > 0 then

			if self.speed == get.n_a_speed() then
				self.speed = self.base_speed
			end
			local aux = self.fear + signals
			self.fear = aux < 100 and round(aux,2) or 100

			local distance = self.location.attacker_v > 0 and self.location.nearest_danger or 30
			self.panic_level   = round(fs.panic(self.fear, self.sensibility), 2)
			self.percived_risk = round(fs.danger(signals,distance), 2)
		end

	end)

	Peacefuls:add_method('desire', function(self)
		if self.percived_risk > 0.2 then
			if self.panic_level > 95 then
				self.state = "in_panic"
			elseif self:must_I_fight() then
				self.state = "fighting"
			elseif self:is_path_congested() then
				self.state = "avoiding_crowd"
			elseif self:secure_exit() then
				self.state = "reaching_exit"
			elseif self:must_I_hide() then
				self.state = "hidden"
			elseif self:any_violent_near() then
				self.state = "avoiding_violent"
			elseif self:app_pack() then
				self.state = "asking_app"
			elseif #self.route > 0 then
				self.state = "following_route"
			else
				self.state = "running_away"
			end
		end
	end)

	Peacefuls:add_method('intention', function(self)
		local state = self.state
		if state == "avoiding_violent" then
			self:avoid_violent()
			self.color = {0.647,0.176,0.176,1}
		elseif state =="avoiding_crowd"  then
			self:avoid_crowd()
			self.color = {0.098,0.709,0.99,1}
		elseif state == "reaching_exit" then
			self:go_to_exit()
			self.color = {0.5,1,0.5,1}
		elseif state == "in_panic" then
			self:irrational_behaviour()
			self.color = {0.588,0.157,0.106,1}
		elseif state == "not_alerted" then
			self:keep_working()
			self.color = {1,1,1,1}
		elseif state == "with_leader" then
			self:follow_leader()
			self.color = {1,1,0.5,1}
		elseif state == "running_away" then
			self:run_away()
			self.color = {0,1,0,1}
		elseif state == "hidden" then
			self:hide()
			self.color = {0.5,0.5,1,1}
		elseif state == "fighting" then
			self:fight()
			self.color = {0,0,0,1}
		elseif state == "asking_app" then
			self:ask_app()
			self.color = {1,1,1,1}
		elseif state == "following_route" then
			self:follow_route()
			self.color = {0.9,0.9,0.8,1}
		end
	end)





    for i=1,get.num_peace() do

        local lead = math.random() < get.leaders_perc()
        local a_node = one_of(Nodes:with( function(x) return x.capacity > x.my_agents.count end ) )
		-- local a_node = Nodes:get(4)

        -- a_node.residents = a_node.residents + 1
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
            in_a_secure_room    = false,
            nearest_danger      = 100

		})
		new_peaceful.location:come_in(new_peaceful)
		-- new_peaceful.label = new_peaceful.__id
		-- new_peaceful.show_label = true
		if new_peaceful.sensibility > 100 then new_peaceful.sensibility = 100 end
		-- print(new_peaceful.__id)
    end


    for i=1, get.num_violents() do
        -- local a_node = one_of(Nodes:with( function(x) return x.capacity > x.residents end ) )
        local a_node = Nodes.agents[6]

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
            detected        = false,
            police_sighted  = 0,
            route           = { Nodes.agents[17],Nodes.agents[16],Nodes.agents[4],Nodes.agents[3],Nodes.agents[2],Nodes.agents[1] },
            last_locations  = {a_node}

		})

    end


end





-------------------------------------
--------------  STEP  --------------
-------------------------------------

STEP = function()

    local sum = 0
    -- print('\n\n----------', Simulation.time)

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
						node.attacker_v = node.attacker_v + violent.efectivity * link.value
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
		if p.__alive then

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


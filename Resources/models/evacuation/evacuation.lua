require 'Engine.utilities.utl_main'

add_path("/Resources/models/evacuation/files/")

local cs 	= require('create_scenario')
local fs 	= require('fuzzy_sets')
local iw 	= require('interface_windows')

local mqtt  = require('client')
get 		= iw.create_interface() -- by doing this at this point, we can use 'get' in peacefuls' and violents' files

local add_peacefuls_functions 	= require('peacefuls_functions')
local add_violents_functions  	= require('violents_functions')


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
	app_is_triggered    = 0
}

-- Global variables to search routes
g 	= graph.create(0,true) -- Initial number of nodes = 0. 'true' means the graph is directed
djk	= dijkstra.create()

local reset_global_vars = function()
	for k,_ in pairs(global_vars) do
		global_vars[k] = 0
	end
end

-- A map "id -> internal_id". It will be populated by the "create_scenario function"
id_map = {}

panels_channel:push(Interface.windows)
-------------------------------------
--------------  SETUP  --------------
-------------------------------------

SETUP = function()

	-- print('\n\n\n\n NEW')

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

	Peacefuls:add_method('intention', function(self)
		-- print('\tIntention.state: '..self.state)
		local state = self.state
		if state == "avoiding_violent" then
			self:avoid_violent()
			if self.leadership == 0 then self.color = {0.902,0.098,0.294,1} end
		elseif state =="avoiding_crowd"  then
			self:avoid_crowd()
			if self.leadership == 0 then self.color = {0.502,0,0,1} end
		elseif state == "asking_app" then
			self:ask_app()
			if self.leadership == 0 then self.color = {0,0,0.502,1} end
		elseif state == "reaching_exit" then
			self:go_to_exit()
			if self.leadership == 0 then self.color = {0,0.502,0.502,1} end
		elseif state == "following_route" then
			self:follow_route()
			if self.leadership == 0 then self.color = {0,0.502,0.502,1} end
		elseif state == "with_leader" then
			self:follow_leader()
			if self.leadership == 0 then self.color = {0.667,1,0.765,1} end
		elseif state == "running_away" then
			self:run_away()
			if self.leadership == 0 then self.color = {1,1,0.098,1} end
		elseif state == "fighting" then
			self:fight()
			if self.leadership == 0 then self.color = {0,0,0,1} end
		elseif state =="waiting"  then
			self:to_wait()
			if self.leadership == 0 then self.color = {0.275,0.941,0.941,1} end
		elseif state == "hidden" then
			self:hide()
			if self.leadership == 0 then self.color = {0.275,0.941,0.941,1} end
		elseif state == "at_save" then
			self:to_stay()
			if self.leadership == 0 then self.color = {1,1,1,1} end
		elseif state == "not_alerted" then
			self:keep_working()
			if self.leadership == 0 then self.color = {1,1,1,1} end
		elseif state == "in_panic" then
			self:irrational_behaviour()
			if self.leadership == 0 then self.color = {0.502,0.502,0.502,1} end
		end
	end)

    -- Populates "id_map" and Nodes family
	cs.create_scenario(id_map)
	for _,node in sorted(Nodes) do
		node.label 		= node.__id -- .. '\n' .. node.id
		-- node.label 		= node.has_lock
		node.show_label = true
	end

	-- Create graph in luagraph
	for _,l in sorted(Transits)do
		g:addEdge(l.source.__id, l.target.__id, l.dist)
	end

	-- Create Peacefuls agents
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
            color               = lead and {0.235,0.706,0.294,1} or {1,1,1,1},
            app                 = math.random() < get.app_perc() and true or false,
            sensibility         = gaussian( get.sensib_med(), get.sensib_dev() ) * 100,
            leadership          = lead and math.random() + 0.05 or 0,
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

	-- Create violents
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
	-- pretty.dump(Interface.windows)

	panels_channel:push(global_vars)

end



-------------------------------------
--------------  STEP  --------------
-------------------------------------

STEP = function()

    -- print('\n\n---------- TIME: ', Simulation.time)

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
		v.speed = get.attacker_speed()
        v:belive()
        v:desire()
		v:intention()
    end


	---------------
	-- PEACEFULS
	---------------

	for _,p in shuffled(Peacefuls)do
		if p.__alive and p.state ~= 'at_save' then
			-- print('\nAgent: '.. p.__id .. '-' .. round(p.leadership,2), 'Node: '.. p.location.__id .. ' To: '.. p.next_location.__id)
			if p.state ~= 'not_alerted' and p:in_exit() then p:rescue()	end

			-- p.leader_sighted = p:any_leader()
			if p.leadership == 0 and not p.hidden and p:any_leader() then
				-- print('\twith lead')
				p.percived_risk = p.leader_sighted.percived_risk
				if p.leader_sighted.location == p.location then
					p.route = copy(p.leader_sighted.route) 		-- Leaders will share the route with agents who are in the same node
				else
					p.route = p:path_to(g,p.location.__id, p.leader_sighted.location.__id) -- A route to the leader
				end
				p.state = 'with_leader'
			else
				-- print('\tno lead')
				p:belive()
				p:desire()
			end
			-- print('\tstate: '.. p.state)
			p:intention()

			if p.fear >= 1 then p.fear = p.fear - 1 end

			p:casualty_risk()
		end
	end

	purge_agents(Peacefuls)

	local total = global_vars.app_accident
				+ global_vars.app_killed
				+ global_vars.app_rescued
				+ global_vars.app_secure_room
				+ global_vars.not_app_accident
				+ global_vars.not_app_killed
				+ global_vars.not_app_rescued
				+ global_vars.not_app_secure_room

	if get.num_peace() - total < 1 then
		-- print(get.num_peace(), total)
		Simulation:stop()
	end

	-- Send info to publisher
	if global_vars ~= nil then
		state_channel:push(global_vars)
    end
end


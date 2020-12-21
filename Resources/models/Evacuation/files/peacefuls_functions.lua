require 'Engine.utilities.utl_main'
local fs 	= require 'Resources.models.Evacuation.files.fuzzy_sets'
-- local g 	= graph.create(0,true) -- Initial number of nodes = 0. true means the graph is directed
-- local djk	= dijkstra.create()

local running_people_signal_intensity = 0.3

local add_methods = function()



	-------------------------------------
	---------  Check Functions  ---------
	-------------------------------------

	Peacefuls:add_method('any_leader', function(self)
		if self.location.leaders > 0 then
			return one_of(self.location.my_agents:with(function(x) return x.leadership > 0 and x.state ~= 'not_alerted' end) )
		else
			local nodes_with_leader = self.location:get_out_neighs(Nodes,Visibs):with(function(x) return x.leaders > 0 end)
			if nodes_with_leader.count > 0 then
				local node = one_of(nodes_with_leader)
				local leader = one_of( node:my_agents():with(function(x) return x.leadership > 0 and x.state ~= 'not_alerted' end) )
				return leader
			end
		end
		return nil
	end)

	-- True if there is no violents in the route
	Peacefuls:add_method('secure_route', function(self,route)
		for _,node in sorted(route) do
			if node.num_violents > 0 then return false end
		end
		return true
	end)

	-- True if the agent is in an exit
	Peacefuls:add_method('in_exit', function(self)
		return self.location.id%1 <= 0.099
	end)

	-- True if the agent has the app installed and the app is active and it has been triggered
	Peacefuls:add_method('app_pack', function(self)
		return self.app and get.app_info() and global_vars.app_is_triggered
	end)

	-- True if there is a visible agent and some places to hide in the node.
	Peacefuls:add_method('must_I_hide', function(self)
		if self.hidden then
			return self.location.attacker_v > 0 or self.location.num_violents > 0 -- If the agent is already hidden and there is a violent in its node or in its visible nodes, the peaceful remains hidden.
		else
			return self.location.attacker_v > 0 and self.location.hidden_places - self.location.hidden_people > 0
		end
	end)

	-- True if there is some violent in the node and at least 10 peacefuls for each violent
	Peacefuls:add_method('must_I_fight', function(self)
		local num_agents = self.location.my_agents.count
		local num_violents = Violents:with(function(x) return x.location == self.location end ).count
		return num_violents > 0 and num_agents > 10*num_violents
	end)

	-- True if residents are at least 90% of node's capacity
	Peacefuls:add_method('is_path_congested', function(self)
		local loc, next_loc = self.location, self.next_location
		return loc ~= next_loc and next_loc.my_agents.count * 1.1 > next_loc.capacity
	end)

	-- True if there is a visible violent
	Peacefuls:add_method('any_violents', function(self)
		return self.location.attacker_v > 0
	end)

	-- True if Node has a lock and all lockable edges are locked
	Peacefuls:add_method('am_I_in_secure_room', function(self)
		local lock      = self.location.lock
		local lockables = self.location.get_links(Transits):with(function(x) return x.lockable > 0 end)
		local locked    = lockables:with( function(x) return x.locked end )
		return not lock or lockables.count < 1 or lockables.count > locked.count
	end)

	-- True if there is a violent in the node
	Peacefuls:add_method('any_violents_in_my_room', function(self)
		for _, v in sorted(Violents)do
			if v.location == self.location then return true end
		end
		return false
	end)

	-- True if there is a visible violent
	Peacefuls:add_method('any_violent_near', function(self)
		return self.location.attacker_v > 0
	end)

	-- True if node has any not occupied place to hide
	Peacefuls:add_method('place_to_hide', function(self)
		return self.location.hidden_places > self.location.hidden_people
	end)

	-- It looks for a safe way out to reach. If find it, it gives a route to the agent
	Peacefuls:add_method('secure_exit', function(self)
		local visib_exits = self.location:get_out_neighs(Nodes, Visibs):with(function(x) return x.id - math.floor(x.id) <= 0.099 end)

		if visib_exits.count > 0 then
			for _,exit in sorted(visib_exits)do
				local route = self:path_to(g, self.location.__id, exit.__id)
				if self:secure_route(route) then
					self.route = route
					return true
				end
			end
			return false
		else
			return false
		end
	end)



	-------------------------------------
	--------  Update Functions  ---------
    -------------------------------------

	Peacefuls:add_method('update_signals', function(self)
		self.attacker_heard		= self.attacker_heard   + self.location.attacker_s
		self.attacker_sighted	= self.attacker_sighted + self.location.attacker_v
		self.fire_heard         = self.fire_heard       + self.location.fire_s
		self.fire_sighted       = self.fire_sighted     + self.location.fire_v
		self.bomb_heard         = self.bomb_heard       + self.location.bomb_s
		self.bomb_sighted       = self.bomb_sighted     + self.location.bomb_v
		self.scream_heard       = self.scream_heard     + self.location.scream
		self.corpse_sighted     = self.corpse_sighted   + self.location.corpses
		self.running_people     = self.running_people   + self.location.running_people
	end)

	Peacefuls:add_method('update_running_people', function(self)
		local loc			= self.location
		loc.running_people	= loc.running_people + running_people_signal_intensity

		-- This will update signals in nodes with a visual of the agent
		for _,link in sorted(loc:get_in_links(Visibs)) do
			local signal_intensity = loc.running_people * link.value * link.mod * Interface:get_value('World', 'visib mod')
			link.source.running_people = link.source.running_people + signal_intensity
		end
	end)

	Peacefuls:add_method( 'update_position', function(self)
		local old_node, new_node = self.location, self.next_location

        old_node:come_out(self)
        self.location = new_node
        new_node:come_in(self)

        if not self.location:is_in(self.last_locations) then
            local ll = self.last_locations
			ll[8],ll[7],ll[6],ll[5],ll[4],ll[3],ll[2],ll[1] =
			ll[7],ll[6],ll[5],ll[4],ll[3],ll[2],ll[1],self.location
        else
            local ll = {}
            table.insert(ll,self.location)
            for i=1,#self.last_locations do
                if self.last_locations[i] ~= self.location then table.insert(ll,self.last_locations[i]) end
            end
            self.last_locations = ll
        end

	end)



	-------------------------------------
	--------  Action Functions  ---------
    -------------------------------------

	Peacefuls:add_method('stop_hidden', function(self)
		if self.hidden then
			self.hidden = false
			if self.in_a_secure_room then
				local lockables_links = self.location:get_links():with( function(x) return x.lockable > 0 end )

				for _,link in sorted( lockables_links )do
					if link.locked then
						link.transitable = 1
						link.locked 	 = false
					end
				end
			else
				self.location.hidden_people = self.location.hidden_people - 1
			end
		end
	end)

	Peacefuls:add_method('visible_exits', function(self)
		return	self.location:get_out_neighs(Nodes,Visibs):with(function(x) return x.__id%1 <= 0.099 end)
	end)

	Peacefuls:add_method( 'advance', function(self)
		self:advance_not_alerted()
		self:update_running_people()
	end)

	-- This function is used only when agents are not alerted. The difference with advance() is that this function does not update the running_people signals in nodes
	Peacefuls:add_method( 'advance_not_alerted', function(self)
		local dist_next = self:dist_euc_to(self.next_location)

		if dist_next <= self.speed then self:update_position()	end
		-- if dist_next <= 1.2 then self:update_position()	end

		if self.location ~= self.next_location then
			-- out_neighs is a table "id_of_out_neigh -> list of links". So, we have a direct access to links beetween location and next_location
			local links_with_next_loc = self.location.out_neighs[self.next_location.__id]
			-- As we have created transitable links at last, the last position of the list will contain the link we are looking for.
			local current_link = links_with_next_loc[#links_with_next_loc]

			if current_link.flow_counter > 0 then
				if current_link.flow_counter > 0 and self.location:density() < 0.9 then
					current_link.flow_counter = current_link.flow_counter - 1
					self:fd(self.speed)
					if self.state ~= 'not_alerted' then
						self.location.running_people = self.location.running_people + 1
					end
				end
			end
		end
	end)

	Peacefuls:add_method('casualty_risk', function(self)
		local acc_prob = fs.accident(self.location:density(), self.speed)

		-- print('Casualty.\n\tdens: ' .. round(self.location:density(),2), 'speed: '.. round(self.speed,2), 'acc: '..round(acc_prob,2))

		if acc_prob > 60 and math.random() * 1000 < acc_prob then
			if self.app then
				global_vars.app_accident = global_vars.app_accident +1
			else
				global_vars.not_app_accident = global_vars.not_app_accident +1
			end
			-- Update corpses signals
			self.location:new_corpse()

			-- Update agents in node
			self.location:come_out(self)
			self.family:kill(self)
		end
	end)

	Peacefuls:add_method('rescue', function(self)
		if self.app then
			global_vars.app_rescued = global_vars.app_rescued + 1
		else
			global_vars.not_app_rescued = global_vars.not_app_rescued + 1
		end
		self.location:come_out(self)
		self.family:kill(self)
	end)

	-- Our function to convert the list of edges given by luagraph in a list of nodes (including current node).
	Peacefuls:add_method( 'path_to', function(self, gr,orig,dest)
		-- print('PATH',self.__id,orig,dest)
		path = {}
		djk:run(gr,orig)
		if djk:hasPathTo(dest)then
			edges_path = djk:getPathTo(dest)
			path[1] = self.location
			for i = 0,edges_path:size()-1 do
				path[i+2]=Nodes:get(edges_path:get(i):to())
			end
		end
		return path
	end)



	-------------------------------------
	--------  States Functions  ---------
    -------------------------------------

	Peacefuls:add_method('keep_working', function(self)
		if math.random() < 0.01 or self:dist_euc_to(self.location) >= self.speed then
			if self:dist_euc_to(self.next_location) <= self.speed then
				self:update_position()
				self.next_location = one_of(self.location.neighbors)
				self:face(self.next_location)
			end
			self:advance_not_alerted()
		end
	end)

	Peacefuls:add_method('follow_route', function(self)
		if next(self.route) == nil or not self.location:is_in(self.route) or self.location == self.route[#self.route] then
			self.route = {}
		else
			if self.location == self.next_location then
				for i=1,#self.route do
					if self.location == self.route[i] then
						self.next_location = self.route[i+1]
						self:face(self.next_location)
					end
				end
			end
			self:advance()
		end
	end)

	Peacefuls:add_method('avoid_violent', function(self)
		-- print('avoid_violent')
		if self.hidden then return end

		local visib_exits = self:visible_exits()
		if visib_exits.count > 0 then
			local nearest_exit = visib_exits:min_one_of(function(x) return self:dist_euc_to(x) end)
		end
		if self:any_violent_near() then -- It is possible that the violent is dead (killed by other agents)

			local violent = Violents:min_one_of( function(x) self:dist_euc_to(x) end )
			local percived_risk = self.percived_risk < 100 and self.percived_risk or 100
			local distance 		= self:dist_euc_to( violent ) < 100 and self:dist_euc_to( violent ) or 100
			self.speed = self.base_speed + fs.danger( percived_risk, distance )/100
			-- print('Speed:',self.speed)

			if violent.location == self.location then
				self.route = {self.location, one_of(self.location.neighbors)}
			else
				if next(self.route) == nil or not self:secure_route(self.route) then
					local visib_nodes = self.location:get_out_neighs(Nodes, Visibs)
					local bad_nodes   = violent.location:get_out_neighs(Nodes, Visibs)
					local candidates  = visib_nodes:difference(bad_nodes)

					local node 		  = candidates:max_one_of(function(x) return violent:dist_euc_to(x) end)

					self.route = self:path_to(g, self.location.__id, node.__id)
				end
			end
		end
		self:follow_route()
	end)

	Peacefuls:add_method('ask_app', function(self)
		-- print('ask_app')
		if get.app_mode == 0 then -- The app is warning about a danger, but is not giving any path to the agent
			-- self.route = {}
			if self.location.has_lock and not self:any_violents_in_my_room() then
				self.state = 'hidden'
				self:hide()
			else
				self.state = 'running_away'
				self:run_away()
			end
		elseif get.app_mode == 1 then -- The app gives a path to a secure room
			local candidates = Nodes:with(function(x) return x.lock and x:density() < 0.85 end)

			if candidates.count > 0 then
				local destination = min_one_of(candidates, function(x) return self:dist_euc_to(x) end )
				self:path_to(g,self.location.__id)
			else
				self.state = 'running_away'
			end
		elseif get.app_mode == 2 then -- The app gives a path to an exit
			local candidates = Nodes:with(function(x) return x.id - math.floor(x.id) < 0.099 end)

			if candidates.count > 0 then
				local destination = min_one_of(candidates, function(x) return self:dist_euc_to(x) end )
				self:path_to(g,self.location.__id)
			else
				self.state = 'running_away'
			end
		end
	end)

	Peacefuls:add_method('irrational_behaviour', function(self)
		self:stop_hidden()
		if self.route then
			self:follow_route()
		else
			local visib_exits = self.location:get_out_links(Visibs):with(function(x) return x.target.id%1 < 0.099 end)
			if visib_exits.count > 0 then -- The agent has seen an exit (or more than one).
				local exit = one_of(visib_exits).target
				self.route = self:path_to(g,self.location.__id, exit.__id)
				self:follow_route()
			else
				if self.location == self.next_location then
					self.next_location = self.location.neighbors:min_one_of(function(x) return x.attacker_v end)
					self:face(self.next_location)
				end
				self:advance()
			end
		end
	end)

	Peacefuls:add_method('go_to_exit', function(self)
		-- print('go_to_exit')
		if next(self.route) == nil or not (self.route[#self.route].id % 1 <= 0.099) then
			local visible_exits = self.location:get_out_neighs(Nodes,Visibs):with(function(x) return x.id - math.floor(x.id) <= 0.099 end )
			if visible_exits.count > 0 then
				self.route = self:path_to(g,self.location.__id, one_of(visible_exits).__id)
				self:follow_route()
			else
				self:run_away()
			end
		else
			self:follow_route()
		end
	end)

	Peacefuls:add_method('fight', function(self)
		self:stop_hidden()
		if math.random() < get.defense_prob() then
			local target_violent = one_of(Violents:with(function(x) return x.location == self.location end) )
			global_vars.violents_killed = global_vars.violents_killed + 1
			Violents:kill(target_violent)
		end
	end)

	Peacefuls:add_method('follow_leader', function(self)
		-- print('follow_leader')
		if leader_sighted ~= nil then
			if self.route ~= leader_sighted.route then self.route = leader_sighted.route end
			self:follow_route()
		else
			if self.route ~= {} then -- Maybe the leader is dead, but, if she have shared the route with others, this agents will follow this route
				self:follow_route()
			else
				self.state = 'running_away'
				self:run_away()
			end
		end
	end)

	Peacefuls:add_method('hide', function(self)
		if not self.hidden then
			self.hidden = true
			if self.location.has_lock > 0 and not self:any_violent_near() then
				if self.leadership > 0 then self.color = {1, 0.7, 0.7, 1} end
				local lockables_links = self.location:get_links(Transits):with( function(x) return x.lockable > 0 end )

				for _,link in sorted( lockables_links )do
					link.transitable = 0
					link.locked 	 = true
				end
			else
				self.location.hidden_people = self.location.hidden_people + 1
			end
		end
	end)

	Peacefuls:add_method('avoid_crowd', function(self)
		self.route = {}
		self.next_location = self.location.neighbors:min_one_of(function(x) return x:density() end)
		self:face(self.next_location)
		self:advance()
	end)



end


return add_methods
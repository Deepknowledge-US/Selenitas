require 'Engine.utilities.utl_main'
local fs 	= require 'Resources.models.Evacuation.files.fuzzy_sets'
local g 	= graph.create(0,true) -- Initial number of nodes = 0. true means the graph is directed
local djk	= dijkstra.create()

local add_methods = function()



	-------------------------------------
	---------  Check Functions  ---------
	-------------------------------------

	-- True if there is no violents in the route
	Peacefuls:add_method('secure_route', function(self,route)
		for _,node in sorted(route) do
			if node.num_violents > 0 then return false end
		end
		return true
	end)

	-- True if the agent is in an exit
	Peacefuls:add_method('in_exit', function(self)
		return self.location.id%1 <= 0.01
	end)


	-- True if the agent has the app installed and the app is active and it has been triggered
	Peacefuls:add_method('app_pack', function(self)
		return self.app and get.app_info() and global_vars.app_is_triggered
	end)

	-- True if there is a visible agent and some places to hide in the node.
	Peacefuls:add_method('must_I_hide', function(self)
		return self.location.attacker_v > 0 and self.location.hidden_places - self.location.hidden_people > 0
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
		local lockables = self.location.my_links(Transits):with(function(x) return x.lockable > 0 end)
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


	-------------------------------------
	--------  Action Functions  ---------
    -------------------------------------

	Peacefuls:add_method('go_to_exit', function(self)
		print('go_to_exit')
		if next(self.route) == nil or not (self.route[#self.route].id % 1 <= 0.099) then
			local visible_exits = self.location:out_link_neighbors(Nodes,Visibs):with(function(x) return x.id - math.floor(x.id) <= 0.099 end )
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

	Peacefuls:add_method('stop_hidden', function(self)
		if self.hidden then
			self.hidden = false
			if self.in_a_secure_room then
				local lockables_links = self.location:my_links():with( function(x) return x.lockable > 0 end )

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

	Peacefuls:add_method('follow_leader', function(self)
		print('follow_leader')
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
		if not self.hidden_people then
			self.hidden = true
			if self.location.has_lock > 0 and not self:any_violent_near() then
				if self.leadership > 0 then self.color = {1, 0.7, 0.7, 1} end
				local lockables_links = self.location:my_links():with( function(x) return x.lockable > 0 end )

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

	Peacefuls:add_method('visible_exits', function(self)
		return	self.location:my_out_links(Visibs):with(function(x) return x.target.id%1 <= 0.099 end)
	end)


	Peacefuls:add_method( 'advance', function(self)
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


	Peacefuls:add_method('update_running_people', function()
		if self.state ~= 'not_alerted' then
			local loc, next_loc 	= self.location, self.next_location
			loc.running_people 		= loc.running_people + 0.02
			next_loc.running_people = next_loc.running_people + 0.02
			for _,link in sorted(loc:my_in_links(Visibs)) do
				link.source.running_people = link.source.running_people + (loc.running_people * link.value * get.visual_mod)
			end
		end
	end)


	Peacefuls:add_method('casualty_risk', function(self)
		local acc_prob = fs.accident(self.location:density(), self.speed)

		print(self.location.__id, self.location:density(), self.speed, acc_prob)

		if acc_prob > 0.6 and math.random() * 100 < acc_prob then
			if self.app then
				global_vars.app_accident = global_vars.app_accident +1
			else
				global_vars.not_app_accident = global_vars.not_app_accident +1
			end

			self.location.corpses = self.location.corpses + 1
			self.location:come_out(agent)
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


	-- Our function to convert the list of edges given by luagraph in a list of nodes (including current node).
	Peacefuls:add_method( 'path_to', function(self, gr,orig,dest)
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


end


return add_methods
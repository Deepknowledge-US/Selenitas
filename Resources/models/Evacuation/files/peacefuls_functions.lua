require 'Engine.utilities.utl_main'
local fs 	= require 'Resources.models.Evacuation.files.fuzzy_sets'

local wait_time_mean, wait_time_dev	  = 5,1
local running_people_signal_intensity = 0.1

local add_methods = function()



	-------------------------------------
	----------  BDI Functions  ----------
	-------------------------------------

	Peacefuls:add_method('belive', function(self)
		local signals = 0

		-- If the agent has the app and it is active. The agent will be alerted, and if it is not a danger near, the agent will follow app instructions (if any).
		if self:app_pack() then
			signals = 1
		else
			self:update_signals()
			signals = self.attacker_sighted + self.fire_sighted   + self.bomb_sighted
					+ self.attacker_heard   + self.fire_heard     + self.bomb_heard
					+ self.scream_heard     + self.corpse_sighted + self.running_people
			if signals > 1 then signals = 1 end
		end

		-- In our case, any signal will alert the agent. In the decission making, some signals forces the agent to take concrete deccissions (short distance to a violent, for example).
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
			if self:secure_exit() then
				self:stop_hidden()
				self.state = "reaching_exit"
			elseif self:am_I_in_locked_room() then
				self.state = "at_save"
			elseif self.panic_level > 95 then
				self:stop_hidden()
				self.state = "in_panic"
			elseif self.p_timer > 0 then
				self.state = "waiting"
			elseif self:is_path_congested() then
				self:stop_hidden()
				self.state = "avoiding_crowd"
			elseif self:any_violent_near() then
				self.state = "avoiding_violent"
			elseif self:app_pack() then
				self:stop_hidden()
				self.state = "asking_app"
			elseif #self.route > 0 then
				self:stop_hidden()
				self.state = "following_route"
			else
				self:stop_hidden()
				self.state = "running_away"
			end
		end
	end)

	Peacefuls:add_method('intention', function(self)
		local state = self.state
		if state == "avoiding_violent" then
			self:avoid_violent()
			self.color = {0.647,0.176,0.176,1}
		elseif state =="waiting"  then
			self:to_wait()
			self.color = {0.5,0.5,1,1}
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
			self.color = {0.2,0.2,1,1}
		elseif state == "fighting" then
			self:fight()
			self.color = {0,0,0,1}
		elseif state == "asking_app" then
			self:ask_app()
			self.color = {1,1,1,1}
		elseif state == "following_route" then
			self:follow_route()
			self.color = {0.5,0.5,0.5,1}
		elseif state == "at_save" then
			self:to_stay()
			self.color = {1,1,1,1}
		end
	end)



	-------------------------------------
	---------  Check Functions  ---------
	-------------------------------------

	-- True if there is a visible violent
	Peacefuls:add_method('any_violent_near', function(self)
		if self.location.attacker_v > 0 then
			local visib_neighs = self.location:get_in_neighs(Nodes,Visibs)
			self.bad_area = one_of(visib_neighs:with(function(x) return x.num_violents > 0 end))
			return true
		else
			return false
		end
	end)

	-- It returns true if two nodes are in the same room/area
	Peacefuls:add_method('same_area', function(self, node_a, node_b)
		local a = math.floor(node_a.id)
		local b = node_b and math.floor(node_b.id) or math.floor(self.location.id)
		if a > b then
			return a % b == 0
		else
			return b % a == 0
		end
	end)

	Peacefuls:add_method('am_I_visible', function(self)
		return not self.hidden
	end)

	Peacefuls:add_method('am_I_in_lockable_room', function(self)
		local target_id = math.floor(self.location.id)
		local have_lock = Nodes:with(function(x) return math.floor(x.id) == target_id and x.has_lock > 0 end)
		return have_lock.count > 0
	end)

	Peacefuls:add_method('am_I_in_locked_room', function(self)
		return self.location.locked_room
	end)

	Peacefuls:add_method('any_better_location', function(self)
		local bad, loc 		= self.bad_area, self.location
		local better_neighs = self.location.neighbors:with(function(x) return not self:same_area(x,bad) and not x.locked_room end)

		if better_neighs.count > 0 then
			if self:same_area(loc,bad) then
				self.next_location = one_of(better_neighs)
				self:face(self.next_location)
				return true
			else
				neighs_to_hide = better_neighs:with(function(x) return x.hidden_places > x.hidden_people end )
				if neighs_to_hide.count > 0 then
					self.next_location = one_of(neighs_to_hide)
					self:face(self.next_location)
					return true
				end
				far_neighs = better_neighs:with(function(x) return x:dist_euc_to(bad) > self:dist_euc_to(bad) end)
				if far_neighs.count > 0 then
					self.next_location = one_of(far_neighs)
					self:face(self.next_location)
					return true
				end
			end
		end
		return false
	end)


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

	-- True if the agent has a route and there is no violents in the route
	Peacefuls:add_method('secure_route', function(self,route)
		for _,node in sorted(route) do
			if node.num_violents > 0 then return false end
		end
		return next(route) ~= nil
		-- return true
	end)

	-- True if the agent is in an exit
	Peacefuls:add_method('in_exit', function(self)
		return self.location.id%1 <= 0.099
	end)

	-- True if the agent has the app installed and the app is active and it has been triggered
	Peacefuls:add_method('app_pack', function(self)
		return self.app and get.app_info() and global_vars.app_is_triggered > 0
	end)

	-- True if there is a visible agent and some places to hide in the node.
	Peacefuls:add_method('must_I_hide', function(self)
		if self.hidden then
			return self.location.attacker_v > 0 or self.location.num_violents > 0 -- If the agent is already hidden and there is a violent in its node or in its visible nodes, the peaceful remains hidden.
		else
			return self.location.attacker_v > 0 and self.location.hidden_places > self.location.hidden_people
		end
	end)

	-- True if there is some violent in the node and at least 10 peacefuls for each violent
	Peacefuls:add_method('must_I_fight', function(self)
		local num_agents = self.location.my_agents.count
		-- local num_violents = Violents:with(function(x) return x.__alive and x.location == self.location end ).count
		local num_violents = self.location.num_violents
		return num_violents > 0 and num_agents > 10*num_violents
	end)

	-- True if residents are at least 90% of node's capacity
	Peacefuls:add_method('is_path_congested', function(self)
		local loc, next_loc = self.location, self.next_location
		return loc ~= next_loc and next_loc:density() > 0.8
	end)

	Peacefuls:add_method('am_I_in_locked_room', function(self)
		return self.location.locked_room
	end)

	-- True if there is a violent in the node
	Peacefuls:add_method('any_violents_in_my_room', function(self)
		for _, v in sorted(Violents)do
			if v.__alive and math.floor(v.location.id) == math.floor(self.location.id) then
				self.bad_area = v.location
				return true
			end
		end
		return false
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

		-- This will update signals in nodes with a visual of the runner agent
		for _,link in sorted(loc:get_in_links(Visibs)) do
			local signal_intensity = running_people_signal_intensity * link:current_value()
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
			self.location.hidden_people = self.location.hidden_people - 1
		end
	end)

	Peacefuls:add_method('hide', function(self)
		if not self.hidden then
			self.hidden = true
			self.location.hidden_people = self.location.hidden_people + 1
			self.p_timer = gaussian(wait_time_mean,wait_time_dev)
		end
	end)

	Peacefuls:add_method('kill_violent', function(self, violent)
		if violent then
			global_vars.violents_killed = global_vars.violents_killed + 1
			violent.location.num_violents = violent.location.num_violents - 1
			violent.location:come_out(violent)
			Violents:kill_and_purge(violent)
		end
	end)

	Peacefuls:add_method('avoid_violent', function(self)
		if self.hidden then return end
		local loc,n_l		= self.location, self.next_location
		local vis_nodes		= loc:get_out_neighs(Nodes, Visibs)
		vis_nodes:add(loc)
		local bad_nodes		= vis_nodes:with(function(x) return x.num_violents > 0 end) -- Current visible nodes with at least an attacker
		local violent 		= Violents
							:with(function(x) return x.location:is_in(bad_nodes) end) -- Visible attackers
							:min_one_of( function(x) return self:dist_euc_to(x) end ) -- the closest one

		-- It is possible that another agent had killed the violent.
		if violent == nil then return end

		self.bad_area 		= violent.location
		local ba 			= self.bad_area
		local percived_risk = self.percived_risk < 100 and self.percived_risk or 100
		local distance 		= self:dist_euc_to( violent ) < 100 and self:dist_euc_to( violent ) or 100
		self.speed 			= self.base_speed + fs.danger( percived_risk, distance )/100
		self.speed 			= round(self.speed, 2)

		if self:secure_route(self.route) then
			self:stop_hidden()
			self:follow_route()
		elseif self:must_I_hide()	then
			self:hide()
		elseif self:must_I_fight() 	then
			self:stop_hidden()
			self:fight()
		elseif loc.num_violents > 0 then
			self:stop_hidden()
			self.route = {self.location, one_of(self.location.neighbors)}
			self:follow_route()
		elseif n_l.num_violents > 0 then
			self:stop_hidden()
			-- self.bad_area = n_l
			self.next_location = loc
			self:face(self.next_location)
		elseif self:same_area(self.bad_area) then
			self:stop_hidden()
			local candidate = one_of(vis_nodes:with(function(x) return not self:same_area(x,ba) end))
			if candidate then
				self.route = self:path_to(g, loc.__id, candidate.__id)
				self:follow_route()
			else
				self.next_location = loc.neighbors:max_one_of(function(x) x:dist_euc_to(ba) end)
				self:face(self.next_location)
				self.route = {self.location, self.next_location}
				self:follow_route()
			end
		else
			self:stop_hidden()
			local candidates = loc.neighbors:with(function(x) return self:same_area(x) end)
			if candidates.count > 0 then
				self.next_location = candidates:max_one_of( function(x) x:dist_euc_to(ba) end )
				self:face(self.next_location)
				self.route = {self.location, self.location}
				self:follow_route()
			else
				self.p_timer = gaussian(wait_time_mean,wait_time_dev)
			end
		end

	end)

	Peacefuls:add_method('to_wait', function(self)

		if self:am_I_in_lockable_room() then
			self:wait_to_lock()
		elseif self.location.hidden_places > self.location.hidden_people then
			self:hide()
			self.p_timer = self.p_timer - 1
		elseif self:am_I_visible() and self:any_violent_near() then
			self:stop_hidden()
			self.p_timer = 0
			self:avoid_violent()

		elseif not self.hidden and self.bad_area and self:any_better_location() then
			self:advance()
		else
			self.p_timer = self.p_timer - 1
			if self.p_timer <= 0 then self:stop_hidden() end
		end
	end)

	Peacefuls:add_method('ask_app', function(self)
		self.color = {0,1,0,1}
		if next(self.route) ~= nil and self:secure_route(self.route) and not self.route[#self.route].locked_room then
			self:follow_route()
		else
			if get.app_mode() == 0 then -- The app is warning about a danger, but is not giving any path to the agent
				if self.location.has_lock > 0 and not self:any_violents_in_my_room() then
					-- TODO -> wait_to_lock
				else
					self.state = 'running_away'
				end
			elseif get.app_mode() == 1 then -- The app gives a path to a secure room
				local candidates = Nodes:with(function(x) return x.has_lock > 0 and not x.locked_room and x:density() < 0.75 end)

				if candidates.count > 0 then
					local destination = one_of(candidates)
					self.route = self:path_to(g,self.location.__id, destination.__id)
				else
					self.state = 'running_away'
				end
			elseif get.app_mode() == 2 then -- The app gives a path to an exit
				local candidates = Nodes:with(function(x) return x.id - math.floor(x.id) < 0.099 end)

				if candidates.count > 0 then
					local destination = one_of(candidates)
					self.route = self:path_to(g,self.location.__id, destination.__id)
				else
					self.state = 'running_away'
				end
			end
		end
	end)

	Peacefuls:add_method('to_stay', function(self)
		if self.app then
			global_vars.app_secure_room = global_vars.app_secure_room + 1
		else
			global_vars.not_app_secure_room = global_vars.not_app_secure_room + 1
		end
		self:move_to(self.location)
	end)

	Peacefuls:add_method('to_lock', function(self)
		local room_id = math.floor(self.location.id)
		local room_nodes = Nodes:with(function(x) return math.floor(x.id) == room_id end)
		local nodes_with_lock = room_nodes:with(function(x) return x.has_lock > 0 end)

		if nodes_with_lock.count > 0 then
			-- All nodes of the room will be in 'locked' state
			for _,node in sorted(room_nodes) do
				node.locked_room = true
			end
			-- Stop the transitability to/from the room
			for _,node in sorted(nodes_with_lock) do
				local lockable_edges = self.location:get_links(Transits):with(function(x) return x.lockable > 0 end)
				for _,link in sorted(lockable_edges) do
					link.mod = 0 -- This will do the edge untransitable
					link.locked = true
				end
			end
		end
	end)

	Peacefuls:add_method('wait_to_lock', function(self)
		self:stop_hidden()
		local loc = self.location
		if loc.num_violents > 0 then -- An attacker has reached the node of the agent
			self.state = 'avoiding_violent'
			self.bad_area = loc
			self:avoid_violent()
		elseif loc.attacker_v > 0 or self.p_timer < 0 or loc:density() > 0.85 then -- There is at least one attacker near or the room is full, so the agent will lock the room.
			self.location.color = {0.8,0.8,1,1}
			self:to_lock()
		elseif loc ~= self.next_location then
			self:face(self.next_location)
			self:advance()
		elseif loc:density() > 0.5 and math.random() < 0.5 then -- The agents will fill other places (nodes) of the room.
			local candidates = loc:get_out_neighs(Nodes, Transits):with(function(x) return math.floor(x.id) == math.floor(loc.id) end)
			if candidates.count > 0 then
				self.next_location = candidates:one_of()
				self:face(self.next_location)
				self:advance()
			end
		else
			if self:dist_euc_to(self.location) > 0.5 then
				self:face(self.location)
				self:fd(0.5)
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
		local dist_loc  = self:dist_euc_to(self.location)
		local dist_next = self:dist_euc_to(self.next_location)

		if dist_next <= dist_loc * 0.8 then self:update_position() end

		if self.location ~= self.next_location then
			-- out_neighs is a table "id_of_out_neigh -> list of links". So, we have a direct access to links beetween location and next_location
			local links_with_next_loc = self.location.out_neighs[self.next_location.__id]
			-- As we have created transitable links at last, the last position of the list will contain the link we are looking for.
			local current_link = links_with_next_loc[#links_with_next_loc]

			if current_link.flow_counter > 0 then
				if current_link.flow_counter > 0 and self.next_location:density() < 0.8 then
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

		-- Agents have a low probability of suffering a fatal accident, but may suffer an accident that causes them to move more slowly
		local rand = math.random()
		local letal_acc, non_letal_acc = rand*10000, rand*1000

		if acc_prob > 60 and letal_acc < acc_prob then
			if letal_acc < acc_prob then

				if self.app then
					global_vars.app_accident = global_vars.app_accident +1
				else
					global_vars.not_app_accident = global_vars.not_app_accident +1
				end
				-- Update corpses signals
				self.location:new_corpse()
				self.location:come_out(self)
				self.family:kill(self)

			elseif non_letal_acc < acc_prob then
				self.base_speed = self.base_speed * 0.8
			end
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

		if self.location == self.next_location then
			if self.location == self.route[#self.route] then
				-- The agent has reach its destiny.
				self.route   = {}
				self.p_timer = gaussian(wait_time_mean,wait_time_dev)
			elseif next(self.route)~=nil and not self.location:is_in(self.route) or not self.next_location:is_in(self.route) then
				-- A congestion in the path or the vision of an attacker will force the agent to temporaly stop following the route, but it is near of that route and it could start following again.
				self.route = self:path_to(g,self.location.__id, self.route[#self.route].__id)
			else
				for i=1,#self.route do
					if self.location == self.route[i] then
						self.next_location = self.route[i+1]
						self:face(self.next_location)
						break
					end
				end
			end
		else
			self:advance()
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
					self.next_location = self.location.neighbors:min_one_of(function(x) return x.attacker_v and not x.locked_room end)
					self:face(self.next_location)
				end
				self:advance()
			end
		end
	end)

	Peacefuls:add_method('go_to_exit', function(self)
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
			local target_violent = one_of(Violents:with(function(x) return x.__alive and x.location == self.location end) )
			self:kill_violent(target_violent)
		end
	end)

	Peacefuls:add_method('follow_leader', function(self)
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

	Peacefuls:add_method('avoid_crowd', function(self)
		self.route = {}
		self.next_location = self.location.neighbors
							:with(function(x) return not x.locked_room end) -- Look around for not locked areas
							:min_one_of(function(x) return x:density() end) -- Choose the less populated one
		self:face(self.next_location)
		self:advance()
	end)

	Peacefuls:add_method('run_away', function(self)
		self:stop_hidden()
		if self.leadership > 0 then
			if next(self.route) == nil or not self.location:is_in(self.route) then
				self.route = self:path_to(g,self.location.__id, one_of(Nodes:with(function(x) return x.id%1 < 0.099 end)).__id )
			end
			self.state = 'following_route'
			self:follow_route()
		else
			if self.location == self.next_location then
				self:search_new_node()
			end
			self:advance()
		end
	end)

	Peacefuls:add_method('search_new_node',function(self)
		local not_visited = self.location.neighbors:with(function(x) return not x:is_in(self.last_locations) and not x.locked_room end)

		if not_visited.count > 0 then
			self.next_location = one_of(not_visited)
			self:face(self.next_location)
		else
			for i = #self.last_locations, 1, -1 do
				if self.last_locations[i]:is_in(self.location.neighbors) and not self.last_locations[i].locked_room then
					self.next_location = self.last_locations[i]
					self:face(self.next_location)
					break
				end
			end
		end
	end)


end


return add_methods
require 'Engine.utilities.utl_main'

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

	Peacefuls:add_method('secure_exit', function(self)
		local visib_exits = self.location:my_out_links(Visibs):with(function(x) return x.target.id%1 < 0.1 end)
		if visib_exits.count > 0 then
			--TODO ruta hacia la salida
		else
			return {}
		end

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
    




end


return add_methods
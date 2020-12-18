
local add_methods = function()

    Violents:add_method( 'belive', function(self)
        self.police_sighted = self.police_sighted + self.location.police
    end)

    Violents:add_method( 'desire', function(self)
        if self.police_sighted > 0 then
            self.state = 'avoiding_police'
        elseif #self.route > 0 then
            self.state = 'following_route'
        else
            self.state = 'aggressive_behaviour'
        end
    end)

    Violents:add_method( 'intention', function(self)
        local state = self.state
        if state == "avoiding_police" then
            self:avoid_police()
        elseif state == 'following_route' then
            self:follow_route()
        elseif state == "aggressive_behaviour" then
            self:be_aggressive()
        end
    end)

    Violents:add_method( 'visible_peacefuls', function(self)
        local visibles = self.location:link_neighbors(Nodes,Visibs)

        local visible_ags = Collection()
        for _,node in sorted(visibles)do
            for _,ag in sorted(node.my_agents)do
                if ag.__alive and ag.family == Peacefuls and not ag.hidden then
                    visible_ags:add(ag)
                end
            end
        end
        return visible_ags
    end)

    Violents:add_method( 'be_aggressive', function(self)
        self.label = 'BA'

        local v_p = self:visible_peacefuls()

        if Interface:get_value('violents', 'shooting?') then
            if v_p.count > 0 then
                local choosen = one_of(v_p)
                self:shoot(choosen)
            else
                self:advance()
            end
        else
            local choosen = one_of(self.location.my_agents)

            if choosen then
                self:melee(choosen)
            else
                self:advance()
            end
        end

    end)

    Violents:add_method( 'kill', function(self, agent)
        if agent.app then
            global_vars.app_killed = global_vars.app_killed + 1
        else
            global_vars.not_app_killed = global_vars.not_app_killed + 1
        end
        agent.location.corpses = agent.location.corpses + 1
        agent.location:come_out(agent)
        agent.family:kill(agent)
    end)

    Violents:add_method( 'shoot', function(self, agent)
        self.detected   = 1
        self.color      = {1,0,0,1}
        local loc       = self.location
        loc.habitable   = 0
        loc.attacker_s  = loc.attacker_s + Interface:get_value('violents','shoot noise')
        for _,out_sound_link in sorted(loc:my_out_links(Sounds) )do
            local neighbor = out_sound_link.target
            neighbor.attacker_sound = get.shoot_noise() * out_sound_link.value
        end
        if math.random() < Interface:get_value('violents','success rate') then
            self:kill(agent)
        end
    end)

    Violents:add_method( 'melee', function(self,agent)
        self.detected   = 1
        self.color      = {1,0,0,1}
        self.location.habitable   = 0

        if math.random() < Interface:get_value('violents','success rate') then
            self:kill(agent)
        end
    end)

    Violents:add_method( 'update_position', function(self, old_node, new_node)
        old_node.attacker_v  = old_node.attacker_v - self.efectivity

        self.location.num_violents = self.location.num_violents - 1

        for id, list_of_links in pairs(old_node.out_neighs) do
            for _, link in pairs(list_of_links)do
				if link.family == Visibs then
					local node, dist = Nodes:get(id), 30
					node.nearest_danger = dist
                    node.attacker_v = node.attacker_v - self.efectivity * link.value
                    if node.attacker_v < 0 then node.attacker_v = 0 end
                end
            end
        end

        old_node.num_violents = old_node.num_violents - 1
        self.location = new_node
        new_node.num_violents = new_node.num_violents + 1

        if not self.location:is_in(self.last_locations) then
            local ll = self.last_locations -- The Violent will remember the last 8 visited nodes
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

        for id, list_of_links in pairs(new_node.out_neighs) do
            for _, link in pairs(list_of_links)do
				if link.family == Visibs then
					local node, dist = Nodes:get(id), self:dist_euc_to(Nodes:get(id))
					node.nearest_danger = dist < node.nearest_danger and dist or node.nearest_danger
                    node.attacker_v = node.attacker_v + self.efectivity * link.value
                    if node.attacker_v > 1 then node.attacker_v = 1 end
                end
            end
        end

        new_node.num_violents = new_node.num_violents + 1

    end)

    Violents:add_method( 'advance', function(self)
        local dist_next = self:dist_euc_to(self.next_location)
        local speed     = self.speed < dist_next and self.speed or dist_next

        if dist_next <= speed then
            if self.state == 'following_route' then
                self:fd(speed)
                self:update_position(self.location, self.next_location)
            else
                self:fd(speed)
                self:update_position(self.location, self.next_location)

                local not_recent_neighs = self.next_location.neighbors:with( function(x) return not x:is_in(self.last_locations) end )
                local choosen = not_recent_neighs.count > 0 and one_of(not_recent_neighs) or one_of(self.next_location.neighbors)

                self.next_location = choosen
                self:face(self.next_location)
            end
        else
            -- out_neighs is a table "id_of_out_neigh -> list of links". So, we have a direct access to links beetween location and next_location
            local links_with_next_loc = self.location.out_neighs[self.next_location.__id]
            -- As we have created transitable links at last, the last position of the list will contain the link we are looking for.
            local current_link = links_with_next_loc[#links_with_next_loc]

            if current_link.flow_counter > 0 then
                current_link.flow_counter = current_link.flow_counter - 1
                self:fd(speed)
            end
        end
    end)

    Violents:add_method( 'follow_route', function(self)
        local route = self.route
        if route[#route] == self.location or not self.location:is_in(route) then
            self.route = {}
            self.state = 'be_aggressive'
        else
            if self.location == self.next_location then
                local index = list_index_of(route, self.location)
                self.next_location = route[index+1]
                self:face(self.next_location)
            end
            self:advance()
        end
    end)

    Violents:add_method( 'find_next_location', function(self)
        local destinations = self.location.neighbors
        local not_visited  = destinations:with( function(x) return not x:is_in(self.last_locations) end )
        local with_people  = destinations:with( function(x) return x.my_agents.count > 0 end )
        local ll           = self.last_locations
        if with_people.count > 0 then
            self.next_location = one_of(with_people)
        elseif not_visited.count > 0 then
            self.next_location = one_of(not_visited)
        else
            for i=#last_locations, 1 do
                if last_locations[i]:is_in(destinations) then
                    self.next_location = last_locations[i]
                end
            end
        end
    end)

    --[[ NetLogo
        to find-target
            set label "ft"
            let loc-aux location

            ; The attacker will search for the target agent first
            ifelse target-agent >= 0 and person t-agent != nobody [
                ifelse loc-aux = [location] of person t-agent [
                ifelse shooting? [shoot (list location) ][attack]
                set route []
                ][
                if empty? route [ set route (path_to ([location] of person t-agent)) ]
                follow-route2
                ]
            ][
                if target-node >= 0[
                ifelse [who] of location = target-node [
                    ifelse shooting? [shoot [visibles] of location][attack]
                    if [residents] of location = 1 [set target-node -1]
                ][
                    if empty? route [ set route ( path_to node target-node ) ]
                    follow-route2
                ]
                ]
            ]
        end
    ]]
    Violents:add_method( 'find_target', function(self)
        -- TODO
        -- print('FIND TARGET')
    end)

    Violents:add_method( 'avoid_police', function(self)
        --TODO
        self.label = 'AP'
    end)

end

return add_methods

local scream_intensity = Interface:get_value('peacefuls', 'scream intensity')
local add_methods = function()



	-------------------------------------
	----------  BDI Functions  ----------
    -------------------------------------

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



	-------------------------------------
	--------  Action Functions  ---------
	-------------------------------------

    Violents:add_method( 'visible_peacefuls', function(self)
        local visibles = self.location:get_out_neighs(Nodes,Visibs):with(function(x) return not x.locked_room end)
        visibles:add(self.location)

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

        if Interface:get_value('violents', 'shooting?') then
            local v_p = self:visible_peacefuls()
            if math.random() < get.attack_prob() and v_p.count > 0 then
                local choosen = one_of(v_p)
                self:shoot(choosen)
            else
                self:advance()
            end
        else
            local choosen = one_of(self.location.my_agents:with(
                    function(x) return x.__alive and x.family == Peacefuls and not x.hidden end
                )
            )

            if math.random() < get.attack_prob() and choosen then
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
        if agent.leadership > 0 then
            agent.location.leaders = agent.location.leaders - 1
        end
        agent.location:new_corpse()
        agent.location:come_out(agent)
        agent.family:kill(agent)
    end)

    Violents:add_method( 'shoot', function(self, agent)
        if not self.detected then
            self.detected   = true
            self.location.num_violents = self.location.num_violents + 1
            self.location.attacker_v   = self.location.attacker_v + self.efectivity
            for _,link in sorted(self.location:get_in_links(Visibs)) do
                link.source.attacker_v = link.source.attacker_v + link.value*self.efectivity
            end
        end
        local loc       = self.location
        loc.habitable   = 0
        loc.attacker_s  = loc.attacker_s + Interface:get_value('violents','shoot noise')
        for _,out_sound_link in sorted(loc:get_out_links(Sounds) )do
            local neighbor = out_sound_link.target
            neighbor.attacker_sound = get.shoot_noise() * out_sound_link.value
        end

        -- The agent will scream if is attacked.
        agent.location.scream = agent.location.scream + scream_intensity
        for _,link in sorted(agent.location:get_out_links(Sounds)) do
            local neigh              = link.target
            local sound_transmission = link.value * link.mod
            neigh.scream = neigh.scream + (sound_transmission * scream_intensity)
        end

        if math.random() < Interface:get_value('violents','success rate') then
            self:kill(agent)
        end
    end)

    Violents:add_method( 'melee', function(self,agent)
        if not self.detected then
            self.detected   = true
            self.location.num_violents = self.location.num_violents + 1
            self.location.attacker_v   = self.location.attacker_v + self.efectivity
            for _,link in sorted(self.location:get_in_links(Visibs)) do
                link.source.attacker_v = link.source.attacker_v + link.value*self.efectivity
            end
        end
        self.detected   = true
        self.color      = {1,0,0,1}
        self.location.habitable   = 0

        -- The agent will scream if is attacked.
        agent.location.scream = agent.location.scream + scream_intensity
        for _,link in sorted(agent.location:get_out_links(Sounds)) do
            local neigh              = link.target
            local sound_transmission = link.value * link.mod
            neigh.scream = neigh.scream + (sound_transmission * scream_intensity)
        end
        if math.random() < Interface:get_value('violents','success rate') then
            self:kill(agent)
        end
    end)

    Violents:add_method( 'update_position', function(self, old_node, new_node)
        self.location = new_node
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

        if self.detected then
            old_node.attacker_v  = old_node.attacker_v - self.efectivity
            old_node.num_violents = old_node.num_violents - 1
            new_node.num_violents = new_node.num_violents + 1

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
        end

    end)

    Violents:add_method( 'advance', function(self)
        if self.next_location.locked_room then
            self:find_next_location()
        end
        local dist_loc  = self:dist_euc_to(self.location)
        local dist_next = self:dist_euc_to(self.next_location)
        local speed     = self.speed < dist_next and self.speed or dist_next

        if dist_next <= 0.8*dist_loc then
            if self.state == 'following_route' then
                self:fd(speed)
                self:update_position(self.location, self.next_location)
            else
                self:fd(speed)
                self:update_position(self.location, self.next_location)
                self:find_next_location()
            end
        else
            -- out_neighs is a table "id_of_out_neigh -> list of links". So, we have a direct access to links beetween location and next_location
            local links_with_next_loc = self.location.out_neighs[self.next_location.__id]
            if links_with_next_loc then
                -- As we have created transitable links at last, the last position of the list will contain the link we are looking for.
                local current_link = links_with_next_loc[#links_with_next_loc]

                if current_link.flow_counter > 0 then
                    current_link.flow_counter = current_link.flow_counter - 1
                    self:fd(speed)
                end
            end
        end
    end)

    Violents:add_method( 'follow_route', function(self)
        local route = self.route
        if route[#route] == self.location
        or self.next_location.locked_room
        or not self.location:is_in(route) then
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
        local destinations = self.location.neighbors:with(function(x) return not x.locked_room end)
        local not_visited  = destinations:with( function(x) return not x:is_in(self.last_locations) end )
        local with_people  = destinations:with( function(x) return x.my_agents.count - x.hidden_people > 0 end )
        local ll           = self.last_locations
        if with_people.count > 0 then
            self.next_location = one_of(with_people)
        elseif not_visited.count > 0 then
            self.next_location = one_of(not_visited)
        else
            for i=#self.last_locations, 1, -1 do
                if self.last_locations[i]:is_in(destinations) then
                    self.next_location = self.last_locations[i]
                    break
                end
            end
        end
        self:face(self.next_location)
    end)

    Violents:add_method( 'find_target', function(self)
        -- TODO
        self.label = 'FT'
    end)

    Violents:add_method( 'avoid_police', function(self)
        --TODO
        self.label = 'AP'
    end)

end

return add_methods

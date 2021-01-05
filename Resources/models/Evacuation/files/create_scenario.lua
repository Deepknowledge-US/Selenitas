local cs = {}

-- This function will create the scenario when called
cs.create_scenario = function(id_map)

    local nodes_file = 'Resources/models/Evacuation/csv/nodesP.csv'
    local edges_file = 'Resources/models/Evacuation/csv/edgesP.csv'
    local nodes = lines_from(nodes_file)
    local edges = lines_from(edges_file)

    -- Populate Nodes family
    -- First line of csv files contains the names of the attributes
    for i=2, #nodes do
        local v = split( nodes[i], ',' )
        local new_node = Nodes:new({
            shape           = 'circle',
            fill            = true,
            color           = {0,0,1,1},
            id              = tonumber(v[1]),
            size            = tonumber(v[4]),
            radius          = tonumber(v[4]),
            capacity        = tonumber(v[5]),
            hidden_places   = tonumber(v[6]),
            info            = tonumber(v[7]),
            has_lock        = tonumber(v[8]),
            pos             = { tonumber(v[2])*2,tonumber(v[3])*2 },
            fire_v          = 0,
            fire_s          = 0,
            attacker_v      = 0,
            attacker_s      = 0,
            bomb_v          = 0,
            bomb_s          = 0,
            num_violents    = 0,
            scream          = 0,
            running_people  = 0,
            corpses         = 0,
            leaders         = 0,
            police          = 0,
            hidden_people   = 0,
            locked_room     = false,
            nearest_danger  = 50
        })
    end

    -- Create a map of "model ids -> internal ids" to quickly acces elements
    for _,node in sorted(Nodes)do
        id_map[node.id] = node.__id
    end

    -- This method returns the target agent by "model id", there is no search, is a direct acces.
    Nodes.find_by_id = function(self, id)
        return self:get(id_map[id])
    end

    Nodes:add_method('density',function(self)
        local density = self.my_agents.count / self.capacity
        return density < 1 and density or 1
    end)

    Nodes:add_method('visible_neighs',function(self)
        return self:get_out_neighs(Nodes,Visibs)
    end)

    Nodes:add_method('all_my_signals',function(self)
        return  self.attacker_s     + self.attacker_v   + self.fire_s
                + self.fire_v       + self.bomb_s		+ self.bomb_v
                + self.scream		+ self.corpses      + self.running_people
    end)

    Nodes:add_method('new_corpse', function(self)
        -- When a agent dies, the corpse will lie in the node and it will be sighted from neighbors nodes.
        self.corpses = self.corpses + 1
        for _,link in sorted(self:get_in_links(Visibs))do
            local neigh = link.source
            neigh.corpses = neigh.corpses + link:current_value()
        end
    end)

    Sounds:add_method('current_value', function(self)
        return self.value * self.mod * Interface:get_value('World', 'sound mod')
    end)

    Visibs:add_method('current_value', function(self)
        return self.value * self.mod * Interface:get_value('World', 'sound mod')
    end)

    Transits:add_method('current_value', function(self)
        return self.transit * self.mod
    end)

    -- Three relational families are created and populated, one for every possible kind of link (visibility, sound or transitability), this will simplify accesses to this agents.
    for i=2, #edges do
        local v = split( edges[i], ',' )

        local n1,n2,dis,visi,soun,trans,lockab,flo =
            Nodes:find_by_id(tonumber(v[1])),
            Nodes:find_by_id(tonumber(v[2])),
            tonumber(v[3]),
            tonumber(v[4]),
            tonumber(v[5]),
            tonumber(v[6]),
            tonumber(v[7]),
            tonumber(v[8])

        if soun > 0 then
            Sounds:new({
                source = n1,
                target = n2,
                value  = soun,
                mod    = 1,
                visible=false
            })
        end
        if visi > 0 then
            Visibs:new({
                source = n1,
                target = n2,
                value  = visi,
                mod    = 1,
                visible=false
            })
        end
        if trans > 0 then
            n1.neighbors:add(n2) -- Reacheables neighbors
            Transits:new({
                source      = n1,
                target      = n2,
                dist        = dis,
                transit     = trans,
                mod         = 1,
                lockable    = lockab,
                locked      = false,
                flow        = flo,
                flow_counter= flo
            })
        end
    end

end

return cs
require 'Engine.utilities.utl_main'

local nodes_file = 'Resources/models/Evacuation/csv/nodesP.csv'
local edges_file = 'Resources/models/Evacuation/csv/edgesP.csv'

local nodes = lines_from(nodes_file)
local edges = lines_from(edges_file)

-- -- First line of csv files contains the names of the attributes
-- local header = split( nodes[1] , ',' )
-- local header_edges = split( edges[1] , ',' )


-- Populate Nodes family
for i=2, #nodes do
    local v = split( nodes[i], ',' )
    Nodes:new({
        shape           = 'circle',
        fill            = true,
        color           = {0,0,1,1},
        id              = tonumber(v[1]),
        size            = tonumber(v[4]),
        capacity        = tonumber(v[5]),
        hidden_places   = tonumber(v[6]),
        info            = tonumber(v[7]),
        has_lock        = tonumber(v[8]),
        pos             = { tonumber(v[2]),tonumber(v[3]) }
    })
end

-- Create a map of "model ids -> internal ids" to quickly acces elements
local id_map = {}
for _,node in sorted(Nodes)do
    id_map[node.id] = node.__id
end

-- This method returns the target agent by "model id", there is no search, is a direct acces.
Nodes.find_by_id = function(self, id)
    return self:get(id_map[id])
end

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
            value  = sound,
            mod    = 1,
            visible=false
        })
    end
    if visi > 0 then
        Visibs:new({
            source = n1,
            target = n2,
            value  = visib,
            mod    = 1,
            visible=false
        })
    end
    if trans > 0 then
        Transits:new({
            source      = n1,
            target      = n2,
            dist        = dis,
            transit     = trans,
            lockable    = lockab,
            flow        = flo
        })
    end
end
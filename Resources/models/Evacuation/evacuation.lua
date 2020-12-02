require 'Engine.utilities.utl_main'


-- require 'Resources.models.Evacuation.files.create_scenario'

Interface:create_window('peacefuls',{height=350})
Interface:create_window('violents', {height=250})
Interface:create_window('App',      {height=250})
Interface:create_window('World',    {height=100})

Interface:create_boolean('App', 'app info?', true)
Interface:create_slider( 'App', 'app mode', 0, 2, 1, 2)
Interface:create_boolean('App', 'crowd running?', true)
Interface:create_slider( 'App', 'what is a crowd?', 0, 20, 1, 20)
Interface:create_boolean('App', 'first blood?', true)

local function app_info() return Interface:get_value('app', 'app info?') end
local function app_mode() return Interface:get_value('App', 'app mode') end
local function crowd_running() return Interface:get_value('App', 'crowd running?') end
local function what_is_a_crowd() return Interface:get_value( 'App', 'what is a crowd?') end
local function first_blood() return Interface:get_value('App', 'first blood?') end


Interface:create_slider('World','visib mod', 0.0, 1.0, 0.01, 1.0)
Interface:create_slider('World','sound mod', 0.0, 1.0, 0.01, 1.0)


Interface:create_slider('peacefuls','num peacefuls', 0, 5000, 1, 20)
Interface:create_slider('peacefuls','leaders percentage',  0.0, 1.0, 0.01, 0.25)
Interface:create_slider('peacefuls','app percentage', 0.0, 1.0, 0.01, 0.5)
Interface:create_slider('peacefuls','defense probability', 0.0, 1.0, 0.01, 0.1)
Interface:create_slider('peacefuls','not alerted speed', 0.0, 1.0, 0.01, 0.5)
Interface:create_slider('peacefuls','mean speed', 0.0, 2.0, 0.1, 2.0)
Interface:create_slider('peacefuls','max speed deviation', 0.0, 1.0, 0.01, 0.15)


local peace_lp = function() return Interface:get_value('peacefuls','leaders percentage') end

Interface:create_slider('violents','num violents', 0, 10, 1, 1)
Interface:create_slider('violents','shoot noise', 0.0, 1.0, 0.01, 0.5)
Interface:create_slider('violents','attack prob', 0.0, 1.0, 0.01, 0.8)
Interface:create_slider('violents','succes rate', 0.0, 1.0, 0.01, 0.5)
Interface:create_slider('violents','attacker speed', 0.0, 1.0, 0.01, 0.5)


-- print(one_of(Nodes))

local id_map = {}

SETUP = function()

    -- Reset the simulation
    Simulation:reset()

    declare_FamilyCell('Nodes')
    declare_FamilyRel('Visibs')
    declare_FamilyRel('Transits')
    declare_FamilyRel('Sounds')
    declare_FamilyMobile('Violents')
    declare_FamilyMobile('Peacefuls')
    Nodes.z_order, Peacefuls.z_order, Violents.z_order = 3,4,5

    -- require 'Resources.models.Evacuation.files.create_scenario'

    local nodes_file = 'Resources/models/Evacuation/csv/nodesP.csv'
    local edges_file = 'Resources/models/Evacuation/csv/edgesP.csv'
    local nodes = lines_from(nodes_file)
    local edges = lines_from(edges_file)

    -- Populate Nodes family
    -- First line of csv files contains the names of the attributes
    for i=2, #nodes do
        local v = split( nodes[i], ',' )
        Nodes:new({
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
            pos             = { tonumber(v[2])*2,tonumber(v[3])*2 }
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


    -- print(Interface:get_value('peacefuls', 'num peacefuls'))
    -- print(Interface:get_value('violents', 'num violents'))


    for i=1,Interface:get_value('peacefuls', 'num peacefuls') do

        local lead = math.random() < peace_lp()
        Peacefuls:new({
            pos = copy(one_of(Nodes).pos ),
            shape = 'person',
            color = lead and {0,1,0,1} or {1,1,1,1}
        }):lt(math.pi/2)
    end
end


STEP = function()

end

-- pd(header_edges)
-- print(Nodes.count)













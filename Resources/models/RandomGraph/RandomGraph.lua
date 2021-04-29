--[[
    An example of growing and cloning of agents.

    It uses customized methods for families and several standard methods
    (die, clone) and agent properties (__alive)
]]

-----------------
-- Interface 
-----------------
Interface:create_slider('N_nodes', 0, 100, 1, 22)
Interface:create_slider('Max_Links', 0, 10000, 1, 15)

panels_channel:push(Interface.windows)

---------------------
-- Auxiliar functions 
---------------------

local function layout_circle(collection, r)
    local step = 2*math.pi / collection.count
    local angle = 0

    for _,ag in ordered(collection) do
        ag:lt(angle)
        ag:fd(r)
        angle = angle + step
    end

end

-----------------
-- Setup Function
-----------------

SETUP = function()

    -- Reset Simulation
    Simulation:reset()

    -- Family for Nodes of the graph
    declare_FamilyMobile('Nodes')
-- <<<<<<< HEAD:Resources/examples/RandomGraph.lua
--     for i=1,Interface.N_nodes do
-- =======
    for i=1,Interface:get_value("N_nodes") do
-- >>>>>>> dev:Resources/examples/Network_example.lua
        Nodes:new({
            ['pos']     = {0,0}
            ,['scale']   = 1.5
            ,['shape']   = 'circle'
            ,['color']   = {0,1,0,0.5}
        })
    end

    -- Distribute them in a circle
    layout_circle(Nodes, 20)

    -- A new family to store the links of the graph
    declare_FamilyRel('Links')

end

-----------------
-- Step Function
-----------------

STEP = function()

    -- In every step, we choose 2 nodes and link them
    local node_1 = one_of(Nodes)
    local node_2 = one_of(Nodes:others(node_1))

    Links:new({
        ['source'] = node_1,
        ['target'] = node_2,
        ['color'] = {0.75, 0, 0, .5},
        ['visible'] = true
    })

-- <<<<<<< HEAD:Resources/examples/RandomGraph.lua
--     -- If the number of current links is over the maximum, 
--     -- we remove the leftovers
--     while Links.count > Interface.Max_Links do
-- =======
    while Links.count > Interface:get_value("Max_Links") do
-- >>>>>>> dev:Resources/examples/Network_example.lua
        Links:kill_and_purge(one_of(Links))
    end

end

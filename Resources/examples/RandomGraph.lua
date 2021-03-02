--[[
    An example of growing and cloning of agents.

    It uses customized methods for families and several standard methods
    (die, clone) and agent properties (__alive)
]]

-----------------
-- Interface 
-----------------
Interface:create_slider('N_nodes', 0, 100, 1, 30)
Interface:create_slider('Max_Links', 0, 10000, 1, 150)

---------------------
-- Auxiliar functions 
---------------------

local function layout_circle(collection, radius)
    local step = 2*math.pi / collection.count
    local angle = 0

    for _,ag in ordered(collection) do
        ag:lt(angle)
        ag:fd(radius)
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
    
    for i=1,Interface:get_value("N_nodes") do
        Nodes:new({
            shape   = 'circle',
            color   = color('green')
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
        source  = node_1,
        target  = node_2,
        color   = color('blue',0.5),
    })

    while Links.count > Interface:get_value("Max_Links") do
        Links:kill_and_purge(one_of(Links))
    end

end

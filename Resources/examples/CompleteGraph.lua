--[[
    A complete graph
]]--

-----------------
-- Interface
-----------------
Interface:create_slider('N_Nodes', 0, 100, 1, 20)
Interface:create_slider('Radius', 0, 100, 1, 15)

----------------------
-- Auxiliary Functions
----------------------

-- Distribute the agents of collection in a circle
-- centered at the origin and radius r
local function layout_circle(collection, r)

    -- Compute angle-step between nodes
    local step = 2*math.pi / collection.count
    local angle = 0

    -- Iterate (ordered) the collection to distribute the nodes
    for _,ag in ordered(collection) do
        ag:rt(angle)
        ag:fd(r)
        angle = angle + step
    end

end

-----------------
-- Setup Function
-----------------

SETUP = function()

    -- Reset the simulation
    Simulation:reset()

    -- Family of Nodes of the graph
    declare_FamilyMobile('Nodes')

-- <<<<<<< HEAD:Resources/examples/CompleteGraph.lua
--     -- Creation of the Nodes
--     for i=1,Interface.N_Nodes do
-- =======
    for i=1,Interface:get_value('N_Nodes') do
-- >>>>>>> dev:Resources/examples/Fully_Connected.lua
        Nodes:new({
            ['pos']     = {0,0},
            ['color']   = {0,0,1,1},
            ['heading'] = 0
        })
    end

-- <<<<<<< HEAD:Resources/examples/CompleteGraph.lua
--     -- Layout the Nodes in a circle
--     layout_circle(Nodes, Interface.Radius )
-- =======
    layout_circle(Nodes, Interface:get_value("Radius"))
-- >>>>>>> dev:Resources/examples/Fully_Connected.lua

    -- A new Family to store the links
    declare_FamilyRel('Links')
    -- Each agent will create a link with the other agents.
    for _, ag1 in ordered(Nodes) do
        for _, ag2 in ordered(Nodes:others(ag1)) do
            -- Create new link connecting ag1 with ag2
            Links:new({
                ['source'] = ag1,
                ['target'] = ag2,
                ['color']  = {1, 0, 0, .3}
                }
            )
        end
    end

end

-----------------
-- Step Function
-----------------

STEP = function()
    Simulation:stop()
end

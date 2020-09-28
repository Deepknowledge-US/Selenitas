-----------------


--[[
    In this example we create n nodes and distribute them in the grid. Once this is done,
    each node will create a link with the others.
]]--

Interface:create_slider('nodes', 0, 100, 1, 20)
Interface:create_slider('radius', 0, 100, 1, 15)

-- In tick 0, all the agents are in the center of the grid, so we only have to divide 2\pi by
-- the number of agents to obtain the degrees of separation between agents (step).
-- Once this value is obtained, we iterate over the agents to locate them in the correct position.
local function layout_circle(collection, radius)

    local step = 2*math.pi / collection.count
    local angle = 0

    for _,ag in ordered(collection) do
        ag:rt(angle)
        ag:fd(radius)
        angle = angle + step
    end

end

SETUP = function()
    clear('all')
    Simulation:reset()

    Simulation.is_running = true

    Nodes = FamilyMobil()
    Nodes:create_n( Interface.nodes, function()
        return {
            ['pos']     = {0,0},
            ['heading'] = 0
        }
    end)

    layout_circle(Nodes, Interface.radius )

    -- A new collection to store the links
    Links = FamilyRelational()
    -- Each agent will create a link with the other agents.
    for _, ag in ordered(Nodes) do
        for _, other in pairs(Nodes:others(ag).agents) do
            Links:new({
                ['source'] = ag,
                ['target'] = other,
                ['color'] = {0.75, 0, 0, 1}
                }
            )
        end
    end

end


STEP = function()

end

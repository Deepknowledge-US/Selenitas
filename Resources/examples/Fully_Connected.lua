require 'Engine.utilities.utl_main'

--[[
    In this example we create n nodes and distribute them in the grid. Once this is done,
    each node will create a link with the others.
]]--

Config:create_slider('nodes', 0, 100, 1, 22)
Config:create_slider('speed', 0, 1, 0.01, 0.3)

local x,y  =  Config.xsize, Config.ysize
local size =  x > y and math.floor(x/2) or math.floor(y/2)

-- In tick 0, all the agents are in the center of the grid, so we only have to divide 360º by
-- the number of agents to obtain the degrees of separation between agents (step).
-- Once this value is obtained, we iterate over the agents. Each agent turns a number of degrees
-- equals to "degrees" variable and increment the value of "degrees" with "step".
local function layout_circle(collection, radius)

    local num = collection.count
    local step = 2*math.pi / num
    local degrees = 0

    for k,v in pairs(collection.agents)do

        local current_agent = collection.agents[k]
        current_agent:rt(degrees)
        current_agent:fd(radius)

        degrees = degrees + step
    end

end

SETUP = function()

    Nodes = FamilyMobil()
    Nodes:create_n( Config.nodes, function()
        return {
            ['pos']     = {0,0},
            ['head']    = {0,0}
        }
    end)

    layout_circle(Nodes, size - 1 )

    -- A new collection to store the links
    Links = FamilyRelational()


end


RUN = function()

    -- Each agent will create a link with the other agents.
    ask(Nodes, function(agent)
        ask(Nodes:others(agent), function(another_agent)
            Links:add({
                    ['source'] = agent,
                    ['target'] = another_agent,
                    ['label'] = "",--agent.id .. ',' .. another_agent.id,
                    ['visible'] = true,
                    ['color'] = {0.75, 0, 0, 1}
                }
            )
        end)
    end)

    Config.go = false
end

-- Setup and start visualization
GraphicEngine.set_setup_function(SETUP)
GraphicEngine.set_step_function(RUN)
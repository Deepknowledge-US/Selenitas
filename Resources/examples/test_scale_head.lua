require 'Engine.utilities.utl_main'

--[[
    In this example we create n nodes and distribute them in the grid. Once this is done,
    each node will create a link with the others.
]]--


Config = Params({
    ['start'] = true,
    ['go']    = true,
    ['ticks'] = 1,
    ['xsize'] = 30,
    ['ysize'] = 30
})


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

        current_agent.label = current_agent:xcor() .. ',' .. current_agent:ycor()
        degrees = degrees + step
    end

end

SETUP = function()

    Nodes = FamilyMobil()
    -- Nodes:create_n(4, function()
    --     return {
    --         ['pos']     = {size,size},
    --         ['head']    = {0,0}
    --     }
    -- end)

    local col_step = 0.2
    local col      = 0.1
    for i = 1, 4 do
        col = col + col_step
        Nodes:add({
            ['pos']     = {size,size},
            ['head']    = {0,0},
            ['color']   = {col,col,col,1},
        })
    end

    layout_circle(Nodes, size - 1 )

    -- A new collection to store the links
    Links = FamilyRelational()

    -- Each agent will create a link with the other agents.
    ask_ordered(Nodes, function(agent)
        ask_ordered(Nodes:others(agent), function(another_agent)
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

    Agents = FamilyMobil()
    Agents:add({['pos']={15,15}})

    Checks = FamilyMobil()
    local pos_incr = 2
    local pos = 0
    for i = 1,10 do
        pos = pos + pos_incr
        Checks:add({
            ['pos']     =   {pos,pos},
            ['shape']   =   "circle"
        })
    end

end


RUN = function()

    ask(Agents,function(ag)
        local target = one_of(Nodes)
        ag:face(target)
        print(target.pos[1],target.pos[2])

        -- ag:rt(math.pi/2)
    end)

    Config.go = false
end

-- Setup and start visualization
GraphicEngine.set_coordinate_scale(20)
GraphicEngine.set_world_dimensions(Config.xsize + 2, Config.ysize + 2)
GraphicEngine.set_time_between_steps(0.2)
GraphicEngine.set_simulation_params(Config)
GraphicEngine.set_setup_function(SETUP)
GraphicEngine.set_step_function(RUN)
GraphicEngine.init()
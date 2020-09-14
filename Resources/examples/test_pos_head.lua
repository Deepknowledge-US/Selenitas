require 'Engine.utilities.utl_main'

local radius = 15
Config:create_slider('nodes', 0, 100, 1,10)
Config:create_slider('links', 0, 30, 1, 15)
Config:create_boolean('rt_lt', true)

-- local x,y  =  Config.xsize, Config.ysize
-- local off_x,off_y = Config.xsize/2, Config.ysize/2
-- local size =  x > y and math.floor(x/4) or math.floor(y/4)
-- print(x,y,size)

local function layout_circle(collection, rad)
    local num = collection.count
    local step = 2*math.pi / num
    local degrees = 0

    for k,v in pairs(collection.agents)do
        local current_agent = collection.agents[k]

        current_agent:move_to({0,0})
        current_agent:lt(degrees)
        current_agent:fd(rad)
        degrees = degrees + step
    end

end

SETUP = function()

    Config.go = true

    Nodes = FamilyMobil()
    Nodes:create_n( Config.nodes, function()
        return {
            ['pos']     = {0,0},
            ['scale']   = 1.5,
            ['heading'] = {0,0}
        }
    end)

    -- local minor_half = Config.xsize < Config.ysize and Config.xsize / 2 or Config.ysize / 2

    layout_circle(Nodes, radius - 1 )
    ask(Nodes, function(ag)
        ag:update_cell()
        ag.label = n_decimals(2,ag:xcor()) .. ',' .. n_decimals(2,ag:ycor())
    end)

    -- A new collection to store the links
    Links = FamilyRelational()

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

    Agents = FamilyMobil()
    Agents:add({
        ['pos']     = {0,0},
        ['heading'] = {0,0},
        ['color']   = {0,0,1,1},
        ['shape']   = "triangle_2",
        ['scale']   = 2,
    })

end


RUN = function()
    if Config.rt_lt then
        ask_ordered(Agents, function(ag)
            ag:lt(math.pi/2)
        end)
    else
        ask_ordered(Agents, function(ag)
            ag:rt(math.pi/2)
        end)
    end

    Config.go = false
end

-- Setup and start visualization
GraphicEngine.set_setup_function(SETUP)
GraphicEngine.set_step_function(RUN)
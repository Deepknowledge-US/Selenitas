require 'Engine.utilities.utl_main'

--[[
    In this example we create n nodes and distribute them in the grid. Once this is done,
    each node will create a link with the others.
]]--


Config = Params({
    ['start'] = true,
    ['go']    = true,
    ['ticks'] = 1,
    ['xsize'] = 50,
    ['ysize'] = 50
})

Config:create_slider('houses', 0, 100, 1, 22)
Config:create_slider('people', 10, 1000, 1, 25)
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

    Houses = FamilyMobil()
    Houses:create_n( Config.houses, function()
        return {
            ['pos']     = {size,size},
            ['visible'] = true
        }
    end)

    layout_circle(Houses, size - 1 )

    People = FamilyMobil()
    -- People:create_n(Config.people, function()
    --     return {} -- Agents will have default properties
    -- end)
end


RUN = function()

    -- Config.go = false
end

-- Setup and start visualization
GraphicEngine.set_coordinate_scale(20)
GraphicEngine.set_world_dimensions(Config.xsize + 2, Config.ysize + 2)
GraphicEngine.set_time_between_steps(Config.speed)
GraphicEngine.set_simulation_params(Config)
GraphicEngine.set_setup_function(SETUP)
GraphicEngine.set_step_function(RUN)
GraphicEngine.init()
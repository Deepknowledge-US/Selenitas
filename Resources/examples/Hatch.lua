
require 'Engine.utilities.utl_main'

local pr = require 'pl.pretty'

Config = Params({
    ['start'] = true,
    ['go']    = true,
    ['ticks'] = 300,
    ['xsize'] = 15,
    ['ysize'] = 15,
    ['stride']= 3
})


local histogram = {}


-- This function applies to an agent a random turn in clock direction,
-- then the agent advance a number of units equals to Config.stride
local function wander(agent)
    rt(agent, math.random(360))
    fd_grid(agent, Config.stride)
end

-- Agents have an "age" parameter to simulate its age, this function increment in 1 its value
-- and kills the agent when it reach 51 years
local function grow_old(agent)
    agent.age = agent.age + 1
    if agent.age > 50 then
        Agents:kill(agent)
    end
end

local same_color = function(c1,c2)
    if #c1 ~= 4 or #c1 ~= 4 then
        return false
    end
    for i=1,4 do
        if c1[i] ~= c2[i] then
            return false
        end
    end
    return true
end

-- Only pink agents are capable of cloning themselves.
-- Cloned agents only have a 10% chance of being pink.
local function reproduce(agent)
    if agent.alive then
        if same_rgb(agent, {0.5,0.5,0.5,1}) and math.random(5) == 1 then
            clone_n(Agents, 1, agent, function(x)
                x.color = math.random(10) > 1 and {0,0,1,1} or {0.5,0.5,0.5,1}
                x.age   = 0
            end)
        end
    end
end


setup = function()

    -- "create_patches" encapsulates the creation of the patches collection
    Patches = create_patches(Config.xsize, Config.ysize)

    -- Create a collection of agents
    Agents = FamilyMobil()

    -- Populate the collection with 3 agents. Each agent will have the parameters
    -- specified in the table (and the parameters obteined just for be an Agent instance)
    Agents:create_n( 3, function()
        return {
            ['pos']     ={math.random(Config.xsize),math.random(Config.ysize)},
            ['head']    = math.random(360),
            ['age']     = 0,
            ['color']   = {0.5,0.5,0.5,1},
            ['shape']   = "circle"
        }
    end)

    -- All agents will advance 3 units in the faced direction
    ask(Agents, function(agent)
        fd_grid(agent,Config.stride)
    end)

end


-- The run function is executed until a stop condition in reached
-- At the moment we have discrete iterations
run = function()    
    -- A stop condition. We stop when the number of ticks is reached or when there are no agents alive
    if Agents.count == 0 or __ticks == Config.ticks then
        Config.go = false
        --for k,v in ipairs(histogram)do
        --    print('t: '..k,' n: '..v)
        --end
        return
    end

    -- In each iteration each agent moves randomly in a radius, then "grow_old" increases its age,
    -- finally it has a chance to clone itself

    ask( Agents, function(agent)
        agent:does(wander, grow_old, reproduce)
    end)

    -- -- This is another way to do it:
    -- ask(Agents, function(agent)
    --     wander(agent)
    --     grow_old(agent)
    --     reproduce(agent)
    -- end)



    -- When the simulation ends, in "histogram" we have an evolution of the population of
    -- agents along the iterations.
    table.insert(histogram, Agents.count)

end

-- Setup and start visualization
GraphicEngine.set_coordinate_scale(20)
GraphicEngine.set_world_dimensions(Config.xsize + 2, Config.ysize + 2)
GraphicEngine.set_time_between_steps(0)
GraphicEngine.set_simulation_params(Config)
GraphicEngine.set_setup_function(setup)
GraphicEngine.set_step_function(run)
GraphicEngine.init()
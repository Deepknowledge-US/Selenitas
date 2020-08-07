
local _main         = require 'Engine.utilities.utl_main'
local _coll         = require 'Engine.utilities.utl_collections'
local _fltr         = require 'Engine.utilities.utl_filters'
local _chk          = require 'Engine.utilities.utl_checks'
local _act          = require 'Engine.utilities.utl_actions'

local first_n       = _fltr.first_n
local last_n        = _fltr.last_n
local member_of     = _chk.member_of
local one_of        = _fltr.one_of
local n_of          = _fltr.n_of
local ask           = _coll.ask
local fd            = _act.fd
local fd_grid       = _act.fd_grid
local rt            = _act.rt
local lt            = _act.lt

local setup         = _main.setup
local run           = _main.run
local create_patches= _coll.create_patches

local pr = require 'pl.pretty'

Config = Params({
    ['start'] = true,
    ['go']    = true,
    ['ticks'] = 300,
    ['xsize'] = 15,
    ['ysize'] = 15,
    ['stride']= 3
})


--[[
    In this example we are going to init the simulation with 3 agents in the virtual environment.
    The color of an agent determines if it has the capability to clone itself (pink for those how
    are capable)
    In each iteration the agents move randomly, increment its age in 1 and if they are too old they die
    There is also a chance to clone itself in each iteration (only for pink agents)
]]





-- Representation of the world in a non graphical environment.
-- It prints the patches labels which contains the number of agents in the patch
local function print_current_config()
    -- pr.dump(Patches)

    print('\n========= tick: '.. __Ticks ..' =========')
    -- Reset the labels of the patches
    ask(Patches, function(patch)
        patch.label = 0
    end)
    
    -- Each agent increments in 1 the value of the patch in its position.
    ask(Agents, function(ag)
        local target_link = one_of( Patches:with(function(x) return x:xcor() == ag:xcor() and  x:ycor() == ag:ycor() end) )[1]
        target_link.label = target_link.label + 1
    end)

    for i=Config.ysize,1,-1 do
        local line = ""
        for j = 1,Config.xsize do
            local target = one_of( Patches:with(function(x) return x:xcor() == i and x:ycor() == j end) )[1]
            line = line .. target.label .. ','
        end
        print(line)
    end
    print('=============================\n')
end


local histogram = {}


-- This function applies to an agent a random turn in clock direction,
-- then the agent advance in 1.5 units
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

-- Only pink agents are capable of cloning themselves.
-- Cloned agents only have a 10% chance of being pink.
local function reproduce(agent)
    if agent.color == 'pink' and math.random(5) == 1 then
        Agents:clone_n_act(1,agent, function(x)
            x.color = math.random(10) > 1 and 'blue' or 'pink'
            x.age   = 0
        end)
    end
end


setup(function()

    -- "create_patches" encapsulates the creation of the patches collection
    Patches = create_patches(Config.xsize, Config.ysize)

    -- Create a collection of agents
    Agents = CollectionMobil()

    -- Populate the collection with 3 agents. Each agent will have the parameters
    -- specified in the table (and the parameters obteined just for be an Agent instance)
    Agents:create_n( 3, function()
        return {
            ['pos']     ={math.random(Config.xsize),math.random(Config.ysize)},
            ['head']    = math.random(360),
            ['age']     = 0,
            ['color']   = 'pink'
        }
    end)

    -- All agents will advance 3 units in the faced direction
    ask(Agents, function(agent)
        fd_grid(agent,Config.stride)
    end)

    -- pr.dump(Patches)

end)


-- The run function is executed until a stop condition in reached
-- At the moment we have discrete iterations
run(function()

    -- A stop condition. We stop when the number of ticks is reached or when there are no agents alive
    if #Agents.order == 0 or __Ticks == Config.ticks then
        print('adios')
        Config.go = false
        for k,v in ipairs(histogram)do
            print('t: '..k,' n: '..v)
        end
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
    table.insert(histogram, #Agents.order)

    -- print('hola')
    print_current_config()



end)



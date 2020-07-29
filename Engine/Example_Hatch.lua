local Collection    = require 'Engine.classes.class_collection_agents'
local Params        = require 'Engine.classes.class_params'
local utils         = require 'Engine.utilities'
local ask           = utils.ask
local setup         = utils.setup
local run           = utils.run
local rt            = utils.rt
local fd_grid       = utils.fd_grid
local create_patches= utils.create_patches

Config = Params({
    ['start'] = true,
    ['go']    = true,
    ['ticks'] = 300,
    ['xsize'] = 15,
    ['ysize'] = 15

})

local function print_current_config()
    for i=Config.ysize,1,-1 do
        local line = ""
        for j = 1,Config.xsize do
            line = line .. Patches.agents[j..','..i].label .. ','
        end
        print(line)
    end
end


local histogram = {}



local function wander(agent)
    rt(agent, math.random(360))
    fd_grid(agent, 1.5)
end

local function grow_old(agent)
    agent.age = agent.age + 1
    if agent.age > 50 then
        Agents:kill(agent)
    end
end

local function reproduce(agent)
    if agent.color == 'pink' and math.random(5) == 1 then
        Agents:clone_n_act(1,agent, function(x)
            x.color = math.random(10) > 1 and 'blue' or 'pink'
            x.age   = 0
        end)
    end
end


setup(function()

    Patches = create_patches(Config.xsize, Config.ysize)

    Agents = Collection()
    Agents:create_n( 3, function()
        return {
            ['xcor']    = math.random(Config.xsize),
            ['ycor']    = math.random(Config.ysize),
            ['head']    = math.random(360),
            ['age']     = 0,
            ['color']   = 'pink'
        }
    end)

    ask(Agents, function(agent)
        fd_grid(agent,3)
    end)

end)


run(function()

    print('\n========= tick: '.. T ..' =========')

    if Agents.size == 0 or T == Config.ticks then
        Config.go = false
        for k,v in ipairs(histogram)do
            print('t: '..k,' n: '..v)
        end
        return
    end


    ask(Agents, function(agent)
        wander(agent)
        grow_old(agent)
        reproduce(agent)
    end)

    ask(Patches, function(patch)
        patch.label = 0
    end)
    ask(Agents, function(agent)
        local target_link = Patches.agents[agent.xcor .. ',' .. agent.ycor]
        target_link.label = target_link.label + 1
    end)


    table.insert(histogram, Agents.size)

    print_current_config()

    print('=============================\n')
end)



local pl            = require 'pl'
local pretty        = require 'pl.pretty'
local config        = require 'Engine.config_file'
local Collection    = require 'Engine.classes.class_collection'
local Agent         = require 'Engine.classes.class_agent'
local Relational    = require 'Engine.classes.class_relational'
local Patch         = require 'Engine.classes.class_patch'
local utils         = require 'Engine.utilities'
local utl           = require 'pl.utils'
local lamb          = utl.bind1
local lambda        = utl.string_lambda
local first_n       = utils.first_n
local last_n        = utils.last_n
local member_of     = utils.member_of
local one_of        = utils.one_of
local n_of          = utils.n_of
local ask           = utils.ask
local setup         = utils.setup
local run           = utils.run
local rt            = utils.rt
local lt            = utils.lt
local fd            = utils.fd
local die           = utils.die
local clone_n_act   = utils.clone_n_act
local fd_grid       = utils.fd_grid


local function print_current_config()
    for i=config.ysize,1,-1 do
        local line = ""
        for j = 1,config.xsize do
            line = line .. Patches.agents[j..','..i].label .. ', '
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
        die(agent,Agents)
        -- Agents:kill(agent) -- This is another option
    end
end


local function reproduce(agent)
    if agent.color == 'pink' and math.random(5) == 1 then
        clone_n_act(1,agent,Agents, function(x)
            x.color = math.random(10) > 1 and 'blue' or 'pink'
            x.age   = 0
        end)
    end
end


setup(function()

    Agents = Collection()
    Agents:create_n( 3, function()
        return Agent({
            ['xcor']    = math.random(config.xsize),
            ['ycor']    = math.random(config.ysize),
            ['head']    = math.random(360),
            ['age']     = 0,
            ['color']   = 'pink'
        })
    end)

    ask(Agents, function(agent)
        fd_grid(agent,3)
    end)

    table.insert(histogram,#Agents.order)

end)


run(function()

    if #Agents.order == 0 then
        config.go = false
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
        patch.label = #Agents:with( function(agent)
            return agent.xcor == patch.xcor and agent.ycor == patch.ycor
        end)
    end)

    table.insert(histogram, #Agents.order)

    print_current_config()
end)



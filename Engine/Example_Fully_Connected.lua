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
local ask           = utils.ask
local setup         = utils.setup
local run           = utils.run
local rt            = utils.rt
local fd            = utils.fd
local fd_grid       = utils.fd_grid
local create_patches= utils.create_patches


local function print_current_config()
    for i=config.ysize,1,-1 do
        local line = ""
        for j = 1,config.xsize do
            local label = Patches.agents[j..','..i].label == 0 and Patches.agents[j..','..i].label or '_'
            line = line .. label .. ','
        end
        print(line)
    end

    pretty.dump(Links.agents)
    print(#Links.order)

end

local x,y = config.xsize,config.ysize
local size =  x > y and math.floor(x/2) or math.floor(y/2)

local function layout_circle(collection, radius)

    local num = #collection.order
    local step = 360 / num
    local degrees = 0

    for k,v in pairs(collection.agents)do

        local current_agent = collection.agents[k]
        rt(current_agent, degrees)

        -- Use this in a continuous space
        -- fd(current_agent, radius)

        -- Use this in a discrete space
        fd_grid(current_agent, radius)

        degrees = degrees + step
    end

end




setup(function()

    Patches = create_patches()

    Agents = Collection()
    Agents:create_n( 10, function()
        return Agent({
            ['xcor']    = size,
            ['ycor']    = size,
            ['head']    = 0
        })
    end)

    layout_circle(Agents, size - 1 )

    -- A new collection to store the links
    Links = Collection()

    -- Each agent will create a link with the other agents.
    ask(Agents, function(agent)
        ask(Agents:with( function(other_agent) return agent ~= other_agent end), function(other_agent)
            Links:add(
                Relational({
                    ['end1'] = agent,
                    ['end2'] = other_agent
                })
            )
        end)
    end)

end)


run(function()
    print('\n\n========== tick '.. T + 1 .. ' ===========')


    ask(Agents, function(x)
        Patches.agents[x.xcor .. ',' .. x.ycor].label = 0
    end)

    print_current_config()
    config.go = false


    print('=============================\n')
end)



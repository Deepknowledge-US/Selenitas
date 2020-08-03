local Collection_Agents = require 'Engine.classes.class_collection_agents'
local Collection_Links  = require 'Engine.classes.class_collection_links'
local Params            = require 'Engine.classes.class_params'
local Link              = require 'Engine.classes.class_link'
local utils             = require 'Engine.utilities'
local ask               = utils.ask
local setup             = utils.setup
local run               = utils.run
local rt                = utils.rt
local fd_grid           = utils.fd_grid
local create_patches    = utils.create_patches


Config = Params({
    ['start'] = true,
    ['go']    = true,
    ['ticks'] = 100,
    ['xsize'] = 15,
    ['ysize'] = 15

})

--[[
    In this example we create n nodes and distribute them in the grid. Once this is done,
    each node will create a link with the anothers.
]]--

-- A function to represent the space in a non graphical environment
local function print_current_config()

    print('\n\n========== tick '.. T .. ' ===========')
    for i=Config.ysize,1,-1 do
        local line = ""
        for j = 1,Config.xsize do
            local label = Patches.agents[j..','..i].label == 0 and Patches.agents[j..','..i].label or '_'
            line = line .. label .. ','
        end
        print(line)
    end
    print('=============================\n')
end

local x,y  =  Config.xsize, Config.ysize
local size =  x > y and math.floor(x/2) or math.floor(y/2)

-- In tick 0, all the agents are in the center of the grid, so we only have to divide 360º by
-- the number of agents to obtain the degrees of separation between agents (step).
-- Once this value is obtained, we iterate over the agents. Each agent turns a number of degrees
-- equals to "degrees" variable and increment the value of "degrees" with "step".
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

    Patches = create_patches(Config.xsize, Config.ysize)

    Nodes = Collection_Agents()
    Nodes:create_n( 10, function()
        return {
            ['xcor']    = size,
            ['ycor']    = size,
            ['head']    = 0
        }
    end)

    layout_circle(Nodes, size - 1 )

    -- A new collection to store the links
    Links = Collection_Links()

    -- Each agent will create a link with the other agents.
    ask(Nodes, function(agent)
        ask(Nodes:others(agent), function(another_agent)
            Links:add({
                    ['end1'] = agent,
                    ['end2'] = another_agent
                }
            )
        end)
    end)

    -- This function prints a 0 in the grid position of a node.
    -- A representation of the world in a non graphical environment.
    ask(Nodes, function(x)
        Patches.agents[x.xcor .. ',' .. x.ycor].label = 0
    end)

    -- print(one_of(Nodes)[1])
    print(Links)
end)


run(function()

    print_current_config()
    Config.go = false
    print(Links)
end)



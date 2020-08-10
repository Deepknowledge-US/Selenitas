local pretty            = require 'pl.pretty'
local pd                = pretty.dump

require 'Engine.utilities.utl_main'


Config = Params({
    ['start'] = true,
    ['go']    = true,
    ['ticks'] = 100,
    ['xsize'] = 16,
    ['ysize'] = 16,
    ['num_nodes'] = 10

})

--[[
    In this example we create n nodes and distribute them in the grid. Once this is done,
    each node will create a link with the anothers.
]]--

-- A function to represent the space in a non graphical environment
local function print_current_config()

    print('\n\n========== tick '.. __ticks .. ' ===========')
    for i=Config.ysize,1,-1 do
        local line = ""
        for j = 1,Config.xsize do
            local target = one_of(Patches:with( function(x) return x:xcor() == i and x:ycor() == j end ) )
            local label = target.label == 'O' and target.label or '_'
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

    Nodes = FamilyMobil()
    Nodes:create_n( Config.num_nodes, function()
        return {
            ['pos']     = {size,size},
            ['head']    = 0
        }
    end)

    layout_circle(Nodes, size - 1 )

    -- A new collection to store the links
    Links = FamilyRelational()

    -- Each agent will create a link with the other agents.
    ask(Nodes, function(agent)
        ask(Nodes:others(agent), function(another_agent)
            Links:add({
                    ['source'] = agent,
                    ['target'] = another_agent,
                    ['legend'] = agent.id .. ',' .. another_agent.id
                }
            )
        end)
    end)

    -- This function prints a 0 in the grid position of a node.
    -- A representation of the world in a non graphical environment.
    ask(Nodes, function(x)
        ask(
            one_of(Patches:with( function(c) return c:xcor() == x:xcor() and c:ycor() == x:ycor() end ))
            , function(o)
            o.label = 'O'
        end)
    end)

end)


run(function()
    print_current_config()
    Config.go = false
    -- pd(Links)
end)



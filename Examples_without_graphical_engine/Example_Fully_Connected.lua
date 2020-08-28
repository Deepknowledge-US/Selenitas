require 'Engine.utilities.utl_main'


Config = Params({
    ['start'] = true,
    ['go']    = true,
    ['ticks'] = 100,
    ['xsize'] = 16,
    ['ysize'] = 16,
    ['num_nodes'] = 5
})

--[[
    In this example we create n nodes and distribute them in the grid. Once this is done,
    each node will create a link with the anothers.
]]--

-- A function to represent the space in a non graphical environment
local function print_current_config()
    -- This function prints a 0 in the grid position of a node.
    -- A representation of the world in a non graphical environment.
    ask(Patches, function(p)
        p.label = '_'
    end)
    ask(Nodes, function(ag)
        ag.current_cells[1].label = 'O'
    end)

    print('\n\n========== tick '.. __ticks .. ' ===========')
    for i=Config.ysize,1,-1 do
        local line = ""
        for j = 1,Config.xsize do
            local target = Patches:cell_of({j,i})
            line = line .. target.label .. ','
        end
        print(line)
    end
    print('=============================\n')

end

local x,y  =  Config.xsize, Config.ysize
local size =  x > y and math.floor(x/2) or math.floor(y/2)

-- In tick 0, all the agents are in the center of the grid, so we only have to divide 2*pi by
-- the number of agents to obtain the radians of separation between agents (step).
-- Once this value is obtained, we iterate over the agents. Each agent turns a number of radians
-- equals to "radians" variable and increment the value of "radians" with "step".
local function layout_circle(collection, radius)
    local num = collection.count
    local step = (math.pi * 2) / num
    local radians = 0

    for k,v in pairs(collection.agents)do
        rt(v, radians)
        fd(v, radius)
        v:update_cell()

        radians = radians + step
    end
end

local function cell_n_pos(ag)
    for _,c in pairs(ag.current_cells)do
        print( ag.pos[1],ag.pos[2],' <> ',c.family.count,c:xcor(),c:ycor())
    end
end

setup(function()

    Patches = create_grid(Config.xsize, Config.ysize)

    Nodes = FamilyMobil()
    Nodes:create_n( Config.num_nodes, function()
        return {
            ['pos']     = {size,size},
            ['head']    = {0,nil}
        }
    end)

    layout_circle(Nodes, size-1 )

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

end)

local function print_aux()
    for k,v in pairs(Links.agents)do
        print('link id:', k)
    end
end

run(function()

    print_current_config()

    Config.go = false
    -- print(Links)
end)



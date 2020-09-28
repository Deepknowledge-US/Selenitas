-----------------
require 'Engine.utilities.utl_main'


local xsize,ysize = 15,15

Interface:create_slider('nodes', 5, 500, 1, 15)

--[[
    In this example we create n nodes and distribute them in the grid. Once this is done,
    each node will create a link with the anothers.
]]--

-- A function to represent the space in a non graphical environment
local function print_current_config()
    -- This function prints a 0 in the grid position of a node.
    -- A representation of the world in a non graphical environment.
    -- ask(Patches, function(p)
    --     p.label = '_'
    -- end)
    -- ask(Nodes, function(ag)
    --     ag.current_cells[1].label = 'O'
    -- end)

    for _,p in ordered(Patches)do
        p.label = '_'
    end
    for _,ag in ordered(Nodes)do
        ag.current_cells[1].label = 'O'
    end

    print('\n\n========== tick '.. Simulation.time .. ' ===========')
    for i=ysize-1,0,-1 do
        local line = ""
        for j = 0,xsize-1 do
            local target = Patches:cell_of({j,i})
            line = line .. target.label .. ','
        end
        print(line)
    end
    print('=============================\n')

end

local x,y  =  xsize, ysize
local size =  x > y and math.floor(x/2) or math.floor(y/2)

-- In tick 0, all the agents are in the center of the grid, so we only have to divide 2*pi by
-- the number of agents to obtain the radians of separation between agents (step).
-- Once this value is obtained, we iterate over the agents. Each agent turns a number of radians
-- equals to "radians" variable and increment the value of "radians" with "step".
local function layout_circle(family, radius)
    local num = family.count
    local step = (math.pi * 2) / num
    local radians = 0

    for k,v in ordered(family)do
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

SETUP(function()
    Patches = create_grid(xsize, ysize)

    Nodes = FamilyMobil()
    Nodes:create_n( Interface.nodes, function()
        return {
            ['pos']     = {size,size},
            ['heading'] = 0
        }
    end)

    layout_circle(Nodes, size-1 )

    -- A new collection to store the links
    Links = FamilyRelational()

    for _,agent in ordered(Nodes)do
        for _,another_agent in ordered(Nodes)do
            Links:new({
                ['source'] = agent,
                ['target'] = another_agent,
                ['legend'] = agent.id .. ',' .. another_agent.id
            })
        end
    end

end)

local function print_aux()
    for k,v in pairs(Links.agents)do
        print('link id:', k)
    end
end

STEP(function()

    print_current_config()

    Simulation.is_running = false
    -- print(Links)
end)



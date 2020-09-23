-----------------
require 'Engine.utilities.utl_main'


Config = Params({
    ['start'] = true,
    ['go']    = true,
    ['ticks'] = 100,
    ['xsize'] = 16,
    ['ysize'] = 16,
    ['num_nodes'] = 5
})


Config:create_slider('houses', 5, 500, 1, 20)

--[[
    In this example we create n houses and distribute them in the grid. Once this is done,
    each node will create a link with the anothers.
]]--

-- A function to represent the space in a non graphical environment
local function print_current_config()
    -- This function prints a 0 in the grid position of a node.
    -- A representation of the world in a non graphical environment.
    for _,p  in ordered(Patches)do p.label = '_' end
    for _,ag in ordered(Houses) do ag.current_cells[1].label = 'O' end
    for _,ag in ordered(People) do ag.current_cells[1].label = 'I' end


    print('\n\n========== tick '.. __ticks .. ' ===========')
    for i=Config.ysize-1,0,-1 do
        local line = ""
        for j = 0,Config.xsize-1 do
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

    Patches = create_grid(Config.xsize, Config.ysize)

    Houses = FamilyMobil()
    Houses:create_n( Config.houses, function()
        return {
            ['pos']     = {size,size},
            ['heading'] = 0
        }
    end)
    layout_circle(Houses, size-1 )

    People = FamilyMobil()
    People:create_n(1, function()
        return {
            ['pos'] = {0,0},
        }
    end)

    for _,pers in shuffled(People)do
        local house = one_of(Houses)
        pers:face(house)
        pers.next_house = house
        pers:update_cell()
    end

end)

local function print_aux()
    for k,v in pairs(Links.agents)do
        print('link id:', k)
    end
end

STEP(function()

    for _,pers in shuffled(People)do
        if pers:dist_euc_to(pers.next_house) < 1 then
            pers.current_house = pers.next_house
            pers.next_house = one_of(Houses:others(pers.current_house))
            pers:face(pers.next_house)
        end
        pers:fd(1):update_cell()
    end

    print_current_config()
    local list = {math.random(10,19),math.random(20,29),math.random(30,39)}

    if Config.ticks <=0 then
        Config.go = false
    end
end)



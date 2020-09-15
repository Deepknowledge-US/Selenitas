require 'Engine.utilities.utl_main'

--[[
    In this example we create n nodes and distribute them in the grid. Once this is done,
    each node will create a link with the others.
]]--


local radius = 20
Config:create_slider('houses', 0, 100, 1, 22)
Config:create_slider('people', 10, 1000, 1, 25)


-- In tick 0, all the agents are in the center of the grid, so we only have to divide 360º by
-- the number of agents to obtain the degrees of separation between agents (step).
-- Once this value is obtained, we iterate over the agents. Each agent turns a number of degrees
-- equals to "degrees" variable and increment the value of "degrees" with "step".
local function layout_circle(collection, radius)

    local num = collection.count
    local step = 2*math.pi / num
    local degrees = 0

    for k,v in pairs(collection.agents)do

        local current_agent = collection.agents[k]
        current_agent:rt(degrees)
        current_agent:fd(radius)

        degrees = degrees + step
    end

end

SETUP = function()
    math.randomseed(os.clock())
    Houses = FamilyMobil()
    Houses:create_n( Config.houses, function()
        local tree_or_house = math.random(100)<=50 and "house" or "tree"
        return {
            ['pos']     = {0,0},
            ['shape']   = tree_or_house,
            ['color']   = tree_or_house == "house" and {0,0,1,1} or {0,1,0,1},
            ['scale']   = 3,
            ['visible'] = true
        }
    end)

    layout_circle(Houses, radius - 1 )

    People = FamilyMobil()
    People:create_n(Config.people, function()
        return {
            ['pos']     = {math.random(-radius,radius),math.random(-radius,radius)},
            ['shape']   = "triangle"
        }
    end)
    ask(People,function(pers)
        local house = one_of(Houses)
        pers:face(house)
        pers.next_house = house
    end)
end


RUN = function()
    ask(People,function(pers)
        -- print(pers.next_house.id,pers:dist_euc_to(pers.next_house))
        if pers:dist_euc_to(pers.next_house) <= 0.25 then
            pers.current_house = pers.next_house
            pers.next_house = one_of(Houses:others(pers.current_house))
            pers:face(pers.next_house)
        end
        pers:fd(0.5):update_cell()
    end)
end
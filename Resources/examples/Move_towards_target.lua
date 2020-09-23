-----------------
local radius = 20
Config:create_slider('houses', 0, 100, 1, 22)
Config:create_slider('people', 10, 1000, 1, 25)


-- In tick 0, all the agents are in the center of the grid, so we only have to divide 360º by
-- the number of agents to obtain the degrees of separation between agents (step).
-- Once this value is obtained, we iterate over the agents. Each agent turns a number of degrees
-- equals to "degrees" variable and increment the value of "degrees" with "step".
local function layout_circle(collection, radius)

    local step  = __2pi / collection.count
    local angle = 0

    for _,ag in pairs(collection.agents) do
        ag:lt(angle)
        ag:fd(radius)
        angle = angle + step
    end

end

SETUP = function()

    clear('all')
    Houses = FamilyMobil()
    Houses:create_n( Config.houses, function()
        --local tree_or_house = math.random(100)<=50 and "house" or "tree"
        local tree_or_house = one_of {"house", "tree"}
        return {
              ['pos']     = {0,0}
            , ['shape']   = tree_or_house
            , ['color']   = tree_or_house == "house" and {0,0,1,1} or {0,1,0,1}
            , ['scale']   = 3
        }
    end)

    layout_circle(Houses, radius)

    People = FamilyMobil()
    People:create_n(Config.people, function()
        return {
            ['pos']     = {math.random(-radius,radius),math.random(-radius,radius)}
            , ['shape']   = "person"
            , ['speed']   = math.random()
        }
    end)
    for _, pers in pairs(People.agents) do
        local house = one_of(Houses)
        pers:face(house)
        pers.next_house = house
    end
end

STEP = function()
    for _, pers in pairs(People.agents) do
        if pers:dist_euc_to(pers.next_house) <= pers.speed then
            pers.current_house = pers.next_house
            pers.next_house = one_of(Houses:others(pers.current_house))
            pers:face(pers.next_house)
        end
        pers:fd(pers.speed)
    end
end

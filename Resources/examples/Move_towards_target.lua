-----------------
local radius = 30
Interface:create_slider('houses', 0, 50, 1, 24)
Interface:create_slider('people', 1, 100, 1, 10)


-- In tick 0, all the agents are in the center of the grid, so we only have to divide 360º by
-- the number of agents to obtain the degrees of separation between agents (step).
-- Once this value is obtained, we iterate over the agents. Each agent turns a number of degrees
-- equals to "degrees" variable and increment the value of "degrees" with "step".
local function layout_circle(collection, radius)

    local step  = 2*math.pi / collection.count
    local angle = 0

    for _,ag in pairs(collection.agents) do
        ag:lt(angle)
        ag:fd(radius)
        angle = angle + step
    end

end

SETUP = function()

    -- clear('all')
    Simulation:reset()
    declare_FamilyMobile('Houses')

    for i=1,Interface:get_value("houses") do
        local tree_or_house = one_of {"house", "tree"}
        Houses:new({
          pos     = {0,0},
          shape   = tree_or_house,
          color   = tree_or_house == "house" and color('blue') or color('green'),
          scale   = 0,
          label   = 0,
          show_label = true,
          visits  = 0
      })
    end

    layout_circle(Houses, radius)

    declare_FamilyMobile('People')
    for i=1,Interface:get_value("people") do
        local sp = math.random()
        People:new({
            pos     = {math.random(-radius,radius),math.random(-radius,radius)},
            shape   = "triangle",
            scale   = 2 * (.5 + sp),
            speed   = sp,
            color   = random_color(.5),
        })
    end

    for _, pers in ordered(People) do
        local house = one_of(Houses)
        pers:face(house)
        pers.next_house = house
    end
end

STEP = function()
    for _, pers in pairs(People.agents) do
        if pers:dist_euc_to(pers.next_house) <= pers.speed then
            h = pers.next_house
            h.visits = h.visits + 1 
            h.scale = h.visits / 5
            h.label = h.visits
            pers.next_house = one_of(Houses:others(h))
            pers:face(pers.next_house)
        end
        pers:fd(pers.speed)
    end
end
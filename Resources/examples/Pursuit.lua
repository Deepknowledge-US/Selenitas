-----------------
Interface:create_slider('Num_pursuers', 0, 100, 1, 10)

-- pos_to_torus relocate the agents as they are living in a torus
local function pos_to_torus(agent, size_x, size_y)
    local x,y = agent:xcor(),agent:ycor()

    if x > size_x then
        agent.pos[1] = agent.pos[1] - size_x
    elseif x < 0 then
        agent.pos[1] = agent.pos[1] + size_x
    end

    if y > size_y then
        agent.pos[2] = agent.pos[2] - size_y
    elseif y < 0 then
        agent.pos[2] = agent.pos[2] + size_y
    end
end

local function random_float(a,b)
    return a + (b-a) * math.random();
end


SETUP = function()

    -- clear('all')
    Simulation:reset()

    -- Test collection
    declare_FamilyMobil('Checkpoints')
    Checkpoints:new({ ['pos'] = {0, 100} })
    Checkpoints:new({ ['pos'] = {0,0} })
    Checkpoints:new({ ['pos'] = { 100,0} })
    Checkpoints:new({ ['pos'] = { 100, 100} })

    for _, ch in pairs(Checkpoints.agents) do
        ch.shape = 'circle'
        ch.scale = 5
        ch.color = {1,0,0,1}
        ch.label = ch:xcor() .. ',' .. ch:ycor()
    end

    -- Create a new collection
    declare_FamilyMobil('Pursuers')

    -- Populate the collection with Agents.
    for i = 1,Interface.Num_pursuers do
        Pursuers:new({
            ['pos']     = {math.random(0,100),math.random(0,100)}
            ,['heading'] = math.random(__2pi)
            ,['scale']   = 2
            ,['color']   = {0,0,1,1}
            ,['speed']   = math.random()
        })
    end

    declare_FamilyMobil('Pursueds')

    pursued = Pursueds:new({
        ['pos']     = {math.random(0,100),math.random(0,100)}
        ,['heading'] = math.random(__2pi)
        ,['scale']   = 2
        ,['color']   = {0,1,0,1}
        ,['speed']   = 1
    })

end

-- This function is executed until the stop condition is reached, 
-- or the button go/stop is stop
STEP = function()

    pursued:lt(random_float(-0.6,0.6))
    pursued:fd(1)
    pos_to_torus(pursued,100,100)

    for _,p in pairs(Pursuers.agents) do
        p:face(pursued)
        p:fd(p.speed)
        pos_to_torus(p,100,100)
    end

end

--[[
    Pursuit model where some agents must follow one prefixed agent.

    It uses customized methods for families and several standard methods
    (die, clone) and agent properties (__alive)
]]

-----------------
-- Interface 
-----------------
Interface:create_slider('Num_Pursuers', 0, 100, 1, 10)

panels_channel:push(Interface.windows)

----------------------
-- Auxiliary Functions
----------------------

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

-- Funtion to return a random float in an interval
local function random_float(a,b)
    return a + (b-a) * math.random();
end

-----------------
-- Setup Function
-----------------

SETUP = function()

    -- Reset Simulation
    Simulation:reset()

    -- Test collection
    declare_FamilyMobile('Checkpoints')
    Checkpoints:new({ ['pos'] = {0, 100} })
    Checkpoints:new({ ['pos'] = {0,0} })
    Checkpoints:new({ ['pos'] = { 100,0} })
    Checkpoints:new({ ['pos'] = { 100, 100} })

    for _, ch in ordered(Checkpoints) do
        ch.shape = 'square'
        ch.scale = 5
        ch.color = {1,0,0,0.5}
        ch.label = ch:xcor() .. ',' .. ch:ycor()
    end

    -- Create family of pursuers
    declare_FamilyMobile('Pursuers')

    -- Populate the collection with Agents.
    for i = 1,Interface:get_value("Num_Pursuers") do
        Pursuers:new({
            ['pos']     = {math.random(0,100),math.random(0,100)}
            ,['heading'] = math.random(__2pi)
            ,['scale']   = 2
            ,['color']   = {0,0,1,1}
            ,['speed']   = math.random()
        })
    end

    -- Create family of pursueds
    declare_FamilyMobile('Pursueds')

    -- Create one pursued
    pursued = Pursueds:new({
        ['pos']     = {math.random(0,100),math.random(0,100)}
        ,['heading'] = math.random(__2pi)
        ,['scale']   = 2
        ,['color']   = {0,1,0,1}
        ,['speed']   = 1
    })

end

-----------------
-- Step Function
-----------------

STEP = function()
    -- move the pursued in the torus
    pursued:lt(random_float(-0.6,0.6))
    pursued:fd(1)
    pos_to_torus(pursued,100,100)

    -- Move the pursuers trying to catch the pursued
    for _,pursuer in shuffled(Pursuers) do
        pursuer:face(pursued)
        pursuer:fd(pursuer.speed)
        pos_to_torus(pursuer,100,100)
    end

end
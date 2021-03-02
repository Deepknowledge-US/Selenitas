--[[
    Pursuit model where some agents must follow one prefixed agent.
]]

-----------------
-- Interface 
-----------------
Interface:create_slider('Num_Pursuers', 0, 100, 1, 10)

----------------------
-- Auxiliary Functions
----------------------

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
    declare_FamilyMobile('Limitpoints')
    Limitpoints:new({ pos = {0, 100} })
    Limitpoints:new({ pos = {0,0} })
    Limitpoints:new({ pos = { 100,0} })
    Limitpoints:new({ pos = { 100, 100} })

    for _,lp in ordered(Limitpoints) do
        lp.shape      = 'square'
        lp.scale      = 4
        lp.color      = color('grey',.5)
        lp.show_label = true
        lp.label      = lp:xcor() .. ',' .. lp:ycor()
    end

    -- Create family of pursuers
    declare_FamilyMobile('Pursuers')

    -- Populate the collection with Agents.
    for i = 1,Interface:get_value("Num_Pursuers") do
        Pursuers:new({
            pos     = {math.random(0,100),math.random(0,100)},
            heading = math.random(__2pi),
            scale   = 2,
            color   = color('blue'),
            speed   = math.random()
        })
    end

    -- Create family of pursueds
    declare_FamilyMobile('Pursueds')

    -- Create one pursued
    pursued = Pursueds:new({
        pos     = {math.random(0,100),math.random(0,100)},
        heading = math.random(__2pi),
        scale   = 3,
        color   = color('green'),
        speed   = 1.2
    })

end

-----------------
-- Step Function
-----------------

STEP = function()
    -- move the pursued
    pursued:lt(random_float(-0.3,0.3))
           :fd(pursued.speed)
    -- Check if it is inside the area, if not, move it back and turn it randomly
    if (math.abs(pursued:xcor()-50) > 50 or math.abs(pursued:ycor()-50) > 50) then
        pursued:fd(-pursued.speed)
               :lt(math.random())
    end 

    -- Move the pursuers trying to catch the pursued
    for _,p in shuffled(Pursuers) do
        p:face(pursued)
         :fd(p.speed)
        -- Check if it is inside the area, if not, move it back
        if (math.abs(p:xcor()-50) > 50 or math.abs(p:ycor()-50) > 50) then p:fd(-1) end
        -- Check if it catched the pursued
        if p:dist_euc_to(pursued) < 1 then p.color=color('red') else p.color=color('blue') end
    end

end
-- "COMUNICATION_T_T"
-- Agents are created and randomly located in the world
-- A message is given to one of them
-- Agents will share the message with others if close enough.
-- The simulation ends when all agents have the message.

Interface:create_slider('Num_agents', 0, 1000, 1, 100)
Interface:create_slider('radius', 0.0, 10.00001, .01, 1.0)


-- Agents with the message will share it with other agents in the same patch
local function comunicate(ag)

    if ag.message then
        local neighborhood = People:with(function(other)
            return ag:dist_euc_to(other) <= Interface.radius
        end)
        for _,other in ordered(neighborhood) do
            other.message = true
            other.color = {0,0,1,1}
        end
    end

end

-- pos_to_torus relocate the agents as they are living in a torus
local function pos_to_torus(agent, minsize_x, maxsize_x, minsize_y, maxsize_y)
    local x,y = agent:xcor(),agent:ycor()

    if x > maxsize_x then
        agent.pos[1] = minsize_x + (x - maxsize_x)
    elseif x < minsize_x then
        agent.pos[1] =  maxsize_x - (minsize_x - x)
    end

    if y > maxsize_y then
        agent.pos[2] = minsize_y + (y - maxsize_y)
    elseif y < minsize_y then
        agent.pos[2] = maxsize_y - (minsize_y - y)
    end
end


SETUP = function()
    -- clear('all')
    Simulation:reset()

    --GraphicEngine.set_background_color(0.8, 0.8, 0.8)

    -- Test collection
    -- Checkpoints = FamilyMobil()
    declare_FamilyMobil('Checkpoints')
    Checkpoints:new({ ['pos'] = {100, 100} })
    Checkpoints:new({ ['pos'] = {-100,-100} })
    Checkpoints:new({ ['pos'] = {-100,100} })
    Checkpoints:new({ ['pos'] = { 100,-100} })

    for _, ch in ordered(Checkpoints) do
        ch.shape = 'square'
        ch.scale = 5
        ch.color = {1,0,0,.5}
        ch.label = ch:xcor() .. ',' .. ch:ycor()
    end

    -- Create a new collection
    declare_FamilyMobil('People')

    -- Populate the collection with Agents.
    for i=1,Interface.Num_agents do
        People:new({
            ['pos']     = {math.random(-100,100),math.random(-100,100)}
            ,['message'] = false
            ,['heading'] = math.random(__2pi)
            ,['scale']   = 2
        })
    end

    local one_person = one_of(People)
    one_person.message = true
    one_person.color = {0,0,1,1}


end

-- This function is executed until the stop condition is reached, 
-- or the button go/stop is stop
STEP = function()
    -- if not Simulation.is_running then
    --     return
    -- end
    -- Stop condition
    if People:with(function(x) return x.message == false end).count == 0 then
        Simulation.is_running = false
        return
    end

    for _, person in ordered(People) do
        person:lt(math.random(-0.5,0.5))
        person:fd(1)
        pos_to_torus(person,-100,100,-100,100)
        comunicate(person)
    end

end

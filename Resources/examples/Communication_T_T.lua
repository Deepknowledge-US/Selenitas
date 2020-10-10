
local utl           = require 'pl.utils'
local lamb          = utl.bind1
local lambda        = utl.string_lambda


-- "COMUNICATION_T_T"
-- Agents are created and randomly located in the world
-- A message is given to one of them
-- Agents will share the message with others if close enough.
-- The simulation ends when all agents have the message.

Interface:create_slider('Num_agents', 0, 1000, 1, 100)
Interface:create_slider('radius', 0, 10, .01, 1)


SETUP = function()
    -- clear('all')
    Simulation:reset()

    GraphicEngine.set_background_color(.8,.8,.8)
    -- Test collection
    -- Checkpoints = FamilyMobil()
    declare_FamilyMobile('Checkpoints')

    Checkpoints:new({ ['pos'] = {0, 100} })
    Checkpoints:new({ ['pos'] = {0,0} })
    Checkpoints:new({ ['pos'] = { 100,0} })
    Checkpoints:new({ ['pos'] = { 100, 100} })

    for _, ch in ordered(Checkpoints) do
        ch.shape = 'circle'
        ch.scale = 5
        ch.color = {1,0,0,1}
        ch.label = ch:xcor() .. ',' .. ch:ycor()
    end

    -- Create a new collection
    declare_FamilyMobile('People')

    -- Agents with the message will share it with other agents in the same patch.
    People:add_method('comunicate', function(self)
        if self.message then
            local neighborhood = People:with(function(other)
                return self:dist_euc_to(other) <= Interface:get_value("radius", "testwindow")
            end)
            for _,other in ordered(neighborhood) do
                other.message = true
                other.color = {0,0,1,1}
            end
        end
        return self
    end)

    -- pos_to_torus relocate the agents as they are living in a torus
    People:add_method('pos_to_torus', function(self, size_x, size_y)
        local x,y = self:xcor(),self:ycor()
        if x > size_x then
            self.pos[1] = self.pos[1] - size_x
        elseif x < 0 then
            self.pos[1] = self.pos[1] + size_x
        end
        if y > size_y then
            self.pos[2] = self.pos[2] - size_y
        elseif y < 0 then
            self.pos[2] = self.pos[2] + size_y
        end
        return self
    end)

    -- Populate the collection with Agents.
    for i=1,Interface:get_value("Num_agents") do
        People:new({
            ['pos']     = {math.random(0,100),math.random(0,100)}
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

    if People:with(function(x) return x.message == false end).count == 0 then
        -- Simulation.is_running = false
        Simulation:stop()
        return
    end

    for _, person in ordered(People) do
        person
            :lt(math.random(-0.5,0.5))
            :fd(1)
            :pos_to_torus(100,100)
            :comunicate()
    end

end

--[[
    Agents are created and randomly located in the world.
    A message is given to one of them.
    Agents will share the message with others if close enough.
    The simulation ends when all agents have the message.

    This example shows the option to create customized methods for families of 
    agents 
--]]

global_vars = {
  Informed = 0
  }
-----------------
-- Interface 
-----------------
Interface:create_slider('Num_agents', 0, 1000, 1, 100)
Interface:create_slider('Radius', 0.0, 10.0, .01, 1.0)
Interface:create_monitor('Informed')
-----------------
-- Setup Function
-----------------

SETUP = function()
    
    -- Reset Simulation
    Simulation:reset()

    -- Auxiliary Family to show the bounds of the world
    declare_FamilyMobile('Checkpoints')

    for x=-50,50,100 do
      for y=-50,50,100 do
        Checkpoints:new({ 
          pos        = {x,y},
          shape      = 'square',
          scale      = 3,
          color      = color('green',.5),
          show_label = true,
          label      = '(' .. x .. ',' .. y .. ')'
        })
      end
    end

    -- Family of mobil agents
    declare_FamilyMobile('People')

    -- New method for People family: if the calling agent
    -- has the message, he will communicate it to other
    -- close agents. People with message are blue.
    People:add_method('comunicate', 
      function(self)
        if self.message then
            local r = Interface:get_value('Radius')
            -- Take the neighborhood as the collection of people close enough
            local PUninformed = People:with(function(ag) return not ag.message end)
            local neighborhood = PUninformed:with(function(other) return self:dist_euc_to(other) <= r end)
            -- Spread the message to neighborhood
            for _,other in ordered(neighborhood) do
                other.message = true
                other.color = color('red')
            end
        end
        -- A method must return the self agent in order to concatenate methods
        return self
      end)

    -- New method for People family: relocate people as they are living in a torus
    People:add_method('pos_to_torus', 
      function(self, minsize_x, maxsize_x, minsize_y, maxsize_y)
        -- Current position of agent
        local x,y = self:xcor(),self:ycor()
        -- Change coordinates to restrict inside the torus
        if x > maxsize_x then
            self.pos[1] =  minsize_x + (x - maxsize_x)
        elseif x < minsize_x then
            self.pos[1] = maxsize_x - (minsize_x - x)
        end
        if y > maxsize_y then
            self.pos[2] =  minsize_y + (y - maxsize_y)
        elseif y < minsize_y then
            self.pos[2] = maxsize_y - (minsize_y - y)
        end
        -- A method must return the self agent in order to concatenate methods
        return self
      end)

    -- Populate People Family.
    for i=1,Interface:get_value('Num_agents') do
        People:new({
            pos     = {math.random(-50,50),math.random(-50,50)},
            color   = color('green'),
            message = false,
            heading = math.random(__2pi),
            scale   = 1
        })
    end

    -- Choose one random agent to initially have the message
    local one_person = one_of(People)
    one_person.message = true
    one_person.color = color('red')

end

-----------------
-- Step Function
-----------------

STEP = function()
    -- Stop simulation when all the people has the message
    uninformed = People:with(function(x) return x.message == false end).count
    global_vars.Informed = Interface:get_value('Num_agents') - uninformed
    if uninformed == 0 then
        Simulation:stop()
    end

    -- Iterate over people to randomly move and communicate the message (if possible)
    for _, person in ordered(People) do
        -- Next lines show the concatenation of method over an agent
        person
            :lt(math.random(-0.5,0.5))
            :fd(1)
            :pos_to_torus(-50,50,-50,50)
            :comunicate()
    end
end

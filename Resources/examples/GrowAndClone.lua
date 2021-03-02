--[[
    An example of growing and cloning of agents.

    It uses customized methods for families and several standard methods
    (die, clone) and agent properties (alive)
]]

-----------------
-- Interface 
-----------------
Interface:create_slider('N_agents', 0, 10, 1, 3)
Interface:create_slider('Max_age', 5, 100, 1, 40)
Interface:create_slider('Clone_probability', 0, 100, 1, 30)
Interface:create_slider('Size_world', 0, 100, 5, 50)
Interface:create_boolean('Torus', true)

----------------------
-- Auxiliary Functions
----------------------

function Agents_methods()
    -- Customized Method: The agent get older, and dies when it reachs the max 
    -- age. Died agents have an '__alive = false', but they still remain in the 
    -- world until a purge is performed. 
    -- 'purge_agents()' at the end of the 'step' block will delete them.

    Agents:add_method('ageing', 
      function(self, max_age)
        self.age = self.age + 1
        self.scale = self.age / 10
        if self.age > max_age then die(self) end
        -- Return the agent itself in order to concatenate methods
        return self
      end)

    -- New method for Agents family: relocation in a torus
    Agents:add_method('pos_to_torus', 
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
        -- Return the agent itself in order to concatenate methods
        return self
      end)

    -- Agents have a chance to clone itself in each iteration
    Agents:add_method('reproduce', 
      function(self,cp)
        if self.__alive then
        -- By default, Lua can't compare tables by value
          if same_rgb(self, color('red')) and math.random(100) <=  cp then
            -- Clone agent and provide some changes to new agents
            Agents:clone_n(1, self, 
              function(x)
                x.color = math.random(10) > 1 and color('blue') or color('red')
                x.age   = 0
              end)
          end
        end
      end)
  
end

-----------------
-- Setup Function
-----------------

SETUP = function()

    -- clear('all')
    Simulation:reset()

    -- Create a Family of Mobil agents
    declare_FamilyMobile('Agents')

    -- Add new methods to Agents
    Agents_methods()
    
	local sw= Interface:get_value('Size_world')
    -- Populate the initial collection
    for i=1,Interface:get_value("N_agents") do
        Agents:new({
            pos     = {math.random(-sw, sw), math.random(-sw, sw)},
            head    = math.random(2*math.pi),
            age     = 0,
            color   = color('red')
        })
    end
end

-----------------
-- Step Function
-----------------

STEP = function()

	local sw = Interface:get_value('Size_world')
    -- A stop condition: when there are no agents alive
  if Agents.count == 0 then
    Simulation:stop()
  end

  -- Iterate the Family in a shuffled way
 for _,agent in shuffled(Agents) do
    agent                           -- concatenate methods calls
      :lt(math.random(-0.5, 0.5))
      :fd(0.5)
      
    if Interface:get_value('Torus') then agent:pos_to_torus(-sw, sw, -sw, sw) end
    
    agent
      :ageing(Interface:get_value("Max_age"))
      :reproduce(Interface:get_value("Clone_probability"))
  end

  -- Purgue killed agents of the simulation
  purge_agents(Agents)
end

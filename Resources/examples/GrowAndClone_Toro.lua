--[[
    An example of growing and cloning of agents.

    It uses customized methods for families and several standard methods
    (die, clone) and agent properties (alive)
]]

-----------------
-- Interface 
-----------------
Interface:create_slider('N_agents', 0, 10, 1, 3)
Interface:create_slider('Max_age', 5, 100, 1, 50)
Interface:create_slider('Clone_probability', 0, 100, 1, 20)
Interface:create_boolean('Torus', true)

----------------------
-- Auxiliary Functions
----------------------

function Agents_methods()
    -- Customized Method: The agent get older, and dies when it reachs the max 
    -- age. Died agents have a 'alive = false', but they still remain in the world until 
    -- a purge is performed. 
    -- 'purge_agents()'  at the end of the 'step' block will delete them from the world.
    Agents:add_method('grow_old', function(agent)
        agent.age   = agent.age + 1
        agent.scale = agent.age / 20

        if agent.age > Interface:get_value("Max_age") then
            die(agent)
        end
        -- Always a method must return the self agent in order to concatenate methods
        return agent
    end)

    -- New method for Agents family: relocate agents as they are living in a torus
    Agents:add_method('pos_to_torus', function(self, minsize_x, maxsize_x, minsize_y, maxsize_y)
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
        -- Always a method must return the self agent in order to concatenate methods
        return self
    end)

    -- Agents have a chance to clone itself in each iteration
    Agents:add_method('reproduce', function(agent)
        if agent.alive then
            local cp = Interface:get_value("Clone_probability")
            if same_rgb(agent, {1,0,0,1}) and math.random(100) <= cp then

                Agents:clone_n(1, agent, function(x)
                    x.color = math.random(10) > 1 and {0,0,1,1} or {1,0,0,1}
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

    -- Create a Family of Estructural Agents
    declare_FamilyCell('Cells')

    -- Create cells and give a grid structure to them
    Cells:create_grid(50,50,-25,-25) -- width, height, offset x, offset y
    for _,c in ordered(Cells) do
        local m = math.random(2) / 10
        c.color = {m,m,m,.5}
    end


    -- Create a Family of Mobile agents
    declare_FamilyMobile('Agents')

    -- Add new methods to Agents
    Agents_methods()

    -- Populate the Family with 3 agents. Each agent will have the parameters
    -- specified in the table (and some parameters obteined just for be a Mobil instance)

    for i=1,Interface:get_value("N_agents") do
        Agents:new({
              pos       = one_of(Cells).pos --{math.random(-25,25),math.random(-25,25)}
            , heading   = random_float(0, 2*math.pi)
            , age       = 0
            , color     = {1,0,0,1}
        })
    end
end

-----------------
-- Step Function
-----------------

STEP = function()

    -- A stop condition. We stop when the number of ticks is reached or when there are no agents alive
    if Agents.count == 0 then
        Simulation:stop()
    end

    -- Iterate Agents shuffled to move them, grow and reproduce
    for _,agent in shuffled(Agents) do
        agent
        :lt(random_float(-0.5,0.5))
        :fd(1)
        
        if Interface:get_value('Torus') then agent:pos_to_torus(-25,25,-25,25) end
        
        agent
        :grow_old()
        :reproduce()
    end

    -- Killed agents are purged of the simulation
    purge_agents(Agents)
end

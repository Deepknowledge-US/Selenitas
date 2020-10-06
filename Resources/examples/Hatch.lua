-----------------

Interface:create_slider('num_agents', 0, 10, 1, 3)
Interface:create_slider('max_age', 5, 100, 1, 30)
Interface:create_slider('clone_probability', 0, 100, 1, 20)

-- In the 'setup' block we define the initial configuration of the system.
SETUP = function()

    -- clear('all')
    Simulation:reset()

    -- Create a Family of Mobil agents
    declare_FamilyMobil('Agents')

    -- The agent dies when it reachs the max age.
    -- Died agents have a value of false to its parameter 'alive', but they still remain in the world until 
    -- a purge is performed. 
    -- 'purge_agents()' instruction at the end of the 'run' block delete them from the world.
    Agents:add_method('grow_old', function(agent)
        agent.age = agent.age + 1
        agent.scale = agent.age / 10
        if agent.age > Interface.max_age then
            die(agent)
        end
        return agent
    end)

    -- Change the position of the agents as they are living in a torus
    -- In this version it only works when the torus area is in the form
    --   [0,size_x]x[0,size_y]
    Agents:add_method('pos_to_torus', function(agent, size_x, size_y)
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
        return agent
    end)

    -- Grey agents have a chance to clone itself in each iteration
    Agents:add_method('reproduce', function(agent)
        if agent.alive then
            if same_rgb(agent, {1,0,0,1}) and math.random(100) <= Interface.clone_probability then
                Agents:clone_n(1, agent, function(x)
                    x.color = math.random(10) > 1 and {0,0,1,1} or {1,0,0,1}
                    x.age   = 0
                end)
            end
        end
    end)


    -- Populate the Family with 3 agents. Each agent will have the parameters
    -- specified in the table (and some parameters obteined just for be a Mobil instance)
    for i=1,Interface.num_agents do
        Agents:new({
            ['pos']     = {math.random(0,10),math.random(0,10)}
            ,['head']    = math.random(2*math.pi)
            ,['age']     = 0
            ,['color']   = {1,0,0,1}
        })
    end

end

-- The run function is executed until a stop condition in reached
-- At the moment we have discrete iterations
STEP = function()

    -- A stop condition. We stop when the number of ticks is reached or when there are no agents alive
    if Agents.count == 0 then
        Simulation.is_running = false
        return
    end

    for _,agent in shuffled(Agents) do
        agent
        :lt(math.random(-0.5,0.5))
        :fd(0.8)
        -- :pos_to_torus(100,100)
        :grow_old()
        :reproduce()
    end

    -- Killed agents are purged of the simulation
    purge_agents(Agents)

end

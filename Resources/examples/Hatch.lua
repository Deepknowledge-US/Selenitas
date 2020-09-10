require 'Engine.utilities.utl_main'


-- In the 'setup' block we define the initial configuration of the system.
SETUP = function()

    -- Create a Family of Mobil agents
    Agents = FamilyMobil()

    -- Populate the Family with 3 agents. Each agent will have the parameters
    -- specified in the table (and some parameters obteined just for be a Mobil instance)
    Agents:create_n( 3, function()
        return {
            ['pos']     = {math.random(Config.xsize),math.random(Config.ysize)},
            ['head']    = {math.random(2*math.pi),0},
            ['age']     = 0,
            ['color']   = {0.5,0.5,0.5,1}
        }
    end)

    -- The agent dies when it reachs 50 cicles.
    -- Died agents have a value of false to its parameter 'alive', but still remains in the system. The 'purge_agents()' instruction at the end of the 'run' block delete them from the system.
    Agents:add_method('grow_old', function(agent)
        agent.age = agent.age + 1
        if agent.age > 50 then
            die(agent)
        end
        return agent
    end)

    -- Grey agents have a chance to clone itself in each iteration
    Agents:add_method('reproduce', function(agent)
        if agent.alive then
            if same_rgb(agent, {0.5,0.5,0.5,1}) and math.random(5) == 1 then
                Agents:clone_n(1, agent, function(x)
                    x.color = math.random(10) > 1 and {0,0,1,1} or {0.5,0.5,0.5,1}
                    x.age   = 0
                end)
            end
        end
    end)

end


-- The run function is executed until a stop condition in reached
-- At the moment we have discrete iterations
RUN = function()

    -- A stop condition. We stop when the number of ticks is reached or when there are no agents alive
    if Agents.count == 0 or __ticks == Config.ticks then
        Config.go = false
        return
    end

    -- In each iteration each agent:
        -- Turns a random number of degrees
        -- Advance in the faced direction
        -- Increases its age, and die if it is old enough
        -- Have a chance to clon itself
    ask( Agents, function(agent)
        agent
            :lt(math.random(-0.5,0.5))
            :fd(0.8)
            :grow_old()
            :reproduce()
    end)

    -- Killed agents are purged of the simulation
    purge_agents(Agents)

end

-- Setup and start visualization
GraphicEngine.set_coordinate_scale(20)
GraphicEngine.set_world_dimensions(Config.xsize + 2, Config.ysize + 2)
GraphicEngine.set_time_between_steps(0.2)
GraphicEngine.set_setup_function(SETUP)
GraphicEngine.set_step_function(RUN)
GraphicEngine.init()
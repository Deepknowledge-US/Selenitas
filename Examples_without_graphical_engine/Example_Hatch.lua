-----------------
require 'Engine.utilities.utl_main'

local pr = require 'pl.pretty'

local xsize,ysize = 15,15
local max_age     = 20
local stride      = 1

local function print_current_config()

    print('\n========= tick: '.. Simulation.time ..' =========')

    for i=ysize-1,0,-1 do
        local line = ""
        for j = 0,xsize-1 do
            local target = Patches:cell_of({j,i})
            line = line .. target.my_agents.count .. ','
        end
        print(line)
    end

    print('=============================\n')

end


local histogram = {}



SETUP(function()

    -- "create_patches" encapsulates the creation of the patches collection
    declare_FamilyCell('Patches')
    Patches:create_grid(xsize, ysize)

    -- Create a collection of agents
    declare_FamilyMobile('Agents')
    -- Populate the collection with 3 agents. Each agent will have the parameters
    -- specified in the table (and the parameters obteined just for be an Agent instance)

    for i=1,3 do
        Agents:new({
            ['pos']     = {math.random(xsize-1),math.random(ysize-1)},
            ['heading'] = math.random(360),
            ['age']     = 0,
            ['color']   = {0.5,0.5,0.5,1}
        })
    end


    -- This function applies to an agent a random turn in clock direction,
    -- then the agent advance a number of units equals to stride
    Agents:add_method('wander', function(agent)
        agent
            :rt( math.random(2*math.pi))
            :fd(stride)
            :update_cell(Patches)
        return agent
    end)

    Agents:add_method('grow_old', function(agent)
        agent.age = agent.age + 1
        if agent.age > max_age then
            die(agent)
        end
        return agent
    end)

    Agents:add_method('reproduce', function(agent)
        if agent.__alive then
            if same_rgb(agent, {0.5,0.5,0.5,1}) and math.random(5) == 1 then
                clone_n(Agents, 1, agent, function(x)
                    x.color = math.random(10) > 1 and {0,0,1,1} or {0.5,0.5,0.5,1}
                    x.age   = 0
                end)
            end
        end
    end)

    Agents:add_method('update_position', function(agent, min_x, max_x, minim_y, maxim_y)
        local x,y = agent:xcor(),agent:ycor()

        local min_y, max_y = minim_y or min_x, maxim_y or max_x

        local size_x, size_y = max_x-min_x, max_y-min_y

        if x > max_x then
            agent.pos[1] = agent.pos[1] - size_x
        elseif x < min_x then
            agent.pos[1] = agent.pos[1] + size_x
        end

        if y > max_y then
            agent.pos[2] = agent.pos[2] - size_y
        elseif y < min_y then
            agent.pos[2] = agent.pos[2] + size_y
        end
        return agent
    end)

    for _,agent in ordered(Agents)do
        agent
        :fd(stride)
        :update_position(0,15)
        :update_cell(Patches)
    end

end)

-- The run function is executed until a stop condition in reached
-- At the moment we have discrete iterations
STEP(function()

    -- A stop condition. We stop when the number of ticks is reached or when there are no agents alive
    if Agents.count == 0 or Simulation.time > Simulation.max_time then
        -- print(Agents.count,__ticks,__Controller.ticks)
        Simulation:stop()
        for k,v in ipairs(histogram)do
            print('t: '..k,' n: '..v)
        end
        return
    end

    for _,agent in ordered(Agents)do
        agent
        :rt(math.random(2*math.pi))
        :fd(stride)
        :update_position(0,15)
        :update_cell(Patches)
        :grow_old()
        :reproduce()
    end

    purge_agents(Agents)

    table.insert(histogram, Agents.count)


    print_current_config()

end)



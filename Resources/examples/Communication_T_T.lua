local graphicengine = require 'Visual.graphicengine'

require 'Engine.utilities.utl_main'

local utl           = require 'pl.utils'
local lamb          = utl.bind1
local lambda        = utl.string_lambda


-- "COMUNICATION_T_T"
-- Agents are created and randomly positioned in the grid of patches
-- A message is given to one of them
-- Agents will share the message with others in the same patch.
-- The simulation ends when all agents have the message.



-- Agents with the message will share it with other agents in the same patch
local function comunicate(x)

    if x.message then
        ask(
            People:with(function(other)
                return x:dist_euc_to(other) <= 1
            end),

            function(other)
                other.message = true
                other.color = {0,0,1,1}
            end
        )
    end

end

local function update_position(agent, min_x, max_x, minim_y, maxim_y)
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
end


SETUP = function()
    -- Test collection
    Checkpoints = FamilyMobil()
    Checkpoints:add({ ['pos'] = {-20, 20} })
    Checkpoints:add({ ['pos'] = {-20,-20} })
    Checkpoints:add({ ['pos'] = { 20,-20} })
    Checkpoints:add({ ['pos'] = { 20, 20} })

    ask(Checkpoints, function(ch) 
        ch.shape = 'circle'
        ch.scale = 1.5
        ch.color = {1,0,0,1}
        ch.label = ch:xcor() .. ',' .. ch:ycor()
    end)



    -- Create a new collection
    People = FamilyMobil()

    -- Populate the collection with Agents.
    People:create_n( 13, function()
        return {
            ['pos']     = {math.random(-20,20),math.random(-20,20)},
            ['message'] = false,
            ['heading'] = {math.random(__2pi),0}
        }
    end)

    ask(one_of(People), function(agent)
        agent.message = true
        agent.color = {0,0,1,1}
    end)

    Config.go = true

end

-- This function is executed until the stop condition is reached, or until
-- the number of iterations equals the number of ticks specified inf config_file
RUN = function()
    if not Config.go then
        do return end
    end
    -- Stop condition
    if People:with(lambda '|x| x.message == false').count == 0 then
        Config.go = false
        return
    end

    ask(People, function(person)
        -- gtrn(person)
        person:lt(math.random(-0.5,0.5)):fd(1)
        update_position(person,-20,20)
        comunicate(person)
    end)

end

-- Setup and start visualization
GraphicEngine.set_setup_function(SETUP)
GraphicEngine.set_step_function(RUN)
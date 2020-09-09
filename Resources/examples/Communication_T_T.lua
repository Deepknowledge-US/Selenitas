local graphicengine = require 'Visual.graphicengine'

require 'Engine.utilities.utl_main'

local utl           = require 'pl.utils'
local lamb          = utl.bind1
local lambda        = utl.string_lambda



Config = Params({
    ['start'] = true,
    ['go']    = true,
    ['ticks'] = 200,
    ['xsize'] = 30,
    ['ysize'] = 30
})


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
                return x:dist_euc_to_agent(other) <= 1
            end),

            function(other)        
                other.message = true
                other.color = {0,0,1,1}
            end
        )
    end

end


SETUP = function()
    -- Create a new collection
    People = FamilyMobil()

    -- Populate the collection with Agents.
    People:create_n( 13, function()
        return {
            ['pos']     = {math.random(Config.xsize),math.random(Config.ysize)},
            ['message'] = false,
            ['head']    = {math.random(__2pi),0}
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
        comunicate(person)
    end)

end

-- Setup and start visualization
GraphicEngine.set_coordinate_scale(20)
GraphicEngine.set_world_dimensions(Config.xsize + 2, Config.ysize + 2)
GraphicEngine.set_time_between_steps(0.25)
GraphicEngine.set_simulation_params(Config)
GraphicEngine.set_setup_function(SETUP)
GraphicEngine.set_step_function(RUN)
GraphicEngine.init()
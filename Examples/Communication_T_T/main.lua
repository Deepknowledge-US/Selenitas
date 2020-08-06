local graphicengine = require 'Visual.graphicengine'

local Collection    = require 'Engine.classes.class_collection_mobil'
local Patches       = require 'Engine.classes.class_collection_cell'
local Params        = require 'Engine.classes.class_params'
local utl           = require 'pl.utils'
local lamb          = utl.bind1
local lambda        = utl.string_lambda

local _main         = require 'Engine.utilities.utl_main'
local _coll         = require 'Engine.utilities.utl_collections'
local _fltr         = require 'Engine.utilities.utl_filters'
local _chk          = require 'Engine.utilities.utl_checks'
local _act          = require 'Engine.utilities.utl_actions'

local first_n       = _fltr.first_n
local last_n        = _fltr.last_n
local member_of     = _chk.member_of
local one_of        = _fltr.one_of
local n_of          = _fltr.n_of
local ask           = _coll.ask
local gtrn          = _act.gtrn
local fd            = _act.fd
local rt            = _act.rt
local lt            = _act.lt

local setup         = _main.setup
local run           = _main.run
local create_patches= _coll.create_patches


Config = Params({
    ['start'] = true,
    ['go']    = true,
    ['ticks'] = 200,
    ['xsize'] = 15,
    ['ysize'] = 15
})






-- "COMUNICATION_T_T"
-- Agents are created and randomly positioned in the grid of patches
-- A message is given to one of them
-- Agents will share the message with others in the same patch.
-- The simulation ends when all agents have the message.



-- Agents with the message will share it with other agents in the same patch
local function comunicate(x)

    if x.message then
        local my_x, my_y = x:xcor(), x:ycor()
        ask(
            People:with(function(other)
                return x ~= other and other:xcor() == my_x and other:ycor() == my_y
            end),

            function(other)        
                other.message = true
                other.color = {0, 0, 1, 1}
            end
        )
    end

end


setup = function()
    -- Create a new collection
    People = Collection()

    -- Populate the collection with Agents.
    People:create_n( 10, function()
        return {
            ['pos']     = {math.random(Config.xsize),math.random(Config.ysize)},
            ['message'] = false
        }
    end)

    ask(one_of(People), function(agent)
        agent.message = true
        agent.color = {0, 0, 1, 1}
    end)

    Config.go = true

    return People.agents
end

-- This function is executed until the stop condition is reached, or until
-- the number of iterations equals the number of ticks specified inf config_file
run = function()
    if not Config.go then
        do return end
    end
    -- Stop condition
    if #People:with(lambda '|x| x.message == false') == 0 then
        Config.go = false
        return
    end

    ask(People, function(person)
        gtrn(person)
        comunicate(person)
    end)

    --print_current_config()
end

-- Setup and start visualization
GraphicEngine.set_coordinate_scale(20)
GraphicEngine.set_world_dimensions(Config.xsize + 2, Config.ysize + 2)
GraphicEngine.set_time_between_steps(0)
GraphicEngine.set_simulation_params(Config)
GraphicEngine.set_setup_function(setup)
GraphicEngine.set_step_function(run)
GraphicEngine.init()
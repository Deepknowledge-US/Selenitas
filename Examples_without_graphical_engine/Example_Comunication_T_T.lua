local pl            = require 'pl'
local pretty        = require 'pl.pretty'
local Params        = require 'Engine.classes.class_params'
local Collection    = require 'Engine.classes.class_collection_mobil'
local _main         = require 'Engine.utilities.utl_main'
local _coll         = require 'Engine.utilities.utl_collections'
local _act          = require 'Engine.utilities.utl_actions'
local _fltr         = require 'Engine.utilities.utl_filters'
local utl           = require 'pl.utils'
local lambda        = utl.string_lambda
local ask           = _coll.ask
local setup         = _main.setup
local run           = _main.run
local one_of        = _fltr.one_of
local gtrn          = _act.gtrn
local create_patches= _coll.create_patches


-- "COMUNICATION_T_T"
-- Agents are created and randomly positioned in the grid of patches
-- A message is given to one of them
-- Agents will share the message with others in the same patch.
-- The simulation ends when all agents have the message.


-- An instance of Params class is needed to define some usefull parameters.
Config = Params({
    ['start'] = true,
    ['go']    = true,
    ['ticks'] = 200,
    ['xsize'] = 15,
    ['ysize'] = 15

})



-- Agents with the message will share it with other agents in the same patch
local function comunicate(agent)

    if agent.message then
        ask(
            People:others(agent),

            function(other)
                if other:xcor() == agent:xcor() and other:ycor() == agent:ycor() then
                    other.message = true
                end
            end
        )
    end

end


-- This function is only needed in a non graphical environment to print current configuration of the system.
local function print_current_config()

    print('\n\n========== tick '.. T .. ' ===========')

    -- Reset patches value
    ask(Patches, function(patch)
        patch.label = 0
    end)

    -- Each agent will increment in 1 the value of its current patch
    ask(People, function(person)
        local x,y = person:xcor(), person:ycor()
        local target = Patches.agents[x..','..y]
        target.label = target.label + 1
    end)

    -- Print the number of agents in each patch
    for i = Config.ysize,1,-1 do
        local line = ""
        for j = 1, Config.xsize do
            line = line .. Patches.agents[j..','..i].label .. ', '
        end
        print(line)
    end

    print('\n\n=============================')
end


-- The anonymous function in this call is executed once by the setup function
-- defined in utilities.lua
setup(function()

    -- Create a grid of patches with the specified dimensions
    Patches = create_patches(Config.xsize,Config.ysize)

    -- Create a new collection of agents
    People = Collection()

    -- Populate the collection with Agents. Each agent will be randomly positioned.
    People:create_n( 10, function()
        return {
            ['pos']     = {math.random(Config.xsize),math.random(Config.ysize)},
            ['message'] = false
        }
    end)

    -- A message is given to one of the agents
    ask(one_of(People), function(agent)
        agent.message = true
    end)

end)


-- This function is executed until the stop condition is reached, or until
-- the number of iterations equals the number of ticks specified inf config_file
run(function()

    -- Stop condition: All agents have the message
    if #People:with(lambda '|x| x.message == false') == 0 then
        Config.go = false
        print(People)
        return
    end

    -- In each iteration, agents go to a random neighbour and try to share the message
    ask(People, function(person)
        gtrn(person)
        comunicate(person)
    end)


    print_current_config()

end)



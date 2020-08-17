require 'Engine.utilities.utl_main'

local pretty        = require 'Thirdparty.pl.pretty'
local utl           = require 'Thirdparty.pl.utils'
local lambda        = utl.string_lambda


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

    print('\n\n========== tick '.. __ticks .. ' ===========')

    ask_coroutine(Patches, function(cell)
        cell.label = People:with(function(ag)
            return ag:xcor() == cell:xcor() and ag:ycor() == cell:ycor()
        end).size
    end)

    -- Print the number of agents in each patch
    for i = Config.ysize,1,-1 do
        local line = ""
        for j = 1, Config.xsize do
            local target = one_of(Patches:with(function(cell)
                return cell:xcor() == i and cell:ycor() == j
            end))
            line = line .. target.label .. ','
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
    People = FamilyMobil()

    -- Populate the collection with Agents. Each agent will be randomly positioned.
    People:create_n( 10, function()
        return {
            ['pos']     = {math.random(Config.xsize),math.random(Config.ysize)},
            ['message'] = false
        }
    end)

    -- A message is given to one of the agents
    ask_coroutine(one_of(People), function(agent)
        agent.message = true
    end)


end)


-- This function is executed until the stop condition is reached, or until
-- the number of iterations equals the number of ticks specified inf config_file
run(function()

    -- Stop condition: All agents have the message
    if People:with(function(x) return x.message == false end).size == 0 then
        Config.go = false
        return
    end

    -- In each iteration, agents go to a random neighbour and try to share the message
    ask(People, function(person)
        person:rt(math.random(360)):fd_grid(2)
        comunicate(person)
    end)


    print_current_config()

end)



-----------------
require 'Engine.utilities.utl_main'

local pretty        = require 'Thirdparty.pl.pretty'
local utl           = require 'Thirdparty.pl.utils'
local lambda        = utl.string_lambda


-- "COMUNICATION_T_T"
-- Agents are created and randomly positioned in the grid of patches
-- A message is given to one of them
-- Agents will share the message with others in the same patch.
-- The simulation ends when all agents have the message.

Simulation.max_time = 500

local xsize,ysize = 15,15

-- Agents with the message will share it with other agents in the same patch
local function comunicate(agent)
    if agent.message then
        for _, other in ordered(People)do
            if Patches:cell_of(agent) == Patches:cell_of(other) and agent ~= other then
                other.message = true
            end
        end
    end
end

-- This function is only needed in a non graphical environment to print current configuration of the system.
local function print_current_config()

    print('\n\n========== tick '.. Simulation.time .. ' ===========')

    -- ask_ordered(Patches, function(x) x.label = 0 end)
    for _,x in ordered(Patches)do
        x.label = 0
    end

    for _,ag in ordered(People)do
        local cell = Patches:cell_of(ag)
        cell.label = cell.label + 1
    end

    -- Print the number of agents in each patch
    for i = ysize-1,0,-1 do
        local line = ""
        for j = 0, xsize-1 do
            local target = Patches:cell_of({j,i})
            line = line .. target.label .. ','
        end
        print(line)
    end

    print('\n\n=============================')
end


-- The anonymous function in this call is executed once by the setup function
-- defined in utilities.lua
SETUP(function()

    -- Create a grid of patches with the specified dimensions
    declare_FamilyCell('Patches')
    Patches:create_grid(xsize,ysize)

    -- Create a new collection of agents
    declare_FamilyMobile('People')


    People:add_method('update_pos',function(agent, min_x, max_x, minim_y, maxim_y)
        local x,y            = agent:xcor(),agent:ycor()
        local min_y, max_y   = minim_y or min_x, maxim_y or max_x -- Two last params are optional
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

    for i = 1, 10 do
        local new_ag = People:new({
            pos     = {math.random(xsize-1),math.random(ysize-1)},
            message = false
        })
        new_ag
            :update_pos(xsize,ysize)
            :update_cell(Patches)
    end

    one_of(People).message = true

end)

-- This function is executed until the stop condition is reached, or until
-- the number of iterations equals the number of ticks specified inf config_file
STEP(function()


    -- Stop condition: All agents have the message
    if People:with(function(x) return x.message == false end).count == 0 then
        Simulation:stop()
        return
    end

    for k, person in shuffled(People) do
        person
            :lt(math.random(__2pi))
            :fd(1)
            :update_pos(0,15)
            :update_cell(Patches)
        comunicate(person)
    end

    print_current_config()

end)



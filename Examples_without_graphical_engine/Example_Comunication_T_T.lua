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
        -- ask(
        --     People:others(agent),

        --     function(other)
        --         if agent.current_cells[1] == other.current_cells[1] then
        --             other.message = true
        --         end
        --     end
        -- )
        for _, other in ordered(People)do
            -- TOD funcion same_pos(optional_families) devuelve true si dos agentes estan en la misma posición en alguno de los "grids" creados, o en algunos en concreto si se pasan como parámetros
            if agent.current_cells[1] == other.current_cells[1] and agent ~= other then
                other.message = true
            end
        end
    end
end

-- This function is only needed in a non graphical environment to print current configuration of the system.
local function print_current_config()

    print('\n\n========== tick '.. __ticks .. ' ===========')

    -- ask_ordered(Patches, function(x) x.label = 0 end)
    for _,x in ordered(Patches)do
        x.label = 0
    end

    -- ask_ordered(People, function(ag)
    --     ordered(Patches:cell_of(ag), function(p)
    --         p.label = p.label + 1
    --     end)
    -- end)

    for _,ag in ordered(People)do
        local cell = Patches:cell_of(ag)
        cell.label = cell.label + 1
    end

    -- Print the number of agents in each patch
    for i = Config.ysize-1,0,-1 do
        local line = ""
        for j = 0, Config.xsize-1 do
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
    Patches = create_grid(Config.xsize,Config.ysize)

    -- Create a new collection of agents
    People = FamilyMobil()

    -- Populate the collection with Agents. Each agent will be randomly positioned.
    People:create_n( 10, function()
        return {
            ['pos']     = {math.random(Config.xsize-1),math.random(Config.ysize-1)},
            ['message'] = false
        }
    end)
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


    one_of(People).message = true

end)

-- local function producer(a_list, an_index)
--     return coroutine.create(
--         function()
--             local j = math.random(an_index)
--             a_list[an_index], a_list[j] = a_list[j], a_list[an_index]
--             coroutine.yield(a_list[an_index], an_index-1)
--         end
--     )
-- end

-- local function consumer(a_list, an_index)
--     local status, element, new_index = coroutine.resume(producer(a_list, an_index))
--     a_list[an_index] = nil
--     return new_index, element
-- end

-- local function shuffled(fam_or_list)
--     local list
--     if fam_or_list.agents then
--         list = fam_to_list(fam_or_list)
--     else
--         list = list_copy(fam_or_list)
--     end

--     return consumer, list, #list
-- end

-- This function is executed until the stop condition is reached, or until
-- the number of iterations equals the number of ticks specified inf config_file
STEP(function()

    -- Stop condition: All agents have the message
    if People:with(function(x) return x.message == false end).count == 0 then
        Config.go = false
        return
    end

    for k, person in shuffled(People) do
        person
            :lt(math.random(__2pi))
            :fd(1)
            :update_pos(0,15)
            :update_cell()
        comunicate(person)
    end

    print_current_config()

end)



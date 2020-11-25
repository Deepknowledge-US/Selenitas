------------------
-- Some methods to operate over families.
-- @module
-- families

local Cell = require "Engine.classes.Cell"

local utl_fam = {}

function utl_fam.declare_FamilyMobile(...)
    local args = {...}

    for i=1,#args do
        local name = args[i]

        if not _G[name] or not Simulation.families[name] then
            _G[name] = FamilyMobile(name)
            Simulation.families[name] = _G[name]
            Interface:create_family_mobile_window( { ['title'] = name } )
        end
    end
end

function utl_fam.declare_FamilyRel(...)
    local args = {...}

    for i=1,#args do
        local name = args[i]

        if not _G[name] or not Simulation.families[name] then
            _G[name] = FamilyRelational(name)
            Simulation.families[name] = _G[name]
            Interface:create_family_rel_window( { ['title'] = name } )
        end
    end
end

function utl_fam.declare_FamilyCell(...)
    local args = {...}

    for i=1,#args do
        local name = args[i]

        if not _G[name] or not Simulation.families[name] then
            _G[name] = FamilyCell(name)
            Simulation.families[name] = _G[name]
            Interface:create_family_cell_window( { ['title'] = name } )
        end
    end
end


--===================--
--      ACTIONS      --
--===================--


------------------
-- This function encapsulates a call to the function clone_n_act in the Family given as parameter.
-- @function clone_n
-- @param family The Family where the agent belongs to and where the clones will be added.
-- @param n Number. The number of agents to clone
-- @param agent The Agent instance used as model to create the clones
-- @param funct Optional. An anonymous function to ask the clones to do something
-- @return Nothing
-- @usage
-- clone_n(3, ag1, ag1_family, function(clone)
--     clone:gtrn()
-- end)
-- @see AgentSet.clone_n
function utl_fam.clone_n(family, n, agent, funct)
    return family:clone_n(n, agent, funct)
end

------------------
-- This function delete from the system all agents marked as not alive (a value of false in its parameter '__alive'), it will also delete all the relational agents that involve a not-alive agent.
-- @function purge_agents
-- @param ... Undefined number of Families from where we want to purge agents. If no Family is passed, it purge all families in the system.
-- @return Nothing
-- @usage
-- purge_agents(Prays, Predators)
function utl_fam.purge_agents(...)
    if ... ~= nil then
        for i = 1, select("#", ...) do
            local family = select(i, ...)
            family:__purge_agents()
        end
    else
        for i = 1, #Config.__all_families do
            local family = Config.__all_families[i]
            family:__purge_agents()
        end
    end
end

--===================--
--    COROUTINES     --
--===================--

------------------
-- Internal function to make the iterator. It yields a random item of the list gived as parameter every time it is called. This function is called by a consumer function when a new element is needed
-- @function __producer
-- @param list A list of elements
-- @param list A index of the list
-- @return A random element in a position lower or equal to "index" parameter
-- @usage
-- local status, number = coroutine.resume(utl_fam.__producer(list, index))
function utl_fam.__producer(list, index)
    return coroutine.create(
        function()
            local j = math.random(index)
            list[index], list[j] = list[j], list[index]
            coroutine.yield(list[index])
        end
    )
end

------------------
-- Beside __producer, this functions are a coroutine to implement the Fisher-Yates shuffle. __consumer calls the __producer to take a new element of the list.
-- @function __consumer
-- @param list A List of elements.
-- @param index A position in the list.
-- @return A new element of the list
-- @usage
-- for i=#list,1,-1 do
--     local new_element = __consumer(list,i)
--     print(new_element)
-- end
function utl_fam.__consumer(list, index)
    local status, element = coroutine.resume(utl_fam.__producer(list, index))
    list[index] = nil
    return element
end

return utl_fam
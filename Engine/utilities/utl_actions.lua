--- Utilities to apply actions to agents or families mainly.
-- @module
-- actions

local sin       = math.sin
local cos       = math.cos
local rad       = math.rad

local utl_actions = {}


------------------
-- Fisher-Yates method to shuffle a list, it consist on permutations of the objects in a list.
-- @function array_shuffle
-- @param list A list to shuffle
-- @return Nothing
-- @usage
-- local a_list = {1,2,3,4,5}
-- array_shuffle(a_list)
-- print(a_list)
-- -- => {3,2,5,1,4}
function utl_actions.array_shuffle(list)
    local array = list
    for i = #array,2, -1 do
        local j = math.random(i)
        array[i], array[j] = array[j], array[i]
    end
end;

------------------
-- Produces a right turn in an agent of "num" radians
-- @function rt
-- @param agent The agent we want to turn.
-- @param num Number of degrees to turn.
-- @return Nothing
-- @usage rt(agent,180)
-- @see Mobil.rt
function utl_actions.rt(agent, num)
    return agent:rt(num)
end

------------------
-- Produces a left turn in an agent of "num" radians
-- @function lt
-- @param agent The agent we want to turn.
-- @param num Number of degrees to turn.
-- @return Nothing
-- @usage lt(agent,180)
-- @see Mobil.lt
function utl_actions.lt(agent, num)
    return agent:lt(num)
end

------------------
-- The agent will advance some units in the faced direction
-- @function fd
-- @param agent The agent we want to advance.
-- @param num Number of units to advance.
-- @return Nothing
-- @usage fd(agent,2)
-- @see Mobil.fd
function utl_actions.fd(agent, num)
    return agent:fd(num)
end

------------------
-- It marks an agent as dead by giving a false value to its 'live' param.
-- @function die
-- @param agent The agent we want to mark as die.
-- @param family The family the agent belongs to. Optional param, if not gived
-- @return Nothing
-- @usage
-- ask(Nodes, function(node)
--     if node.color == {1,1,1,1} then
--         die(node, Nodes)
-- --      Nodes:kill(node) -- This is equivalent.
-- --      die(node)        -- This is also possible, and the agent will be searched and killed (but not purged) in every Family.
--     end
-- end)
-- @see Family.kill
function utl_actions.die(agent, family)
    if family ~= nil then
        family:kill(agent)
    else
        for i=1,#Simulation.families do
            if agent == Simulation.families[i].agents[agent.id]  then
                Simulation.families[i]:kill(agent)
            end
        end
    end
end


------------------
-- This function must be used to kill and agent and remove it for the simulation. It will delete all the references to the agent and the links related to it.
-- @function kill_and_purge
-- @param agent The agent to be purged.
-- @return Nothing
-- @usage
-- kill_and_purge(an_agent)
function utl_actions.kill_and_purge(agent)
    return agent.family:kill_and_purge(agent)
end

return utl_actions
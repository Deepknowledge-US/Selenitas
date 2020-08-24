------------------
-- @module
-- actions

local sin       = math.sin
local cos       = math.cos
local rad       = math.rad

local utl_actions = {}

------------------
-- Fisher-Yates method to shuffle a list. It consist on permutations of the objects in a list.
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
-- Produces a right turn in an agent of "num" degrees
-- @function rt
-- @param agent The agent we want to turn.
-- @param num Number of degrees to turn.
-- @return Nothing
-- @usage rt(agent,180)
function utl_actions.rt(agent, num)
    agent.head = (agent.head + num) % 360
end

------------------
-- Produces a left turn in an agent of "num" degrees
-- @function lt
-- @param agent The agent we want to turn.
-- @param num Number of degrees to turn.
-- @return Nothing
-- @usage lt(agent,180)
function utl_actions.lt(agent, num)
    agent.head = (agent.head + num) % 360
end

------------------
-- The agent will advance some units in the faced direction
-- @function fd
-- @param agent The agent we want to advance.
-- @param num Number of units to advance.
-- @return Nothing
-- @usage fd(agent,2)
function utl_actions.fd(agent, num)

    local s = sin(rad(agent.head))
    agent.pos[1] = (agent:xcor() + s * num) % Config.xsize

    local c = cos(rad(agent.head))
    agent.pos[2] = (agent:ycor() + c * num) % Config.ysize

end

------------------
-- The agent will advance some units in the faced direction, but coordinates are rounded to discrete numbers.
-- @function fd_grid
-- @param agent The agent we want to advance.
-- @param num Number of units to advance.
-- @return Nothing
-- @usage fd_grid(agent,2)
function utl_actions.fd_grid(agent, num)

    local s = sin(rad(agent.head))
    agent.pos[1] = math.ceil( (agent:xcor() + s * num) % Config.xsize )
    if agent:xcor() == 0 then agent.pos[1] = Config.xsize end

    local c = cos(rad(agent.head))
    agent.pos[2] = math.ceil( (agent:ycor() + c * num) % Config.ysize )
    if agent:ycor() == 0 then agent.pos[2] = Config.ysize end

end

------------------
-- Agent will be moved to one of its neighbors' patches (8 neighbors are considered).
--  0 0 0        0 0 x
--  0 x 0   ->   0 0 0
--  0 0 0        0 0 0
-- Extremes of the grid are conected.
-- @function gtrn
-- @param agent The agent we want to move
-- @return Nothing
-- @usage gtrn(an_agent)
function utl_actions.gtrn(agent)

    local changes = { {0,1},{0,-1},{1,0},{-1,0},{1,1},{1,-1},{-1,1},{-1,-1} }
    local choose  = math.random(#changes)

    -- Agents that cross a boundary will appear on the opposite side of the grid
    agent.pos[1] = (agent:xcor() + changes[choose][1]) % Config.xsize
    agent.pos[1] = agent:xcor() > 0 and agent:xcor() or Config.xsize

    agent.pos[2] = (agent:ycor() + changes[choose][2]) % Config.ysize
    agent.pos[2] = agent:ycor() > 0 and agent:ycor() or Config.ysize

end

------------------
-- Marks an agent as die by given a value of false to its param 'alive'. Agents with alive=false does not do actions when we ask to the agents in the family to do something, but they still are present in the table 'agents' of its family and all its links with other agents are presents in the simulation. If you want to totally remove an agent and its relations with others of the simulation you have to do 'purge_agents()'.
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
        for i=1,#Config.__all_families do
            if agent == Config.__all_families[i].agents[agent.id]  then
                Config.__all_families[i]:kill(agent)
            end
        end
    end
end


return utl_actions
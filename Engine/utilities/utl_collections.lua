------------------
-- @module
-- collections

local Cell     = require 'Engine.classes.Cell'

local utl_coll = {}

------------------
-- A function to create a bidimensional grid of patches quickily
-- @function create_patches
-- @param x Number. Dimension of x axis of the grid
-- @param y Number. Dimension of y axis of the grid
-- @return A FamilyCell instance
-- @usage
-- Patches = create_patches(100,100)
function utl_coll.create_patches(x,y)
    local cells  = FamilyCell()

    for i=1,x do
        for j = 1,y do
            cells:add( Cell({ ['pos'] = {i,j} })  )
        end
    end
    cells:shuffle()
    return cells
end

------------------
-- Applies a function to all elements. Works with Families or with subsets of families (Collections).
-- @function ask
-- @param elements A Family or a filtered Family to ask to do something.
-- @return  Nothing
-- @usage
-- ask(Nodes, function(node) 
--     if Node:xcor() > 4 then Node.color = {0,0,0,1} end
-- end)
function utl_coll.ask(elements, funct)
    if elements:is_a(Agent) then
        funct(elements)
    else
        for _,v in ipairs(elements.order)do
            funct( elements.agents[v] )
        end
    end
end


function utl_coll.ask_coroutine(fam, funct, prod, cons, custom_for)
    if fam:is_a(Agent) then
        funct(fam)
        return
    end

    local producer = prod or function(list, index)
        return coroutine.create(
            function()
                local j = math.random(index)
                list[index], list[j] = list[j], list[index]
                coroutine.yield(list[index])
            end
        )
    end

    local consumer =  cons or function(list, index)
        local status, number = coroutine.resume(producer(list, index))
        table.remove(list,index)
        return number
    end


    -- for _,v in pairs(fam.agents) do
    --     table.insert(list_copy,v)
    -- end

    -- for index = #list_copy, 1, -1 do
    --     local current = consumer(list_copy, index)
    --     funct(current)
    -- end


    if custom_for then
        custom_for(fam,funct)
    else
        local list_copy={}
        
        for k,_ in pairs(fam.agents) do
            table.insert(list_copy,k)
        end
        for index = #list_copy, 1, -1 do
            local current = consumer(list_copy, index)
            funct(fam.agents[current])
        end 
    end
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
--     end
-- end)
function utl_coll.die(agent, family)
    if family ~= nil then
        Agents:kill(agent)
    else
        --TODO: si no se pasa colección, buscar al agente en todas las colecciones
    end
end

------------------
-- This function encapsulates a call to the function clone_n_act in the Family given as parameter.
-- @function clone_n_act
-- @param n Number. The number of agents to clone
-- @param agent The Agent instance used as model to create the clones
-- @param family The Family where the agent belongs to and where the clones will be added.
-- @param funct Optional. An anonymous function to ask the clones to do something
-- @return Nothing
-- @usage
-- clone_n_act(3, ag1, ag1_family, function(clone)
--     clone:gtrn()
-- end)
function utl_coll.clone_n_act(n,agent,family, funct)
    return family:clone_n_act(n,agent,funct)
end

------------------
-- This function delete from the system all agents marked as not alive (a value of false in its parameter 'alive'), it will also delete all the relational agents that involve a not-alive agent.
-- @function purge_agents
-- @param ... Undefined number of Families from where we want to purge agents. If no Family is passed, it purge all families in the system.
-- @return Nothing
-- @usage
-- purge_agents(Prays, Predators)
function utl_coll.purge_agents(...)
    if ... ~= nil then
        for i = 1,select('#', ...)do
            local family = select(i,...)
            family:__purge_agents()
        end
    else
        for i = 1,#Config.__all_families do
            local family = Config.__all_families[i]
            family:__purge_agents()
        end
    end
end

return utl_coll
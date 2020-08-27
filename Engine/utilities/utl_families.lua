------------------
-- Some methods to operate over families.
-- @module
-- families

local Cell     = require 'Engine.classes.Cell'

local utl_fam = {}

------------------
-- A function to create a bidimensional grid of patches quickily
-- @function create_patches
-- @param x Number. Dimension of x axis of the grid
-- @param y Number. Dimension of y axis of the grid
-- @return A FamilyCell instance
-- @usage
-- Patches = create_patches(100,100)
function utl_fam.create_grid(x,y,cell_width,cell_height)
    local cells  = FamilyCell()

    local w,h = cell_width or 1, cell_height or 1

    for i=1,x do
        for j = 1,y do
            cells:add( Cell({ ['pos'] = {i,j} })  )
        end
    end

    local grid_neighs = { {-1,0},{1,0},{0,1},{0,-1},{1,1},{1,-1},{-1,1},{-1,-1} }

    cells:ask_ordered(function(cell)
        local c_x,c_y = cell:xcor(),cell:ycor()
        local neighs = {}

        for i=1,8 do
            local neigh_pos = { grid_neighs[i][1] + c_x, grid_neighs[i][2] + c_y}
            if neigh_pos[1] > 0 and neigh_pos[2] > 0 and neigh_pos[1] <= x and neigh_pos[2] <= y then
                -- table.insert(neighs, cells:cell_in_pos(neigh_pos))
                cell.neighbors:add( cells:cell_in_pos(neigh_pos) )
            end
        end
        -- cell.neighbors = neighs
    end)

    return cells
end


--===================--
--      ACTIONS      --
--===================--


------------------
-- Create n new Agents in the family. The type of the agent depends on the family it will be created.
-- @function create_n
-- @param family The family where the agents will be created.
-- @param num The number of agents that will be added to the family.
-- @param funct An anonymous function that will be executed to create the Cell.
-- @return Nothing
-- @usage
-- create_n( A_family, 10, function()
--     return {
--         ['pos'] = {math.random[100],math.random[100]}
--     }
-- end)
function utl_fam.create_n (family,num, funct)
    family:create_n(num,funct)
end

------------------
-- Applies a function to all elements. Works with Families or with subsets of families (Collections).
-- @function ask_ordered
-- @param elements A Family or a filtered Family to ask to do something.
-- @return  Nothing
-- @usage
-- ask(Nodes, function(node) 
--     if Node:xcor() > 4 then Node.color = {0,0,0,1} end
-- end)
-- @see Family.ask_ordered
function utl_fam.ask_ordered(elements, funct)
    if elements:is_a(Agent) then
        if elements.alive then
            funct(elements)
        end
    else
        for _,v in pairs(elements.agents)do
            if v.alive then
                funct(v)
            end
        end
    end
end

------------------
-- Applies an anonymous function to a Family of agents.
-- @function ask
-- @param fam A Family instance. Note that Collections are also Families.
-- @param funct Anonymous function that will be applied to the agents of the family.
-- @return Nothing
-- @usage
-- ask(A_family, function(ag) ag:fd(1.3) end)
-- @see Family.ask
function utl_fam.ask(fam, funct)
    if is_instance(fam,Agent) then
        funct(fam)
        return
    end
    fam:ask(funct)
end

------------------
-- It works same way as "ask", but this function applies the action only at n random selected elements of the family.
-- @function ask_n
-- @param n Number of agents to be asked.
-- @param fam Family where the agents will be asked..
-- @param funct Anonymous function that will be applied to the agents.
-- @return Nothing
-- @usage
-- ask_n(Agents, function(ag) ag:fd(2.1) end)
-- @see Family.ask_n
function utl_fam.ask_n(n,fam, funct)
    fam:ask_n(n,funct)
end

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
-- @see Family.clone_n
function utl_fam.clone_n(family, n,agent, funct)
    return family:clone_n(n,agent,funct)
end

------------------
-- This function delete from the system all agents marked as not alive (a value of false in its parameter 'alive'), it will also delete all the relational agents that involve a not-alive agent.
-- @function purge_agents
-- @param ... Undefined number of Families from where we want to purge agents. If no Family is passed, it purge all families in the system.
-- @return Nothing
-- @usage
-- purge_agents(Prays, Predators)
function utl_fam.purge_agents(...)
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
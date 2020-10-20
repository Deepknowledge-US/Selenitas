------------------
-- Utilities to apply actions to agents or families mainly.
-- @module
-- iterators

local sin       = math.sin
local cos       = math.cos
local rad       = math.rad

local utl_iterators = {}


------------------
-- This function is used by shuffled function, It creates a coroutine that returns a new shuffled element in a list everytime it is called..
-- @function __producer
-- @param a_list List of elements
-- @param index Integer, pointing the current element.
-- @return An element of the list
-- @see __consumer
function utl_iterators.__producer(a_list, index)
    return coroutine.create(
        function()
            local an_index = index - 1
            local j = math.random(an_index)
            a_list[an_index], a_list[j] = a_list[j], a_list[an_index]
            coroutine.yield(a_list[an_index], an_index)
        end
    )
end

------------------
-- This function ask to the producer for a new element everytime is called.
-- @function __consumer
-- @param a_list List of elements
-- @param index Integer, pointing the current element.
-- @return An element of the list
-- @see __producer
function utl_iterators.__consumer(a_list, an_index)
    local status, element, new_index = coroutine.resume(__producer(a_list, an_index))
    a_list[an_index] = nil

    if not element or not new_index or new_index < 1 then
        return nil
    else
        return new_index, element
    end
    -- return new_index, element

end

------------------
-- Auxiliar function used with merge_sort to compare two elements in an increasing order.
-- @function __comparator
-- @param a Element A parameter of an agent
-- @param b Element A parameter of an agent
-- @param funct A function to apply to a and b params
-- @return Boolean true if the result of apply the function to 'a' is less or equal to the result of apply the function to 'b'
function utl_iterators.__comparator(a,b,funct)
    if funct then
        if a == math.huge then
            return false
        elseif b == math.huge then
            return true
        else
            return funct(a) <= funct(b)
        end
    else
        return a <= b
    end
end

------------------
-- Auxiliar function used with merge_sort to compare two elements in an decreasing order.
-- @function __comparator_reverse
-- @param a Element A parameter of an agent
-- @param b Element A parameter of an agent
-- @param funct A function to apply to a and b params
-- @return Boolean true if the result of apply the function to 'a' is greater or equal to the result of apply the function to 'b'
function utl_iterators.__comparator_reverse(a,b,funct)
    if funct then
        if a == -math.huge then
            return false
        elseif b == -math.huge then
            return true
        else
            return funct(a) >= funct(b)
        end
    else
        return a >= b
    end
end

------------------
-- Iterator. It consist in Fisher-Yates permutations over a list. In each step, it returns a shuffled element of a list.
-- @function shuffled
-- @param fam_or_list A family or a List to be iterated
-- @return An element of the list
-- @usage
-- for _,agent in shuffled(Agents)do
--     print(agent.id)
-- end
-- @see ordered
-- @see sorted
function utl_iterators.shuffled(fam_or_list)
    local list
    if fam_or_list.agents then
        list = fam_to_list(fam_or_list)
    else
        list = list_copy(fam_or_list)
    end

    return __consumer, list, #list + 1
end

------------------
-- Iterator. Iterates over the elements of a list or a family. This is the cheapest iterator you can use with families if you do not need a random order.
-- @function ordered
-- @param fam_or_list A family or a List to be iterated
-- @return An element of the list
-- @usage
-- for _,agent in ordered(Agents)do
--     print(agent.id)
-- end
-- @see shuffled
-- @see sorted
function utl_iterators.ordered(fam_or_list)
    local list
    if fam_or_list.agents then
        list = fam_to_list(fam_or_list)
    else
        list = list_copy(fam_or_list)
    end

    return next, list
end

------------------
-- Iterator. First, this function checks if the users wants to order the elements by a parameter, if do not, we use the default order of the table to iterate over the items,
-- otherwise, this function sort the elements of a family or list and then it iterates over this sorted list.
-- @function sorted
-- @param fam_or_list A family or a List to be sorted and iterated
-- @param param String The name of a parameter of the agent
-- @param reverse Boolean. Optional parameter, if true, it will sort the list in reverse order
-- @param funct function. A function that takes a param of the agent (the one gived as parameter) and returns a numeric value, this numeric value will be used to sort the elements.
-- @return An element of the list
-- @usage
-- for _,agent in sorted(Agents,'id',true)do
--     print(agent.id)
-- end
-- @see shuffled
-- @see ordered
function utl_iterators.sorted(fam_or_list, param, reverse, funct)
    if param then

        local max_or_min, comparator, list

        if reverse == true then
            max_or_min    = -math.huge           
            comparator    = utl_iterators.__comparator_reverse
        else
            max_or_min    = math.huge
            comparator    = utl_iterators.__comparator
        end

        -- Check if we recive a family or a list or table
        if pcall(function() return fam_or_list:is_a(Family) end) then
            list = fam_to_list(fam_or_list)
        else
            list = list_copy(fam_or_list)
        end

        -- Check if we are working with agents or with numbers
        if param then
            utl_iterators.merge_sort_agents( list,1,#list,comparator,max_or_min, param, funct)
        else
            utl_iterators.merge_sort_numbers(list,1,#list,comparator,max_or_min)
        end

        return next, list

    else
        return utl_iterators.ordered(fam_or_list)
    end
end

function utl_iterators.merge_sort_agents(A, p, r, comparator, max_or_min, param, funct)
    -- return if only 1 element
    if p < r then
        local q = math.floor((p + r) / 2)
        utl_iterators.merge_sort_agents(A, p, q, comparator, max_or_min, param, funct)
        utl_iterators.merge_sort_agents(A, q + 1, r, comparator, max_or_min, param, funct)
        utl_iterators.merge_ag(A, p, q, r, comparator, max_or_min, param, funct)
    end
end

function utl_iterators.merge_ag(A, p, q, r,  comparator, max_or_min, param, funct)
    local n1 = q - p + 1
    local n2 = r - q
    local left = {}
    local right = {}

    for i = 1, n1 do
        left[i] = A[p + i - 1]
    end
    for i = 1, n2 do
        right[i] = A[q + i]
    end

    left[n1 + 1]  = {[param] = max_or_min}
    right[n2 + 1] = {[param] = max_or_min}

    local i = 1
    local j = 1
    for k = p, r do
        if comparator(left[i][param], right[j][param], funct) then
            A[k] = left[i]
            i = i + 1
        else
            A[k] = right[j]
            j = j + 1
        end
    end
end

function utl_iterators.merge_sort_numbers(A, p, r, comparator,max_or_min)
    -- return if only 1 element
    if p < r then
        local q = math.floor((p + r) / 2)
        utl_iterators.merge_sort_numbers(A, p, q, comparator,max_or_min)
        utl_iterators.merge_sort_numbers(A, q + 1, r, comparator,max_or_min)
        utl_iterators.merge_num(A, p, q, r, comparator, max_or_min)
    end
end

function utl_iterators.merge_num(A, p, q, r, comparator, max_or_min)
    local n1 = q - p + 1
    local n2 = r - q
    local left = {}
    local right = {}

    for i = 1, n1 do
        left[i] = A[p + i - 1]
    end
    for i = 1, n2 do
        right[i] = A[q + i]
    end

    left[n1 + 1]  = max_or_min
    right[n2 + 1] = max_or_min

    local i = 1
    local j = 1

    for k = p, r do
        if comparator(left[i], right[j]) then
            A[k] = left[i]
            i = i + 1
        else
            A[k] = right[j]
            j = j + 1
        end
    end
end

return utl_iterators
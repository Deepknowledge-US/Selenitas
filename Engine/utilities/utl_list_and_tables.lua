------------------
-- Utilities to operate over lists and tables
-- @module
-- list_and_tables


local utl_list = {}

------------------
-- It returns a list containing the agents of a family.
-- @function fam_to_list
-- @param fam A Family instance.
-- @return List
-- @usage
-- local list_of_agents = fam_to_list(Agents)
function utl_list.fam_to_list(fam)
    local res = {}
    for _,v in pairs(fam.agents)do
        table.insert(res,v)
    end
    return res
end

------------------
-- Returns a new list, copy of another list or a table.
-- @function list_copy
-- @param table_ List or Table to be copied.
-- @return List
-- @usage
-- local another_list = list_copy(list_or_table)
function utl_list.list_copy(table_)
    local res = {}
    for _,v in pairs(table_) do
        table.insert(res,v)
    end
    return res
end

------------------
-- Removes elements in a table by givin a nil value and moving to the last position of the list.
-- @function list_remove
-- @param list List to remove a single element.
-- @return List
-- @usage
-- list_remove({20,21,11,23,31}, 23) -- => {20,21,11,31}
function utl_list.list_remove(list,element)
    for i=#list,1, -1 do
        if list[i] == element then
            list[i],list[#list] = list[#list], list[i]
        end
    end
end

------------------
-- It removes from the list the element of a determined position, and permute this element with the last of the list, otherwise it returns 0.
-- @function list_remove_index
-- @param list The list from where remove the index
-- @return List
-- @usage
function utl_list.list_remove_index(list,index)
    list[index] = nil
    list[index], list[#list] = list[#list],list[#index]
end

------------------
-- It search for the index of an element in a list. If found it, it returns the index otherwise it returns -1.
-- @function list_index_of
-- @param list The list where we search for the element
-- @param element The element we are searching for.
-- @return Number
-- @usage
function utl_list.list_index_of(list,element)
    for i=1,#list do
        if list[i] == element then
            return i
        end
    end
    return -1
end

return utl_list
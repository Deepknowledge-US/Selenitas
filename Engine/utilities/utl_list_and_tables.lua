------------------
-- @module
-- list_and_tables


local utl_list = {}


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



return utl_list
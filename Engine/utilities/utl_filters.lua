------------------
-- @module
-- filters

local utl_filters = {}

------------------
-- It returns a random selectec element of a family or collection
-- @function one_of
-- @param family The family from which we will choose an agent.
-- @return An agent
-- @usage
-- local n1 = one_of(Nodes)
function utl_filters.one_of(family)
    local candidates = family.order
    local chosen = math.random(#candidates)
    return family.agents[ family.order[chosen] ]
end

------------------
-- Select n random elements in a Family, a Collection or a Table.
-- @function n_of
-- @param n Number, the number of agents we want.
-- @return f_c_t A Family, a Collection or a Table from where we will pick the agents.
-- @usage
-- local five_red_nodes = n_of( 5,
--    Nodes:with( function(node)
--        return node.color == {1,0,0,1}
--    end)
-- )
function utl_filters.n_of(n,f_c_t)

    local res, aux={},{}
    local elements = f_c_t.order

    if elements ~= nil then
        utl_filters.shuffle(elements)
        local n_ids = utl_filters.first_n(n,elements)
        for _,v in pairs(n_ids) do
            table.insert(res,f_c_t.agents[v])
        end
    else
        if n > #f_c_t / 2 then
            while #aux < # f_c_t - n do
                local chosen = f_c_t[ math.random(#elements)]
                if not utl_filters.member_of(chosen,aux) then
                    table.insert(aux,chosen)
                end
            end

            for _,v in pairs(elements) do 
                if not utl_filters.member_of(v,aux) then
                    table.insert(res,v)
                end
            end
        else
            while #res < n do
                local chosen = f_c_t[ math.random(#elements)]
                if not utl_filters.member_of(chosen,res) then
                    table.insert(res,chosen)
                end
            end
        end

    end

    return res
end

------------------
-- This function returns the first n elements of a List.
-- @function first_n
-- @param n Number, the number of elements we want.
-- @return A List of agents.
-- @usage
-- first_n(3, {1,2,3,4,5,6,7,8,9})
function utl_filters.first_n(n,list)
    local res = {}
    if n >= #list then
        return list
    else
        for i=1,n do
            res[i] = list[i]
        end
    end
    return res
end

------------------
-- This function returns the last n elements of a list
-- @function last_n
-- @param n Number, the number of elements we want.
-- @return A List of agents.
-- @usage
-- last_n(3, {1,2,3,4,5,6,7,8,9})
function utl_filters.last_n(n,list)
    local res = {}
    if n >= #list then
        return list
    else
        for i = #list-(n-1) , #list do
            res[#res+1] = list[i]
        end
    end
    return res
end


return utl_filters
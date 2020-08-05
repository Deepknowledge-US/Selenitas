

local utl_filters = {}


-- Caution!! this function returns a list containing a single element. This is necessary becouse "ask" function receives
-- a table as the first parameter to iterate on its elements.
function utl_filters.one_of(elements)
    if elements.order then
        local target = elements.order
        local chosen = math.random(#target)
        return {elements.agents[ elements.order[chosen] ]}
    else
        local target = elements
        local chosen = math.random(#target)
        return {elements[chosen]}
    end
end

-- Select n random elements in a collection or a table
function utl_filters.n_of(n,collection)

    local res, aux={},{}
    local elements = collection.order

    if elements ~= nil then
        utl_filters.shuffle(elements)
        local n_ids = utl_filters.first_n(n,elements)
        for _,v in pairs(n_ids) do
            table.insert(res,collection.agents[v])
        end
    else
        if n > #collection / 2 then
            while #aux < # collection - n do
                local chosen = collection[ math.random(#elements)]
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
                local chosen = collection[ math.random(#elements)]
                if not utl_filters.member_of(chosen,res) then
                    table.insert(res,chosen)
                end
            end
        end

    end

    return res
end




return utl_filters
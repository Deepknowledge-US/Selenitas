

local utl_filters = {}


-- It returns a random selectec element of a family or collection
function utl_filters.one_of(elements)
    local candidates = elements.order
    local chosen = math.random(#candidates)
    return elements.agents[ elements.order[chosen] ]
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


-- This function returns the first n elements of a list
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


-- This function returns the last n elements of a list
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
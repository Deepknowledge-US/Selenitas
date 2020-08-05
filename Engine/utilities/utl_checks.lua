

local utl_checks = {}



-- Given an item and a set of elements or a collection, decide if item is included in the set.
function utl_checks.member_of(item, elements)
    if elements.agents then
        if elements.agents[item.id] then return true end
    else
        for _,v in pairs(elements) do
            if v == item then return true end
        end
    end
    return false
end

return utl_checks
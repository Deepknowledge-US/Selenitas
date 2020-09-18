------------------
-- Utilities to apply actions to agents or families mainly.
-- @module
-- actions

local sin       = math.sin
local cos       = math.cos
local rad       = math.rad

local utl_iterators = {}

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

function utl_iterators.__consumer(a_list, an_index)
    local status, element, new_index = coroutine.resume(__producer(a_list, an_index))
    a_list[an_index] = nil

    if not element or not new_index or new_index < 1 then
        return nil
    else
        return new_index, element
    end

end

function utl_iterators.shuffled(fam_or_list)
    local list
    if fam_or_list.agents then
        list = fam_to_list(fam_or_list)
    else
        list = list_copy(fam_or_list)
    end

    return __consumer, list, #list + 1
end


function utl_iterators.ordered(fam_or_list)
    local list
    if fam_or_list.agents then
        list = fam_to_list(fam_or_list)
    else
        list = list_copy(fam_or_list)
    end

    return next, list
end


return utl_iterators
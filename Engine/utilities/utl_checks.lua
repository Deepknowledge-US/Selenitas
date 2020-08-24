------------------
-- @module
-- checks

local utl_checks = {}




------------------
-- Given an item and a set of elements or a collection, decide if item is included in the set.
-- @function is_in_list
-- @param item An Object (usually an agent).
-- @param elements List of elements.
-- @return Boolean, true if 'item' is present in 'elements'
-- @usage
-- local my_check = is_in_list( 2, {1,2,3,4})
-- print(my_check) -- => true
function utl_checks.is_in_list(item, elements)
    for _,v in pairs(elements) do
        if v == item then return true end
    end
    return false
end

------------------
-- Returns true if any agent in the family validates a predicate.
-- @function exists
-- @param pred An anonymous function (boolean predicate).
-- @return Boolean: True if there is at least one agent that validates the predicate. It also returns in second place an Agent validating the predicate.
-- @usage
-- local response = exists( A_family, function(x) x.label ~= '' end )
-- if response then
--     print('There is almost an agent with a non empty label')
-- end
-- @see Family.exists
function utl_checks.exists(family,pred)
    return family:exists(pred)
end

------------------
-- Checks if all agents in a family validates a condition.
-- @function all
-- @param family A family to check.
-- @param pred Anonymous function (boolean predicate).
-- @return Boolean. True if all agents in the family validate the condition.
-- @usage
-- all(A_family, function(ag) ag.label == '' end)
-- @see Family.all
function utl_checks.all(family,pred)
    return family:all(pred)
end

------------------
-- Checks if an agent is member of the family.
-- @function is_in
-- @param family A family to check.
-- @param agent The Agent instance we want to check.
-- @return Boolean. True if the agent is in the family
-- @usage
-- local my_boolean = is_in(A_family, agent)
-- @see Family.is_in
function utl_checks.is_in(family, agent)
    return family:is_in(agent)
end

------------------
-- A check function to compare colors.
-- @function same_rgb
-- @param object_1 It may be an Agent or a 4 parameters vector (rgba).
-- @param object_2 It may be an Agent or a 4 parameters vector (rgba).
-- @return Boolean, true if both colors have the same rgb components.
-- @usage
-- local check_color   = same_rgb(an_agent_instance, {1, 0.5, 0.5, 1} )
-- local check_color_2 = same_rgb(an_agent_instance, another_agent )
-- local check_color_3 = same_rgb( {1, 0.5, 0.5, 1}, {1, 1, 1, 1} )
function utl_checks.same_rgb(object_1, object_2)
    local color_1 = object_1.color ~= nil and object_1.color or object_1
    local color_2 = object_2.color ~= nil and object_2.color or object_2

    if #color_1 ~= 4 or #color_2 ~= 4 then
        return 'Error in same_rgb(). Color must be a 4 parameters vector'
    else
        for i=1,3 do
            if color_1[i] ~= color_2[i] then
                return false
            end
        end
        return true
    end
end

------------------
-- A check function to compare colors. This function compares also the alpha channel.
-- @function same_rgba
-- @param object_1 It may be an Agent or a 4 parameters vector (rgba).
-- @param object_2 It may be an Agent or a 4 parameters vector (rgba).
-- @return Boolean, true if both colors have the same rgba components.
-- @usage
-- local check_color   = same_rgba(an_agent_instance, {1, 0.5, 0.5, 1} )
-- local check_color_2 = same_rgba(an_agent_instance, another_agent )
-- local check_color_3 = same_rgba( {1, 0.5, 0.5, 1}, {1, 1, 1, 1} )
function utl_checks.same_rgba(object_1, object_2)
    local color_1 = object_1:is_a(Agent) and object_1.color or object_1
    local color_2 = object_2:is_a(Agent) and object_2.color or object_2

    if #color_1 ~= 4 or #color_1 ~= 4 then
        return 'Error in same_rgba(). Color must be a 4 parameters vector'
    else
        for i=1,4 do
            if color_1[i] ~= color_2[i] then
                return false
            end
        end
        return true
    end
end


return utl_checks
------------------
-- Some filter methods.
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
-- function utl_filters.one_of(family)
--     local candidates = family:keys()
--     local chosen = math.random(#candidates)
--     return family.agents[ candidates[chosen] ]
-- end
function utl_filters.one_of(fam_or_list)
    if pcall( function() return fam_or_list:is_a(Family) end ) then
        return fam_or_list:one_of()
    else
        return fam_or_list[ math.random(#fam_or_list) ]
    end
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
function utl_filters.n_of(n,family)
    return family:n_of(n)
end

------------------
-- Select n (or less if not enough agents) random elements in a Family.
-- @function up_to_n_of
-- @param n Number, the number of agents we want.
-- @return f_c_t A Family, a Collection or a Table from where we will pick the agents.
-- @usage
-- local five_red_nodes = n_of( 5,
--    Nodes:with( function(node)
--        return node.color == {1,0,0,1}
--    end)
-- )
function utl_filters.up_to_n_of(n,family)
    return family:up_to_n_of(n)
end

------------------
-- This function returns the first n elements of a List, or the entire list if not enough elements.
-- @function first_n
-- @param n Number, the number of elements we want.
-- @return A List of agents.
-- @usage
-- first_n(3, {1,2,3,4,5,6,7,8,9}) -- => {1,2,3}
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
-- @param list A List of elements.
-- @return A List of elements.
-- @usage
-- last_n(3, {1,2,3,4,5,6,7,8,9}) -- => {7,8,9}
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

------------------
-- Given a family and an agent, it returns all the other agents in the family.
-- @function others
-- @param family the target family.
-- @param agent An Agent instance.
-- @return A Collection containing all Agents of the Family except the agent gived as parameter.
-- @usage others(A_family, agent)
-- @see Family.others
function utl_filters.others (family, agent)
    return family:others(agent)
end

------------------
-- Filter function.
-- @function with
-- @param family the target family.
-- @param pred Anonymous function (boolean predicate)
-- @return Collection of agents in the family satisfying the predicate.
-- @usage
-- local lower_agents = with(Agents, function(ag) return ag:ycor() < 2 end )
-- @see Family.with
function utl_filters.with(family, pred)
    return family:with(pred)
end

------------------
-- Given an agent, it returns,randomly, one of the other agents in the family, or nil if there is no other agent.
-- @function one_of_others
-- @param family the target family.
-- @param agent is an Agent instance.
-- @return An Agent instance of the Family distinct of the agent gived as parameter.
-- @usage one_of_others(A_family, agent)
-- @see Family.one_of_others
function utl_filters.one_of_others(family, agent)
    return family:one_of_others(agent)
end

------------------
-- Returns the agent with the minimum value for a gived function 
-- @function max_one_of
-- @param family the target family.
-- @param funct An anonimous function that will be applied to the agents to searching for the maximum.
-- @return Agent.
-- @usage
-- local olderer_agent = max_one_of(A_family, function(agent) return agent.age end )
-- -- Assuming that all agents in "A_family" have a parameter "age"
-- @see Family.max_one_of
function utl_filters.max_one_of(family, funct)
    return family:max_one_of(funct)
end

------------------
-- Returns the n elements producing the maximum values for a gived function
-- @function max_n_of
-- @param family the target family.
-- @param num Number of agents we want
-- @param funct An anonimous function that will be applied to agents to compute the value
-- @return Collection.
-- @usage
-- local older_5_agents = max_n_of(A_family, 5, function(ag) return ag.age end)
-- @see Family.max_n_of
function utl_filters.max_n_of(family, num, funct)
    return family:max_n_of(num,funct)
end

------------------
-- Returns the n elements producing the minimum values for a gived function
-- @function min_n_of
-- @param family the target family.
-- @param num Number of agents we want
-- @param funct An anonimous function that will be applied to agents to compute the value
-- @return Collection of agents
-- @usage
-- local younger_5_agents = min_n_of(A_family, 5, function(ag) return ag.age end)
-- @see Family.min_n_of
function utl_filters.min_n_of(family, num,funct)
    return family:min_n_of(num,funct)
end

------------------
-- Returns the agent with the minimum value for a gived function 
-- @function min_one_of
-- @param family the target family.
-- @param funct An anonimous function that will be applied to the agents to searching for the minimum.
-- @return An Agent. The type of agent depends on the type of family that has called the method.
-- @usage
-- local younger_agent = min_one_of(A_family, function(agent) return agent.age end )
-- -- Assuming that all agents in "A_family" have a parameter "age"
-- @see Family.min_one_of
function utl_filters.min_one_of(family, funct)
    return family:min_one_of(funct)
end

------------------
-- Returns a Collection of agents with the min value for a gived function.
-- @function with_max
-- @param family the target family.
-- @param funct An anonymous function to calculate the value for each agent
-- @return Collection
-- @usage
-- local agents_in_the_right = with_max(A_family, function(agent) return agent:xcor() end )
-- @see Family.with_max
function utl_filters.with_max(family,funct)
    return family:with_max(funct)
end

------------------
-- Returns a Collection of agents with the min value for a gived function.
-- @function with_min
-- @param family the target family.
-- @param funct An anonymous function to calculate the value for each agent
-- @return Collection
-- @usage
-- local agents_in_the_left = with_min(A_family, function(agent) return agent:xcor() end )
-- @see Family.with_min
function utl_filters.with_min(family,funct)
    return family:with_min(funct)
end

------------------
-- Returns a Collection of agents who have a relation with the cell (usually the agents in the region of the cell).
-- @function agents_in
-- @param cell Cell instance.
-- @return Collection
-- @usage
-- ask( agents_in(a_cell), function(ag)
--     ag.label = a_cell.label
-- end)
function utl_filters.agents_in(cell)
    return cell.my_agents
end

------------------
-- Returns a List of families of a concrete type.
-- @function find_families
-- @param fam_type A Family type: FamilyCell, FamilyMobil, or FamilyRelational.
-- @usage 
-- cell_fams = find_families(FamilyCell)
function utl_filters.find_families (fam_type)
    local cell_fams, fams = {}, Config.__all_families
    for i=1,#fams do
        if fams[i]:is_a(fam_type) then
            table.insert(cell_fams,fams[i])
        end
    end
    return cell_fams
end

return utl_filters
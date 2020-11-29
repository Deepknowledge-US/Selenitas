------------------
-- Some methods to operate over families.
-- @module
-- agentset


local agent_set = {}



------------------
-- A function to do a Set difference.
-- @function difference
-- @return A collection with the difference of both AgentSets.
-- @usage new_collection = Nodes_1:difference(Nodes_2)
agent_set.difference = function(as1, as2)
    local res = Collection(as1)

    for _,ag in next, as1.agents do
        if as2.agents[ag.__id] == nil then
            res:add(ag)
        end
    end

    return res
end


------------------
-- A function to do a Set union.
-- @function union
-- @return The AgentSet that has called the method
-- @usage Nodes_1:union(Nodes_2)
agent_set.union = function(self, agent_set)
    res = Collection(self)

    for _,ag in next, self.agents do
        res:add(ag)
    end

    for _,ag in next, agent_set.agents do
        res:add(ag)
    end

    return res
end


------------------
-- A function to do a Set intersection.
-- @function intersection
-- @return A collection with the intersection of both AgentSets.
-- @usage new_collection = Nodes_1:intersection(Nodes_2)
agent_set.intersection = function(as1, as2)
    local res = Collection(self)

    local less, more

    if as1.count < as2.count then
        less, more = as1.agents, as2.agents
    else
        more, less = as1.agents, as2.agents
    end

    for _,ag in next, less do
        if more[ag.__id] then
            res:add(ag)
        end
    end

    return res

end





return agent_set
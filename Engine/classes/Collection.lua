------------------
-- Collections are auxiliar structures to generate subsets of the agents of a Family. They are instance of main class Family, so a Collection will have all methods of a Family to manipulate agents.
-- @classmod
-- Collection

local class  = require 'Thirdparty.pl.class'

local Collection = class.Collection(AgentSet)

------------------
-- Collection constructor. It is usually called by some Family methods. A Collection is a set of agents from a Family.
-- @function _init
-- @param family Is the reference to the Family that has created the Collection and is used to update some methods of the collection. It is also usefull when we need to know the main family of the agents in a collection.
-- @return A new instance of Collection.
Collection._init = function(self)
    self:super()
    self.agents     = {}
    self.count      = 0

    return self
end

------------------
-- This function overwrites the add method of the Family class. This add does not increment global number of agents.
-- @function add
-- @param object Is an instance of Agent which is member of any Family, this agent will be added to the Collection.
-- @return nothing
-- @usage Coll_instance:add(existing_agent)
Collection.add = function(self,object)
    local old_agent = object
    local not_new_id= old_agent.__id

    if not self.agents[not_new_id] then
        self.agents[not_new_id] = old_agent
        self.count = self.count + 1
    else
        -- print('Warning! Collection.add: Attemp to insert an already existing agent:', agent.__id, 'pos', agent:xcor(), agent:ycor())
    end
end

------------------
-- This function removes an element of the Collection by giving a value of nil to the reference of the object.
-- @function remove
-- @param agent
-- @return Nothing
-- @usage
-- A_collection:remove(agent)
Collection.remove = function(self, agent)
    if self.agents[agent.__id] then
        self.agents[agent.__id] = nil
        self.count = self.count - 1
    else
        -- print('Warning! Collection.remove: There is no agent in the collection with id:',agent.__id, 'pos', agent:xcor(), agent:ycor() )
    end
end


--===========================--
--       SETS FUNCTIONS      --
--===========================--


------------------
-- A function to do a Set union.
-- @function union
-- @return The AgentSet that has called the method
-- @usage Nodes_1:union(Nodes_2)
Collection.union = function(self, agent_set)

    for _,ag in next, agent_set.agents do
        if self.agents[ag.__id] == nil then
            self.agents[ag.__id] = ag
            if ag.__alive then
                self.count = self.count + 1
            else
                self:kill(self.agents[ag.__id])
            end
        end
    end

    return self
end


Collection.intersection = function(self, agent_set)

    for _,ag in next, self.agents do
        if agent_set.agents[ag.__id] == nil then
            self:remove(ag)
        end
    end

    return self
end



------------------
-- A function to do a Set difference.
-- @function difference
-- @return A collection with the difference of both AgentSets.
-- @usage new_collection = Nodes_1:difference(Nodes_2)
Collection.difference = function(self, agent_set)

    if self.count < agent_set.count then
        for _,ag in next, self.agents do
            if agent_set.agents[ag.__id] ~= nil then
                res:remove(ag)
            end
        end
    else
        for _,ag in next, agent_set.agents do
            self:remove(ag)
        end
    end

    return self

end


return Collection
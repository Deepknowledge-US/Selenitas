------------------
-- Collections are auxiliar structures to generate subsets of the agents of a Family. They are instance of main class Family, so a Collection will have all methods of a Family to manipulate agents.
-- @classmod
-- Collection

local class  = require 'Thirdparty.pl.class'
local Collection = class.Collection(Family)

------------------
-- Collection constructor. It is usually called by some Family methods. A Collection is a set of agents from a Family.
-- @function _init
-- @param family Is the reference to the Family that has created the Collection and is used to update some methods of the collection. It is also usefull when we need to know the main family of the agents in a collection.
-- @return A new instance of Collection.
Collection._init = function(self,family)
    self:super()
    self.agents     = {}
    self.order      = {}
    self.size       = 0
    self.family     = family
    self.create_n   = family.create_n
    self.with       = family.with

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
    local not_new_id= old_agent.id

    table.insert(self.order,not_new_id)

    self.agents[not_new_id] = old_agent
    self.size = self.size + 1
end

return Collection
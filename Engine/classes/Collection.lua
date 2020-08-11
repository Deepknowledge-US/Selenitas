local class  = require 'Thirdparty.pl.class'


local Collection = class.Collection(Family)
--[[
    A collection is a set of agents of a family, the family is gived as a parameter in the constructor and is used to update some methods of the collection, it is also usefull when we need to know the main family of the agents in a collection.
]]
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


-- This function overwrites the add method of the Family class. This add does not increment global number of agents.
Collection.add = function(self,object)

    local old_agent = object
    local not_new_id= old_agent.id

    table.insert(self.order,not_new_id)

    self.agents[not_new_id] = old_agent
    self.size = self.size + 1
end

return Collection
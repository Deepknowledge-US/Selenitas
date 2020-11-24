------------------
-- Family Class is the basis class from which we build the families of agents.
-- Families are the main structures of the system. It consists in a table of Agents, a list of ids and some methods to manipulate the agents.
-- self.agents is a table 'object_id: object' and we use it to find an element quickily.
--
-- @classmod
-- Family

local class = require "Thirdparty.pl.class"

local Family = class.Family(AgentSet)



--===========================--
--          ACTIONS          --
--===========================--

------------------
-- Family constructor.
-- @function _init
-- @return Family. A new instance of Family class.
-- @usage New_Instance = Family()
Family._init = function(self,name)
    self.name       = name or 'Collection'
    self:super(self.name)

    return self
end



return Family
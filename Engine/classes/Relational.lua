------------------
-- Relationals are agents used to create relations bettween two agents.
-- @classmod
-- Relational

local class  = require 'Thirdparty.pl.class'

local Rel = class.Relational(Agent)

------------------
-- When a Relational agent is created, some properties are given to it. There are two properties a Relational have to have: source agent and target agent, this determine the direction of the new link. An error message is returned if one of this field is missing.
-- This class is used by FamilyRelational to create new links betwen agents.
-- @function _init
-- @param obj A table with some properties to the new link.
-- @return A Relational instance.
-- @usage
-- Family_of_relationals:add(
--     Relational({
--         [source]=ag1,
--         [target]=ag2,
--         [weight]=3.2
--     })
-- )
Rel._init = function(self,obj)

    self:super()

    for k,v in pairs(obj) do
        self[k] = v
    end

    self.type       = obj.type        or 'standard'
    self.source     = obj.source      or {}
    self.target     = obj.target      or {}
    self.color      = obj.color       or {0.5, 0.5, 0.5, 1}
    self.label      = obj.label       or ''
    self.label_color= obj.label_color or {1,1,1,1}
    self.thickness  = obj.thickness   or 1
    self.shape      = obj.shape       or 'line'
    self.visible    = obj.visible     or false
    self.z_order    = obj.z_order     or 0
    return self
end;


return Rel
local class  = require 'Thirdparty.pl.class'

--[[
    When a Relational agent is created, some properties are given to it.
]]--

local Rel = class.Relational(Agent)
--[[
    When a new Link is created, some properties are given to it (If we do not have done it yet)
]]
Rel._init = function(self,o)

    self:super()

    for k,v in pairs(o) do
        self[k] = v
    end

    self.type       = o.type      or 'standard'
    self.source     = o.source    or {}
    self.target     = o.target    or {}
    self.color      = o.color     or {0.5, 0.5, 0.5, 1}
    self.label      = o.label     or ''
    self.label_color= o.color     or {1,1,1,1}
    self.thickness  = o.thickness or 1
    self.shape      = o.shape     or 'line'
    self.visible    = o.visible   or false
    self.z_order    = o.z_order   or 0
    return self
end;


return Rel
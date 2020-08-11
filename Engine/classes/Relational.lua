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
    local c   = o or {}
    self      = c
    self.type       = c.type      or 'standard'
    self.source     = c.source    or {}
    self.target     = c.target    or {}
    self.color      = c.color     or {0.5, 0.5, 0.5, 1}
    self.label      = c.label     or ''
    self.label_color= c.color     or {1,1,1,1}
    self.thickness  = c.thickness or 1
    self.shape      = c.shape     or 'line'
    self.visible    = c.visible   or false
    self.z_order    = c.z_order   or 0
    return self
end;


return Rel
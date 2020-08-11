local class = require 'Thirdparty.pl.class'
local Agent = require 'Engine.classes.Agent'


local Cell = class.Cell(Agent)


--[[
    When a new Cell is created, some properties are given to it (If we do not have done it yet)
]]--
Cell._init = function(self,o)
    self:super()
    local c         = o or {}
    self            = c
    self.pos        = c.pos         or {0,0,0}
    self.label      = c.label       or ''
    self.label_color= c.color       or {1,1,1,1}
    self.color      = c.color       or {0,0,0,1}
    self.shape      = c.shape       or 'square'
    self.region     = c.region      or {}
    self.neighbors  = c.neighbors   or {}
    self.visible    = c.visible     or true
    self.z_order    = c.z_order     or 0

    return self
end;


Cell.xcor = function(self)
    return self.pos[1]
end

Cell.ycor = function(self)
    return self.pos[2]
end

Cell.zcor = function(self)
    return self.pos[3]
end

return Cell
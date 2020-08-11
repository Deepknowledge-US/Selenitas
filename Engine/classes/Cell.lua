local class = require 'Thirdparty.pl.class'
local Agent = require 'Engine.classes.Agent'


local Cell = class.Cell(Agent)


--[[
    When a new Cell is created, some properties are given to it (If we do not have done it yet)
]]--
Cell._init = function(self,o)

    self:super()

    for k,v in pairs(o) do
        self[k] = v
    end

    self.pos        = o.pos         or {0,0,0}
    self.label      = o.label       or ''
    self.label_color= o.color       or {1,1,1,1}
    self.color      = o.color       or {0,0,0,1}
    self.shape      = o.shape       or 'square'
    self.region     = o.region      or {}
    self.neighbors  = o.neighbors   or {}
    self.visible    = o.visible     or true
    self.z_order    = o.z_order     or 0

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
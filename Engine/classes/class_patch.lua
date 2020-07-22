local class  = require 'pl.class'

local Patch = class.Patch{

    _init = function(self,o)
        local c     = o or {}
        self        = c
        self.xcor   = c.xcor or 0
        self.ycor   = c.ycor or 0
        self.label  = c.label or ''
        self.color  = c.color or 'black'
        self.shape  = c.xcor or 'square'
        return self
    end

}



return Patch
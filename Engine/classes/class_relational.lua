local class  = require 'pl.class'

local Relational = class.Relational{

    _init = function(self,o)
        local c   = o or {}
        self      = c
        self.end1 = c.end1 or {}
        self.end2 = c.end2 or {}
        return self
    end

}



return Relational
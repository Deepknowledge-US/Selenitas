local class  = require 'pl.class'

-- Creation example:
-- local agent_1 = Agent({})
-- local agent_2 = Agent({ ['xcor'] = 1000, ['ycor'] = 1 })

local Agent = class.Agent {
    _init = function(self,o)
        local c     = o or {}
        self        = c
        self.xcor   = c.xcor or 0
        self.ycor   = c.ycor or 0
        self.head   = c.head or 0
        self.shape  = c.shape or 'triangle'
        self.color  = c.color or 'yellow'

        return self
    end;
}


return Agent
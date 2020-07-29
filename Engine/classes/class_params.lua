local class  = require 'pl.class'

-- Creation example:
-- local agent_1 = Agent({})
-- local agent_2 = Agent({ ['xcor'] = 1000, ['ycor'] = 1 })

local Params = class.Params {
    _init = function(self,o)
        local c     = o or {}
        self        = c
        self.ticks  = c.ticks or 0
        self.xcor   = c.xsize or 0
        self.ycor   = c.ysize or 0

        return self
    end;

    create_boolean = function(name)
    end;

    create_slider = function(name, min, max)
    end;

    create_input = function(name)
    end;
}


return Params
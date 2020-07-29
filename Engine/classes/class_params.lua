local class  = require 'pl.class'

-- This class allows users to create elements in interface

local Params = class.Params {
    _init = function(self,o)
        local c     = o or {}
        self        = c
        self.ticks  = c.ticks or 0
        self.xcor   = c.xsize or 0
        self.ycor   = c.ysize or 0
        self.ui_settings = {}
        return self
    end;

    create_boolean = function(name, value)
        self[name] = value
        self.ui_settings[name] = {type = "boolean"}
    end;

    create_slider = function(name, min, max, step, value)
        self[name] = value
        self.ui_settings[name] = { type = "slider", min = min, max = max, step = step}
    end;

    create_input = function(name, value)
        self[name] = value
        self.ui_settings[name] = { type = "input" }
    end;
}


return Params
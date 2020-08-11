local class  = require 'Thirdparty.pl.class'

-- This class allows users to create elements in interface

local Params = class.Params {
    _init = function(self,o)
        local c           = o or {}
        self              = c
        self.ticks        = c.ticks or 0
        self.xsize        = c.xsize or 0
        self.ysize        = c.ysize or 0
        self.__num_agents = 0
        self.ui_settings  = {}
        return self
    end;

    __new_id = function(self)
        self.__num_agents = self.__num_agents + 1
        return self.__num_agents
    end;

    create_boolean = function(self, name, value)
        self[name] = value
        self.ui_settings[name] = {type = "boolean"}
    end;

    create_slider = function(self, name, min, max, step, value)
        self[name] = value
        self.ui_settings[name] = { type = "slider", min = min, max = max, step = step}
    end;

    create_input = function(self, name, value)
        self[name] = value
        self.ui_settings[name] = { type = "input" }
    end;
}


return Params
------------------
-- A class to control the configuration settings of the system.
-- @classmod
-- Params

local class  = require 'Thirdparty.pl.class'

local Params = class.Params()

------------------
-- One of the first things we do when creating a new file is to create an instance of this class.
-- This instance (called Config by default) holds some parameters to determine some aspects of the world.
-- This class allows users to create elements in interface
-- @function _init
-- @param obj A table with some parameters of the initial configuration.
-- @return A Params instance.
-- @usage
-- Config = Params({
--     ['ticks'] = 200,
--     ['xsize'] = 15,
--     ['ysize'] = 15
-- })
Params._init = function(self,obj)
    local c           = obj or {}
    self              = c
    self.ticks        = c.ticks or 0
    self.xsize        = c.xsize or 0
    self.ysize        = c.ysize or 0
    self.__num_agents = 0
    self.ui_settings  = {}
    return self
end;

Params.__new_id = function(self)
    self.__num_agents = self.__num_agents + 1
    return self.__num_agents
end;

------------------
-- Allows the user to create a new boolean field
-- @function create_boolean
-- @param name The name of the new field
-- @param value The default value of the new field
-- @return Nothing
-- @usage
-- -- TODO
Params.create_boolean = function(self, name, value)
    self[name] = value
    self.ui_settings[name] = {type = "boolean"}
end;

------------------
-- Allows the user to create a new slider field
-- @function create_slider
-- @param name The name of the new field
-- @param min The minim value of the new field
-- @param max The maxim value of the new field
-- @param step The step bettween possible values
-- @param value The default value of the new field
-- @return Nothing
-- @usage
-- -- TODO
Params.create_slider = function(self, name, min, max, step, value)
    self[name] = value
    self.ui_settings[name] = { type = "slider", min = min, max = max, step = step}
end;

------------------
-- Allows the user to create a new input field
-- @function create_input
-- @param name The name of the new field
-- @param value The default value of the new field
-- @return Nothing
-- @usage
-- -- TODO
Params.create_input = function(self, name, value)
    self[name] = value
    self.ui_settings[name] = { type = "input" }
end;


return Params
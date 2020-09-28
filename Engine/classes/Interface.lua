------------------
-- A class to control some parameters of the interface. By using this class the user can create inputs or plots
-- @classmod
-- Interface

local class  = require 'Thirdparty.pl.class'

local Interface = class.Simulation()


------------------
-- TODO
-- @function _init
-- @param obj A table with some basic parameters of the Controller.
-- @return A Controller instance.
Interface._init = function(self)
    self.ui_settings    = {}
    return self
end;


--=========--
-- Getters --
--=========--
------------------
-- TODO
-- @function get_value
-- @param name String, the name of an Interface parameter.
-- @return The current value of the parameter.
-- @usage
-- Interface:create_slider('Num_nodes', 0, 50, 1, 10)
-- -- After the slider is created, we can get its value:
-- local a_number = Interface:get_value('num_nodes')
Interface.get_value = function(self,name)
    return self[name]
end


--=========================--
-- Create inputs functions --
--=========================--

------------------
-- Allows the user to create a new boolean field
-- @function create_boolean
-- @param name The name of the new field
-- @param value The default value of the new field
-- @return Nothing
-- @usage
-- -- TODO
Interface.create_boolean = function(self, name, value)
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
Interface.create_slider = function(self, name, min, max, step, value)
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
Interface.create_input = function(self, name, value)
    self[name] = value
    self.ui_settings[name] = { type = "input" }
end;


return Interface
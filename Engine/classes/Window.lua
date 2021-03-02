------------------
-- A class to content some parameters related with the Interface as sliders or input.
-- @classmod
-- Window

local class  = require 'Thirdparty.pl.class'

local Window = class.Window()

------------------
-- This function is used to create a new parameters window to be used in the interface.
-- @function _init
-- @param a_table A table with some basic parameters of the Window (title, width, height, x, y).
-- @return A Window instance.
Window._init = function(self, a_table)

    self.title       = a_table.title
    self.width       = a_table.width or 200
    self.height      = a_table.height or 200
    self.x           = a_table.x or (10 + 205 * Interface.num_windows)
    self.y           = a_table.y or 100
    self.ui_settings = {}
    self.order       = {}
    self.num_items   = 0

    return self
end;




--=========--
-- Getters --
--=========--
------------------
-- This function is used to obtain the value of a parameter.
-- @function get_value
-- @param name String, the name of an Interface parameter.
-- @return The current value of the parameter.
-- @usage
-- Interface:create_slider('Num_nodes', 0, 50, 1, 10)
-- -- After the slider is created, we can get its value:
-- local a_number = Interface:get_value('num_nodes')
-- @see Interface.get_value
Window.get_value = function(self,name)
    return self[name]
end



Window.__new_item = function(self, name)
    self.num_items = self.num_items + 1
    self.order[self.num_items] = name
end

------------------
-- Allows the user to create a new boolean field
-- @function create_boolean
-- @param name The name of the new field
-- @param value The default value of the new field
-- @return Nothing
-- @usage
-- -- It is not recomended to use the methods of this class. You must use the Interface method to do this.
-- @see Interface.create_boolean
Window.create_boolean = function(self, name, value)
    self[name] = value
    self.ui_settings[name] = {type = "boolean"}
    self:__new_item(name)
end;

------------------
-- Allows the user to create a new monitor field
-- @function create_monitor
-- @param name The name of the field
-- @return Nothing
-- @usage
-- -- It is not recomended to use the methods of this class. You must use the Interface method to do this.
-- @see Interface.create_boolean
Window.create_monitor = function(self, name)
    self.ui_settings[name] = {type = "monitor"}
    self:__new_item(name)
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
-- Interface:create_slider('Num_nodes', 0, 50, 1, 10)
Window.create_slider = function(self, name, min, max, step, value)
    self[name]             = value
    self.ui_settings[name] = { type = "slider", min = min, max = max, step = step}
    self:__new_item(name)
end;

------------------
-- Allows the user to create a new input field
-- @function create_input
-- @param name The name of the new field
-- @param value The default value of the new field
-- @return Nothing
-- @usage
-- Interface:create_input('text', 'hello')
-- print( Interface:get_value('text') )
-- --> hello
Window.create_input = function(self, name, value)
    self[name] = value
    self.ui_settings[name] = { type = "input" }
    self:__new_item(name)
end;



return Window
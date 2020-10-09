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
    self.windows  = {}
    self.num_windows = 0
    return self
end;

Interface.create_window = function(self, a_table)
    local new_window = Window(a_table)
    self.windows[a_table['title']] = new_window
    self.num_windows = self.num_windows + 1
end

Interface.get_window_value = function(self, window_name, param_name )
    return self.windows[window_name]:get_value(param_name)
end

Interface.create_boolean = function(self, window_name, new_boolean_name, def_value)
    self.windows[window_name]:create_boolean(new_boolean_name, def_value)
end;

------------------
-- Allows the user to create a new slider field
-- @function create_slider
-- @param window_name The name of the window where the slider will be created
-- @param slider_name The name of the new field
-- @param min The minim value of the new field
-- @param max The maxim value of the new field
-- @param step The step bettween possible values
-- @param value The default value of the new field
-- @return Nothing
-- @usage
-- -- TODO
Interface.create_slider = function(self, window_name, slider_name, min, max, step, value)
    self.windows[window_name]:create_slider(slider_name, min, max, step, value)
end;

------------------
-- Allows the user to create a new input field
-- @function create_input
-- @param name The name of the new field
-- @param value The default value of the new field
-- @return Nothing
-- @usage
-- -- TODO
Interface.create_input = function(self, window_name, input_name, value)
    self.windows[window_name]:create_input(input_name, value)
end;




Interface.clear = function(self)
    self.windows = {} -- key: window name (Parameters: default window), value: table with widgets
end



return Interface



-- ------------------
-- -- A class to control some parameters of the interface. By using this class the user can create inputs or plots
-- -- @classmod
-- -- Interface

-- local class  = require 'Thirdparty.pl.class'

-- local Interface = class.Simulation()


-- ------------------
-- -- TODO
-- -- @function _init
-- -- @param obj A table with some basic parameters of the Controller.
-- -- @return A Controller instance.
-- Interface._init = function(self)
--     self.ui_settings    = {Parameters = {}} -- key: window name (Parameters: default window), value: table with widgets
--     self.values         = {Parameters = {}}
--     return self
-- end;


-- --=========--
-- -- Getters --
-- --=========--
-- ------------------
-- -- TODO
-- -- @function get_value
-- -- @param name String, the name of an Interface parameter.
-- -- @param window_name String, name of the window to add the widget. If nil, widget will be added to default window.
-- -- @return The current value of the parameter.
-- -- @usage
-- -- Interface:create_slider('Num_nodes', 0, 50, 1, 10)
-- -- -- After the slider is created, we can get its value:
-- -- local a_number = Interface:get_value('num_nodes')
-- Interface.get_value = function(self,name,window_name)
--     local target = window_name or "Parameters"
--     if self.values[target] == nil then
--         return nil
--     end
--     return self.values[target][name]
-- end


-- --=========================--
-- -- Create inputs functions --
-- --=========================--

-- ------------------
-- -- Allows the user to create a new boolean field
-- -- @function create_boolean
-- -- @param name The name of the new field
-- -- @param value The default value of the new field
-- -- @param window_name String, name of the window to add the widget. If nil, widget will be added to default window.
-- -- @return Nothing
-- -- @usage
-- -- -- TODO
-- Interface.create_boolean = function(self, name, value, window_name)
--     local target = window_name or "Parameters"
--     if not self.values[target] then
--         self.values[target] = {}
--         self.ui_settings[target] = {}
--     end
--     self.values[target][name] = value
--     self.ui_settings[target][name] = {type = "boolean"}
-- end;

-- ------------------
-- -- Allows the user to create a new slider field
-- -- @function create_slider
-- -- @param name The name of the new field
-- -- @param min The minim value of the new field
-- -- @param max The maxim value of the new field
-- -- @param step The step bettween possible values
-- -- @param value The default value of the new field
-- -- @param window_name String, name of the window to add the widget. If nil, widget will be added to default window.
-- -- @return Nothing
-- -- @usage
-- -- -- TODO
-- Interface.create_slider = function(self, name, min, max, step, value, window_name)
--     local target = window_name or "Parameters"
--     if not self.values[target] then
--         self.values[target] = {}
--         self.ui_settings[target] = {}
--     end
--     self.values[target][name] = value
--     self.ui_settings[target][name] = { type = "slider", min = min, max = max, step = step}
-- end;

-- ------------------
-- -- Allows the user to create a new input field
-- -- @function create_input
-- -- @param name The name of the new field
-- -- @param value The default value of the new field
-- -- @param window_name String, name of the window to add the widget. If nil, widget will be added to default window.
-- -- @return Nothing
-- -- @usage
-- -- -- TODO
-- Interface.create_input = function(self, name, value, window_name)
--     local target = window_name or "Parameters"
--     if not self.values[target] then
--         self.values[target] = {}
--         self.ui_settings[target] = {}
--     end
--     self.values[target][name] = value
--     self.ui_settings[target][name] = { type = "input" }
-- end;

-- ------------------
-- -- Clears all windows
-- -- @function clear
-- -- @return Nothing
-- -- @usage
-- -- -- TODO
-- Interface.clear = function(self)
--     self.ui_settings    = {Parameters = {}} -- key: window name (Parameters: default window), value: table with widgets
--     self.values         = {Parameters = {}}
-- end


-- return Interface
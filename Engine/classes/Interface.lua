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

    self.family_mobile_windows = {}
    self.family_cell_windows = {}
    self.family_rel_windows = {}

    self.num_family_windows = 0

    return self
end;


------------------
-- This function creates a new information window in the Interface instance for a FamilyMobile type Family. It is used by internal methods to automatize the creation of the information windows.
-- @function create_family_mobile_window
-- @param a_table. This parameter could be a string with the NAME OF AN EXISTING FAMILY or an Optional table with the properties of the table, in this last case, the table HAVE TO contain a 'title' param with the name of the family.
-- @return Nothing
-- @usage
-- Used by internal functions
Interface.create_family_mobile_window = function(self, a_table)
    if not self.family_mobile_windows[a_table['title']] then
        local new_window = WindowFamilyInfo(a_table)
        self.family_mobile_windows[a_table['title']] = new_window
        self.num_family_windows = self.num_family_windows + 1
    end

end

------------------
-- This function creates a new information window in the Interface instance for a FamilyCell type Family. It is used by internal methods to automatize the creation of the information windows.
-- @function create_family_mobile_window
-- @param a_table. This parameter could be a string with the NAME OF AN EXISTING FAMILY or an Optional table with the properties of the table, in this last case, the table HAVE TO contain a 'title' param with the name of the family.
-- @return Nothing
-- @usage
-- Used by internal functions
Interface.create_family_cell_window = function(self, a_table)
    if not self.family_cell_windows[a_table['title']] then
        local new_window = WindowFamilyInfo(a_table) -- Crear la clase
        self.family_cell_windows[a_table['title']] = new_window
        self.num_family_windows = self.num_family_windows + 1
    end
end

------------------
-- This function creates a new information window in the Interface instance for a FamilyRelational type Family. It is used by internal methods to automatize the creation of the information windows.
-- @function create_family_mobile_window
-- @param a_table. This parameter could be a string with the NAME OF AN EXISTING FAMILY or an Optional table with the properties of the table, in this last case, the table HAVE TO contain a 'title' param with the name of the family.
-- @return Nothing
-- @usage
-- Used by internal functions
Interface.create_family_rel_window = function(self, a_table)
    if not self.family_rel_windows[a_table['title']] then
        local new_window = WindowFamilyInfo(a_table) -- Crear la clase
        self.family_rel_windows[a_table['title']] = new_window
        self.num_family_windows = self.num_family_windows + 1
    end
end



------------------
-- This function creates a new window in the Interface instance
-- @function create_window
-- @param wname, The name of the new window.
-- @param optional_table. An optiopnal to define the width, the height, the x offset, and the y offset of the new window
-- @return Nothing
-- @usage
-- Interface:create_window('my_window')
-- 
-- -- And with the table:
-- Interface:create_window('my_window', {
--    ['width'] = 130,
--    ['height'] = 250,
--    ['x'] = 100,
--    ['y'] = 100,
-- })
Interface.create_window = function(self, name, optional_table)
    local final_table = optional_table or {}
    final_table['title'] = name

    local new_window = Window(final_table)

    self.windows[name] = new_window
    self.num_windows = self.num_windows + 1
end


------------------
-- Allows the user to get the value of a Interface parameter
-- @function get_value
-- @param window_name Optional string, The name of the window where the input will be created. If not gived as parameter, the default window will be used
-- @param param_name The name of the param we are searching for
-- @return Nothing
-- @usage
-- -- Default window option:
-- Interface:get_value('param_name')
--
-- -- Custom window option:
-- Interface:get_value('window_name', 'param_name')
Interface.get_value = function(self, window_name, param_name)
    local window = param_name and window_name or 'Parameters'
    local param = param_name or window_name

    return self.windows[window]:get_value(param)
end


------------------
-- Allows the user to create a new boolean field
-- @function create_boolean
-- @param window_name Optional string, The name of the window where the input will be created. If not gived as parameter, the default window will be used
-- @param new_boolean_name The name of the new field
-- @param def_value The default value of the new field
-- @return Nothing
-- @usage
-- -- Default window option:
-- Interface:create_boolean('my boolean', true)
--
-- -- Custom window option:
-- Interface:create_window('window_name') -- We need to create the window first
-- Interface:create_slider('window_name', 'my boolean', true)
Interface.create_boolean = function(self, window_name, new_boolean_name, def_value)
    if next(self.windows) == nil then
        self:create_window('Parameters')
    end
    if def_value then -- If there is no def_value, the user has not used the window_name parameter, so all inputs must be moved one position
        self.windows[window_name]:create_boolean(new_boolean_name, def_value)
    else
        self.windows['Parameters']:create_boolean(window_name, new_boolean_name)
    end
end;

------------------
-- Allows the user to create a new slider field
-- @function create_slider
-- @param window_name Optional String. The name of the window where the slider will be created, if no window_name is used, the slider will be created in the default window
-- @param slider_name The name of the new field
-- @param min The minim value of the new field
-- @param max The maxim value of the new field
-- @param step The step bettween possible values
-- @param value The default value of the new field
-- @return Nothing
-- @usage
-- -- Default window option:
-- Interface:create_slider('my slider', 0, 100, 1, 50)
-- -- Custom window option:
-- Interface:create_window('window_name')
-- Interface:create_slider('window_name', 'my slider', 0, 100, 1, 50)
--
Interface.create_slider = function(self, window_name, slider_name, min, max, step, value)
    if next(self.windows) == nil then -- If there is no windows, we use a default window
        self:create_window('Parameters')
    end
    if value then -- If we have received 6 params, the user has used a custom window name
        self.windows[window_name]:create_slider(slider_name, min, max, step, value)
    else
        local sl_name, mn, mx, stp, val = window_name, slider_name, min, max, step
        self.windows['Parameters']:create_slider(sl_name, mn, mx, stp, val)
    end
end;

------------------
-- Allows the user to create a new input field
-- @function create_input
-- @param window_name Optional string, The name of the window where the input will be created. If not gived as parameter, the default window will be used
-- @param input_name The name of the new field
-- @param value The default value of the new field
-- @return Nothing
-- @usage
-- -- Default window option:
-- Interface:create_input('my input', 'a_text')
--
-- -- Custom window option:
-- Interface:create_window('window_name')
-- Interface:create_slider('window_name', 'my input', 'a_text')
Interface.create_input = function(self, window_name, input_name, value)
    if next(self.windows) == nil then
        self:create_window('Parameters')
    end
    if value then
        self.windows[window_name]:create_input(input_name, value)
    else
        self.windows['Parameters']:create_input(window_name, input_name)
    end
end;




------------------
-- This function resets the parameters of the interface to its default values. It is used most of the time when we load a new model.
-- @function clear
-- @return Nothing
-- @usage
-- Interface:clear()
-- @see Simulation.clear
Interface.clear = function(self)
    self.windows = {} -- key: window name (Parameters: default window), value: table with widgets

    self.family_mobile_windows = {}
    self.family_cell_windows = {}
    self.family_rel_windows = {}

    self.num_windows = 0
    self.num_family_windows = 0
end



return Interface
------------------
-- A class to control the view of the simulation.
-- @classmod
-- Observer

local class = require 'Thirdparty.pl.class'
local utf8  = require "Thirdparty.utf8.init"
utf8:init()

local Observer = class.Observer()

------------------
-- TODO
-- @function _init
-- @param obj A table with some basic parameters of the Controller.
-- @return A Controller instance.
Observer._init = function(self)
    self.center = {0,0}
    self.zoom   = 1
    return self
end;

--=========--
-- Setters --
--=========--

------------------
-- Sets the center of the camera in a concrete point.
-- @function set_center
-- @return Nothing.
-- @usage
-- Observer:set_center({1,1})
Observer.set_center = function(self,vector)
    for i=1,#vector do
        self.center[i] = vector[i]
    end
end

------------------
-- Sets the zoom of the camera in a concrete value.
-- @function set_zoom
-- @return Nothing.
-- @usage
-- Observer:set_zoom(10)
Observer.set_zoom = function(self,number)
    self.zoom = number
end



--=========--
-- Getters --
--=========--

------------------
-- A function to know the current center of the camera.
-- @function get_center
-- @return Table. A position vector.
-- @usage
-- local center = Observer:get_center()
Observer.get_center = function(self)
    return self.center
end

------------------
-- A function to know the current zoom of the camera.
-- @function get_zoom
-- @return Number. The value of the separation between two consecutive lines of the Interface grid.
-- @usage
-- local zoom = Observer:get_zoom()
Observer.get_zoom = function(self)
    return self.zoom
end

local codes = {
    ['-'] = utf8.char(8315),
    ['0'] = utf8.char(8304),
    ['1'] = utf8.char(185),
    ['2'] = utf8.char(178),
    ['3'] = utf8.char(179),
    ['4'] = utf8.char(8308),
    ['5'] = utf8.char(8309),
    ['6'] = utf8.char(8310),
    ['7'] = utf8.char(8311),
    ['8'] = utf8.char(8312),
    ['9'] = utf8.char(8313)
}

Observer.get_zoom_string = function(self)
    local res = self.zoom >= 0 and '' or '' .. utf8.char(8315)
    local num = self.zoom >= 0 and self.zoom or self.zoom * -1
    local str_num = tostring(num)
    for i = 1, #str_num do
        local c = str_num:sub(i,i)
        res = res .. codes[c]
    end

    return '1:10' .. res
end


return Observer
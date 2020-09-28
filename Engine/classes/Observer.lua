------------------
-- A class to control the view of the simulation.
-- @classmod
-- Observer

local class  = require 'Thirdparty.pl.class'

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
-- TODO.
-- @function set_center
-- @return .
-- @usage
-- -- TODO
Observer.set_center = function(self,vector)
    for i=1,#vector do
        self.center[i] = vector[i]
    end
end

------------------
-- TODO.
-- @function set_zoom
-- @return .
-- @usage
-- -- TODO
Observer.set_zoom = function(self,number)
    self.zoom = number
end



--=========--
-- Getters --
--=========--

------------------
-- TODO.
-- @function get_center
-- @return .
-- @usage
-- -- TODO
Observer.get_center = function(self)
    return self.center
end

------------------
-- TODO.
-- @function get_zoom
-- @return .
-- @usage
-- -- TODO
Observer.get_zoom = function(self)
    return self.zoom
end



return Observer
------------------
-- Class for handling input events and callbacks.
-- @module
-- input

local Input = {}

-- Callback functions for scroll and mouse movement events
local scroll_callback_funcs = {}
local mouse_moved_callback_funcs = {}

------------------
-- Gets pressed state for the specified key
-- @function is_key_pressed
-- @param key key to check. Keys available listed at: https://love2d.org/wiki/KeyConstant
-- @return status Whether the key is pressed
function Input.is_key_pressed(key)
    return love.keyboard.isDown(key)
end

------------------
-- Gets pressed state for the specified mouse button
-- @function is_mouse_button_pressed
-- @param key_id mouse button to check. 1 is the primary mouse button, 2 is the secondary mouse button 
-- and 3 is the middle button. Further buttons are mouse dependant.
-- @return status Whether the mouse button is pressed
function Input.is_mouse_button_pressed(key_id)
    return love.mouse.isDown(key_id)
end

------------------
-- Gets mouse position
-- @function get_mouse_position
-- @return x The position of the mouse along the x-axis.
-- @return y The position of the mouse along the y-axis.
function Input.get_mouse_position()
    return love.mouse.getPosition()
end

------------------
-- Add callback function for mouse scroll event
-- @function add_scroll_callback_func
-- @param f callback function to add
function Input.add_scroll_callback_func(f)
    table.insert(scroll_callback_funcs, f)
end

------------------
-- Add callback function for mouse movement event
-- @function add_mouse_moved_callback_func
-- @param f callback function to add
function Input.add_mouse_moved_callback_func(f)
    table.insert(mouse_moved_callback_funcs, f)
end

-- Run callbacks for wheel movement event
function love.wheelmoved(dx, dy)
    for _, f in ipairs(scroll_callback_funcs) do
        f(dx, dy)
    end
end

-- Run callbacks for mouse movement event
function love.mousemoved(x, y, dx, dy, istouch)
    for _, f in ipairs(mouse_moved_callback_funcs) do
        f(x, y, dx, dy) -- ignoring istouch for now, only useful for touchscreens
    end
end

return Input
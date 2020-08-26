local scroll_callback_funcs = {}
local mouse_moved_callback_funcs = {}


local function is_key_pressed(key)
    return love.keyboard.isDown(key)
end

local function is_mouse_button_pressed(key_id)
    return love.mouse.isDown(key_id)
end

local function get_mouse_position()
    return love.mouse.getPosition()
end

local function add_scroll_callback_func(f)
    table.insert(scroll_callback_funcs, f)
end

local function add_mouse_moved_callback_func(f)
    table.insert(mouse_moved_callback_funcs, f)
end

function love.wheelmoved(dx, dy)
    -- Run callbacks
    for _, f in ipairs(scroll_callback_funcs) do
        f(dx, dy)
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    -- Run callbacks
    for _, f in ipairs(mouse_moved_callback_funcs) do
        f(x, y, dx, dy) -- ignoring istouch for now, only useful for touchscreens
    end
end

-- Public functions
Input = {
    is_key_pressed = is_key_pressed,
    is_mouse_button_pressed = is_mouse_button_pressed,
    add_scroll_callback_func = add_scroll_callback_func,
    get_mouse_position = get_mouse_position,
    add_mouse_moved_callback_func = add_mouse_moved_callback_func
}

return Input
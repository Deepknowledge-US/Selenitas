local Slab = require "Thirdparty.Slab.Slab"

-- Simulation info
local agents = nil
local setup_func = nil
local step_func = nil
local simulation_params = nil
local initialized = false
local go = false

-- Time handling
local time_between_steps = 0
local _time_acc = 0

-- Drawing params
local coord_scale = 1 -- coordinate scaling for better visualization
local ui_width = 152 -- width in pixels of UI column
local ui_height = 400 -- height of UI column

local function init()
    -- TODO: read user settings
    -- The engine is explictly initialized to avoid running 
    -- LOVE loop since startup
    initialized = true
    love.window.setTitle("Selenitas")
    Slab.Initialize({})
end

local function update_ui(dt)
    -- Re-draw UI in each step
    Slab.Update(dt)

    -- Create panel for UI with fixed size
    Slab.BeginWindow("Simulation", {
        Title = "Simulation",
        X = 2,
        Y = 2,
        W = ui_width,
        H = ui_height,
        AllowMove = false,
        AutoSizeWindow = false,
        AllowResize = false
    })
    -- Layout to horizontally expand all controls
    Slab.BeginLayout("Layout", {
        ExpandW = true
    })
    if Slab.Button("Setup") then
        if setup_func then
            agents = setup_func()
        end
        go = false
    end

     -- Show "step" button
     if Slab.Button("Step") then
        if step_func then
            step_func()
        end
    end

    -- Change "go" button label if it's already running
    local go_button_label = go and "Stop" or "Go"
    if Slab.Button(go_button_label) then
        go = not go
    end

    -- Parse simulation params
    for k, v in pairs(simulation_params.ui_settings) do
        -- Checkbox
        if v.type == "boolean" then
            Slab.Text(k, {Color = {0.258, 0.529, 0.956}})
            if Slab.CheckBox(simulation_params[k], "Enabled") then
                simulation_params[k] = not simulation_params[k]
            end
        -- Slider
        elseif v.type == "slider" then
            Slab.Text(k, {Color = {0.258, 0.529, 0.956}})
            -- TODO: parse step
            if Slab.InputNumberSlider(k .. "Slider", simulation_params[k], v.min + 0.0000001, v.max, {}) then
                simulation_params[k] = Slab.GetInputNumber()
            end
        -- Number input
        elseif v.type == "input" then
            Slab.Text(k, {Color = {0.258, 0.529, 0.956}})
            if Slab.InputNumberDrag(k .. "InputNumber", simulation_params[k], nil, nil, {}) then
                simulation_params[k] = Slab.GetInputNumber()
            end
        -- Radio buttons
        elseif v.type == "enum" then
            Slab.Text(k, {Color = {0.258, 0.529, 0.956}})
            for i, e in ipairs(v.options) do
                if Slab.RadioButton(e, {Index = i, SelectedIndex = simulation_params[k]}) then
                    simulation_params[k] = i
                end
            end
        else
            print("UI Control of type \"" .. v.type .. "\" is not recognized.")
        end
    end
    Slab.EndLayout()
    Slab.EndWindow()
end

-- Sets setup function. Called from the simulation main file
local function set_setup_function(f)
    setup_func = f
end

-- Sets step function. Called from the simulation file
local function set_step_function(f)
    step_func = f
end

-- Sets time between steps in seconds for better visualization
local function set_time_between_steps(t)
    time_between_steps = t
end

-- Expected input:
-- An object of type Params. It includes an UI setting table like this:
-- {
--    "param_1_name" : {type = "boolean"},
--    "param_2_name" : {type = "slider", min = minval, max = maxval, step = step},
--    "param_3_name" : {type = "enum", options = {enum_val_1, enum_val_2, enum_val_3}},
--    "param_4_name" : {type = "input"}
--}
local function set_simulation_params(p)
    simulation_params = p
end

-- Sets viewport size, using as minimum prefixed UI size
local function set_viewport_size(w, h)
    love.window.setMode(math.max(ui_width, w), math.max(ui_height, h), {})
end

-- Sets world dimensions, taking into account coordinate scale factor
local function set_world_dimensions(x, y)
    set_viewport_size(ui_width + (x * coord_scale), y * coord_scale)
end

-- Coordinate scale factor. Useful for using small spaces in simulations
-- and scaling the space only during visualization
local function set_coordinate_scale(f)
    coord_scale = f
end

-- Sets background color in RGB [0..1] format
local function set_background_color(r, g, b)
    love.graphics.setBackgroundColor(r, g, b)
end

-- Gets RGB in [0..1] format from predefined color strings
local function get_rgb_color(p_color_str)
    if p_color_str == "red" then
        return {1, 0, 0, 1}
    elseif p_color_str == "green" then
        return {0, 1, 0, 1}
    elseif p_color_str == "blue" then
        return {0, 0, 1, 1}
    elseif p_color_str == "green" then
        return {0, 1, 0, 1}
    elseif p_color_str == "yellow" then
        return {1, 1, 0, 1}
    elseif p_color_str == "cyan" then
        return {0, 1, 1, 1}
    elseif p_color_str == "magenta" then
        return {1, 0, 1, 1}
    elseif p_color_str == "pink" then
        return {1, 0.41, 0.7, 1}
    elseif p_color_str == "black" then
        return {0, 0, 0, 1}
    else
        -- Default to white
        return {1, 1, 1, 1}
    end
end

-- Main update function
function love.update(dt)
    update_ui(dt)

    if not initialized then
        do return end
    end
    -- Skips until time between steps is covered
    _time_acc = _time_acc + dt
    if _time_acc < time_between_steps then
        do return end
    end
    _time_acc = 0

    if step_func and go then
        step_func()
    end
end

-- Drawing function
function love.draw()
    -- Draw UI
    Slab.Draw()

    if (not initialized) or (not agents) then
        do return end
    end

    -- Draw agents
    for _, a in pairs(agents) do
        love.graphics.setColor(get_rgb_color(a.color))
        -- Agent coordinate is scaled and shifted in its x coordinate
        -- to account for UI column
        local x = (a:xcor() * coord_scale) + ui_width
        local y = a:ycor() * coord_scale
        if a.shape == "triangle" then
            love.graphics.polygon("fill",
                x, y - 5,
                x + 5, y + 5,
                x - 5, y + 5
            )
        elseif a.shape == "rectangle" then
            love.graphics.polygon("fill",
                x - 5, y - 5,
                x + 5, y - 5,
                x + 5, y + 5,
                x - 5, y + 5
            )
        else
            -- Default to circle
            love.graphics.circle("fill", x, y, 5)
        end
    end
end

-- Public functions
GraphicEngine = {
    init = init,
    set_world_dimensions = set_world_dimensions,
    set_background_color = set_background_color,
    set_coordinate_scale = set_coordinate_scale,
    set_setup_function = set_setup_function,
    set_step_function = set_step_function,
    set_simulation_params = set_simulation_params,
    set_time_between_steps = set_time_between_steps
}

return GraphicEngine
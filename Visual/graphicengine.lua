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
    initialized = true
    love.window.setTitle("Selenitas")
    Slab.Initialize({})
end

local function update_ui(dt)
    Slab.Update(dt)

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
    Slab.BeginLayout("Layout", {
        ExpandW = true
    })
    if Slab.Button("Setup") then
        if setup_func then
            agents = setup_func()
        end
        go = false
    end
    local go_button_label = go and "Stop" or "Go"
    if Slab.Button(go_button_label) then
        go = not go
    end
    -- Parse simulation params
    for k, v in pairs(simulation_params.ui_settings) do
        if v.type == "boolean" then
            Slab.Text(k, {Color = {0.258, 0.529, 0.956}})
            if Slab.CheckBox(simulation_params[k], "Enabled") then
                simulation_params[k] = not simulation_params[k]
            end
        elseif v.type == "slider" then
            Slab.Text(k, {Color = {0.258, 0.529, 0.956}})
            -- TODO: parse step
            if Slab.InputNumberSlider(k .. "Slider", simulation_params[k], v.min + 0.0000001, v.max, {}) then
                simulation_params[k] = Slab.GetInputNumber()
            end
        elseif v.type == "input" then
            Slab.Text(k, {Color = {0.258, 0.529, 0.956}})
            if Slab.InputNumberDrag(k .. "InputNumber", simulation_params[k], nil, nil, {}) then
                simulation_params[k] = Slab.GetInputNumber()
            end
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

local function set_agents(p_agents)
    agents = p_agents
end

local function set_setup_function(f)
    setup_func = f
end

local function set_step_function(f)
    step_func = f
end

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

local function set_viewport_size(w, h)
    love.window.setMode(math.max(ui_width, w), math.max(ui_height, h), {})
end

local function set_world_dimensions(x, y)
    set_viewport_size(ui_width + (x * coord_scale), y * coord_scale)
end

local function set_coordinate_scale(f)
    coord_scale = f
end

local function set_background_color(r, g, b)
    love.graphics.setBackgroundColor(r, g, b)
end

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

function love.draw()
    -- Draw UI
    Slab.Draw()

    if (not initialized) or (not agents) then
        do return end
    end

    for _, a in pairs(agents) do
        love.graphics.setColor(get_rgb_color(a.color))
        local x = (a.xcor * coord_scale) + ui_width
        local y = a.ycor * coord_scale
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

GraphicEngine = {
    init = init,
    set_agents = set_agents,
    set_world_dimensions = set_world_dimensions,
    set_background_color = set_background_color,
    set_coordinate_scale = set_coordinate_scale,
    set_setup_function = set_setup_function,
    set_step_function = set_step_function,
    set_simulation_params = set_simulation_params,
    set_time_between_steps = set_time_between_steps
}

return GraphicEngine
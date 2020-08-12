local Slab = require "Thirdparty.Slab.Slab"
local ResourceManager = require("Thirdparty.cargo.cargo").init("Resources")

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
local menu_bar_width = 20 -- approximate width of horizontal menu bar

-- File handling
local file_loaded_path = nil
local show_file_picker = false

local function init()
    -- TODO: read user settings
    -- The engine is explictly initialized to avoid running
    -- LOVE loop since startup
    love.window.setTitle("Selenitas")
    initialized = true
end

local function _reset()
    -- Simulation info
    agents = nil
    setup_func = nil
    step_func = nil
    simulation_params = nil
    initialized = false
    go = false
end

local function load_simulation_file(file_path)
    _reset()
    file_loaded_path = file_path
    dofile(file_loaded_path)
end

local function update_ui(dt)
    -- Re-draw UI in each step
    Slab.Update(dt)

    -- Build menu bar
    if Slab.BeginMainMenuBar() then
        -- "File" section
        if Slab.BeginMenu("File") then
            if Slab.MenuItem("Load file...") then
                show_file_picker = true
            end
            -- Show "Reload file" option if file was loaded
            if file_loaded_path then
                if Slab.MenuItem("Reload file") then
                    load_simulation_file(file_loaded_path)
                end
            end
            Slab.Separator()
            if Slab.MenuItem("Quit") then
                love.event.quit()
            end
            Slab.EndMenu()
        end
        Slab.EndMenuBar()
    end

    -- Show file picker if Selected
    if show_file_picker then
        local result = Slab.FileDialog({Type = 'openfile', AllowMultiSelect = false})
        if result.Button ~= "" then
            show_file_picker = false
            if result.Button == "OK" then
                -- Load selected file
                load_simulation_file(result.Files[1])
            end
        end
    end

    -- Create panel for UI with fixed size
    Slab.BeginWindow("Simulation", {
        Title = "Simulation",
        X = 2,
        Y = menu_bar_width,
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
    if simulation_params then
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

-- LOVE2D load function
function love.load()
    Slab.Initialize({})
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
        if not a.visible then
            goto continue
        end

        love.graphics.setColor(a.color)
        -- Agent coordinate is scaled and shifted in its x coordinate
        -- to account for UI column
        local x = (a:xcor() * coord_scale) + ui_width
        local y = a:ycor() * coord_scale + menu_bar_width

        -- Base resources are 100x100 px, using 10x10 px as base scale (0.1 factor)
        if a.shape == "triangle" then
            love.graphics.draw(ResourceManager.images.triangle, x, y, 0, 0.1 * a.scale)
        elseif a.shape == "square" then
            love.graphics.draw(ResourceManager.images.rectangle, x, y, 0, 0.1 * a.scale)
        else
            -- Default to circle
            love.graphics.draw(ResourceManager.images.circle, x, y, 0, 0.1 * a.scale)
        end

        ::continue::
    end
end

-- Public functions
GraphicEngine = {
    init = init,
    load_simulation_file = load_simulation_file,
    set_world_dimensions = set_world_dimensions,
    set_background_color = set_background_color,
    set_coordinate_scale = set_coordinate_scale,
    set_setup_function = set_setup_function,
    set_step_function = set_step_function,
    set_simulation_params = set_simulation_params,
    set_time_between_steps = set_time_between_steps
}

return GraphicEngine
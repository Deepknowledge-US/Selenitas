------------------
-- Graphic Engine used to visualize implemented simulations.
-- @module
-- graphicengine

local Slab = require "Thirdparty.Slab.Slab"
local ResourceManager = require("Thirdparty.cargo.cargo").init("Resources")
local FileUtils = require("Visual.fileutils")
local Camera = require("Thirdparty.brady.camera")
local Input = require("Visual.input")

-- Simulation info
local agents = nil
local links = nil
local cells = nil
local setup_func = nil
local step_func = nil
local simulation_params = nil
local initialized = false
local go = false

-- Time handling
local time_between_steps = 0
local _time_acc = 0

-- File handling
local file_loaded_path = nil
local show_file_picker = false

-- Drawing & UI params
local coord_scale = 1 -- coordinate scaling for better visualization
local ui_width = 152 -- width in pixels of UI column
local ui_height = 400 -- height of UI column
local menu_bar_width = 20 -- approximate width of horizontal menu bar
local show_about_dialog = false
local camera = nil
-- Callbacks for Input, registered in `init` function
local drag_camera_callback_func = function(x, y, dx, dy)
    if Input.is_mouse_button_pressed(2) then
        camera:translate(dx, dy)
    end
end
local zoom_camera_callback_func = function(dx, dy)
    camera:scaleToPoint(1 + dy / 10)
end


------------------
-- inits the graphic engine using the configurations specified.
-- @function init
local function init()
    -- TODO: read user settings

    -- Window title
    love.window.setTitle("Selenitas")

    -- Default font size for labels
    love.graphics.setNewFont(7)

    -- Set up camera
    local w, h, _ = love.window.getMode()
    camera = Camera(w, h, {translationX = w / 2, translationY = h / 2, resizable = true, maintainAspectRatio = true})

    -- Input callbacks
    Input.add_mouse_moved_callback_func(drag_camera_callback_func)
    Input.add_scroll_callback_func(zoom_camera_callback_func)

    initialized = true
end

local function _reset()
    -- Simulation info
    agents = nil
    links = nil
    cells = nil
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

-- List of files in "examples" resource folder
local function list_examples()
    local ret = {}
    for i, f in ipairs(love.filesystem.getDirectoryItems("Resources/examples")) do
        local name = string.gsub(f, ".lua", "")
        table.insert(ret, name)
    end
    return ret
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

            -- Show "Edit loaded file" option if file was loaded
            if file_loaded_path then
                if Slab.MenuItem("Edit loaded file") then
                    FileUtils.open_in_editor(file_loaded_path)
                end
            end

            -- "Load example" submenu
            if Slab.BeginMenu("Load example") then
                for _,e in ipairs(list_examples()) do
                    if Slab.MenuItem(e) then
                        -- Create save directory if it doesn't exist
                        if not FileUtils.exists(love.filesystem.getSaveDirectory() .. "/files") then
                            love.filesystem.createDirectory("files")
                        end
                        -- Copy file to save directory
                        local src = "Resources/examples/" .. e .. ".lua"
                        local dst = "files/" .. e .. ".lua" -- contained in Save directory
                        FileUtils.copy_to_save_dir(src, dst)
                        file_loaded_path =
                            love.filesystem.getSaveDirectory() .. "/" .. dst
                        -- Reset variables and run example
                        -- (just calling it is enough for it to be run because of how 'cargo' library loads it)
                        _reset()
                        _ = ResourceManager.examples[e]
                    end
                end
                Slab.EndMenu()
            end

            Slab.Separator()

            -- Quit button
            if Slab.MenuItem("Quit") then
                love.event.quit()
            end

            Slab.EndMenu()
        end

        if Slab.BeginMenu("View") then
            if Slab.MenuItem("Reset camera") then
                local w, h, _ = love.window.getMode()
                camera:setTranslation(w / 2, h / 2)
                camera:setScale(1)
            end
            Slab.EndMenu()
        end

        -- "Help" section
        if Slab.BeginMenu("Help") then

            if Slab.MenuItem("Selenitas User Manual") then
                love.system.openURL("https://github.com/fsancho/Selenitas/wiki")
            end

            if Slab.MenuItem("Report issue") then
                love.system.openURL("https://github.com/fsancho/Selenitas/issues")
            end

            Slab.Separator()

            if Slab.MenuItem("About...") then
                show_about_dialog = true
            end

            Slab.EndMenu()
        end

        Slab.EndMenuBar()
    end

    -- Show file picker if selected
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

    -- Show about dialog if selected
    if show_about_dialog then
        Slab.OpenDialog("About")
        Slab.BeginDialog("About", {Title = "About"})
        Slab.BeginLayout("AboutLayout", {AlignX = "center"})
        Slab.Text("Selenitas (alpha)")
        Slab.NewLine()
        Slab.Text("Webpage: ")
        Slab.SameLine()
        Slab.Text("https://github.com/fsancho/Selenitas", {URL = "https://github.com/fsancho/Selenitas"})
        Slab.NewLine()
        if Slab.Button("OK") then
            show_about_dialog = false
            Slab.CloseDialog()
        end
        Slab.EndLayout()
        Slab.EndDialog()
    end

    -- Create panel for UI with fixed size
    Slab.BeginWindow("Simulation", {
        Title = "Simulation",
        X = 2,
        Y = menu_bar_width,
        W = ui_width - 2,
        H = ui_height,
        AllowMove = false,
        AutoSizeWindow = false,
        AllowResize = false
    })
    -- Layout to horizontally expand all controls
    Slab.BeginLayout("Layout", {
        ExpandW = true
    })
    if Slab.Button("Setup", {Disabled = file_loaded_path == nil}) then
        if setup_func then
            setup_func()
            -- Get agents and links lists
            for k, f in ipairs(simulation_params.__all_families) do
                if f:is_a(FamilyMobil) then
                    agents = f.agents -- f.agents is a "Mobil" collection
                elseif f:is_a(FamilyRelational) then
                    links = f.agents -- f.agents is a "Relational" collection
                elseif f:is_a(FamilyCell) then
                    cells = f.agents -- f.agents is a "Cell" collection
                end
            end
        end
        go = false -- Reset 'go' in case Setup button is pressed more than once
    end

     -- Show "step" button
     if Slab.Button("Step", {Disabled = agents == nil}) then
        if step_func then
            step_func()
        end
    end

    -- Change "go" button label if it's already running
    local go_button_label = go and "Stop" or "Go"
    if Slab.Button(go_button_label, {Disabled = agents == nil}) then
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

------------------
-- Sets setup function.
-- @function set_setup_function
-- @param f Setup function.
local function set_setup_function(f)
    setup_func = f
end

------------------
-- Sets step function.
-- @function set_step_function
-- @param f Step function.
local function set_step_function(f)
    step_func = f
end

------------------
-- Sets time between steps in seconds for better visualization
-- @function set_time_between_steps
-- @param t time in seconds.
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

------------------
-- Sets simulation parameters that can be exposed via the UI.
-- The parameters exposed can then be modified using UI controls automatically created by the graphic engine.
-- @function set_simulation_params
-- @param p simulation parameters object. Check the Params class of the simulations engine for more information.
local function set_simulation_params(p)
    simulation_params = p
end

-- Sets viewport size, using as minimum prefixed UI size
local function set_viewport_size(w, h)
    love.window.setMode(math.max(ui_width, w), math.max(ui_height, h), {})
end

------------------
-- Sets world space in 2D, using pixels as unit. 
-- For using different units, provide an scale using the set_coordinate_scale before calling this function.
-- @function set_world_dimensions
-- @param x the width of the space.
-- @param y the height of the space.
local function set_world_dimensions(x, y)
    set_viewport_size(ui_width + (x * coord_scale), menu_bar_width + (y * coord_scale))
end

------------------
-- Allows scaling the world space for using units different to pixels.
-- Must be called before setting the world dimensions. This scale also affects agents' positions.
-- @param f Scaling factor. Must be a positive number.
local function set_coordinate_scale(f)
    coord_scale = f
end

------------------
-- Sets the world background color in RGB format. If this is not called, the background color will be black.
-- @param r Red channel of the color. Must be in the 0..1 range.
-- @param g Green channel of the color. Must be in the 0..1 range.
-- @param b Blue channel of the color. Must be in the 0..1 range.
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

    camera:update()
end

-- Drawing function
function love.draw()
    if (not initialized) or (not agents) then
        goto skip
    end

    camera:push()

    -- Draw cells
    for _, c in pairs(cells or {}) do
        if not c.visible then
            goto continuecells
        end

        -- Handle cell color
        love.graphics.setColor(c.color)

        local x = (c:xcor() * coord_scale) + ui_width
        local y = (c:ycor() * coord_scale) + menu_bar_width
        if c.shape == "square" then
            -- Squares are assumed to be 1x1
            -- Each square is 4 lines
            local top_left = {x - (0.5 * coord_scale), y - (0.5 * coord_scale)}
            local top_right = {x + (0.5 * coord_scale), y - (0.5 * coord_scale)}
            local bottom_left = {x - (0.5 * coord_scale), y + (0.5 * coord_scale)}
            local bottom_right = {x + (0.5 * coord_scale), y + (0.5 * coord_scale)}
            love.graphics.line(top_left[1], top_left[2], top_right[1], top_right[2]) -- Top line
            love.graphics.line(top_left[1], top_left[2], bottom_left[1], bottom_left[2]) -- Left line
            love.graphics.line(bottom_left[1], bottom_left[2], bottom_right[1], bottom_right[2]) -- Bottom line
            love.graphics.line(top_right[1], top_right[2], bottom_right[1], bottom_right[2]) -- Right line
        end

        -- Draw label
        love.graphics.setColor(c.label_color)
        love.graphics.printf(c.label, x - 45, y, 100, 'center')

        ::continuecells::
    end

    -- Draw links
    for _, l in pairs(links or {}) do
        -- Handle link visibility
        if not l.visible then
            goto continuelinks
        end
        -- Handle link color
        love.graphics.setColor(l.color)
        -- Link thickness
        love.graphics.setLineWidth(l.thickness)
        -- Agent coordinate is scaled and shifted in its x coordinate
        -- to account for UI column
        local sx = (l.source:xcor() * coord_scale) + ui_width
        local sy = (l.source:ycor() * coord_scale) + menu_bar_width
        local tx = (l.target:xcor() * coord_scale) + ui_width
        local ty = (l.target:ycor() * coord_scale) + menu_bar_width
        -- Draw line
        love.graphics.line(sx, sy, tx, ty)
        -- Draw label
        love.graphics.setColor(l.label_color)
        local dirx = tx - sx
        local diry = ty - sy
        local midx = sx + dirx * 0.5
        local midy = sy + diry * 0.5
        love.graphics.printf(l.label, midx - 45, midy, 100, 'center')
        ::continuelinks::
    end

    -- Draw agents
    for _, a in pairs(agents) do

        -- Handle agent visibility
        if not a.visible then
            goto continueagents
        end

        -- Handle agent color
        love.graphics.setColor(a.color)

        -- Agent coordinate is scaled and shifted in its x coordinate
        -- to account for UI column
        local x = (a:xcor() * coord_scale) + ui_width
        local y = (a:ycor() * coord_scale) + menu_bar_width

        -- Handle agent shape and scale (TODO: rotation)
        -- Base resources are 100x100 px, using 10x10 px as base scale (0.1 factor)
        local center_shift = 50 * 0.1 * a.scale -- pixels to shift to center the figure
        if a.shape == "triangle" then
            love.graphics.draw(ResourceManager.images.triangle, x - center_shift, y - center_shift, 0, 0.1 * a.scale)
        elseif a.shape == "square" then
            love.graphics.draw(ResourceManager.images.rectangle, x - center_shift, y - center_shift, 0, 0.1 * a.scale)
        else
            -- Default to circle
            love.graphics.draw(ResourceManager.images.circle, x - center_shift, y - center_shift, 0, 0.1 * a.scale)
        end

        -- Handle agent label
        love.graphics.setColor(a.label_color)
        love.graphics.printf(a.label, x - 45, y + 10, 100, 'center')

        ::continueagents::
    end

    camera:pop()

    ::skip::
    -- Draw UI
    Slab.Draw()
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
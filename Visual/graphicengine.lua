------------------
-- Graphic Engine used to visualize implemented simulations.
-- @module
-- graphicengine

local Slab = require "Thirdparty.Slab.Slab"
local ResourceManager = require("Thirdparty.cargo.cargo").init("Resources")
local FileUtils = require("Visual.fileutils")
local Camera = require("Thirdparty.brady.camera")
local Input = require("Visual.input")

require 'Engine.utilities.utl_main'

-- Simulation info
local agents_families = {}
local links_families = {}
local cells_families = {}
local initialized = false
local setup_func_executed = false
local go = false

-- Time handling
local time_between_steps = 0.2
local _time_acc = 0

-- File handling
local file_loaded_path = nil
local show_file_picker = false
local load_file_error_msg = nil

-- Drawing & UI params
local coord_scale = 16 -- coordinate scaling for better visualization
local show_about_dialog = false
local show_params_window = false
local camera = nil
-- Callbacks for Input, registered in `init` function
local drag_camera_callback_func = function(x, y, dx, dy)
    if Input.is_mouse_button_pressed(2) then
        camera:translate(-dx / (camera.scale * 2), -dy / (camera.scale * 2))
    end
end
local zoom_camera_callback_func = function(dx, dy)
    local inc = 1 + dy / 50
    camera:scaleToPoint(inc)
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
    agents_families = {}
    links_families = {}
    cells_families = {}
    initialized = false
    setup_func_executed = false
    go = false
    -- Reset Config properties that depend on the loaded file
    Config.__all_families = {}
    Config.ui_settings = {}
end

local function load_simulation_file(file_path)
    _reset()
    file_loaded_path = file_path
    local r, e = loadfile(file_loaded_path)
    if r then
        r()
        init() -- Re-init graphic engine with settings specified in loaded file
        local sim_name = string.gsub(FileUtils.get_filename_from_path(file_loaded_path), ".lua", "")
        love.window.setTitle("Selenitas - " .. sim_name)
        if next(Config.ui_settings) ~= nil then
            -- Loaded simulation has params, show params window
            show_params_window = true
        end
    else
        load_file_error_msg = e
    end
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

            if Slab.MenuItem("Show parameters window") then
                show_params_window = true
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

    -- Show load file error if it happened
    if load_file_error_msg ~= nil then
        local res = Slab.MessageBox("Load file error", "An error occurred loading the selected file:\n " .. load_file_error_msg)
        if res ~= "" then
            load_file_error_msg = nil
        end
    end

    -- Get screen width
    local screen_w, _, _ = love.window.getMode()

    -- Create toolbar with main controls
    Slab.BeginWindow("Toolbar", {
        Title = "", -- No title means it shows no title border and is not movable
        X = 0,
        Y = 15,
        W = screen_w,
        H = 35,
        AutoSizeWindow = false,
        AllowResize = false
    })

    Slab.Separator()

    Slab.BeginLayout("ToolbarLayout", {
        AlignY = 'center',
        AlignRowY = 'center'
    })

    -- Setup button
    if Slab.Button("Setup", {Disabled = file_loaded_path == nil}) then
        if SETUP then
            Config.__all_families = {}
            agents_families = {}
            links_families = {}
            cells_families = {}
            SETUP()
            -- Get agents and links lists
            for k, f in ipairs(Config.__all_families) do
                if f:is_a(FamilyMobil) then
                    table.insert(agents_families, f.agents) -- f.agents is a "Mobil" collection
                elseif f:is_a(FamilyRelational) then
                    table.insert(links_families, f.agents) -- f.agents is a "Relational" collection
                elseif f:is_a(FamilyCell) then
                    table.insert(cells_families, f.agents) -- f.agents is a "Cell" collection
                end
            end
            setup_func_executed = true
        end
        go = false -- Reset 'go' in case Setup button is pressed more than once
    end

    Slab.SameLine()

    -- Step button
    if Slab.Button("Step", {Disabled = not setup_func_executed}) then
        if RUN then
            RUN()
        end
    end

    Slab.SameLine()

    -- Go button
    local go_button_label = go and "Stop" or "Go" -- Change "go" button label if it's already running
    if Slab.Button(go_button_label, {Disabled = not setup_func_executed}) then
        go = not go
    end

    Slab.SameLine()

    if Slab.Button("Reload", {Disabled = file_loaded_path == nil}) then
        load_simulation_file(file_loaded_path)
    end

    Slab.SameLine()

    -- "Time between steps" slider
    Slab.Text(" Delta T: ", {})
    Slab.SameLine()
    if Slab.InputNumberSlider("tbs_slider", time_between_steps, 0.0, 1.0 + 0.00000001, {}) then
        time_between_steps = Slab.GetInputNumber()
    end

    Slab.EndLayout()

    Slab.EndWindow()

    -- Create panel for simulation params
    show_params_window = Slab.BeginWindow("Simulation", {
        Title = "Simulation parameters",
        X = 10,
        Y = 100,
        W = 200,
        ContentW = 200,
        AutoSizeWindow = false,
        AllowResize = true,
        IsOpen = show_params_window,
        NoSavedSettings = true
    })

    -- Layout to horizontally expand all controls
    Slab.BeginLayout("Layout", {
        ExpandW = true
    })

    -- Parse simulation params
    -- Config object taken from 'utl_main'
    for k, v in pairs(Config.ui_settings) do
        -- Checkbox
        if v.type == "boolean" then
            Slab.Text(k, {Color = {0.258, 0.529, 0.956}})
            if Slab.CheckBox(Config[k], "Enabled") then
                Config[k] = not Config[k]
            end
        -- Slider
        elseif v.type == "slider" then
            Slab.Text(k, {Color = {0.258, 0.529, 0.956}})
            if Slab.InputNumberSlider(k .. "Slider", Config[k], v.min, v.max + 0.0000001, {Step = v.step}) then
                Config[k] = Slab.GetInputNumber()
            end
        -- Number input
        elseif v.type == "input" then
            Slab.Text(k, {Color = {0.258, 0.529, 0.956}})
            if Slab.InputNumberDrag(k .. "InputNumber", Config[k], nil, nil, {}) then
                Config[k] = Slab.GetInputNumber()
            end
        -- Radio buttons
        elseif v.type == "enum" then
            Slab.Text(k, {Color = {0.258, 0.529, 0.956}})
            for i, e in ipairs(v.options) do
                if Slab.RadioButton(e, {Index = i, SelectedIndex = Config[k]}) then
                    Config[k] = i
                end
            end
        else
            print("UI Control of type \"" .. v.type .. "\" is not recognized.")
        end
    end
    Slab.EndLayout()
    Slab.EndWindow()
end

------------------
-- Sets time between steps in seconds for better visualization
-- @function set_time_between_steps
-- @param t time in seconds.
local function set_time_between_steps(t)
    time_between_steps = t
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

    if RUN and go then
        RUN()
    end

    camera:update()
end

-- Drawing function
function love.draw()
    if (not initialized) or (not setup_func_executed) then
        goto skip
    end

    camera:push()

    -- Translate (0, 0) to center of the screen (local scope to avoid goto-jump issues)
    do
        local sw, sh, _ = love.window.getMode()
        love.graphics.translate(sw / 2, sh / 2)
    end

    -- Draw cells
    for _, cells in pairs(cells_families or {}) do
        for _, c in pairs(cells) do
            if not c.visible then
                goto continuecells
            end

            -- Handle cell color
            love.graphics.setColor(c.color)

            local x = c:xcor() * coord_scale
            local y = - c:ycor() * coord_scale -- Invert Y-axis to have its positive side point up
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
            elseif c.shape == "triangle" then
                -- Each triangle is 3 lines
                local top = {x, y - (0.5 * coord_scale)}
                local left = {x - (0.5 * coord_scale), y + (0.5 * coord_scale)}
                local right = {x + (0.5 * coord_scale), y + (0.5 * coord_scale)}
                love.graphics.line(top[1], top[2], left[1], left[2]) -- Left line
                love.graphics.line(top[1], top[2], right[1], right[2]) -- Right line
                love.graphics.line(left[1], left[2], right[1], right[2]) -- Bottom line
            elseif c.shape == "circle" then
                -- Circle of radius=0.5
                love.graphics.circle("line", x, y, 0.5 * coord_scale)
            else
                -- Shape is a generic polygon
                love.graphics.polygon("line", c.shape)
            end

            -- Draw label
            love.graphics.setColor(c.label_color)
            love.graphics.printf(c.label, x - 45, y, 100, 'center')

            ::continuecells::
        end
    end

    -- Draw links
    for _, links in pairs(links_families or {}) do
        for _, l in pairs(links) do
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
            local sx = l.source:xcor() * coord_scale
            local sy = - l.source:ycor() * coord_scale -- Invert Y-axis to have its positive side point up
            local tx = l.target:xcor() * coord_scale
            local ty = - l.target:ycor() * coord_scale -- Invert Y-axis to have its positive side point up
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
    end

    -- Draw agents
    for _, agents in pairs(agents_families or {}) do
        for _, a in pairs(agents) do

            -- Handle agent visibility
            if not a.visible then
                goto continueagents
            end

            -- Handle agent color
            love.graphics.setColor(a.color)

            local x = a:xcor() * coord_scale
            local y = - a:ycor() * coord_scale -- Invert Y-axis to have its positive side point up

            -- Handle agent shape, scale and rotation
            -- Base resources are 100x100 px, using 10x10 px as base scale (0.1 factor)
            local rot = -( a.heading - (math.pi/2) )
            local scl = 0.1 * a.scale
            local shift = 50 -- pixels to shift to center the figure
            local shape_img = ResourceManager.images.circle -- Default to circle
            if a.shape == "triangle" then
                shape_img = ResourceManager.images.triangle
            elseif a.shape == "triangle_2" then
                shape_img = ResourceManager.images.triangletest
            elseif a.shape == "square" then
                shape_img = ResourceManager.images.rectangle
            elseif a.shape == "house" then
                shape_img = ResourceManager.images.house
            elseif a.shape == "person" then
                shape_img = ResourceManager.images.person
            elseif a.shape == "tree" then
                shape_img = ResourceManager.images.tree
            end

            love.graphics.draw(shape_img, x, y, rot, scl, scl, shift, shift)

            -- Handle agent label
            love.graphics.setColor(a.label_color)
            love.graphics.printf(a.label, x - 45, y + 10, 100, 'center')

            ::continueagents::
        end
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
    set_background_color = set_background_color,
    set_time_between_steps = set_time_between_steps
}

return GraphicEngine
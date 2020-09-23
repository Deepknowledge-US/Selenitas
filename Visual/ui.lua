local Slab = require "Thirdparty.Slab.Slab"
local DebugGraph = require("Thirdparty.debuggraph.debugGraph")
local FileUtils = require "Visual.fileutils"
local View = require "Visual.view"
-- GraphicEngine already required from main.lua

local UI = {}

local show_file_picker = false
local file_loaded_path = nil
local show_params_window = false
local show_about_dialog = false
local show_debug_graph = false
local error_msg = nil
local speed_slider_value = 20
local default_font = love.graphics.newFont(12)
local fps_graph = DebugGraph:new('fps', 0, 0, 100, 60, 0.5, nil, default_font)
local mem_graph = DebugGraph:new('mem', 0, 60, 100, 60, 0.5, nil, default_font)

-- Simulation state trackers
local setup_executed = false
local go_enabled = false

-- Wrapper for FileUtils.load_model_file,
-- Checks for errors and sets window name
local function load_model(path)
    local err = FileUtils.load_model_file(path)
    if err then
        UI.show_error_message(err)
        file_loaded_path = nil
    else
        file_loaded_path = path
        local model_name = string.gsub(FileUtils.get_filename_from_path(path), ".lua", "")
        love.window.setTitle("Selenitas - " .. model_name)
    end
end

function UI.show_error_message(err)
    error_msg = err
end

function UI.init()
    Slab.Initialize({})
end

function UI.reset()
    setup_executed = false
    go_enabled = false
    show_params_window = false
    Config.ui_settings = {}
end

function UI.update(dt)
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
                    load_model(file_loaded_path)
                end
            end

            -- Show "Edit loaded file" option if file was loaded
            if file_loaded_path then
                if Slab.MenuItem("Edit loaded file") then
                    FileUtils.open_in_editor(file_loaded_path)
                end
            end

            Slab.Separator()

            if Slab.MenuItem("Settings...") then
            end

            -- Show "Close" sim file
            if Slab.MenuItem("Close") then
                GraphicEngine.reset_simulation()
                file_loaded_path = nil
            end

            Slab.Separator()

            -- Quit button
            if Slab.MenuItem("Quit") then
                love.event.quit()
            end

            Slab.EndMenu()
        end

        if Slab.BeginMenu("Edit") then
            if Slab.BeginMenu("Mouse mode") then
                if Slab.MenuItem("Move") then
                end
                if Slab.MenuItem("Select") then
                end
                Slab.EndMenu()
            end
            Slab.EndMenu()
        end

        if Slab.BeginMenu("Simulation") then
            if Slab.MenuItem("Setup/Reset") then
            end

            if Slab.MenuItem("Step") then
            
            end

            if Slab.MenuItem("Run/Stop") then
                
            end

            if Slab.MenuItem("Update view") then
                
            end

            Slab.EndMenu()
        end

        if Slab.BeginMenu("View") then
            if Slab.MenuItem("Reset view") then
                View.reset()
            end

            if Slab.BeginMenu("Windows") then
                if Slab.MenuItem("All") then
                    show_params_window = true
                end
                Slab.EndMenu()
            end

            if Slab.BeginMenu("Families") then
                if Slab.MenuItem("All") then
                    
                end
                Slab.EndMenu()
            end

            if Slab.MenuItem("Show grid") then
            end

            if Slab.MenuItem("Show performance stats") then
                show_debug_graph = not show_debug_graph
            end

            Slab.EndMenu()
        end

        -- "Help" section
        if Slab.BeginMenu("Help") then

            if Slab.MenuItem("Selenitas User Manual") then
                love.system.openURL("https://github.com/Deepknowledge-US/Selenitas/wiki")
            end

            if Slab.MenuItem("Report issue") then
                love.system.openURL("https://github.com/Deepknowledge-US/Selenitas/issues")
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
                GraphicEngine.reset_simulation()
                load_model(result.Files[1])
                if next(Config.ui_settings) ~= nil then
                    -- Loaded simulation has params, show params window
                    show_params_window = true
                end
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
        Slab.Text("https://github.com/Deepknowledge-US/Selenitas",
            {URL = "https://github.com/Deepknowledge-US/Selenitas"})
        Slab.NewLine()
        if Slab.Button("OK") then
            show_about_dialog = false
            Slab.CloseDialog()
        end
        Slab.EndLayout()
        Slab.EndDialog()
    end

    -- Show error message if needed
    if error_msg ~= nil then
        local res = Slab.MessageBox("An error occurred", "An error occurred:\n " .. error_msg)
        if res ~= "" then
            error_msg = nil
        end
    end

    -- Get screen size
    local screen_w, screen_h, _ = love.window.getMode()

    -- Create toolbar with main controls
    Slab.BeginWindow("Toolbar", {
        Title = "", -- No title means it shows no title border and is not movable
        X = 0,
        Y = 15,
        W = screen_w - 2,
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
        local err = GraphicEngine.setup_simulation()
        setup_executed = not err
        if err then
            UI.show_error_message(err)
        end
    end

    Slab.SameLine()

    -- Step button
    if Slab.Button("Step", {Disabled = not setup_executed}) then
        local err = GraphicEngine.step_simulation()
        if err then
            UI.show_error_message(err)
        end
    end

    Slab.SameLine()

    -- Go button
    local go_button_label = go_enabled and "Stop" or "Go" -- Change "go" button label if it's already running
    if Slab.Button(go_button_label, {Disabled = not setup_executed}) then
        go_enabled = not go_enabled
        if go_enabled then
            GraphicEngine.run_simulation()
        else
            GraphicEngine.stop_simulation()
        end
    end

    Slab.SameLine()

    if Slab.Button("Reload", {Disabled = file_loaded_path == nil}) then
        GraphicEngine.reset_simulation()
        load_model(file_loaded_path)
    end

    Slab.SameLine()

    Slab.EndLayout()
    Slab.EndWindow()

    -- Bottom status bar
    Slab.BeginWindow("StatusBar", {
        Title = "", -- No title means it shows no title border and is not movable
        X = 0,
        Y = screen_h - 23,
        W = screen_w - 2,
        H = 20,
        AutoSizeWindow = false,
        AllowResize = false
    })

    Slab.BeginLayout("ToolbarLayout", {
        AlignY = 'center',
        AlignRowY = 'center',
        AlignX = 'right'
    })

    -- "Speed" slider: it changes time_between_steps value
    Slab.Text(" Speed: ", {})
    Slab.SameLine()
    --  Speed 0 = 1 sec. ... Speed 5 = 0 sec.
    if Slab.InputNumberSlider("tbs_slider", speed_slider_value, 0.0, 10.0, {step=1}) then
        speed_slider_value = Slab.GetInputNumber()
        GraphicEngine.set_time_between_steps((math.log(11) - math.log (speed_slider_value + 1))/math.log(11))
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
            if Slab.InputNumberSlider(k .. "Slider", Config[k], v.min, v.max, {Step = v.step}) then
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

    -- Update graphs
    fps_graph:update(dt)
    mem_graph:update(dt)
end

local function draw_debug_graphs(dt)
    local screen_w, screen_h, _ = love.window.getMode()
    local panel_width = 100 + 30
    local panel_height = 60 * 2 + 5
    local xpos = screen_w - panel_width - 20
    local ypos = screen_h - panel_height - 30
    -- Draw back panel
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", xpos, ypos, panel_width, panel_height)
    love.graphics.setColor(1, 1, 1, 1)
    -- Update graphs positions
    fps_graph.x = xpos
    fps_graph.y = ypos
    mem_graph.x = xpos
    mem_graph.y = ypos + 60
    fps_graph:draw()
    mem_graph:draw()
end

function UI.draw()
    Slab.Draw()
    if show_debug_graph then
        draw_debug_graphs()
    end
end

return UI
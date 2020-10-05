local Slab = require "Thirdparty.Slab.Slab"
local DebugGraph = require("Thirdparty.debuggraph.debugGraph")
local ResourceManager = require("Thirdparty.cargo.cargo").init("Resources")
local FileUtils = require "Visual.fileutils"
local View = require "Visual.view"

-- GraphicEngine already required from main.lua

local UI = {}

local show_file_picker = false
local file_loaded_path = nil
local show_about_dialog = false
local show_params_window = false
local show_debug_graph = false
local error_msg = nil
local speed_slider_value = 20
local default_font = love.graphics.newFont(12)
local fps_graph = DebugGraph:new('fps', 0, 0, 100, 60, 0.5, nil, default_font)
local mem_graph = DebugGraph:new('mem', 0, 60, 100, 60, 0.5, nil, default_font)
local toolbar_buttons_params = {
    base_color = {0.549, 0.549, 0.549},
    hover_color = {0.698, 0.698, 0.698},
    disabled_color = {0.352, 0.352, 0.352},
}
local families_visibility = {
    all = true
}
local windows_visibility = {
    all = false
}

-- Simulation state trackers
local setup_executed = false

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

local on_click_functions = {
    setup = function()
        local err = GraphicEngine.setup_simulation()
        setup_executed = not err
        if err then
            UI.show_error_message(err)
        end
    end,

    step = function()
        local err = GraphicEngine.step_simulation()
        if err then
            UI.show_error_message(err)
        end
    end,

    go = function()
        Simulation:start()
    end,

    stop = function()
        Simulation:stop()
    end,

    toggle_running = function()
        if Simulation.is_running then
            Simulation:stop()
        else
            Simulation:start()
        end
    end,

    reload = function()
        GraphicEngine.reset_simulation()
        load_model(file_loaded_path)
        show_params_window = true
    end,

    load_file = function()
        show_file_picker = true
    end,

    edit_file = function()
        FileUtils.open_in_editor(file_loaded_path)
    end,

    toggle_draw_enabled = function()
        GraphicEngine.set_draw_enabled(not GraphicEngine.is_draw_enabled())
    end,

    toggle_performance_stats = function()
        show_debug_graph = not show_debug_graph
    end,

    toggle_families_visibility = function()
        families_visibility.all = not families_visibility.all
    end,

    toggle_windows_visibility = function()
        windows_visibility.all = not windows_visibility.all
    end,

    toggle_grid_visibility = function()
        GraphicEngine.set_grid_enabled(not GraphicEngine.is_grid_enabled())
    end,
}


-- TODO: Read windows and create menu entries
-- This must be called inside of a Menu
local function build_window_show_tree()
    if Slab.MenuItemChecked("All", show_params_window) then
        show_params_window = not show_params_window
    end
    Slab.Separator()
end

-- TODO: Read families and create menu entries
-- This must be called inside of a Menu
local function build_family_show_tree()
    if Slab.MenuItemChecked("All", true) then
        local all = not families_visibility.all -- toggled
        families_visibility.all = all
        if all then
            for k, _ in ipairs(families_visibility) do
                families_visibility[k] = true
            end
        end
    end
    Slab.Separator()
    -- for _, f in ipairs(Simulation.families) do
        -- TODO: family id
        --local family_type = "Mobil"
        --if f:is_a(FamilyRelational) then
        --    family_type = "Relational"
        --elseif f:is_a(FamilyCell) then
        --    family_type = "Cell"
        --end
        --if Slab.MenuItemChecked(f.id .. "(" .. family_type .. ")", families_visibility[f.id]) then
        --    local new_val = not families_visibility[f.id]
        --    families_visibility[f.id] = not families_visibility[f.id]
        --    if not new_val then
        --        families_visibility.all = false
        --    end
        --end
    -- end
end

function UI.show_error_message(err)
    error_msg = err
end

function UI.init()
    Slab.Initialize({})
end

function UI.reset()
    setup_executed = false
    show_params_window = false
    Interface.ui_settings = {}
end

local function add_toolbar_button(name, love_img, disabled, tooltip, on_click_func)
    local col = toolbar_buttons_params.base_color
    if toolbar_buttons_params[name .. "hovered"] then
        col = toolbar_buttons_params.hover_color
    end
    if disabled then
        col = toolbar_buttons_params.disabled_color
    end
    Slab.Rectangle({W=2, H=10, Color={0,0,0,0}})
    Slab.SameLine()
    Slab.Image(name, {Image = love_img, ReturnOnClick = true, Color = col, Scale = 0.4, Tooltip = tooltip})
    toolbar_buttons_params[name .. "hovered"] = Slab.IsControlHovered()
    if Slab.IsControlClicked() and not disabled then
        on_click_func()
    end
    Slab.SameLine()
    Slab.Rectangle({W=2, H=10, Color={0,0,0,0}})
end

local function toolbar_separator(w)
    Slab.Rectangle({W=w/2, H=1, Color={0,0,0,0}})
    Slab.SameLine()
--    Slab.Rectangle({W=6, H=25, Color=toolbar_buttons_params.base_color})
    Slab.Rectangle({W=6, H=25, Color={1,1,1,.3}})
    Slab.SameLine()
    Slab.Rectangle({W=w/2, H=1, Color={0,0,0,0}})
    Slab.SameLine()
end

local function file_picker()
  local result = Slab.FileDialog({Type = 'openfile', AllowMultiSelect = false})
  if result.Button ~= "" then
    show_file_picker = false
    if result.Button == "OK" then
      -- Load selected file
      GraphicEngine.reset_simulation()
      load_model(result.Files[1])
      if next(Interface.ui_settings) ~= nil then
        -- Loaded simulation has params, show params window
        show_params_window = true
      end
    end
  end
end

local function about_dialog()
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

local function menu_bar()
   -- Build menu bar
    if Slab.BeginMainMenuBar() then

        -- "File" section
        if Slab.BeginMenu("File") then
            if Slab.MenuItem("Load file...") then
                on_click_functions.load_file()
            end

            -- Show "Reload file" option if file was loaded
            if file_loaded_path then
                if Slab.MenuItem("Reload file") then
                    on_click_functions.reload()
                end
            end

            -- Show "Edit loaded file" option if file was loaded
            if file_loaded_path then
                if Slab.MenuItem("Edit loaded file") then
                    on_click_functions.edit_file()
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
            if Slab.MenuItem("Setup") then
                if file_loaded_path ~= nil then -- TODO: disabled menu item when Slab implements it
                    on_click_functions.setup()
                end
            end

            if Slab.MenuItem("Step") then
                if setup_executed then
                    on_click_functions.step()
                end
            end

            if Slab.MenuItem("Run") then
                if setup_executed then
                    on_click_functions.go()
                end
            end

            if Slab.MenuItem("Stop") then
                if setup_executed then
                    on_click_functions.stop()
                end
            end

            if Slab.MenuItem("Reset") then
                if file_loaded_path ~= nil then
                    on_click_functions.reload()
                end
            end

            if Slab.MenuItemChecked("Draw enabled", GraphicEngine.is_draw_enabled()) then
                on_click_functions.toggle_draw_enabled()
            end

            Slab.EndMenu()
        end

        if Slab.BeginMenu("View") then
            if Slab.MenuItem("Reset view") then
                View.reset()
            end

            if Slab.BeginMenu("Windows") then
                build_window_show_tree()
                Slab.EndMenu()
            end

            if Slab.BeginMenu("Families") then
                build_family_show_tree()
                Slab.EndMenu()
            end

            if Slab.MenuItemChecked("Show grid", GraphicEngine.is_grid_enabled()) then
                on_click_functions.toggle_grid_visibility()
            end

            if Slab.MenuItemChecked("Show performance stats", show_debug_graph) then
                on_click_functions.toggle_performance_stats()
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
end

local function toolbar(screen_w, screen_h)

    -- Create toolbar with main controls
    Slab.BeginWindow("Toolbar", {
        Title = "", -- No title means it shows no title border and is not movable
        X = 0,
        Y = 15,
        W = screen_w - 2,
        H = 40,
        AutoSizeWindow = false,
        AllowResize = false
    })

    Slab.Separator()

    Slab.BeginLayout("ToolbarLayout", {
        AlignY = 'center',
        AlignRowY = 'center'
    })

    ------- File options -------
    add_toolbar_button("New", ResourceManager.ui.newfile, false,
        "New File", function() end) -- TODO
    Slab.SameLine()

    add_toolbar_button("Open", ResourceManager.ui.open, false,
        "Open File", on_click_functions.load_file)
    Slab.SameLine()

    add_toolbar_button("Edit", ResourceManager.ui.edit, file_loaded_path == nil,
        "Edit File (external editor)", on_click_functions.edit_file)
    Slab.SameLine()


    toolbar_separator(30)

    ------- Simulation control -------
    add_toolbar_button("Setup", ResourceManager.ui.setup, file_loaded_path == nil,
        "Setup Simulation", on_click_functions.setup)
    Slab.SameLine()

    if Simulation.is_running then
        add_toolbar_button("Stop", ResourceManager.ui.pause, not setup_executed,
            "Stop Simulation", on_click_functions.toggle_running)
    else
        add_toolbar_button("Go", ResourceManager.ui.play, not setup_executed,
            "Run Simulation", on_click_functions.toggle_running)
    end
    Slab.SameLine()

    add_toolbar_button("Step", ResourceManager.ui.step, not setup_executed,
        "One Step", on_click_functions.step)
    Slab.SameLine()

    add_toolbar_button("Reload", ResourceManager.ui.refresh, file_loaded_path == nil,
        "Reload Model", on_click_functions.reload)
    Slab.SameLine()

    toolbar_separator(30)


    ------- View options -------
    if GraphicEngine.is_draw_enabled() then
        add_toolbar_button("DisableDraw", ResourceManager.ui.eye_on, false,
            "Refresh Off", on_click_functions.toggle_draw_enabled)
    else
        add_toolbar_button("EnableDraw", ResourceManager.ui.eye_off, false,
            "Refresh On", on_click_functions.toggle_draw_enabled)
    end
    Slab.SameLine()

    add_toolbar_button("ShowGraph", ResourceManager.ui.showgraph, false,
        "Performance Stats", on_click_functions.toggle_performance_stats)
    Slab.SameLine()

    add_toolbar_button("WindowShow", ResourceManager.ui.window, false,
        "View Windows", function() end) -- TODO
    Slab.SameLine()

    add_toolbar_button("FamilyShow", ResourceManager.ui.family, false,
        "View Families", function() end) -- TODO
    Slab.SameLine()

    add_toolbar_button("GridShow", ResourceManager.ui.grid, false,
        "Grid", on_click_functions.toggle_grid_visibility)
    Slab.SameLine()

    toolbar_separator(30)


    ------- Help -------
    add_toolbar_button("Help", ResourceManager.ui.help, false,
        "User Manual", function() end) -- TODO
    Slab.SameLine()

    Slab.EndLayout()
    Slab.EndWindow()
end

local function status_bar(screen_w, screen_h)
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

    Slab.BeginLayout("StatusBarLayout", {
        AlignY = 'center',
        AlignRowY = 'center',
        AlignX = 'right'
    })

    -- "Speed" slider: it changes time_between_steps value
    Slab.Text(" Time (steps): ", {})
    Slab.SameLine()
    Slab.Text(tostring(Simulation:get_time()))
    Slab.SameLine()
    Slab.Text(" | Speed: ", {})
    Slab.SameLine()
    --  Speed 0 = 1 sec. ... Speed 5 = 0 sec.
    if Slab.InputNumberSlider("tbs_slider", speed_slider_value, 0.0, 10.0, {step=1}) then
        speed_slider_value = Slab.GetInputNumber()
        GraphicEngine.set_time_between_steps((math.log(11) - math.log (speed_slider_value + 1))/math.log(11))
    end

    Slab.EndLayout()
    Slab.EndWindow()
end

local function params_window()
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
    -- Interface object taken from 'utl_main'
    for k, v in pairs(Interface.ui_settings) do
        -- Checkbox
        if v.type == "boolean" then
            Slab.Text(k, {Color = {0.258, 0.529, 0.956}})
            if Slab.CheckBox(Interface[k], "Enabled") then
                Interface[k] = not Interface[k]
            end
        -- Slider
        elseif v.type == "slider" then
            Slab.Text(k, {Color = {0.258, 0.529, 0.956}})
            if Slab.InputNumberSlider(k .. "Slider", Interface[k], v.min, v.max, {Step = v.step}) then
                Interface[k] = Slab.GetInputNumber()
            end
        -- Number input
        elseif v.type == "input" then
            Slab.Text(k, {Color = {0.258, 0.529, 0.956}})
            if Slab.InputNumberDrag(k .. "InputNumber", Interface[k], nil, nil, {}) then
                Interface[k] = Slab.GetInputNumber()
            end
        -- Radio buttons
        elseif v.type == "enum" then
            Slab.Text(k, {Color = {0.258, 0.529, 0.956}})
            for i, e in ipairs(v.options) do
                if Slab.RadioButton(e, {Index = i, SelectedIndex = Interface[k]}) then
                    Interface[k] = i
                end
            end
        else
            print("UI Control of type \"" .. v.type .. "\" is not recognized.")
        end
    end
    Slab.EndLayout()
    Slab.EndWindow()
end

function UI.update(dt)
    -- Re-draw UI in each step
    Slab.Update(dt)

    menu_bar()

    -- Show file picker if selected
    if show_file_picker then
      file_picker()
    end

    -- Show about dialog if selected
    if show_about_dialog then
      about_dialog()
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

    toolbar(screen_w, screen_h)

    status_bar(screen_w, screen_h)

    params_window()

    -- Update graphs
    fps_graph:update(dt)
    mem_graph:update(dt)
end

local function draw_debug_graphs()
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
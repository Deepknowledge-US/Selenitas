local Slab = require "Thirdparty.Slab.Slab"
local DebugGraph = require("Thirdparty.debuggraph.debugGraph")
local ResourceManager = require("Thirdparty.cargo.cargo").init("Resources")
local FileUtils = require "Visual.fileutils"
local View = require "Visual.view"

-- GraphicEngine already required from main.lua

local UI = {}

local Internal_Editor = {Title = "Selenitas Editor", AllowResize = false, AutoSizeWindow=true}
local Internal_Editor_FileDialog = false
local Internal_Editor_FileName = ""
local Internal_Editor_Contents = ""
local editor_font_size = 14
--local editor_font = love.graphics.newFont(SLAB_FILE_PATH .. "Internal/Resources/Fonts/SourceCodePro-Regular.ttf",editor_font_size)
local editor_font = love.graphics.newFont(SLAB_FILE_PATH .. "Internal/Resources/Fonts/JuliaMono-Regular.ttf",editor_font_size)

local Selenitas_Syntax = require "Visual.SyntaxHighlight"

local show_file_editor = false
local show_file_picker = false
local file_loaded_path = nil
local show_about_dialog = false
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

local families_visibility = { all = true }
local windows_visibility = { all = false }
local family_mobile_visibility = {all = false}
local family_cell_visibility = {all = false}
local family_rel_visibility = {all = false}

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
        families_visibility = {all = true} -- new families added in update loop
        windows_visibility = {all = false}
        family_mobile_visibility = {all = false}
        family_cell_visibility = {all = false}
        family_rel_visibility = {all = false}
        GraphicEngine.reset_simulation()
        load_model(file_loaded_path)
    end,

    load_file = function()
        show_file_picker = true
    end,

    close_editor = function()
      show_file_editor = false
    end,

    edit_file = function()
        FileUtils.open_in_editor(file_loaded_path)
    end,

    save_file = function()
      local Handle, Error = io.open(file_loaded_path, "w")
      if Handle ~= nil then
        Handle:write(Internal_Editor_Contents)
        Handle:close()
      end
    end,

    toggle_draw_enabled = function()
        GraphicEngine.set_draw_enabled(not GraphicEngine.is_draw_enabled())
    end,

    toggle_performance_stats = function()
        show_debug_graph = not show_debug_graph
    end,

    toggle_families_visibility = function()
        -- TODO: Ideally this should show the same
        -- contextmenu as View > Families, but a Slab
        -- bug does not allow it: https://github.com/coding-jackalope/Slab/issues/56
        local visible = false
        for _, v in pairs(families_visibility) do
            if v then
                visible = true
            end
        end
        for k, _ in pairs(families_visibility) do
            if visible then
                families_visibility[k] = false
            else
                families_visibility[k] = true
            end
        end
    end,

    toggle_windows_visibility = function()
        -- TODO: Ideally this should show the same
        -- contextmenu as View > Windows, but a Slab
        -- bug does not allow it: https://github.com/coding-jackalope/Slab/issues/56
        local visible = false
        for _, v in pairs(windows_visibility) do
            if v then
                visible = true
            end
        end
        for k, _ in pairs(windows_visibility) do
            if visible then
                windows_visibility[k] = false
            else
                windows_visibility[k] = true
            end
        end
    end,

    toggle_grid_visibility = function()
        View.set_grid_enabled(not View.is_grid_enabled())
    end,

    toggle_FamilyMobile_windows_visibility = function()
        local visible = false
        for _, v in pairs(family_mobile_visibility) do
            if v then
                visible = true
            end
        end
        for k, _ in pairs(family_mobile_visibility) do
            if visible then
                family_mobile_visibility[k] = false
            else
                family_mobile_visibility[k] = true
            end
        end
    end,

    toggle_FamilyCell_windows_visibility = function()
        local visible = false
        for _, v in pairs(family_cell_visibility) do
            if v then
                visible = true
            end
        end
        for k, _ in pairs(family_cell_visibility) do
            if visible then
                family_cell_visibility[k] = false
            else
                family_cell_visibility[k] = true
            end
        end
    end,

    toggle_FamilyRel_windows_visibility = function()
        local visible = false
        for _, v in pairs(family_rel_visibility) do
            if v then
                visible = true
            end
        end
        for k, _ in pairs(family_rel_visibility) do
            if visible then
                family_rel_visibility[k] = false
            else
                family_rel_visibility[k] = true
            end
        end
    end,

    int_editor = function()
      local Handle, Error = io.open(file_loaded_path, "r")
			if Handle ~= nil then
				Internal_Editor_Contents = Handle:read("*a")
				Handle:close()
			end
      show_file_editor = not show_file_editor
    end,
    
    restore_zoom = function()
      View.set_zoom(1)
      Observer:set_zoom(1)
    end,
    
    restore_center = function()
      View.reset_center()
      Observer:set_center( { 0, 0 } )
    end
}


-- This must be called inside of a Menu
local function build_window_show_tree()
    if Slab.MenuItemChecked("All", windows_visibility.all) then
        windows_visibility.all = not windows_visibility.all
    end
    if windows_visibility.all then
        for k, _ in pairs(windows_visibility) do
            windows_visibility[k] = true
        end
    end
    Slab.Separator()
    for _, window in pairs(Interface.windows) do
        for name,_ in pairs(window.ui_settings) do
            if Slab.MenuItemChecked(name, windows_visibility[name]) then
                local new_val = not windows_visibility[name]
                windows_visibility[name] = new_val
                if not new_val then
                    windows_visibility.all = false
                end
            end
        end
    end
    Slab.Separator()
end

-- This must be called inside of a Menu
local function build_family_show_tree()
    if Slab.MenuItemChecked("All", families_visibility.all) then
        families_visibility.all = not families_visibility.all -- toggled
    end
    if families_visibility.all then
        for k, _ in pairs(families_visibility) do
            families_visibility[k] = true
        end
    end
    Slab.Separator()
    for _, f in pairs(Simulation.families) do
        local family_type = "Mobile"
        if f:is_a(FamilyRelational) then
            family_type = "Relational"
        elseif f:is_a(FamilyCell) then
            family_type = "Cell"
        end
        if Slab.MenuItemChecked(f.name .. " (" .. family_type .. ")", families_visibility[f.name]) then
            local new_val = not families_visibility[f.name]
            families_visibility[f.name] = new_val
            if not new_val then
                families_visibility.all = false
            end
        end
    end
end

function UI.show_error_message(err)
    error_msg = err
end

function UI.init()
    Slab.Initialize({})
    Slab.DisableDocks({'Left','Right','Bottom'})
end

function UI.reset()
    setup_executed = false
    windows_visibility = { all = false }
    family_mobile_visibility = {all = false}
    family_cell_visibility = {all = false}
    family_rel_visibility = {all = false}
    Interface:clear()
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
    Slab.Rectangle({W=3, H=28, Color={1,1,1,.3}})
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
          if next(Interface.windows) ~= nil then
            -- Loaded simulation has params, show params windows
            for k, _ in pairs(windows_visibility) do
                windows_visibility[k] = true
            end
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

local function view_editor()
	Slab.BeginWindow('Internal_Editor', Internal_Editor)

  local model_name = string.gsub(FileUtils.get_filename_from_path(file_loaded_path), ".lua", "")
	Internal_Editor.Title = ("File: " .. model_name)
  
--	Slab.SameLine()
  
--	if Slab.Button("Load") then
--		Internal_Editor_FileDialog = true
--	end
  add_toolbar_button("Open_int_editor", ResourceManager.ui.open, false,
        "Open File", function() end) -- TODO
  Slab.SameLine()
	
  add_toolbar_button("Save", ResourceManager.ui.save, file_loaded_path == nil,
        "Save File", on_click_functions.save_file)
  Slab.SameLine()

  add_toolbar_button("Reload_int_editor", ResourceManager.ui.refresh, file_loaded_path == nil,
        "Reload Model", on_click_functions.reload)
  Slab.SameLine()

  add_toolbar_button("New_int_editor", ResourceManager.ui.newfile, false,
        "New File", function() end) -- TODO
  Slab.SameLine()
  
  Slab.Rectangle({W=490, H=1, Color={0,0,0,0}})
  Slab.SameLine()
  
    add_toolbar_button("Close_int_editor", ResourceManager.ui.close, false,
          "Close Editor", on_click_functions.close_editor)

    Slab.Text(" ")

	Slab.Separator()

    Slab.SetScrollSpeed(20)

    Slab.PushFont(editor_font)

	if Slab.Input('Internal_Editor', {
		MultiLine = true,
		Text = Internal_Editor_Contents,
		W = 700 ,
		H = 500,
    MultiLineW = 680,
		Highlight = Selenitas_Syntax
	}) then
		Internal_Editor_Contents = Slab.GetInputText()
	end
    Slab.PopFont()
    Slab.EndWindow()
end


local function menu_bar()
   -- Build menu bar
    if Slab.BeginMainMenuBar() then

        -- "File" section
        if Slab.BeginMenu("File") then
            if Slab.MenuItem("Load Model...") then
                on_click_functions.load_file()
            end

            -- Show "Reload file" option if file was loaded
            if file_loaded_path then
                if Slab.MenuItem("Reload Model") then
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

            if Slab.MenuItemChecked("Show grid", View.is_grid_enabled()) then
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
        "New Model", function() end) -- TODO
    Slab.SameLine()

    add_toolbar_button("Open", ResourceManager.ui.open, false,
        "Open Model", on_click_functions.load_file)
    Slab.SameLine()

    add_toolbar_button("Edit", ResourceManager.ui.edit2, file_loaded_path == nil,
        "Edit File (external editor)", on_click_functions.edit_file)
    Slab.SameLine()

    add_toolbar_button("Edit2", ResourceManager.ui.edit2, file_loaded_path == nil,
        "Edit Model (internal editor)", on_click_functions.int_editor)
    Slab.SameLine()

    toolbar_separator(15)

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

    toolbar_separator(15)


    ------- View options -------
    if GraphicEngine.is_draw_enabled() then
        add_toolbar_button("DisableDraw", ResourceManager.ui.eye_on2, false,
            "Refresh Off", on_click_functions.toggle_draw_enabled)
    else
        add_toolbar_button("EnableDraw", ResourceManager.ui.eye_off2, false,
            "Refresh On", on_click_functions.toggle_draw_enabled)
    end
    Slab.SameLine()

    add_toolbar_button("ShowGraph", ResourceManager.ui.showgraph2, false,
        "Performance Stats", on_click_functions.toggle_performance_stats)
    Slab.SameLine()

    add_toolbar_button("WindowShow", ResourceManager.ui.window3, false,
        "View Windows", on_click_functions.toggle_windows_visibility)
    Slab.SameLine()

    add_toolbar_button("FamilyShow", ResourceManager.ui.family, false,
        "View Families", on_click_functions.toggle_families_visibility)
    Slab.SameLine()

    if View.is_grid_enabled() then
        add_toolbar_button("GridOff", ResourceManager.ui.gridoff, false,
            "Grid Off", on_click_functions.toggle_grid_visibility)
    else
        add_toolbar_button("GridOn", ResourceManager.ui.grid, false,
            "Grid On", on_click_functions.toggle_grid_visibility)
    end
    Slab.SameLine()

    toolbar_separator(15)


    ------- Help -------
    add_toolbar_button("Help", ResourceManager.ui.help, false,
        "User Manual", function() end) -- TODO
    Slab.SameLine()

    Slab.EndLayout()
    Slab.EndWindow()
end

local function status_bar(screen_w, screen_h)
    local col = toolbar_buttons_params.base_color
    -- Bottom status bar
    Slab.BeginWindow("StatusBar", {
        Title = "", -- No title means it shows no title border and is not movable
        X = 0,
        Y = screen_h - 29,
        W = screen_w + 10,
        H = 30,
        Border = 0,
        AutoSizeWindow = false,
        AllowResize = false
    })

    Slab.BeginLayout("StatusBarLayout", {
        AlignY = 'center',
        AlignRowY = 'center',
        AlignX = 'left'
    })

    Slab.Rectangle({W=5, H=28, Color={0,0,0,0}})
    Slab.SameLine()
    -- Seed
    -- Slab.Text(" Seed : ", {})
    Slab.Image('Icon_dice', {Image = ResourceManager.ui.shuffle, Color = col, Scale = 0.4})
    Slab.SameLine()
    Slab.Text(tostring(Simulation:get_seed()))
    Slab.SameLine()
    toolbar_separator(15)

    -- "Speed" slider: it changes time_between_steps value
    Slab.SameLine()
    Slab.Image('Icon_time', {Image = ResourceManager.ui.time3, Color = col, Scale = 0.4})
    Slab.SameLine()
    Slab.Text(tostring(Simulation:get_time()))
    Slab.SameLine()
    Slab.Text("    Speed: ", {})
    Slab.SameLine()
    if Slab.InputNumberSlider("tbs_slider", speed_slider_value, 0.0, 10.0, {step=1, W=100}) then
        speed_slider_value = Slab.GetInputNumber()
        GraphicEngine.set_time_between_steps((math.log(11) - math.log (speed_slider_value + 1))/math.log(11))
    end
    Slab.SameLine()
    Slab.Text("  ",{})
    Slab.SameLine()
    toolbar_separator(15)

    -- Center point in View
    Slab.SameLine()
--    Slab.Image('Icon_center', {Image = ResourceManager.ui.center3, Color = col, Scale = 0.4})
    add_toolbar_button("Icon_center", ResourceManager.ui.center3, false,
    "Restore center", on_click_functions.restore_center)
    Slab.SameLine()
    local center = Observer:get_center()
    Slab.Text( ' (' .. tostring(round(center[1],2)) .. ' , ' .. tostring(round(center[2],2)) .. ')  ' )
    Slab.SameLine()
    toolbar_separator(15)

    -- Zoom in View
    Slab.SameLine()
--    Slab.Image('Icon_zoom', {Image = ResourceManager.ui.zoom2, Color = col, Scale = 0.4})
    add_toolbar_button("Icon_zoom", ResourceManager.ui.zoom2, false,
    "Restore zoom", on_click_functions.restore_zoom)
    Slab.SameLine()
    Slab.Text( tostring(Observer:get_zoom()) )
    Slab.SameLine()
    toolbar_separator(15)

    -- Mobils info
    local cells,mobils,rels = Simulation:number_of_agents()
    Slab.SameLine()
    -- Slab.Image('Icon_mobils ', {Image = ResourceManager.ui.family2, Color = col, Scale = 0.4})
    add_toolbar_button("Icon_mobils", ResourceManager.ui.family2, false,
    "Mobile families", on_click_functions.toggle_FamilyMobile_windows_visibility )
    Slab.SameLine()
    Slab.Text(tostring(mobils))
    Slab.SameLine()
    toolbar_separator(15)

    -- Cells info
    Slab.SameLine()
    -- Slab.Image('Icon_cells ', {Image = ResourceManager.ui.cell, Color = col, Scale = 0.4})
    add_toolbar_button("Cells", ResourceManager.ui.cell, false,
        "Cell families", on_click_functions.toggle_FamilyCell_windows_visibility )
    Slab.SameLine()
    Slab.Text(tostring(cells))
    Slab.SameLine()
    toolbar_separator(15)

    -- Relationals info
    Slab.SameLine()
    -- Slab.Image('Icon_relationals ', {Image = ResourceManager.ui.share2, Color = col, Scale = 0.4})
    add_toolbar_button("Relationals", ResourceManager.ui.share2, false,
        "Relational families", on_click_functions.toggle_FamilyRel_windows_visibility )
    Slab.SameLine()
    Slab.Text(tostring(rels))
    Slab.SameLine()
    toolbar_separator(15)


    Slab.EndLayout()

    Slab.EndWindow()
end

local function params_window(title)

    local window = Interface.windows[title]

  -- Create panel for simulation params
    windows_visibility[title] = Slab.BeginWindow("ParamWindow" .. title, {
        Title = title,
        X = window.x,
        Y = window.y,
        W = window.width,
        ContentW = window.width,
        AutoSizeWindow = false,
        AllowResize = true,
        IsOpen = windows_visibility[title],
        NoSavedSettings = true
    })


    -- Layout to horizontally expand all controls
    Slab.BeginLayout("Layout", {
        ExpandW = true
    })


    for pos=1,window.num_items do

        Slab.Rectangle({W=window.width - 4, H=2, Color={0,0,0,0}})

        local k = window.order[pos]
        local v = window.ui_settings[k]
                -- Checkbox
        if v.type == "boolean" then
            Slab.Text(k, {Color = {0.258, 0.529, 0.956}})
            if Slab.CheckBox(Interface.windows[title][k], "Enabled") then
                Interface.windows[title][k] = not Interface.windows[title][k]
            end
        -- Slider
        elseif v.type == "slider" then
            Slab.Text(k, {Color = {0.258, 0.529, 0.956}})
            if Slab.InputNumberSlider(k .. "Slider", Interface.windows[title][k], v.min, v.max, {Step = v.step}) then
                Interface.windows[title][k] = Slab.GetInputNumber()
            end
        -- Number input
        elseif v.type == "input" then
            Slab.Text(k, {Color = {0.258, 0.529, 0.956}})
            -- if Slab.InputNumberDrag(k .. "InputNumber", Interface.windows[title][k], nil, nil, {}) then
            --     Interface.windows[title][k] = Slab.GetInputNumber()
            -- end
            if Slab.Input(k .. "InputText", {Text = InputText, ReturnOnText = false}) then
                Interface.windows[title][k] = Slab.GetInputText()
            end
        -- Radio buttons
        elseif v.type == "enum" then
            Slab.Text(k, {Color = {0.258, 0.529, 0.956}})
            for i, e in ipairs(v.options) do
                if Slab.RadioButton(e, {Index = i, SelectedIndex = Interface.windows[title][k]}) then
                    Interface.windows[title][k] = i
                end
            end
        else
            print("UI Control of type \"" .. v.type .. "\" is not recognized.")
        end
    end

    Slab.EndLayout()
    Slab.EndWindow()
end

local function family_mobile_info_windows(title)
    local window = Interface.family_mobile_windows[title]
    family_mobile_visibility[title] = Slab.BeginWindow("ParamWindow" .. title, {
        Title = title,
        X = window.x,
        Y = window.y,
        W = window.width,
        ContentW = window.width,
        AutoSizeWindow = false,
        AllowResize = true,
        IsOpen = family_mobile_visibility[title],
        NoSavedSettings = true
    })
    Slab.BeginLayout("Layout", {
        ExpandW = true
    })

    window:update_family_info()

    for _,param in next, window.order do
        Slab.Text(param .. ': ' .. window.info[param])
    end

    Slab.EndLayout()
    Slab.EndWindow()
end


local function family_cell_info_windows(title)
    local window = Interface.family_cell_windows[title]
    family_cell_visibility[title] = Slab.BeginWindow("ParamWindow" .. title, {
        Title = title,
        X = window.x,
        Y = window.y,
        W = window.width,
        ContentW = window.width,
        AutoSizeWindow = false,
        AllowResize = true,
        IsOpen = family_cell_visibility[title],
        NoSavedSettings = true
    })
    Slab.BeginLayout("Layout", {
        ExpandW = true
    })


    window:update_family_info()

    for _,param in next, window.order do
        Slab.Text(param .. ': ' .. window.info[param])
    end

    Slab.EndLayout()
    Slab.EndWindow()
end


local function family_rel_info_windows(title)
    local window = Interface.family_rel_windows[title]
    family_rel_visibility[title] = Slab.BeginWindow("ParamWindow" .. title, {
        Title = title,
        X = window.x,
        Y = window.y,
        W = window.width,
        ContentW = window.width,
        AutoSizeWindow = false,
        AllowResize = true,
        IsOpen = family_rel_visibility[title],
        NoSavedSettings = true
    })
    Slab.BeginLayout("Layout", {
        ExpandW = true
    })


    window:update_family_info()

    for _,param in next, window.order do
        Slab.Text(param .. ': ' .. window.info[param])
    end

    Slab.EndLayout()
    Slab.EndWindow()
end


function UI.update(dt)
    -- Re-draw UI in each step
    Slab.Update(dt)
    -- Update families visibility settings
    -- Check for newly added families
    for _, f in pairs(Simulation.families) do
        if families_visibility[f.name] == nil then
            families_visibility[f.name] = true
        end
    end
    GraphicEngine.set_families_visibility(families_visibility)

    menu_bar()

    -- Show file picker if selected
    if show_file_picker then
      file_picker()
    end

    -- Show about dialog if selected
    if show_about_dialog then
      about_dialog()
    end
    
    -- Show File Editor
    if show_file_editor then
      view_editor()
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

    for k, _ in pairs(Interface.windows) do
        if windows_visibility[k] == nil then
            windows_visibility[k] = true
        end
        params_window(k)
    end

    for k, _ in pairs(Interface.family_mobile_windows) do
        if family_mobile_visibility[k] == nil then
            family_mobile_visibility[k] = false
        end
        family_mobile_info_windows(k)
    end

    for k, _ in pairs(Interface.family_cell_windows) do
        if family_cell_visibility[k] == nil then
            family_cell_visibility[k] = false
        end
        family_cell_info_windows(k)
    end

    for k, _ in pairs(Interface.family_rel_windows) do
        if family_rel_visibility[k] == nil then
            family_rel_visibility[k] = false
        end
        family_rel_info_windows(k)
    end

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
local Slab            = require "Thirdparty.Slab.Slab"
local View            = require "Visual.view"
local ResourceManager = require("Thirdparty.cargo.cargo").init("Resources")


local tb = {}

tb.create_tool_bar = function(ui)

    tb.toolbar = function()
        local screen_w, screen_h = ui.screen_w, ui.screen_h
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
        ui.add_toolbar_button("New", ResourceManager.ui.newfile, false,
            "New Model", function() end) -- TODO
        Slab.SameLine()

        ui.add_toolbar_button("Open", ResourceManager.ui.open, false,
            "Open Model", ui.on_click_functions.load_file)
        Slab.SameLine()

        ui.add_toolbar_button("Edit", ResourceManager.ui.edit2, ui.file_loaded_path == nil,
            "Edit File (external editor)", ui.on_click_functions.edit_file)
        Slab.SameLine()

        ui.add_toolbar_button("Edit2", ResourceManager.ui.edit2, ui.file_loaded_path == nil,
            "Edit Model (internal editor)", ui.on_click_functions.int_editor)
        Slab.SameLine()

        ui.toolbar_separator(15)

        ------- Simulation control -------
        ui.add_toolbar_button("Setup", ResourceManager.ui.setup, ui.file_loaded_path == nil,
            "Setup Simulation", ui.on_click_functions.setup)
        Slab.SameLine()

        if Simulation.is_running then
            ui.add_toolbar_button("Stop", ResourceManager.ui.pause, not ui.setup_executed,
                "Stop Simulation", ui.on_click_functions.toggle_running)
        else
            ui.add_toolbar_button("Go", ResourceManager.ui.play, not ui.setup_executed,
                "Run Simulation", ui.on_click_functions.toggle_running)
        end
        Slab.SameLine()

        ui.add_toolbar_button("Step", ResourceManager.ui.step, not ui.setup_executed,
            "One Step", ui.on_click_functions.step)
        Slab.SameLine()

        ui.add_toolbar_button("Reload", ResourceManager.ui.refresh, ui.file_loaded_path == nil,
            "Reload Model", ui.on_click_functions.reload)
        Slab.SameLine()

        ui.toolbar_separator(15)

        ------- View options -------
        if GraphicEngine.is_draw_enabled() then
            ui.add_toolbar_button("DisableDraw", ResourceManager.ui.eye_off2, false,
                "View Off", ui.on_click_functions.toggle_draw_enabled)
        else
            ui.add_toolbar_button("EnableDraw", ResourceManager.ui.eye_on2, false,
                "View On", ui.on_click_functions.toggle_draw_enabled)
        end
        Slab.SameLine()

        ui.add_toolbar_button("ShowGraph", ResourceManager.ui.showgraph2, false,
            "Performance Stats", ui.on_click_functions.toggle_performance_stats)
        Slab.SameLine()

        ui.add_toolbar_button("WindowShow", ResourceManager.ui.window3, false,
            "View Windows", ui.on_click_functions.toggle_windows_visibility)
        Slab.SameLine()

        ui.add_toolbar_button("FamilyShow", ResourceManager.ui.family, false,
            "View Families", ui.on_click_functions.toggle_families_visibility)
        Slab.SameLine()

        if View.is_grid_enabled() then
            ui.add_toolbar_button("GridOff", ResourceManager.ui.gridoff, false,
                "Grid Off", ui.on_click_functions.toggle_grid_visibility)
        else
            ui.add_toolbar_button("GridOn", ResourceManager.ui.grid, false,
                "Grid On", ui.on_click_functions.toggle_grid_visibility)
        end
        Slab.SameLine()

        ui.toolbar_separator(15)

        ------- Help -------
        ui.add_toolbar_button("Help", ResourceManager.ui.help, false,
            "User Manual", function() end) -- TODO
        Slab.SameLine()

        Slab.EndLayout()
        Slab.EndWindow()
    end

    tb.add_toolbar_button = function(name, love_img, disabled, tooltip, on_click_func)
        local col = ui.toolbar_buttons_params.base_color
        if ui.toolbar_buttons_params[name .. "hovered"] then
            col = ui.toolbar_buttons_params.hover_color
        end
        if disabled then
            col = ui.toolbar_buttons_params.disabled_color
        end
        Slab.Rectangle({W=2, H=10, Color={0,0,0,0}})
        Slab.SameLine()
        Slab.Image(name, {Image = love_img, ReturnOnClick = true, Color = col, Scale = 0.4, Tooltip = tooltip})
        ui.toolbar_buttons_params[name .. "hovered"] = Slab.IsControlHovered()
        if Slab.IsControlClicked() and not disabled then
            on_click_func()
        end
        Slab.SameLine()
        Slab.Rectangle({W=2, H=10, Color={0,0,0,0}})
    end

    tb.toolbar_separator = function(w)
        Slab.Rectangle({W=w/2, H=1, Color={0,0,0,0}})
        Slab.SameLine()
        Slab.Rectangle({W=3, H=28, Color={1,1,1,.3}})
        Slab.SameLine()
        Slab.Rectangle({W=w/2, H=1, Color={0,0,0,0}})
        Slab.SameLine()
    end

    return tb
end

return tb
local Slab = require "Thirdparty.Slab.Slab"
local View = require "Visual.view"

local mb = {}

-- Functions to be called when UI buttons are clicked


mb.create_menu_bar = function(ui)

-- This must be called inside of a Menu
    local build_window_show_tree = function()
        if Slab.MenuItemChecked("All", ui.windows_visibility.all) then
            ui.windows_visibility.all = not ui.windows_visibility.all
        end
        if ui.windows_visibility.all then
            for k, _ in pairs(ui.windows_visibility) do
                ui.windows_visibility[k] = true
            end
        end
        Slab.Separator()
        for _, window in pairs(Interface.windows) do
            for name,_ in pairs(window.ui_settings) do
                if Slab.MenuItemChecked(name, ui.windows_visibility[name]) then
                    local new_val = not ui.windows_visibility[name]
                    ui.windows_visibility[name] = new_val
                    if not new_val then
                        ui.windows_visibility.all = false
                    end
                end
            end
        end
        Slab.Separator()
    end

    -- This must be called inside of a Menu
    local build_family_show_tree = function()
        if Slab.MenuItemChecked("All", ui.families_visibility.all) then
            ui.families_visibility.all = not ui.families_visibility.all -- toggled
        end
        if ui.families_visibility.all then
            for k, _ in pairs(ui.families_visibility) do
                ui.families_visibility[k] = true
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
            if Slab.MenuItemChecked(f.name .. " (" .. family_type .. ")", ui.families_visibility[f.name]) then
                local new_val = not ui.families_visibility[f.name]
                ui.families_visibility[f.name] = new_val
                if not new_val then
                    ui.families_visibility.all = false
                end
            end
        end
    end


    local menu_bar = function()
        -- Build menu bar
        if Slab.BeginMainMenuBar() then

            -- "File" section
            if Slab.BeginMenu("File") then
                if Slab.MenuItem("Load Model...") then
                    ui.on_click_functions.load_file()
                end

                -- Show "Reload file" option if file was loaded
                if ui.file_loaded_path then
                    if Slab.MenuItem("Reload Model") then
                        ui.on_click_functions.reload()
                    end
                end

                -- Show "Edit loaded file" option if file was loaded
                if ui.file_loaded_path then
                    if Slab.MenuItem("Edit loaded file") then
                        ui.on_click_functions.edit_file()
                    end
                end

                Slab.Separator()

                if Slab.MenuItem("Settings...") then
                end

                -- Show "Close" sim file
                if Slab.MenuItem("Close") then
                    GraphicEngine.reset_simulation()
                    ui.file_loaded_path = nil
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
                    if ui.file_loaded_path ~= nil then -- TODO: disabled menu item when Slab implements it
                        ui.on_click_functions.setup()
                    end
                end

                if Slab.MenuItem("Step") then
                    if ui.setup_executed then
                        ui.on_click_functions.step()
                    end
                end

                if Slab.MenuItem("Run") then
                    if ui.setup_executed then
                        ui.on_click_functions.go()
                    end
                end

                if Slab.MenuItem("Stop") then
                    if ui.setup_executed then
                        ui.on_click_functions.stop()
                    end
                end

                if Slab.MenuItem("Reset") then
                    if ui.file_loaded_path ~= nil then
                        ui.on_click_functions.reload()
                    end
                end

                if Slab.MenuItemChecked("Draw enabled", GraphicEngine.is_draw_enabled()) then
                    ui.on_click_functions.toggle_draw_enabled()
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
                    ui.on_click_functions.toggle_grid_visibility()
                end

                if Slab.MenuItemChecked("Show performance stats", ui.show_debug_graph) then
                    ui.on_click_functions.toggle_performance_stats()
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
                    ui.show_about_dialog = true
                end

                Slab.EndMenu()
            end

            Slab.EndMenuBar()
        end
    end
    return menu_bar
end

return mb
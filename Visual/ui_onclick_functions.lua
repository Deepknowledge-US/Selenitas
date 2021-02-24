local FileUtils          = require "Visual.fileutils"
local View      = require "Visual.view"

local ocf = {}

-- Functions to be called when UI buttons are clicked
ocf.create_functions = function(ui)
    ocf.setup = function()
        local err = GraphicEngine.setup_simulation()
        ui.setup_executed = not err
        if err then
            ui.show_error_message(err)
        end
    end

    ocf.step = function()
        local err = GraphicEngine.step_simulation()
        if err then
            ui.show_error_message(err)
        end
    end

    ocf.go = function()
        Simulation:start()
    end

    ocf.stop = function()
        Simulation:stop()
    end

    ocf.toggle_running = function()
        if Simulation.is_running then
            Simulation:stop()
        else
            Simulation:start()
        end
    end

    ocf.reload = function()
        ui.families_visibility = {all = true} -- new families added in update loop
        ui.windows_visibility = {all = false}
        ui.family_mobile_visibility = {all = false}
        ui.family_cell_visibility = {all = false}
        ui.family_rel_visibility = {all = false}
        GraphicEngine.reset_simulation()
        ui.load_model(ui.file_loaded_path)
    end

    ocf.load_file = function()
        ui.show_file_picker = true
    end

    ocf.close_editor = function()
        ui.show_file_editor = false
    end

    ocf.edit_file = function()
        FileUtils.open_in_editor(ui.file_loaded_path)
    end

    ocf.save_file = function()
      local Handle, Error = io.open(ui.file_loaded_path, "w")
      if Handle ~= nil then
        Handle:write(ui.Internal_Editor_Contents)
        Handle:close()
      end
    end

    ocf.toggle_draw_enabled = function()
        GraphicEngine.set_draw_enabled(not GraphicEngine.is_draw_enabled())
    end

    ocf.toggle_performance_stats = function()
        ui.show_debug_graph = not ui.show_debug_graph
    end

    ocf.toggle_families_visibility = function()
        -- TODO: Ideally this should show the same
        -- contextmenu as View > Families, but a Slab
        -- bug does not allow it: https://github.com/coding-jackalope/Slab/issues/56
        local visible = false
        for _, v in pairs(ui.families_visibility) do
            if v then
                visible = true
            end
        end
        for k, _ in pairs(ui.families_visibility) do
            if visible then
                ui.families_visibility[k] = false
            else
                ui.families_visibility[k] = true
            end
        end
    end

    ocf.toggle_windows_visibility = function()
        -- TODO: Ideally this should show the same
        -- contextmenu as View > Windows, but a Slab
        -- bug does not allow it: https://github.com/coding-jackalope/Slab/issues/56
        local visible = false
        for _, v in pairs(ui.windows_visibility) do
            if v then
                visible = true
            end
        end
        for k, _ in pairs(ui.windows_visibility) do
            if visible then
                ui.windows_visibility[k] = false
            else
                ui.windows_visibility[k] = true
            end
        end
    end

    ocf.toggle_grid_visibility = function()
        View.set_grid_enabled(not View.is_grid_enabled())
    end

    ocf.toggle_FamilyMobile_windows_visibility = function()
        local visible = false
        for _, v in pairs(ui.family_mobile_visibility) do
            if v then
                visible = true
            end
        end
        for k, _ in pairs(ui.family_mobile_visibility) do
            if visible then
                ui.family_mobile_visibility[k] = false
            else
                ui.family_mobile_visibility[k] = true
            end
        end
    end

    ocf.toggle_FamilyCell_windows_visibility = function()
        local visible = false
        for _, v in pairs(ui.family_cell_visibility) do
            if v then
                visible = true
            end
        end
        for k, _ in pairs(ui.family_cell_visibility) do
            if visible then
                ui.family_cell_visibility[k] = false
            else
                ui.family_cell_visibility[k] = true
            end
        end
    end

    ocf.toggle_FamilyRel_windows_visibility = function()
        local visible = false
        for _, v in pairs(ui.family_rel_visibility) do
            if v then
                visible = true
            end
        end
        for k, _ in pairs(ui.family_rel_visibility) do
            if visible then
                ui.family_rel_visibility[k] = false
            else
                ui.family_rel_visibility[k] = true
            end
        end
    end

    ocf.int_editor = function()
        local Handle, Error = io.open(ui.file_loaded_path, "r")
			if Handle ~= nil then
				ui.Internal_Editor_Contents = Handle:read("*a")
				Handle:close()
			end
        ui.show_file_editor = not show_file_editor
    end

    ocf.restore_zoom = function()
        View.set_zoom(1)
        Observer:set_zoom(1)
    end

    ocf.restore_center = function()
        View.reset_center()
        Observer:set_center( { 0, 0 } )
    end

    return ocf
end

return ocf
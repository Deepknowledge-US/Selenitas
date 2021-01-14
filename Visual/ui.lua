local Slab            = require "Thirdparty.Slab.Slab"
local DebugGraph      = require("Thirdparty.debuggraph.debugGraph")
local FileUtils       = require "Visual.fileutils"
local ed              = require "Visual.ui_internal_editor"
local mb              = require "Visual.ui_menu_bar"
local tb              = require "Visual.ui_tool_bar"
local sb              = require "Visual.ui_status_bar"
local w               = require "Visual.ui_windows"
local ocf             = require "Visual.ui_onclick_functions"
local sintax          = require "Visual.syntax_highlight"

local UI = {}

local tb_functs   = tb.create_tool_bar(UI)
local menu_bar    = mb.create_menu_bar(UI)
local winds       = w.create_functions(UI)
local internal_ed = ed.create_editor(UI)

UI.Selenitas_Syntax   = sintax
UI.status_bar         = sb.create_status_bar(UI)
UI.on_click_functions = ocf.create_functions(UI)

UI.toolbar                    = tb_functs.toolbar
UI.add_toolbar_button         = tb_functs.add_toolbar_button
UI.toolbar_separator          = tb_functs.toolbar_separator
UI.toolbar_buttons_params     = {
    base_color     = {0.549, 0.549, 0.549},
    hover_color    = {0.698, 0.698, 0.698},
    disabled_color = {0.352, 0.352, 0.352},
}

UI.params_window              = winds.params_window
UI.family_mobile_info_windows = winds.family_mobile_info_windows
UI.family_cell_info_windows   = winds.family_cell_info_windows
UI.family_rel_info_windows    = winds.family_rel_info_windows
UI.update_windows             = winds.update_windows

UI.families_visibility        = {all = true }
UI.windows_visibility         = {all = false}
UI.family_mobile_visibility   = {all = false}
UI.family_cell_visibility     = {all = false}
UI.family_rel_visibility      = {all = false}

UI.Internal_Editor            = {Title = "Selenitas Editor", AllowResize = false, AutoSizeWindow=true}
UI.Internal_Editor_FileDialog = false
UI.Internal_Editor_FileName   = ""
UI.Internal_Editor_Contents   = ""
UI.editor_font_size           = 14
UI.editor_font                = love.graphics.newFont(SLAB_FILE_PATH .. "Internal/Resources/Fonts/JuliaMono-Regular.ttf",editor_font_size)

UI.show_file_editor       = false
UI.show_file_picker       = false
UI.file_loaded_path       = nil
UI.show_about_dialog      = false
UI.show_debug_graph       = false
UI.error_msg              = nil
UI.speed_slider_value     = 20
UI.default_font           = love.graphics.newFont(12)
UI.fps_graph              = DebugGraph:new('fps', 0, 0, 100, 60, 0.5, nil, UI.default_font)
UI.mem_graph              = DebugGraph:new('mem', 0, 60, 100, 60, 0.5, nil, UI.default_font)

-- Simulation state trackers
UI.setup_executed = false

-- Internal editor view
UI.view_editor = internal_ed.view_editor

-- Wrapper for FileUtils.load_model_file,
-- Checks for errors and sets window name
UI.load_model = function(path)
    local err = FileUtils.load_model_file(path)
    if err then
        UI.show_error_message(err)
        UI.file_loaded_path = nil
    else
        UI.file_loaded_path = path
        local model_name = string.gsub(FileUtils.get_filename_from_path(path), ".lua", "")
        love.window.setTitle("Selenitas - " .. model_name)
    end
end

UI.file_picker = function()
    local result = Slab.FileDialog({Type = 'openfile', AllowMultiSelect = false})
    if result.Button ~= "" then
        UI.show_file_picker = false
        if result.Button == "OK" then
            -- Load selected file
            GraphicEngine.reset_simulation()
            UI.load_model(result.Files[1])
            if next(Interface.windows) ~= nil then
                -- Loaded simulation has params, show params windows
                for k, _ in pairs(UI.windows_visibility) do
                    UI.windows_visibility[k] = true
                end
            end
        end
    end
end

UI.about_dialog = function()
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
        UI.show_about_dialog = false
        Slab.CloseDialog()
    end
    Slab.EndLayout()
    Slab.EndDialog()
end


function UI.update(dt)
    -- Re-draw UI in each step
    Slab.Update(dt)
    -- Update families visibility settings
    -- Check for newly added families
    for _, f in pairs(Simulation.families) do
        if UI.families_visibility[f.name] == nil then
            UI.families_visibility[f.name] = true
        end
    end
    GraphicEngine.set_families_visibility(UI.families_visibility)

    menu_bar()

    -- Show file picker if selected
    if UI.show_file_picker then
        UI.file_picker()
    end

    -- Show about dialog if selected
    if UI.show_about_dialog then
        UI.about_dialog()
    end

    -- Show File Editor
    if UI.show_file_editor then
        UI.view_editor()
    end

    -- Show error message if needed
    if UI.error_msg ~= nil then
        local res = Slab.MessageBox("An error occurred", "An error occurred:\n " .. UI.error_msg)
        if res ~= "" then
            UI.error_msg = nil
        end
    end

    -- Get screen size
    UI.screen_w, UI.screen_h, _ = love.window.getMode()

    UI.toolbar()
    UI.status_bar()

    -- Update windows
    UI.update_windows()

    -- Update graphs
    UI.fps_graph:update(dt)
    UI.mem_graph:update(dt)
end

function UI.show_error_message(err)
    UI.error_msg = err
end

function UI.init()
    Slab.Initialize({})
    Slab.DisableDocks({'Left','Right','Bottom'})
--    Slab.PushFont(love.graphics.newFont(SLAB_FILE_PATH .. "Internal/Resources/Fonts/JuliaMono-Regular.ttf",14))
    Slab.PushFont(love.graphics.newFont(SLAB_FILE_PATH .. "Internal/Resources/Fonts/JuliaMono-Regular.ttf",14))
end

function UI.reset()
    UI.setup_executed           = false
    UI.windows_visibility       = { all = false }
    UI.family_mobile_visibility = {all = false}
    UI.family_cell_visibility   = {all = false}
    UI.family_rel_visibility    = {all = false}
    Interface:clear()
end

local function draw_debug_graphs()
    UI.screen_w, UI.screen_h, _ = love.window.getMode()
    UI.panel_width = 100 + 30
    UI.panel_height = 60 * 2 + 5
    UI.xpos = UI.screen_w - UI.panel_width - 20
    UI.ypos = UI.screen_h - UI.panel_height - 30
    -- Draw back panel
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", UI.xpos, UI.ypos, UI.panel_width, UI.panel_height)
    love.graphics.setColor(1, 1, 1, 1)
    -- Update graphs positions
    UI.fps_graph.x = UI.xpos
    UI.fps_graph.y = UI.ypos
    UI.mem_graph.x = UI.xpos
    UI.mem_graph.y = UI.ypos + 60
    UI.fps_graph:draw()
    UI.mem_graph:draw()
end

function UI.draw()
    Slab.Draw()
    if UI.show_debug_graph then
        draw_debug_graphs()
    end
end

return UI
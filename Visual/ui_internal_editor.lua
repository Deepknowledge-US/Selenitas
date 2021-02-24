local Slab            = require "Thirdparty.Slab.Slab"
local ResourceManager = require("Thirdparty.cargo.cargo").init("Resources")
local FileUtils       = require "Visual.fileutils"

local ed = {}

-- Functions to be called when UI buttons are clicked
ed.create_editor = function(ui)


    ed.view_editor = function()
        Slab.BeginWindow('Internal_Editor', ui.Internal_Editor)

        local model_name = string.gsub(FileUtils.get_filename_from_path(ui.file_loaded_path), ".lua", "")
            ui.Internal_Editor.Title = ("File: " .. model_name)

        ui.add_toolbar_button("Open_int_editor", ResourceManager.ui.open, false,
                "Open File", function() end) -- TODO
        Slab.SameLine()

        ui.add_toolbar_button("Save", ResourceManager.ui.save, ui.file_loaded_path == nil,
            "Save File", ui.on_click_functions.save_file)
        Slab.SameLine()

        ui.add_toolbar_button("Reload_int_editor", ResourceManager.ui.refresh, ui.file_loaded_path == nil,
            "Reload Model", ui.on_click_functions.reload)
        Slab.SameLine()

        ui.add_toolbar_button("New_int_editor", ResourceManager.ui.newfile, false,
            "New File", function() end) -- TODO
        Slab.SameLine()

        Slab.Rectangle({W=490, H=1, Color={0,0,0,0}})
        Slab.SameLine()

        ui.add_toolbar_button("Close_int_editor", ResourceManager.ui.close, false,
              "Close Editor", ui.on_click_functions.close_editor)

        Slab.Text(" ")

        Slab.Separator()

        Slab.SetScrollSpeed(20)

        Slab.PushFont(editor_font)

        if Slab.Input('Internal_Editor', {
            MultiLine = true,
            Text = ui.Internal_Editor_Contents,
            W = 700 ,
            H = 500,
        MultiLineW = 680,
            Highlight = ui.Selenitas_Syntax
        }) then
            ui.Internal_Editor_Contents = Slab.GetInputText()
        end
        Slab.PopFont()
        Slab.EndWindow()
    end

    return ed


end

return ed




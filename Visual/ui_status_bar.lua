local Slab = require "Thirdparty.Slab.Slab"
local ResourceManager    = require("Thirdparty.cargo.cargo").init("Resources")

local sb = {}

sb.create_status_bar = function(ui)

    local status_bar = function()

        local screen_w, screen_h = ui.screen_w, ui.screen_h
        local col = ui.toolbar_buttons_params.base_color
        -- Bottom status bar
        Slab.BeginWindow("StatusBar", {
            Title = "", -- No title means it shows no title border and is not movable
            X = 0,
            Y = screen_h - 29,
            W = ui.screen_w + 10,
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
        ui.toolbar_separator(15)

        -- "Speed" slider: it changes time_between_steps value
        Slab.SameLine()
        Slab.Image('Icon_time', {Image = ResourceManager.ui.time3, Color = col, Scale = 0.4})
        Slab.SameLine()
        Slab.Text(tostring(Simulation:get_time()))
        Slab.SameLine()
        Slab.Text("    Speed: ", {})
        Slab.SameLine()
        if Slab.InputNumberSlider("tbs_slider", ui.speed_slider_value, 0.0, 10.0, {step=1, W=100}) then
            ui.speed_slider_value = Slab.GetInputNumber()
            GraphicEngine.set_time_between_steps((math.log(11) - math.log (ui.speed_slider_value + 1))/math.log(11))
        end
        Slab.SameLine()
        Slab.Text("  ",{})
        Slab.SameLine()
        ui.toolbar_separator(15)

        -- Center point in View
        Slab.SameLine()
        ui.add_toolbar_button("Icon_center", ResourceManager.ui.center3, false,
        "Restore center", ui.on_click_functions.restore_center)
        Slab.SameLine()
        local center = Observer:get_center()
        Slab.Text( ' (' .. tostring(round(center[1],2)) .. ' , ' .. tostring(round(center[2],2)) .. ')  ' )
        Slab.SameLine()
        ui.toolbar_separator(15)

        -- Zoom in View
        Slab.SameLine()
        ui.add_toolbar_button("Icon_zoom", ResourceManager.ui.zoom2, false,
        "Restore zoom", ui.on_click_functions.restore_zoom)
        Slab.SameLine()
        Slab.Text( tostring(Observer:get_zoom_string()) )
        Slab.SameLine()
        ui.toolbar_separator(15)

        -- Mobils info
        local cells,mobils,rels = Simulation:number_of_agents()
        Slab.SameLine()
        ui.add_toolbar_button("Icon_mobils", ResourceManager.ui.family2, false,
        "Mobile families", ui.on_click_functions.toggle_FamilyMobile_windows_visibility )
        Slab.SameLine()
        Slab.Text(tostring(mobils))
        Slab.SameLine()
        ui.toolbar_separator(15)

        -- Cells info
        Slab.SameLine()
        ui.add_toolbar_button("Cells", ResourceManager.ui.cell, false,
            "Cell families", ui.on_click_functions.toggle_FamilyCell_windows_visibility )
        Slab.SameLine()
        Slab.Text(tostring(cells))
        Slab.SameLine()
        ui.toolbar_separator(15)

        -- Relationals info
        Slab.SameLine()
        ui.add_toolbar_button("Relationals", ResourceManager.ui.share2, false,
            "Relational families", ui.on_click_functions.toggle_FamilyRel_windows_visibility )
        Slab.SameLine()
        Slab.Text(tostring(rels))
        Slab.SameLine()
        ui.toolbar_separator(15)

        Slab.EndLayout()
        Slab.EndWindow()

    end

    return status_bar
end

return sb
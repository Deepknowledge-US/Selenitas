local Slab = require "Thirdparty.Slab.Slab"

local w = {}

w.create_functions = function(ui)

    w.params_window = function(title)
        local window = Interface.windows[title]

        -- Create panel for simulation params
        ui.windows_visibility[title] = Slab.BeginWindow("ParamWindow" .. title, {
            Title = title,
            X = window.x,
            Y = window.y,
            H = window.height,
            W = window.width,
            ContentW = window.width,
            AutoSizeWindow = false,
            AllowResize = true,
            IsOpen = ui.windows_visibility[title],
            NoSavedSettings = true
        })

        -- Layout to horizontally expand all controls
        Slab.BeginLayout("Layout", {
            ExpandW = true
        })

        for pos = 1, window.num_items do

            Slab.Rectangle({W=window.width - 4, H=2, Color={0,0,0,0}})

            local k = window.order[pos]
            local v = window.ui_settings[k]

            -- Checkbox
            if v.type == "boolean" then
                Slab.Text(k, {Color = {0.258, 0.529, 0.956}})
                if Slab.CheckBox(Interface.windows[title][k], "Enabled") then
                    Interface.windows[title][k] = not Interface.windows[title][k]
                end
            -- Monitor
            elseif v.type == "monitor" then
                Slab.Text(k .. ': ' .. tostring( global_vars[k] ) )
            -- Slider
            elseif v.type == "slider" then
                Slab.Text(k, {Color = {0.258, 0.529, 0.956}})
                if Slab.InputNumberSlider(k .. "Slider", Interface.windows[title][k], v.min, v.max, {Step = v.step}) then
                -- if Slab.InputNumberDrag(k .. "Slider", Interface.windows[title][k], v.min, v.max, v.step) then
                    Interface.windows[title][k] = Slab.GetInputNumber()
                end
            -- Number input
            elseif v.type == "input" then
                Slab.Text(k, {Color = {0.258, 0.529, 0.956}})
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

    w.family_mobile_info_windows = function(title)
        local window = Interface.family_mobile_windows[title]
        ui.family_mobile_visibility[title] = Slab.BeginWindow("ParamWindow" .. title, {
            Title = title,
            X = window.x,
            Y = window.y,
            W = window.width,
            ContentW = window.width,
            AutoSizeWindow = false,
            AllowResize = true,
            IsOpen =ui.family_mobile_visibility[title],
            NoSavedSettings = true
        })
        Slab.BeginLayout("Layout", {
            ExpandW = true
        })

        window:update_family_info()

        for _, param in next, window.order do
            Slab.Text(param .. ': ' .. window.info[param])
        end

        Slab.EndLayout()
        Slab.EndWindow()
    end

    w.family_cell_info_windows = function(title)
        local window = Interface.family_cell_windows[title]
        ui.family_cell_visibility[title] = Slab.BeginWindow("ParamWindow" .. title, {
            Title = title,
            X = window.x,
            Y = window.y,
            W = window.width,
            ContentW = window.width,
            AutoSizeWindow = false,
            AllowResize = true,
            IsOpen =ui.family_cell_visibility[title],
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

    w.family_rel_info_windows = function(title)
        local window = Interface.family_rel_windows[title]
        ui.family_rel_visibility[title] = Slab.BeginWindow("ParamWindow" .. title, {
            Title = title,
            X = window.x,
            Y = window.y,
            W = window.width,
            ContentW = window.width,
            AutoSizeWindow = false,
            AllowResize = true,
            IsOpen = ui.family_rel_visibility[title],
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

    w.update_windows = function()
        for k, _ in pairs(Interface.windows) do
            if ui.windows_visibility[k] == nil then
                ui.windows_visibility[k] = true
            end
            ui.params_window(k)
        end

        for k, _ in pairs(Interface.family_mobile_windows) do
            if ui.family_mobile_visibility[k] == nil then
                ui.family_mobile_visibility[k] = false
            end
            ui.family_mobile_info_windows(k)
        end

        for k, _ in pairs(Interface.family_cell_windows) do
            if ui.family_cell_visibility[k] == nil then
                ui.family_cell_visibility[k] = false
            end
            ui.family_cell_info_windows(k)
        end

        for k, _ in pairs(Interface.family_rel_windows) do
            if ui.family_rel_visibility[k] == nil then
                ui.family_rel_visibility[k] = false
            end
            ui.family_rel_info_windows(k)
        end
    end

    return w
end

return w
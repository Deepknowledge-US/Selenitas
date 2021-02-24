project = 'Selenitas'
description = 'A multiagent system simulator written in Lua'
full_description = [[
        TODO: A full description here.

        .
]]
file = {
        '.',
        exclude = {
                'conf.lua',
                'Thirdparty/',
                'Examples_without_graphical_engine/',
                'Resources',
                'Visual/Colors.lua',
                'Visual/syntax_highlight.lua',
                'Visual/ui.lua',
                'Visual/ui_internal_editor.lua',
                'Visual/ui_menu_bar.lua',
                'Visual/ui_onclick_functions.lua',
                'Visual/ui_status_bar.lua',
                'Visual/ui_tool_bar.lua',
                'Visual/ui_windows.lua'
                }
       }

not_luadoc=true
no_summary = true
no_return_or_parms = true
format = 'discount'

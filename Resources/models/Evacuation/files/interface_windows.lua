require 'Engine.utilities.utl_main'


local ci = {}

ci.create_interface = function()

    -- Create some parameters windows. They will be shown in the same order they have been created.
    Interface:create_window('peacefuls',{height=550})
    Interface:create_window('violents', {height=250})
    Interface:create_window('App',      {height=250})
    Interface:create_window('World',    {height=100})

    -- Create some inputs inside the windows
    Interface:create_boolean('App', 'app info?', true)
    Interface:create_slider( 'App', 'app mode', 0, 2, 1, 2)
    Interface:create_boolean('App', 'crowd running?', true)
    Interface:create_slider( 'App', 'what is a crowd?', 0, 20, 1, 20)
    Interface:create_boolean('App', 'first blood?', true)

    Interface:create_slider('World','visib mod', 0.0, 1.0, 0.01, 1.0)
    Interface:create_slider('World','sound mod', 0.0, 1.0, 0.01, 1.0)

    Interface:create_slider('peacefuls','num peacefuls', 0, 5000, 1, 20)
    Interface:create_slider('peacefuls','leaders percentage',  0.0, 1.0, 0.01, 0.25)
    Interface:create_slider('peacefuls','app percentage', 0.0, 1.0, 0.01, 0.5)
    Interface:create_slider('peacefuls','defense probability', 0.0, 1.0, 0.01, 0.1)
    Interface:create_slider('peacefuls','not alerted speed', 0.0, 1.0, 0.01, 0.5)
    Interface:create_slider('peacefuls','mean speed', 0.0, 2.0, 0.1, 2.0)
    Interface:create_slider('peacefuls','max speed deviation', 0.0, 1.0, 0.01, 0.15)
    Interface:create_slider('peacefuls','sensibility med', 0.0, 1.0, 0.01, 0.7)
    Interface:create_slider('peacefuls','sensibility deviation', 0.0, 1.0, 0.005, 0.015)

    Interface:create_slider('violents','num violents', 0, 10, 1, 1)
    Interface:create_slider('violents','shoot noise', 0.0, 1.0, 0.01, 0.5)
    Interface:create_slider('violents','attack prob', 0.0, 1.0, 0.01, 0.8)
    Interface:create_slider('violents','succes rate', 0.0, 1.0, 0.01, 0.5)
    Interface:create_slider('violents','attacker speed', 0.0, 1.0, 0.01, 0.5)

    -- Create some functions to acces the current values of sliders
    local getters = {
        app_info        = function() return Interface:get_value('app', 'app info?')         end,
        app_mode        = function() return Interface:get_value('App', 'app mode')          end,
        crowd_running   = function() return Interface:get_value('App', 'crowd running?')    end,
        crowd_number    = function() return Interface:get_value('App', 'what is a crowd?')  end,
        first_blood     = function() return Interface:get_value('App', 'first blood?')      end,

        visual_mod      = function() return Interface:get_value('World', 'visib mod') end,
        sound_mod       = function() return Interface:get_value('World', 'sound mod') end,

        num_peace       = function() return Interface:get_value('peacefuls', 'num peacefuls')        end,
        leaders_perc    = function() return Interface:get_value('peacefuls', 'leaders percentage')   end,
        app_perc        = function() return Interface:get_value('peacefuls', 'app percentage')       end,
        defense_prob    = function() return Interface:get_value('peacefuls', 'defense probability')  end,
        n_a_speed       = function() return Interface:get_value('peacefuls', 'not alerted speed')    end,
        med_speed       = function() return Interface:get_value('peacefuls', 'mean speed')           end,
        med_speed_dev   = function() return Interface:get_value('peacefuls', 'max speed deviation')  end,
        sensib_med      = function() return Interface:get_value('peacefuls', 'sensibility med')      end,
        sensib_dev      = function() return Interface:get_value('peacefuls', 'sensibility deviation')end,

        num_violents    = function() return Interface:get_value('violents', 'num violents')   end,
        shoot_noise     = function() return Interface:get_value('violents', 'shoot noise')    end,
        attack_prob     = function() return Interface:get_value('violents', 'attack prob')    end,
        success_rate    = function() return Interface:get_value('violents', 'success rate')   end,
        attacker_speed  = function() return Interface:get_value('violents', 'attacker speed') end
    }

    return getters
end

return ci
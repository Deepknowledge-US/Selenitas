------------------
-- Graphic Engine used to visualize implemented simulations.
-- @module
-- graphicengine

local GraphicEngine = {}

require 'Engine.utilities.utl_main'
local UI   = require 'Visual.ui'
local View = require 'Visual.view'
local Draw = require 'Visual.draw'

-- Simulation info
local setup_executed = false

-- Time handling
local time_between_steps = 0
local _time_acc          = 0

-- Drawing settings
local draw_enabled         = true
local families_visibility  = {}
local background_color_set = {0, 0, 0}


-- A mqtt subscriptor will be launched in a thread and a publisher in another.
local thread_subscriptor = require "Visual.subscriptor_thread"
local thread_publisher   = require "Visual.publisher_thread"

------------------
-- Inits the graphic engine. Called on program startup.
-- @function init
function GraphicEngine.init()
    -- TODO: read user settings
    love.window.setMode(900,600, {resizable=true, minwidth=400, minheight=300})
    love.window.setTitle("Selenitas")
    View.init()
end

------------------
-- Resets the simulation. Calls Simulation: reset and resets UI-specific parameters
-- @function reset_simulation
function GraphicEngine.reset_simulation()
    -- Simulation info
    Simulation: reset()
    setup_executed = false
    love.window.setTitle("Selenitas")
    GraphicEngine.set_background_color(0, 0, 0)
    View.reset()
    UI.reset()
end

------------------
-- Setups the simulation. Calls Simulation: setup catching any possible errors when running it
-- @function setup_simulation
-- @return ret_err Returns error string. If no error happened, nil is returned.
function GraphicEngine.setup_simulation()
    local ret_err = nil -- return error if any
    if SETUP then
        local ok, err = pcall(SETUP)
        if not ok then
            ret_err = err
            return ret_err
        end
        setup_executed = true
        Simulation: stop() -- Reset 'go' in case Setup button is pressed more than once
    end
    return ret_err
end

------------------
-- Runs a step of the simulation. Calls step function catching any possible errors when running it
-- @function step_simulation
-- @return ret_err Returns error string. If no error happened, nil is returned.
function GraphicEngine.step_simulation()
    local ret_err = nil -- return error if any
    if STEP then
        local ok, err = pcall(STEP)
        if not ok then
            ret_err = err
        else
            Simulation.time = Simulation.time + 1
        end
    end
    return ret_err
end

------------------
-- Enables drawing. If set to false, only a black screen will be rendered. Useful for running simulations
-- where the drawing is not essential.
-- @function set_draw_enabled
-- @param enabled Whether the drawing is enabled.
function GraphicEngine.set_draw_enabled(enabled)
    draw_enabled = enabled
    if not draw_enabled then
        -- If draw disabled, set background color to black
        love.graphics.setBackgroundColor(0, 0, 0)
    else
        -- Set previous background color again if drawing is resumed
        love.graphics.setBackgroundColor(background_color_set)
    end
end

function GraphicEngine.is_draw_enabled()
    return draw_enabled
end

------------------
-- Sets visibility for families in the simulation. Used internally by UI module.
-- @function set_families_visibility
-- @param table Table with family names as keys and visibility (boolean) as values.
function GraphicEngine.set_families_visibility(table)
    families_visibility = table
end

------------------
-- Sets time between steps in seconds for better visualization
-- @function set_time_between_steps
-- @param t time in seconds.
function GraphicEngine.set_time_between_steps(t)
    time_between_steps = t
end

------------------
-- Sets the world background color in RGB format. If this is not called, the background color will be black.
-- @param r Red channel of the color. Must be in the 0..1 range.
-- @param g Green channel of the color. Must be in the 0..1 range.
-- @param b Blue channel of the color. Must be in the 0..1 range.
function GraphicEngine.set_background_color(r, g, b)
    love.graphics.setBackgroundColor(r, g, b)
    background_color_set = {r, g, b}
end

------------------
-- This function processes the received message.
-- @param msg An mqtt message.
function process_msg(msg)
    print( 'processing... ' .. msg )
    if msg == 'Step' then
        GraphicEngine.step_simulation()
    elseif msg == 'Run' then
        if Simulation.is_running then
            Simulation:stop()
        else
            Simulation:start()
        end
    elseif msg == 'Setup' then
        GraphicEngine.setup_simulation()
    elseif msg == 'Reload' then
        GraphicEngine.reset_simulation()
        UI.load_model(UI.file_loaded_path)
    elseif msg == 'Load' then
        GraphicEngine.reset_simulation()
        local path = user_cwd .. '/Resources/models/evacuation/evacuation.lua'
        UI.load_model(path)
    elseif string.find(msg,'Update') then
        local splited = split(msg,'/')
        local window, param, new_val = splited[2],splited[3],splited[4]
        if new_val then
            if new_val == 'true' or new_val == 'false' then
                Interface.windows[window][param] = new_val == 'true' and true or false
            else
                Interface.windows[window][param] = tonumber(new_val)
            end
        end
    end
end

-- LOVE2D load function
function love.load()
    thread       = love.thread.newThread(thread_subscriptor)
    thread_pub   = love.thread.newThread(thread_publisher)

    panels_channel  = love.thread.getChannel( 'new_panel' )
    state_channel   = love.thread.getChannel( 'new_state' )
    control_channel = love.thread.getChannel( 'new_order' )

    thread:start()
    thread_pub:start()

    open_url("Visual_js/react/index.html")

    UI.init()
    Draw.init()
end

-- Main update function
function love.update(dt)
    -- Update UI widgets
    UI.update(dt)

    -- Make sure no errors occured
    local error = thread:getError()
    assert( not error, error )

    -- Check for new control instructions
    local info = love.thread.getChannel( 'info' ):pop()
    if info then
        process_msg(info)
    end

    if not Simulation.is_running then
        do return end
    end

    -- Skips until time between steps is covered
    _time_acc   = _time_acc + dt
    if _time_acc >= time_between_steps then
        -- Steps the simulation if it is running
        if Simulation.is_running then
            local err = GraphicEngine.step_simulation()
            if err then
                -- Show error if any and stop the simulation
                UI.show_error_message(err)
                Simulation: stop()
            end
        end
        _time_acc = 0
    end
end

-- Drawing function
function love.draw()
    -- Attach camera
    View.start()

    -- If draw enabled, draw families in z-orders
    if setup_executed and draw_enabled then
        for _, fam in sorted(Simulation.families, 'z_order') do
            -- Only draw family if it is visible
            if families_visibility[fam.name] then
                if fam: is_a(FamilyMobile) then
                    Draw.draw_agents_family(fam)
                elseif fam: is_a(FamilyRelational) then
                    Draw.draw_links_family(fam)
                else
                    Draw.draw_cells_family(fam)
                end
            end
        end
    end

    -- Detach camera
    View.finish()
    -- Draw UI widgets on top of everything
    UI.draw()
end

return GraphicEngine
------------------
-- Graphic Engine used to visualize implemented simulations.
-- @module
-- graphicengine

require 'Engine.utilities.utl_main'
local UI = require 'Visual.ui'
local View = require 'Visual.view'
local Draw = require 'Visual.draw'

local GraphicEngine = {}

-- Simulation info
local setup_executed = false

-- Time handling
local time_between_steps = 0
local _time_acc = 0

-- Drawing settings
local draw_enabled = true
local grid_enabled = false
local families_visibility = {}
local background_color_set = {0, 0, 0}

function GraphicEngine.init()
    -- TODO: read user settings
    love.window.setMode(900,600, {resizable=true, minwidth=400, minheight=300})
    love.window.setTitle("Selenitas")
    View.init()
end

function GraphicEngine.reset_simulation()
    -- Simulation info
    Simulation:reset()
    setup_executed = false
    love.window.setTitle("Selenitas")
    GraphicEngine.set_background_color(0, 0, 0)
    View.reset()
    UI.reset()
end

function GraphicEngine.setup_simulation()
    local ret_err = nil -- return error if any
    if SETUP then
        local ok, err = pcall(SETUP)
        if not ok then
            ret_err = err
            return ret_err
        end
        setup_executed = true
        Simulation:stop() -- Reset 'go' in case Setup button is pressed more than once
    end
    return ret_err
end

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

function GraphicEngine.set_grid_enabled(enabled)
    grid_enabled = enabled
end

function GraphicEngine.is_grid_enabled()
    return grid_enabled
end

-- Table with family_name:visibility (boolean)
-- Used internally by UI module
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

-- LOVE2D load function
function love.load()
    UI.init()
    Draw.init()
end

-- Main update function
function love.update(dt)
    UI.update(dt)

    if not Simulation.is_running then
        do return end
    end

    -- Skips until time between steps is covered
    _time_acc = _time_acc + dt
    if _time_acc >= time_between_steps then
        if Simulation.is_running then
            local err = GraphicEngine.step_simulation()
            if err then
                UI.show_error_message(err)
                Simulation:stop()
            end
        end
      _time_acc = 0
    end
end

-- Drawing function
function love.draw()
    View.start()

    -- Translate (0, 0) to center of the screen (local scope to avoid goto-jump issues)
    do
        local sw, sh, _ = love.window.getMode()
        love.graphics.translate(sw / 2, sh / 2)
    end

    if grid_enabled then
        Draw.draw_scalable_grid(2)
    end

    if setup_executed and draw_enabled then
        -- Draw families in order
        for _, fam in sorted(Simulation.families, 'z_order') do
            if families_visibility[fam.name] then
                if fam:is_a(FamilyMobile) then
                    Draw.draw_agents_family(fam)
                elseif fam:is_a(FamilyRelational) then
                    Draw.draw_links_family(fam)
                else
                    Draw.draw_cells_family(fam)
                end
            end
        end
    end

    View.finish()
    UI.draw()
end

return GraphicEngine
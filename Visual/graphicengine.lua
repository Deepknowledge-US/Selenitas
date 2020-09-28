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
local agents_families = {}
local links_families = {}
local cells_families = {}

-- Time handling
local time_between_steps = 0
local _time_acc = 0

function GraphicEngine.init()
    -- TODO: read user settings
    love.window.setMode(900,600, {resizable=true, minwidth=400, minheight=300})
    love.window.setTitle("Selenitas")
    View.init()
end

function GraphicEngine.reset_simulation()
    -- Simulation info
    agents_families = {}
    links_families = {}
    cells_families = {}
    Simulation:stop()
    setup_executed = false
    love.window.setTitle("Selenitas")
    GraphicEngine.set_background_color(0, 0, 0)
    clear("all")
    View.reset()
    UI.reset()
end

function GraphicEngine.setup_simulation()
    local ret_err = nil -- return error if any
    if SETUP then
        local ok, err = pcall(SETUP)
        if not ok then
            ret_err = err
            goto skipsetup
        end
        setup_executed = true
        -- This loop can be moved to draw loop for direct family retrieval when z-order is implemented
        for k, f in ipairs(Simulation.families) do
            if f:is_a(FamilyMobil) then
                table.insert(agents_families, f)
            elseif f:is_a(FamilyRelational) then
                table.insert(links_families, f)
            elseif f:is_a(FamilyCell) then
                table.insert(cells_families, f)
            end
        end
        Simulation:stop() -- Reset 'go' in case Setup button is pressed more than once
    end
    ::skipsetup::
    return ret_err
end

function GraphicEngine.step_simulation()
    local ret_err = nil -- return error if any
    if STEP then
        local ok, err = pcall(STEP)
        if not ok then
            ret_err = err
        end
    end
    return ret_err
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
end

-- LOVE2D load function
function love.load()
    UI.init()
    Draw.init()
end

-- Main update function
function love.update(dt)
    UI.update(dt)
    View.update()

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
                Simulation.stop()
            end
        end
      _time_acc = 0
    end
end

-- Drawing function
function love.draw()
    View.start()

    if not setup_executed then
        goto skip
    end

    -- Translate (0, 0) to center of the screen (local scope to avoid goto-jump issues)
    do
        local sw, sh, _ = love.window.getMode()
        love.graphics.translate(sw / 2, sh / 2)
    end

    -- Draw families in order
    -- TODO: implement z-order to draw all families on same loop
    for _, family in pairs(cells_families or {}) do
        Draw.draw_cells_family(family)
    end
    for _, family in pairs(links_families or {}) do
        Draw.draw_links_family(family)
    end
    for _, family in pairs(agents_families or {}) do
        Draw.draw_agents_family(family)
    end

    ::skip::
    View.finish()
    UI.draw()
end

return GraphicEngine
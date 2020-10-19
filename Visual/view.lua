------------------
-- Class for controlling view of the simulation
-- @module
-- view

local View = {}

local Camera = require("Thirdparty.hump.camera")
local Slab = require "Thirdparty.Slab.Slab"
local Grid = require "Thirdparty.editgrid.editgrid"
local Input = require("Visual.input")

local camera = nil
local grid = nil
local grid_enabled = false

local grid_visuals = {
    size = 100,
    subdivisions = 10,
    drawScale = false,
    fadeFactor = 0.2,
    textFadeFactor = 0.5,
    hideOrigin = false
}

-- Add callback for mouse movement
Input.add_mouse_moved_callback_func(
    function(x, y, dx, dy)
        if Input.is_mouse_button_pressed(2) then
            camera:move(-dx / camera.scale, -dy / camera.scale)
            Observer:set_center({camera.x / Draw.get_coord_scale(), -camera.y / Draw.get_coord_scale()})
        end
    end
)

-- Add callback for scroll (zoom)
Input.add_scroll_callback_func(
    function(dx, dy)
      if Slab.IsVoidHovered() then
        local inc = 1 + dy / 25
        camera:zoom(inc)
        -- Zoom to mouse position
        local tx, ty = camera:position()
        local wx, wy = camera:mousePosition()
        camera:move((wx - tx) * (1 - 1 / inc), (wy - ty) * ( 1 - 1 / inc))
        local exponent = math.log10(Grid.getGridInterval(grid_visuals, camera.scale)) - 1
        Observer:set_zoom(exponent)
        Observer:set_center({camera.x / Draw.get_coord_scale(), -camera.y / Draw.get_coord_scale()})
      end
    end
)

------------------
-- Inits view module
-- @function init
function View.init()
    camera = Camera(0, 0)
    grid = Grid.grid(camera, grid_visuals)
    Observer:set_center({0, 0})
    Observer:set_zoom(1)
end

------------------
-- Resets view to initial state
-- @function reset
function View.reset()
    camera:lookAt(0, 0)
    camera:zoomTo(1)
    Observer:set_center({0, 0})

    local exponent = math.log10(Grid.getGridInterval(grid_visuals, camera.scale)) - 1
    Observer:set_zoom(exponent)
end

------------------
-- Sets zoom value
-- @function set_zoom
-- @param z Zoom value
function View.set_zoom(z)
    camera:zoomTo(z)

    local exponent = math.log10(Grid.getGridInterval(grid_visuals, camera.scale)) - 1
    Observer:set_zoom(exponent)
end

------------------
-- Resets view centert
-- @function reset_center
function View.reset_center()
    camera:lookAt(0,0)
    Observer:set_center({0, 0})
end

------------------
-- Starts view and attaches camera and grid
-- @function start
function View.start()
    if grid_enabled then
        grid:draw()
        grid:push()
    else
        camera:attach()
    end
end

------------------
-- Finishes view and dettaches camera and grid
-- @function finish
function View.finish()
    if grid_enabled then
        love.graphics.pop()
    else
        camera:detach()
    end
end

------------------
-- Set grid enabled status
-- @function set_grid_enabled
-- @param enabled Whether to enable grid visibility
function View.set_grid_enabled(enabled)
    grid_enabled = enabled
end

------------------
-- Gets grid visibility
-- @function is_grid_enabled
-- @return grid_enabled Returns whether the grid is enabled
function View.is_grid_enabled()
    return grid_enabled
end

return View
local Camera = require("Thirdparty.hump.camera")
local Slab = require "Thirdparty.Slab.Slab"
local Grid = require "Thirdparty.editgrid.editgrid"
local Input = require("Visual.input")

local View = {}

local camera = nil
local grid = nil
local grid_enabled = false

local visuals = {
    size = 100,
    subdivisions = 10,
    drawScale = false,
    fadeFactor = 0.2,
    textFadeFactor = 0.5,
    hideOrigin = false
}

-- Callbacks for Input
Input.add_mouse_moved_callback_func(
    function(x, y, dx, dy)
        if Input.is_mouse_button_pressed(2) then
            camera:move(-dx / camera.scale, -dy / camera.scale)

            local worldX, worldY = camera:worldCoords( x,y )
            Observer:set_center( { round(worldX - x, 3), round(worldY + y, 3) } )
        end
    end
)

Input.add_scroll_callback_func(
    function(dx, dy)
      if Slab.IsVoidHovered() then
        local inc = 1 + dy / 25
        camera:zoom(inc)
        Observer:set_zoom( round(camera.scale,3) )
        -- Zoom to mouse position
        local tx, ty = camera:position()
        local wx, wy = camera:mousePosition()
        camera:move((wx - tx) * (1 - 1 / inc), (wy - ty) * ( 1 - 1 / inc))
      end
    end
)

function View.init()
    camera = Camera(0, 0)
    grid = Grid.grid(camera, visuals)
    Observer:set_center( { camera.x, camera.y } )
end

function View.reset()
    camera:lookAt(0, 0)
    camera:zoomTo(1)
    Observer:set_center( { camera.x, camera.y } )
    Observer:set_zoom( camera.scale )
end

function View.start()
    if grid_enabled then
        grid:draw()
        grid:push()
    else
        camera:attach()
    end
end

function View.finish()
    if grid_enabled then
        love.graphics.pop()
    else
        camera:detach()
    end
end

function View.set_grid_enabled(enabled)
    grid_enabled = enabled
end

function View.is_grid_enabled()
    return grid_enabled
end

return View
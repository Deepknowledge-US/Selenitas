local Camera = require("Thirdparty.hump.camera")
local Input = require("Visual.input")
local Slab = require "Thirdparty.Slab.Slab"

local View = {}

local camera = nil

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
    local w, h, _ = love.window.getMode()
    camera = Camera(w / 2, h / 2)
    Observer:set_center( { camera.x, camera.y } )
end

function View.reset()
    local w, h, _ = love.window.getMode()
    camera:lookAt(w / 2, h / 2)
    camera:zoomTo(1)
    Observer:set_center( { camera.x, camera.y } )
    Observer:set_zoom( camera.scale )
end

function View.start()
    camera:attach()
end

function View.finish()
    camera:detach()
end

return View
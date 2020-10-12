local Camera = require("Thirdparty.brady.camera")
local Input = require("Visual.input")
local Slab = require "Thirdparty.Slab.Slab"

local View = {}

local camera = nil

-- Callbacks for Input
Input.add_mouse_moved_callback_func(
    function(x, y, dx, dy)
        if Input.is_mouse_button_pressed(2) then
            camera:translate(-dx / camera.scale, -dy / camera.scale)

            local worldX, worldY = camera:getWorldCoordinates( x,y )
            -- print(x,y)
            Observer:set_center( { round(worldX - x, 3), round(worldY + y, 3) } )
        end
    end
)

Input.add_scroll_callback_func(
    function(dx, dy)
      if Slab.IsVoidHovered() then
        local inc = 1 + dy / 25
        camera:scaleToPoint(inc)
        Observer:set_zoom( round(camera.scale,3) )
      end      
    end
)

function View.init()
    local w, h, _ = love.window.getMode()
    camera = Camera(w, h, {translationX = w / 2, translationY = h / 2,
        resizable = true, maintainAspectRatio = true})
    Observer:set_center( { camera.x, camera.y } )
end

function View.reset()
    local w, h, _ = love.window.getMode()
    camera:setTranslation(w / 2, h / 2)
    camera:setScale(1)

    Observer:set_center( { camera.x, camera.y } )
    Observer:set_zoom( camera.scale )
end

function View.update()
    camera:update()
end

function View.start()
    camera:push()
end

function View.finish()
    camera:pop()
end

return View
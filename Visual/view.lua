local Camera = require("Thirdparty.brady.camera")
local Input = require("Visual.input")

local View = {}

local camera = nil

-- Callbacks for Input
Input.add_mouse_moved_callback_func(
    function(x, y, dx, dy)
        if Input.is_mouse_button_pressed(2) then
            camera:translate(-dx / camera.scale, -dy / camera.scale)
        end
    end
)
Input.add_scroll_callback_func(
    function(dx, dy)
        local inc = 1 + dy / 25
        camera:scaleToPoint(inc)
    end
)

function View.init()
    local w, h, _ = love.window.getMode()
    camera = Camera(w, h, {translationX = w / 2, translationY = h / 2,
        resizable = true, maintainAspectRatio = true})
end

function View.reset()
    local w, h, _ = love.window.getMode()
    camera:setTranslation(w / 2, h / 2)
    camera:setScale(1)
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
require "graphicengine"

GraphicEngine.set_agents({
    {x = 10, y = 10, shape = "rectangle", color = {1, 0, 0, 1}},
    {x = 20, y = 20, shape = "triangle"},
    {x = 30, y = 30, shape = "circle"},
    {x = 40, y = 40, color = {0, 1, 0, 1}},
})
GraphicEngine.set_viewport_size(400, 400)
GraphicEngine.set_background_color(0.3, 0.3, 0.3)
GraphicEngine.init()
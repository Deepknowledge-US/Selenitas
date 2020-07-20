require "graphicengine"

GraphicEngine.set_agents({
    {x = 10, y = 10, shape = "rectangle"},
    {x = 10, y = 20, shape = "triangle"},
    {x = 10, y = 30, shape = "circle"},
    {x = 10, y = 40},
})
GraphicEngine.set_viewport_size(400, 400)
GraphicEngine.init()
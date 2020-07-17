require "graphicengine"

GraphicEngine.set_agents({
    {x = 10, y = 10},
    {x = 10, y = 20},
    {x = 10, y = 30},
    {x = 10, y = 40},
})
GraphicEngine.set_viewport_size(400, 400)
GraphicEngine.init()
require "graphicengine"

GraphicEngine.set_agents({
    {xcor = 10, ycor = 10, shape = "rectangle", color = {1, 0, 0, 1}},
    {xcor = 20, ycor = 20, shape = "triangle"},
    {xcor = 30, ycor = 30, shape = "circle"},
    {xcor = 40, ycor = 40, color = {0, 1, 0, 1}},
})
GraphicEngine.set_viewport_size(400, 400)
GraphicEngine.set_background_color(0.3, 0.3, 0.3)
GraphicEngine.init()
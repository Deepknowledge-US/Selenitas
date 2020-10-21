--[[
    An example of growing and cloning of agents.

    It uses customized methods for families and several standard methods
    (die, clone) and agent properties (alive)
]]

------------
-- Interface
------------

Interface:create_slider('Density', 0, 100, 1, 50)



------------------------
-- Pre-creation of cells
------------------------

-- Create a Family of Estructural Agents
declare_FamilyCell('Cells')

-- Create cells and give a grid structure to them
Cells:create_grid(60,60,-30,-30) -- width, height, offset x, offset y

local function pred_is_alive(c)
    return c.is_alive
end

-----------------
-- Setup Function
-----------------

SETUP = function()

Simulation.time = 0

for _,c in ordered(Cells) do
        c.is_alive = (math.random(100) < Interface:get_value('Density')) 
        c.color   = c.is_alive and {1,1,1,1} or {0.1,0.1,0.1,1}
    end

end

-----------------
-- Step Function
-----------------

STEP = function()

    -- A stop condition. We stop when the number of ticks is reached or when there are no agents alive
    local vivos = Cells:with(pred_is_alive)

    if vivos.count == 0 then
        Simulation:stop()
    end

    for _,c in ordered(Cells) do
        c.alive_neighbors = (c.neighbors:with(pred_is_alive)).count
    end

    for _,c in ordered(Cells) do
        if c.alive_neighbors == 3 then 
            c.is_alive = true 
        else
            if c.alive_neighbors ~= 2 then
                c.is_alive = false
            end
        end
        c.color = c.is_alive and {1,1,1,1} or {0.1,0.1,0.1,1}
    end
end

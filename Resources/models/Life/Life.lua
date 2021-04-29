--[[
    Classical Game of Life using Cell Families
]]

------------
-- Interface
------------

-- Initial proportion of alive cells

Interface:create_slider('World_Size', 0, 500, 1, 100)
Interface:create_slider('Density', 0, 100, 1, 50)

panels_channel:push(Interface.windows)

---------------------
-- Auxiliar Functions
---------------------

local function pred_is_alive(c)
    return c.is_alive
end


-----------------
-- Setup Function
-----------------

SETUP = function()

    -- We don't reset everything to reuse the grid of cells between simulations
    -- Restart the time
    Simulation.time = 0

    -- Create a Family of Structural Agents
    declare_FamilyCell('Cells')

    -- Create cells and give a grid structure to them
    local ws = Interface:get_value('World_Size')
    Cells:create_grid(ws, ws, -ws/2, -ws/2) -- width, height, offset x, offset y


    -- Set (and color) the alive cells folowwing Density in the interface
    for _,c in ordered(Cells) do
        c.is_alive = (math.random(100) < Interface:get_value('Density')) 
        c.color   = c.is_alive and {1,1,1,1} or {0.1,0.1,0.1,1}
    end

end

-----------------
-- Step Function
-----------------

STEP = function()

    -- A stop condition. We stop when there are no alive cells
    local alive_cells = Cells:with(pred_is_alive)
    if alive_cells.count == 0 then
        Simulation:stop()
    end

    -- Compute and store in every cell the alive neighbors
    for _,c in ordered(Cells) do
        c.alive_neighbors = (c.neighbors:with(pred_is_alive)).count
    end

    -- Apply GoL rule to every cell.
    --   As we precompute the neighbors in the previous blosk, we can do it ordered
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

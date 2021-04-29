--[[
    Classical Game of Life using Cell Families
    Optimized version using collections to store the areas that can change
]]

------------
-- Interface
------------

-- Initial proportion of alive cells

Interface:create_slider('World_Size', 0, 500, 10, 20)
Interface:create_slider('Density', 0, 100, 1, 50)

---------------------
-- Auxiliar Functions
---------------------

local function pred_is_alive(c)
    return c.is_alive
end

---------------------
-- Auxiliar variables
---------------------

-- Collection to store the cells that must be checked in every step
-- In each step, only cells that change and their neighbors must be 
-- updated in the dynamics of the system. This dramatically reduce
-- the computational resources needed in every iteration.
local cells_to_check = Collection()

-----------------
-- Setup Function
-----------------

SETUP = function()

    -- We don't reset everything to reuse the grid of cells between simulations
    -- Restart the time
    Simulation:reset()

    -- Create a Family of Structural Agents
    declare_FamilyCell('Cells')

    -- Create cells and give a grid structure to them
    local ws = Interface:get_value('World_Size')
    Cells:create_grid(ws, ws, -ws/2, -ws/2) -- width, height, offset x, offset y

    -- Set (and color) the alive cells folowwing Density in the interface
    -- Initially, setup the cells_to_check collection from alive cells and their 
    -- neighbors
    for _,c in ordered(Cells) do
        c.is_alive = (math.random(100) < Interface:get_value('Density')) 
        c.color   = c.is_alive and {1,1,1,1} or {0.1,0.1,0.1,1}
        if c.is_alive then
            cells_to_check:add(c)
            for _, c1 in ordered(c.neighbors) do
                cells_to_check:add(c1)
            end
        end
    end

end

-----------------
-- Step Function
-----------------

STEP = function()

    -- A stop condition. We stop when there are no alive cells
    -- We could add periodical conditions to stop, but it is 
    -- harder to detect
    local alive_cells = Cells:with(pred_is_alive)
    if alive_cells.count == 0 then
        Simulation:stop()
    end

    -- Compute and store in every cell the alive neighbors
    for _,c in ordered(cells_to_check) do
        c.alive_neighbors = (c.neighbors:with(pred_is_alive)).count
    end

    -- Apply GoL rule to every cell.
    --   As we precompute the neighbors in the previous block, we can do it ordered
    local temp
    for _,c in ordered(cells_to_check) do
        temp = c.is_alive
        if c.alive_neighbors == 3 then 
            c.is_alive = true 
        else
            if c.alive_neighbors ~= 2 then
                c.is_alive = false
            end
        end
        c.color = c.is_alive and {1,1,1,1} or {0.1,0.1,0.1,1}
        -- Update the cells_to_check by:
        --   Adding the changing cells and
        --   Removing the static cells (alive or died)
        if c.is_alive ~= temp then
            cells_to_check:add(c)
        else
            cells_to_check:remove(c)
        end
    end
    -- Adding the neighbos of changing cells to cells_to check
    for _,c in ordered(cells_to_check) do
        for _, c1 in ordered(c.neighbors) do
            cells_to_check:add(c1)
        end
    end

end

--[[
    Classical Game of Life using Cell Families
]]

------------
-- Interface
------------

-- Number of Mobile Agents
Interface:create_slider('N_Mobiles', 0, 10, 1, 5)


panels_channel:push(Interface.windows)

-----------------
-- Setup Function
-----------------

SETUP = function()

    -- We don't reset everything to reuse the grid of cells between simulations
    -- Restart the time
    Simulation:reset()

    -- Create a Family of Structural Agents
    declare_FamilyCell('Cells')
    Cells:create_grid(40,40,0,0) -- width, height, offset x, offset y

    -- Set color of the cells
    for _,c in ordered(Cells) do
        c.color   = {1,1,1,.5}
        c.food    = 1             -- food to be stored in the cell
    end

    -- Create a Family of mobile agents
    declare_FamilyMobile('Agents')
    for i = 1, Interface:get_value('N_Mobiles') do
        Agents:new({
            shape = "circle"
            ,pos  = copy(one_of(Cells).pos)
            ,color = {0,0,1,1}
            ,scale = 1
        })
    end

end

-----------------
-- Step Function
-----------------

STEP = function()

    for _,ag in ordered(Agents) do
        -- Every agent move to one neighbors cell
        local c = Cells:cell_of(ag)
        ag:move_to((c.neighbors):one_of())

        -- consume some food there
        c = Cells:cell_of(ag)
        c.food = c.food - .2
        c.food = c.food < 0 and 0 or c.food
        c.color = {c.food,c.food,c.food,.5}
    end

    -- Food grow slowly in the cells
    for _,c in ordered(Cells) do
        c.food = c.food + .001
        c.food = c.food > 1 and 1 or c.food
        c.color = {c.food,c.food,c.food,.5}
    end

end

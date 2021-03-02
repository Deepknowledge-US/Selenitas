--[[
    Combined use of cells and Mobile Agents
]]

------------
-- Interface
------------

-- Number of Mobile Agents
Interface:create_slider('N_Mobiles', 0, 200, 1, 30)
Interface:create_slider('Size_World',0,100,1,50)
Interface:create_slider('Voracity',0,100,1,20)
Interface:create_slider('Growth',0,100,1,20)

-----------------
-- Setup Function
-----------------

SETUP = function()

    -- We reset everything
    Simulation:reset()

    -- Create a Family of Structural Agents
    declare_FamilyCell('Cells')
    sw = Interface:get_value('Size_World')
    hs = math.floor(sw/2)
    Cells:create_grid(sw,sw,-hs,-hs) -- width, height, offset x, offset y

    -- Set color of the cells
    for _,c in ordered(Cells) do
        c.color   = color('green')    -- Green color
        c.food    = 1             -- food to be stored in the cell
    end

    -- Create a Family of mobile agents
    declare_FamilyMobile('Agents')
    n_mobiles = Interface:get_value('N_Mobiles')
    for i = 1, n_mobiles do
        Agents:new({
            shape = "circle",
            pos  = copy(one_of(Cells).pos),
            color = color('blue'),
            scale = 1
        })
    end

end

-----------------
-- Step Function
-----------------

STEP = function()
    vor = Interface:get_value('Voracity')/100
    gro = Interface:get_value('Growth')/10000
    for _,ag in ordered(Agents) do
        -- Every agent move to one neighbors cell
        local c = Cells:cell_of(ag)
        ag:move_to((c.neighbors):one_of())

        -- consume some food there
        c.food = c.food - vor
        c.food = c.food < 0 and 0 or c.food
    end

    -- Food grow slowly in the cells
    for _,c in ordered(Cells) do
        c.food = c.food + gro
        c.food = c.food > 1 and 1 or c.food
        c.color = shade_of(color('green'),c.food - 1)
    end

end

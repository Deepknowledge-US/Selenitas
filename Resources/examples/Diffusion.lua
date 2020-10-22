--[[
    A Diffuse Example
]]--

-----------------
-- Setup Function
-----------------

Interface:create_slider('Evaporation',0,1.0001,0.1,0.99)
Interface:create_slider('Diffusion',0,1.0001,0.1,0.5)


-----------------
-- Setup Function
-----------------

SETUP = function()

    -- Reset the simulation
    Simulation:reset()

    -- 10 Mobile Agents that will disperse the values
    declare_FamilyMobile('Bugs')
    for i=1,10 do
        Bugs:new({
            visible = false
        })
    end

    -- Cells where the diffusion will occur
    declare_FamilyCell('Cells')
    Cells:create_grid(150,150,-75,-75)
    -- feromone will be the parameter to diffuse
    for _,c in ordered(Cells) do
        c.pheromone = 0
        c.color = {0, 0, 0, 1}
    end
end

-----------------
-- Step Function
-----------------

STEP = function()

    local ev = Interface:get_value('Evaporation')
    local dif = Interface:get_value('Diffusion')
    -- The bugs will put some pheromone in their cells
    --  and move randomly
    for _, b in ordered(Bugs) do
        c = Cells:cell_of(b)
        c.pheromone = 1
        b:move_to(c.neighbors:one_of())
    end

    -- Diffuse in Cells
    Cells:diffuse("pheromone",dif ,1)

    -- Evaporate Pheromone
    -- and color the cell
    for _,c in ordered(Cells) do
        c.pheromone = c.pheromone * ev
        c.color = {c.pheromone, 0, 0, 1}
    end

end

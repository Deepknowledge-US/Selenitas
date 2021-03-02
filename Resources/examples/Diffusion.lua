--[[
    A Diffuse Example
]]--

-----------------
-- Setup Function
-----------------

Interface:create_slider('World_Size', 2, 500, 1, 100)
Interface:create_slider('N_Bugs',1,2000,1,2000)
Interface:create_slider('Evaporation', 0, 1.0001, 0.1 , 0.99)
Interface:create_slider('Diffusion', 0, 1.0001, 0.1, 0.5)

-----------------
-- Setup Function
-----------------

SETUP = function()

    -- Reset the simulation
    Simulation:reset()

    -- Cells where the diffusion will occur
    declare_FamilyCell('Cells')
    local ws = Interface:get_value('World_Size')
    ws = ws%2 == 0 and ws or ws+1
    Cells:create_grid(ws, ws, -ws/2, -ws/2)
    -- pheromone will be the parameter to diffuse
    for _,c in ordered(Cells) do
        c.red   = 0
        c.green = 0
        c.blue  = 0
        c.color = {0, 0, 0, 1}
    end

    -- Bugs (Mobile Agents) that will disperse the pheromones
    declare_FamilyMobile('Bugs')
    for i=1,Interface:get_value('N_Bugs') do
        Bugs:new({
            red     = math.random(),
            green   = math.random(),
            blue    = math.random(),
            visible = false
        })
    end 
    for _, b in ordered(Bugs) do
        --b:move_to(Cells:one_of())
        b:move_to(one_of(Cells))
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
    for _,b in ordered(Bugs) do
        c       = Cells:cell_of(b)
        c.red, c.green, c.blue   = b.red, b.green, b.blue
        b:move_to(c.neighbors:one_of())
    end

    -- Diffuse in Cells
    Cells:multi_diffuse({{"red",dif},{"green",dif},{"blue",dif}} ,1)
    
    -- Evaporate Pheromone
    -- and color the cell
    for _,c in ordered(Cells) do
        c.red   = c.red   * ev
        c.green = c.green * ev
        c.blue  = c.blue  * ev
        c.color = {c.red, c.green, c.blue, 1}
    end

end
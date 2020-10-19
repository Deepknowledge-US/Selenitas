--[[
    An example of growing and cloning of agents.

    It uses customized methods for families and several standard methods
    (die, clone) and agent properties (alive)
]]

-----------------
-- Interface 
-----------------
Interface:create_window('Odd')
Interface:create_slider('Odd', 'R', 0, 1.0001, .1, 0)
Interface:create_slider('Odd', 'G', 0, 1.0001, .1, 0)
Interface:create_slider('Odd', 'B', 0, 1.0001, .1, 0)
Interface:create_slider('Odd', 'A', 0, 1.0001, .1, 0.5)

Interface:create_window('Even')
Interface:create_slider('Even', 'R', 0, 1.0001, .1, 1)
Interface:create_slider('Even', 'G', 0, 1.0001, .1, 1)
Interface:create_slider('Even', 'B', 0, 1.0001, .1, 1)
Interface:create_slider('Even', 'A', 0, 1.0001, .1, 0.5)



-----------------
-- Setup Function
-----------------

SETUP = function()

    -- clear('all')
    Simulation:reset()

    -- Create a Family of Estructural Agents
    declare_FamilyCell('Cells')

    -- Create cells and give a grid structure to them
    Cells:create_grid(30,30,-15,-15) -- width, height, offset x, offset y

	STEP()

end

-----------------
-- Step Function
-----------------

STEP = function()

    for _,c in ordered(Cells) do
        local target_window = 'Even'
        if (c:xcor() + c:ycor()) % 2 == 0 then
                target_window = 'Odd'
        end

        c.color = {
            Interface:get_value(target_window, 'R'),
            Interface:get_value(target_window, 'G'),
            Interface:get_value(target_window, 'B'),
            Interface:get_value(target_window, 'A')
        }

    end

end

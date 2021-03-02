--[[
    TIP: 'ordered' is the default order given by lua to the elements of a table. 
    For a concrete order, see 'sorted' iterator.
    This example shows the difference between 'shuffled' and 'ordered' when 
    iterating on agents.
    There is no STEP function in this case, and all the effects are shown 
    in the SETUP
--]]

-----------------
-- Interface 
-----------------
-- Interface:create_window('params')
Interface:create_slider('Number of agents', 0,50, 1.0, 50)
Interface:create_boolean('Random ordered?', false)
Interface:create_boolean('Labels?', false)


-----------------
-- Setup Function
-----------------

SETUP = function()

    Simulation:reset()

    declare_FamilyMobile('Mobils')

    local N = Interface:get_value('Number of agents')
    for i=1,N do
        Mobils:new({
            pos        = {0,0},        -- initially in the origin
            scale      = 1.5,          -- size 1.5 units
--            color      = {1,0,0,1},    -- red
            color      = shade_of(color('red'), 2*(i- N/2) /N),
            shape      ="square",
            heading    = math.pi / 2,  -- looking north
            label      = i,            -- label = id
            show_label = Interface:get_value('Labels?'),         -- show label (false, by default)
        })
    end

    -- This line shows the pros of using a functional language
    local iter = Interface:get_value('Random ordered?') and shuffled or ordered

    -- Locate the agents in a line (ordered or shuffled)
    local x = -N
    for _,ag in iter(Mobils) do
        ag:move_to({x,0})
        x = x + 2
    end

end

-----------------
-- Step Function
-----------------


STEP = function()
  Simulation:stop()
end

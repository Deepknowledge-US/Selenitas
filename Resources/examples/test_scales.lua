--[[
    TIP: 'ordered' is the default order given by lua to the elements of a table. For a concrete order, see 'sorted' iterator.
    This example shows the difference between 'shuffled' and 'ordered' when 
    iterating on agents
    There is no STEP function in this case, and all the effects are shown 
    in the SETUP
--]]

-----------------
-- Interface 
-----------------
-- Interface:create_window('params')
Interface:create_slider('Number of agents', 0, 20, 1.0, 5)
Interface:create_boolean('Random ordered?', true)
Interface:create_slider('scale', 1, 5, 1, 1)


-----------------
-- Setup Function
-----------------

SETUP = function()

    local scale = Interface:get_value('scale')

    Simulation:reset()

    declare_FamilyMobile('Triangles')
    declare_FamilyMobile('Squares')
    declare_FamilyMobile('Circles')

    for i=1,Interface:get_value('Number of agents') do
        Triangles:new({
            ['scale']      = scale
            ,['color']      = {1,0,0,1}    -- red
            ,['heading']    = math.pi / 2  -- looking north
            ,['label']      = i            -- label = id
            ,['show_label'] = true         -- show label (false, by default)
        })

        Squares:new({
            ['scale']       = scale
            ,['color']      = {0,1,0,1}    -- red
            ,['heading']    = math.pi / 2  -- looking north
            ,['label']      = i            -- label = id
            ,['show_label'] = true         -- show label (false, by default)
            ,['shape']      = 'square'
        })

        Circles:new({
            ['scale']      = scale
            ,['color']      = {0,0,1,1}    -- red
            ,['heading']    = math.pi / 2  -- looking north
            ,['label']      = i            -- label = id
            ,['show_label'] = true         -- show label (false, by default)
            ,['shape']      = 'circle'
        })
    end

    -- This line shows the pros of using a functional language
    local iter = Interface:get_value('Random ordered?') and shuffled or sorted

    -- Locate the agents in a line (ordered or shuffled)
    local x = 0 + scale / 2
    for _,ag in iter(Triangles) do
        ag:move_to({x,0 + scale / 2})
        x = x + scale
    end

    x = 0 + scale / 2
    for _,ag in iter(Squares) do
        ag:move_to({x,(scale * 5) + scale / 2})
        x = x + scale
    end

    x = 0 + scale / 2
    for _,ag in iter(Circles) do
        ag:move_to({x,(scale * 10) + scale / 2})
        x = x + scale
    end

end

-----------------
-- Step Function
-----------------


STEP = function()

end

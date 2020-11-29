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
            ,['label']      = i
            ,['show_label'] = true         -- show label (false, by default)
        })

        Squares:new({
            ['scale']       = scale
            ,['color']      = {0,1,0,1}    -- green
            ,['heading']    = math.pi / 2  -- looking north
            ,['label']      = i
            ,['show_label'] = true         -- show label (false, by default)
            ,['shape']      = 'square'
        })

        Circles:new({
            ['scale']      = scale
            ,['color']      = {0,0,1,1}    -- blue
            ,['heading']    = math.pi / 2  -- looking north
            ,['label']      = i
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
    print("\n\n ====================")
    local t_s = union(Triangles, Squares)
    print('union -> T: '..Triangles.count, 'S: '..Squares.count, 'T+S: '..t_s.count)

    local t_c = union(Triangles, Circles)
    print('union -> T: '.. Triangles.count, 'C: '..Circles.count, 'T+C: '..t_c.count)

    local tsc = union(Triangles, union(Squares, Circles))
    print('union -> T: '.. Triangles.count, 'S: '..Squares.count, 'C: '..Circles.count, 'T+S+C: '..tsc.count)


    print('\n')

    local int_ts = intersection(Triangles, Squares)
    print('inter -> T: '..Triangles.count, 'S: '..Squares.count, 'T/S: '..int_ts.count )

    local int_ts = intersection(t_s, t_c)
    print('inter -> T+S: '..Triangles.count, 'T+C: '..Squares.count, 'T+S/T+C: '..int_ts.count )

    local int_ts = intersection(Triangles, tsc)
    print('inter -> T: '..Triangles.count, 'T+S+C: '..tsc.count, 'T/T+S+C: '..int_ts.count )

    local int_ts = intersection(tsc, Circles)
    print('inter -> T+S+C: '..tsc.count, 'C: '..Circles.count, 'T+S+C/C: '..int_ts.count )

    local int_ts = intersection(tsc, Squares)
    print('inter -> T+S+C: '..tsc.count, 'S: '..Squares.count, 'T+S+C/S: '..int_ts.count )

    print('\n')

    local dif_ts = difference(Triangles, Squares)
    print('difer -> T: '..Triangles.count, 'S: '..Squares.count, 'T-S: '..dif_ts.count )

    local dif_ts = difference(t_s, Squares)
    print('difer -> T+S: '..t_s.count, 'S: '..Squares.count, 'T+S-S: '..dif_ts.count )

    print('\n The following methods modify the Collection "new_col"')

    local new_col = union(Triangles, union(Squares, Circles) )
    print('new_col = T+S+C ->', new_col.count )

    new_col:difference(Triangles)
    print('new_col - T ->', new_col.count )

    new_col:difference(Squares)
    print('new_col - S ->', new_col.count )

    new_col:difference(Circles)
    print('new_col - C ->', new_col.count )



    new_col:union(Circles):union(Squares)
    print('new_col + C + S ->', new_col.count )

    new_col:intersection(Circles)
    print('new_col / C ->', new_col.count )



end

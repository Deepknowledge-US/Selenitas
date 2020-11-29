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
            ,['show_label'] = true         -- show label (false, by default)
        })
    end

    for i=1,Interface:get_value('Number of agents') do
        Squares:new({
            ['scale']       = scale
            ,['color']      = {0,1,0,1}    -- green
            ,['heading']    = math.pi / 2  -- looking north
            ,['show_label'] = true         -- show label (false, by default)
            ,['shape']      = 'square'
        })
    end

    for i=1,Interface:get_value('Number of agents') do
        Circles:new({
            ['scale']      = scale
            ,['color']      = {0,0,1,1}    -- blue
            ,['heading']    = math.pi / 2  -- looking north
            ,['show_label'] = true         -- show label (false, by default)
            ,['shape']      = 'circle'
        })
    end

    for _,t in sorted(Triangles)do t.label = t.__id end
    for _,s in sorted(Squares)do s.label = s.__id end
    for _,c in sorted(Circles)do c.label = c.__id end

    -- This line shows the pros of using a functional language
    local iter = Interface:get_value('Random ordered?') and shuffled or sorted

    -- Locate the agents in a line (ordered or shuffled)
    local x = 0 + scale
    for _,ag in iter(Squares) do
        ag:move_to({x,0 + scale})
        x = x + scale*5
    end

    x = 0 + scale
    for _,ag in iter(Triangles) do
        ag:move_to({x,scale * 10})
        x = x + scale*5
    end

    x = 0 + scale
    for _,ag in iter(Circles) do
        ag:move_to({x,scale * 20})
        x = x + scale*5
    end

    declare_FamilyRel('TS')
    declare_FamilyRel('TC')
    declare_FamilyRel('TSC')

    for _,t in sorted(Triangles)do
        for _,s in sorted(Squares)do
            TS:new({source=t,target=s})
            TSC:new({source=s,target=t})
        end
    end

    for _,t in sorted(Triangles)do
        for _,c in sorted(Circles)do
            TC:new({source=t,target=c})
            TSC:new({source=c,target=t})
        end
    end

end

-----------------
-- Step Function
-----------------


STEP = function()
    print("\n\n ====================")

    print("\n ID's:\n Triangles")
    for _,t in sorted(Triangles)do
        print(t.__id)
    end
    print('\n Squares')
    for _,s in sorted(Squares)do
        print(s.__id)
    end
    print('\n Circles')
    for _,c in sorted(Circles)do
        print(c.__id)
    end


    local only_s, only_c, s_and_c

    print('\n Filter by family of neighbor')
    local choosen_t = one_of(Triangles)

    s_and_c = choosen_t:link_neighbors()
    print('\n link_neighbors()')
    for _,ag in sorted(s_and_c)do
        print(ag.__id)
    end

    only_s  = choosen_t:link_neighbors(Squares)
    print('\n link_neighbors(Squares)')
    for _,ag in sorted(only_s)do
        print(ag.__id)
    end

    only_c  = choosen_t:link_neighbors(Circles)
    print('\n link_neighbors(Circles)')
    for _,ag in sorted(only_c)do
        print(ag.__id)
    end

    local aux_col = choosen_t:link_neighbors(Squares,TS)
    print('\n link_neighbors(Squares,TS) --> TS = FamilyRel with links beetween Triangles and Squares')
    for _,ag in sorted(aux_col)do
        print(ag.__id)
    end

    aux_col = choosen_t:link_neighbors(Squares,TSC)
    print('\n link_neighbors(Squares,TSC) ')
    for _,ag in sorted(aux_col)do
        print(ag.__id)
    end

    aux_col = choosen_t:link_neighbors(Squares,TC)
    print('\n link_neighbors(Squares,TC) -> empty Set')
    for _,ag in sorted(aux_col)do
        print(ag.__id)
    end


    print('\n\nTest in_link_neighbors.')

    local aux_col = choosen_t:in_link_neighbors(Squares,TS)
    print('\n1. in_link_neighbors(Squares,TS) --> TS = FamilyRel with links beetween Triangles and Squares  \n --> empty Set')
    for _,ag in sorted(aux_col)do
        print(ag.__id)
    end

    aux_col = choosen_t:in_link_neighbors(Squares,TSC)
    print('\n2. in_link_neighbors(Squares,TSC) ')
    for _,ag in sorted(aux_col)do
        print(ag.__id)
    end

    aux_col = choosen_t:in_link_neighbors(Squares,TC)
    print('\n3. in_link_neighbors(Squares,TC) \n-> empty Set')
    for _,ag in sorted(aux_col)do
        print(ag.__id)
    end



    print('\n\nTest out_link_neighbors.')

    local aux_col = choosen_t:out_link_neighbors(Squares,TS)
    print('\n4. out_link_neighbors(Squares,TS) --> TS = FamilyRel with links beetween Triangles and Squares')
    for _,ag in sorted(aux_col)do
        print(ag.__id)
    end

    aux_col = choosen_t:out_link_neighbors(Squares,TSC)
    print('\n5. out_link_neighbors(Squares,TSC) \n-> empty Set')
    for _,ag in sorted(aux_col)do
        print(ag.__id)
    end

    aux_col = choosen_t:out_link_neighbors(Squares,TC)
    print('\n6. out_link_neighbors(Squares,TC) \n-> empty Set')
    for _,ag in sorted(aux_col)do
        print(ag.__id)
    end

    print('\nEnd\n')
end

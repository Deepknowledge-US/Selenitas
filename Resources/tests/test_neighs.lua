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

    print("\n Families of Relationals:\nTC: out links Tri->Circ\nTS: out links Tri->Squ\nTSC: in links Squ->Tri and Circ->Tri \n\n ID's:")

    local str = "\n Triangles:"
    for _,t in sorted(Triangles)do
        str = str .. " " .. tostring(t.__id)
    end
    str = str .. "\n Squares:"
    for _,s in sorted(Squares)do
        str = str .. " " .. tostring(s.__id)
    end
    str = str .. "\n Circles:"
    for _,c in sorted(Circles)do
        str = str .. " " .. tostring(c.__id)
    end
    print(str)


    local only_s, only_c, s_and_c

    local choosen_t = one_of(Triangles)

    s_and_c = choosen_t:get_neighs()
    print('\n1. get_neighs()')
    str = ""
    for _,ag in sorted(s_and_c)do
        str = str .. " " .. tostring(ag.__id)
    end
    print(str)

    only_s  = choosen_t:get_neighs(Squares)
    print('\n2. get_neighs(Squares)')
    str = ""
    for _,ag in sorted(only_s)do
        str = str .. " " .. tostring(ag.__id)
    end
    print(str)

    only_c  = choosen_t:get_neighs(Circles)
    print('\n3. get_neighs(Circles)')
    str = ""
    for _,ag in sorted(only_c)do
        str = str .. " " .. tostring(ag.__id)
    end
    print(str)

    local aux_col = choosen_t:get_neighs(Squares,TS)
    print('\n4. get_neighs(Squares,TS)')
    str = ""
    for _,ag in sorted(aux_col)do
        str = str .. " " .. tostring(ag.__id)
    end
    print(str)

    aux_col = choosen_t:get_neighs(Squares,TSC)
    print('\n5. get_neighs(Squares,TSC) ')
    str = ""
    for _,ag in sorted(aux_col)do
        str = str .. " " .. tostring(ag.__id)
    end
    print(str)


    aux_col = choosen_t:get_neighs(Squares,TC)
    print('\n6. get_neighs(Squares,TC) -> empty Set')
    str = ""
    for _,ag in sorted(aux_col)do
        str = str .. " " .. tostring(ag.__id)
    end
    print(str)



    print('\n\nTest get_in_neighs.')

    local aux_col = choosen_t:get_in_neighs(Squares,TS)
    print('\n7. get_in_neighs(Squares,TS) --> empty set')
    str = ""
    for _,ag in sorted(aux_col)do
        str = str .. " " .. tostring(ag.__id)
    end
    print(str)


    aux_col = choosen_t:get_in_neighs(Squares,TSC)
    print('\n8. get_in_neighs(Squares,TSC) ')
    str = ""
    for _,ag in sorted(aux_col)do
        str = str .. " " .. tostring(ag.__id)
    end
    print(str)


    aux_col = choosen_t:get_in_neighs(Squares,TC)
    print('\n9. get_in_neighs(Squares,TC) \n-> empty Set')
    str = ""
    for _,ag in sorted(aux_col)do
        str = str .. " " .. tostring(ag.__id)
    end
    print(str)




    print('\n\nTest get_out_neighs.')

    local aux_col = choosen_t:get_out_neighs(Squares,TS)
    print('\n10. get_out_neighs(Squares,TS)')
    str = ""
    for _,ag in sorted(aux_col)do
        str = str .. " " .. tostring(ag.__id)
    end
    print(str)


    aux_col = choosen_t:get_out_neighs(Squares,TSC)
    print('\n11. get_out_neighs(Squares,TSC) \n-> empty Set')
    str = ""
    for _,ag in sorted(aux_col)do
        str = str .. " " .. tostring(ag.__id)
    end
    print(str)


    aux_col = choosen_t:get_out_neighs(Squares,TC)
    print('\n12. get_out_neighs(Squares,TC) \n-> empty Set')
    str = ""
    for _,ag in sorted(aux_col)do
        str = str .. " " .. tostring(ag.__id)
    end
    print(str)




    print('\n\nTest get_links.')

    aux_col = choosen_t:get_links()
    print('\n13. get_links()')
    str = ""
    for _,ag in sorted(aux_col) do
        str = str .. " " .. tostring(ag.__id)
    end
    print(str)


    aux_col = choosen_t:get_in_links()
    print('\n14. get_in_links()')
    str = ""
    for _,ag in sorted(aux_col)do
        str = str .. " " .. tostring(ag.__id)
    end
    print(str)


    aux_col = choosen_t:get_out_links()
    print('\n15. get_out_links()')
    str = ""
    for _,ag in sorted(aux_col)do
        str = str .. " " .. tostring(ag.__id)
    end
    print(str)


    aux_col = choosen_t:get_links(TC,Squares)
    print('\n16. get_links(TC,Squares) \n-> empty Set')
    str = ""
    for _,ag in sorted(aux_col)do
        str = str .. " " .. tostring(ag.__id)
    end
    print(str)



    aux_col = choosen_t:get_links(TSC)
    print('\n17. get_links(TSC) ')
    str = ""
    for _,ag in sorted(aux_col)do
        str = str .. " " .. tostring(ag.__id)
    end
    print(str)



    aux_col = choosen_t:get_links(TSC,Squares)
    print('\n18. get_links(TSC,Squares) ')
    for _,ag in sorted(aux_col)do
        print(ag.__id, '-> ', tostring(ag.family == TSC) , tostring(ag.source.family == Squares or ag.target.family == Squares) )
    end


    aux_col = choosen_t:get_links(TSC,Circles)
    print('\n19. get_links(TSC,Circles) ')
    for _,ag in sorted(aux_col)do
        print(ag.__id, '-> ', tostring(ag.family == TSC) , tostring(ag.source.family == Circles or ag.target.family == Circles) )
    end




    print('\nEnd\n')
end

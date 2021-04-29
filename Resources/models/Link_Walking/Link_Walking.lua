-----------------
Interface:create_slider('nodes', 0, 50, 1, 12)
Interface:create_slider('speed', 0, 2.001, 0.01, 1)

panels_channel:push(Interface.windows)

SETUP = function()
    -- clear('all')
    Simulation:reset()

    declare_FamilyMobile('Nodes')
    declare_FamilyRel('Edges')
    declare_FamilyMobile('Walkers')

    Walkers:add_method('search_next_node',function(self)
        local nn = one_of(self.curr_node:get_out_neighs())
        self:face(nn)
        self.next_node = nn
    end)

    for i=1,Interface:get_value("nodes") do
        Nodes:new({
            ['pos']     = {math.random(-100,100), math.random(-100,100)},
            ['shape']   = 'circle',
            ['color']   = {1,0,0,1},
            ['scale']   = 2,
        })
    end

    local list_of_nodes = fam_to_list(Nodes)
    array_shuffle(list_of_nodes)

    for i=1,#list_of_nodes-1 do
        Edges:new({
            ['source']  = list_of_nodes[i],
            ['target']  = list_of_nodes[i+1],
        })
    end
    Edges:new({
        ['source']  = list_of_nodes[#list_of_nodes],
        ['target']  = list_of_nodes[1],
    })

    local node = one_of(Nodes)
    Wlkr = Walkers:new({
        ['pos']       = {node:xcor(), node:ycor()},
        --['head']      = {0,nil},
        ['curr_node'] = node,
        ['color']     = {0,0,1,1},
        ['scale']     = 3,
        ['shape']     = 'triangle_2',
        ['next_node'] = node
    })

end


STEP = function()
    if Wlkr:dist_euc_to(Wlkr.next_node) < Interface:get_value("speed") then
        Wlkr:move_to(Wlkr.next_node)
        Wlkr.curr_node = Wlkr.next_node
        Wlkr:search_next_node()
    end
    Wlkr:fd(Interface:get_value("speed"))
end
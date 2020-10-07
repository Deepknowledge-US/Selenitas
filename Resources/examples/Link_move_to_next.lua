-----------------

Interface:create_slider('nodes', 0, 50, 1, 12)

SETUP = function()

    Simulation:reset()

    declare_FamilyMobil('Nodes')
    declare_FamilyRel('Edges')
    declare_FamilyMobil('Walkers')
    Walkers.z_order = 4 -- By default, all mobil families have a z_order = 3, by setting this to 4, all Walkers will be painted over the other Mobil agents

    for i=1,Interface:get_value("nodes") do
        Nodes:new({
            ['pos']   = {math.random(-20,20), math.random(-20,20)}
            ,['shape'] = 'circle'
            ,['scale'] = 3
        })
    end

    local list_of_nodes = fam_to_list(Nodes)
    array_shuffle(list_of_nodes)

    for i=1,#list_of_nodes-1 do
        Edges:new({
            ['source'] = list_of_nodes[i]
            ,['target'] = list_of_nodes[i+1]
        })
    end
    Edges:new({
        ['source'] = list_of_nodes[#list_of_nodes]
        ,['target'] = list_of_nodes[1]
    })

    Walkers:add_method('search_next_node',function(self)
        local nn = one_of(self.curr_node:out_link_neighbors())
        self:face(nn)
        self.next_node = nn
    end)

    local node = one_of(Nodes)

    Wlkr = Walkers:new({
        ['pos']       = {node:xcor(), node:ycor()}
        ,['heading']   = 0
        ,['curr_node'] = node
        ,['color']     = {0,0,1,1}
        ,['scale']     = 1.5
        ,['shape']     = 'triangle_2'
        ,['next_node'] = node
    })

end


STEP = function()

    Wlkr:move_to(Wlkr.next_node.pos)
    Wlkr.curr_node = Wlkr.next_node
    Wlkr:search_next_node()

end

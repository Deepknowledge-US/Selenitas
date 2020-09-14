require 'Engine.utilities.utl_main'

Config:create_slider('nodes', 0, 50, 1, 12)

SETUP = function()

    Nodes  = FamilyMobil()
    Edges  = FamilyRelational()
    Walkers= FamilyMobil()

    for i=1,Config.nodes do
        Nodes:add({
            ['pos'] = {math.random(-20,20), math.random(-20,20)},
            ['visible'] = true,
            ['shape'] = 'circle',
            ['scale'] = 3,
        })
    end

    local list_of_nodes = fam_to_list(Nodes)
    array_shuffle(list_of_nodes)

    for i=1,#list_of_nodes-1 do
        Edges:add({
            ['source'] = list_of_nodes[i],
            ['target'] = list_of_nodes[i+1],
            ['visible'] = true
        })
    end
    Edges:add({
        ['source'] = list_of_nodes[#list_of_nodes],
        ['target'] = list_of_nodes[1],
        ['visible']= true
    })

    Walkers:create_n( 1, function()
        local node = one_of(Nodes)
        return {
            ['pos']       = {node:xcor(), node:ycor()},
            ['heading']   = 0,
            ['curr_node'] = node,
            ['color']     = {0,0,1,1},
            ['scale']     = 1.5,
            ['shape']     = 'triangle_2',
            ['next_node'] = node
        }
    end)
    Walkers:add_method('search_next_node',function(self)
        local nn = one_of(self.curr_node:out_link_neighbors())
        self:face(nn)
        self.next_node = nn
    end)
    Wlkr = one_of(Walkers)
end


RUN = function()
    if Wlkr:dist_euc_to(Wlkr.next_node.pos) < 1 then
        Wlkr.curr_node = Wlkr.next_node
        Wlkr:search_next_node()
    end
    Wlkr:fd(0.9)
    Wlkr:update_cell()

end

-- Setup and start visualization
GraphicEngine.set_setup_function(SETUP)
GraphicEngine.set_step_function(RUN)
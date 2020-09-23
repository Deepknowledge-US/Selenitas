-----------------

Config:create_slider('nodes', 0, 50, 1, 12)
Config:create_slider('speed', 0, 2, .01, 1)

SETUP = function()
    clear('all')
    Nodes   = FamilyMobil()
    Edges   = FamilyRelational()
    Walkers = FamilyMobil()

    for i=1,Config.nodes do
        Nodes:new({
            ['pos']     = {math.random(-20,20), math.random(-20,20)},
            ['shape']   = 'circle',
            ['color']   = {1,0,0,1},
            ['scale']   = 3,
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

    Walkers:create_n( 1, function()
        local node = one_of(Nodes)
        return {
            ['pos']       = {node:xcor(), node:ycor()},
            ['head']      = {0,nil},
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
    if Wlkr:dist_euc_to(Wlkr.next_node) < Config.speed then
        Wlkr:move_to(Wlkr.next_node)
        Wlkr.curr_node = Wlkr.next_node
        Wlkr:search_next_node()
    end
    Wlkr:fd(Config.speed)
end

require 'Engine.utilities.utl_main'

Config = Params({
    ['start'] = true,
    ['go']    = true,
    ['ticks'] = 200,
    ['xsize'] = 50,
    ['ysize'] = 50,
    ['stride']= 1
})

Config:create_slider('nodes', 0, 100, 1, 22)

SETUP = function()

    math.randomseed(os.clock())

    Nodes  = FamilyMobil()
    Edges  = FamilyRelational()
    Walkers= FamilyMobil()

    for i=1,Config.nodes do
        Nodes:add({
            ['pos'] = {math.random(Config.xsize-1), math.random(Config.ysize-1)},
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
            ['pos']     = {node:xcor(), node:ycor()},
            ['head']    = {0,nil},
            ['curr_node'] = node,
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
    if Wlkr:dist_euc(Wlkr.next_node.pos) < 1.2 then
        Wlkr.curr_node = Wlkr.next_node
        Wlkr:search_next_node()
    end
    Wlkr:fd(1)
    Wlkr:update_cell()

    Config.ticks = Config.ticks-1
    if Config.ticks <= 0 then
        Config.go = false
    end
end

-- Setup and start visualization
GraphicEngine.set_coordinate_scale(20)
GraphicEngine.set_world_dimensions(Config.xsize + 2, Config.ysize + 2)
GraphicEngine.set_time_between_steps(0.3)
GraphicEngine.set_simulation_params(Config)
GraphicEngine.set_setup_function(SETUP)
GraphicEngine.set_step_function(RUN)
GraphicEngine.init()
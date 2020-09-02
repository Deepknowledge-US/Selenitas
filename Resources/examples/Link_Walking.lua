
require 'Engine.utilities.utl_main'

local pr = require 'pl.pretty'
Config = Params({
    ['start'] = true,
    ['go']    = true,
    ['ticks'] = 200,
    ['xsize'] = 15,
    ['ysize'] = 15,
    ['stride']= 1
})


-- local get_target = function(self,link_id)
--     return self.agents[link_id].target
-- end

-- local get_source = function(self,link_id)
--     return self.agents[link_id].source
-- end


SETUP = function()

    Cells  = create_grid(Config.xsize, Config.ysize)
    Nodes  = FamilyMobil()
    Edges  = FamilyRelational()
    Walkers= FamilyMobil()

    local n_cells = fam_to_list(n_of(10,Cells))
    print(#n_cells)
    ask(Cells, function(c)
        if is_in_list(c,n_cells) then
            c['visited'] = 'N'
        else
            c['visited'] = '_'
        end
    end)

    for i=1,10 do
        Nodes:add({
            ['pos'] = {n_cells[i]:xcor(), n_cells[i]:ycor()}
        })
    end

    math.randomseed(os.clock())
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

        local nn = Edges:get(self.curr_node.out_links[1]).target
        print(nn.id)
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

    -- print(Wlkr.next_node:xcor(),Wlkr.next_node:ycor())

    Config.ticks = Config.ticks-1
    if Config.ticks <= 0 then
        Config.go = false
    end

end


-- Setup and start visualization
GraphicEngine.set_coordinate_scale(20)
GraphicEngine.set_world_dimensions(Config.xsize + 2, Config.ysize + 2)
GraphicEngine.set_time_between_steps(0)
GraphicEngine.set_simulation_params(Config)
GraphicEngine.set_setup_function(SETUP)
GraphicEngine.set_step_function(RUN)
GraphicEngine.init()

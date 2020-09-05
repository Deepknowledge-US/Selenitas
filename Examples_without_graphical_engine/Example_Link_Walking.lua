
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


local function print_current_config()

    print('\n========= tick: '.. __ticks ..' =========')

    for i=Config.ysize-1,0,-1 do
        local line = ""
        for j = 0,Config.xsize-1 do
            local target = Cells:cell_of({j,i})
            local label  = target.visited

            if Wlkr:is_in(target.my_agents) then label = 0 end
            line = line .. label .. ','
        end
        print(line)
    end

    print('=============================\n')

end


local fam_to_list = function(fam)
    local res = {}
    for _,v in pairs(fam.agents)do
        table.insert(res,v)
    end
    return res
end


SETUP(function()
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
            ['source']  = list_of_nodes[i],
            ['target']  = list_of_nodes[i+1],
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
        print(nn.id)
        self:face(nn)
        self.next_node = nn
    end)

    Wlkr = one_of(Walkers)

end)


RUN(function()

    if Wlkr:dist_euc(Wlkr.next_node.pos) < 1.2 then
        Wlkr.curr_node = Wlkr.next_node
        Cells:cell_of(Wlkr.curr_node).visited = 'Y'
        Wlkr:search_next_node()
    end
    Wlkr:fd(1)
    Wlkr:update_cell()

    Config.ticks = Config.ticks-1
    if Config.ticks <= 0 then
        Config.go = false
    end

    print_current_config()
end)

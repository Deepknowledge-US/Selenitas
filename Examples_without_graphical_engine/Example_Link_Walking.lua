
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

    for i=Config.ysize,1,-1 do
        local line = ""
        for j = 1,Config.xsize do
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

    print('\n\n\n\n\n')
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

    local list_of_nodes = fam_to_list(Nodes)

    ask_ordered(Nodes, function(n1)
        local choosen = list_of_nodes[math.random(#list_of_nodes)]
        Edges:add({
            ['source'] = n1,
            ['target'] = choosen
        })
    end)

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
        self.curr_node = self.next_node
        self.next_node = nn
        print(nn.id)
        self:face(nn)
    end)

    Wlkr = one_of(Walkers)

    -- local next_id = one_of(Mobil.)
    -- Mobil.next_node = Nodes[next_id]


end)


RUN(function()


    if Wlkr:dist_euc(Wlkr.curr_node.pos) < 1 then
        Cells:cell_of({Wlkr:xcor(),Wlkr:ycor()})['visited'] = 'Y'
        Wlkr:search_next_node()
    end
    Wlkr:fd(1)
    Wlkr:update_cell()

    print_current_config()
    print(Wlkr.next_node:xcor(),Wlkr.next_node:ycor())

    if __ticks > Config.ticks then
        -- ask_ordered(Nodes,function(x)
        --     print('\n\n',x.id)
        --     for k,v in pairs(x.out_neighs)do
        --         print(k)
        --         for _,v2 in ipairs(v)do
        --             print('link_id:',v2)
        --         end
        --     end
        -- end)
        Config.go = false
    end

end)

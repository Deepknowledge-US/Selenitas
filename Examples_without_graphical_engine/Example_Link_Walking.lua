-----------------
require 'Engine.utilities.utl_main'

local pr = require 'pl.pretty'

local xsize,ysize = 15,15

local function print_current_config()

    print('\n========= tick: '.. Simulation.time ..' =========')

    for i=ysize-1,0,-1 do
        local line = ""
        for j = 0,xsize-1 do
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
    Cells  = create_grid(xsize, ysize)
    Nodes  = FamilyMobil()
    Edges  = FamilyRelational()
    Walkers= FamilyMobil()

    local n_cells = fam_to_list(n_of(10,Cells))

    for _,c in ordered(Cells)do
        if is_in_list(c,n_cells) then
            c['visited'] = 'N'
        else
            c['visited'] = '_'
        end
    end

    for c=1,10 do
        Nodes:new({
            ['pos'] = {n_cells[c]:xcor(), n_cells[c]:ycor()}
        })
    end

    -- math.randomseed(os.clock())
    local list_of_nodes = fam_to_list(Nodes)
    array_shuffle(list_of_nodes)

    for i=1,#list_of_nodes-1 do
        Edges:new({
            ['source']  = list_of_nodes[i],
            ['target']  = list_of_nodes[i+1],
            ['visible'] = true
        })
    end
    Edges:new({
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


STEP(function()

    if Wlkr:dist_euc_to(Wlkr.next_node.pos) < 1.2 then
        Wlkr.curr_node = Wlkr.next_node
        Cells:cell_of(Wlkr.curr_node).visited = 'Y'
        Wlkr:search_next_node()
    end
    Wlkr:fd(1)
    Wlkr:update_cell()

    Simulation.time = Simulation.time+1
    if Simulation.time <= Simulation.max_time then
        Simulation.is_running = false
    end

    print_current_config()
end)

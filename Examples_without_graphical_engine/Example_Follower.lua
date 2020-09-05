
require 'Engine.utilities.utl_main'

local pr = require 'pl.pretty'

Config = Params({
    ['start'] = true,
    ['go']    = true,
    ['ticks'] = 100,
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
            local label  = target.my_agents.count > 0 and target.my_agents.count or '_'
            if Choosen:is_in(target.my_agents) then
                label = 0
            end
            line = line .. label .. ','
        end
        print(line)
    end

    print('=============================\n')

end




SETUP(function()

    print('\n\n\n\n\n')
    Cells = create_grid(Config.xsize, Config.ysize)

    Agents = FamilyMobil()

    Agents:create_n( 2, function()
        return {
            ['pos']     ={Config.xsize-1,Config.ysize-1},
            ['head']    = {0,nil},
            ['age']     = 0
        }
    end)

    Choosen = one_of(Agents)
    Other   = one_of(Agents:others(Choosen))

    Choosen
        :move_to({Config.xsize/2,Config.ysize/2})
        :update_cell()
        :face(Other)

end)


RUN(function()

    if __ticks % 5 == 0 then
        Other
            :set_param('head',{math.random(2*math.pi),nil})
            :fd(7)
            :update_cell()
    end

    Choosen
        :face(Other)
        :fd(2)
        :update_cell()

    print_current_config()

    if Choosen.current_cells[1] == Other.current_cells[1] then
        print(Other.current_cells[1]:xcor(),Other.current_cells[1]:ycor())
        Config.go = false
    end

end)

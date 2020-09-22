-----------------
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
            ['heading'] = 0,
            ['age']     = 0
        }
    end)
    Agents:add_method('update_position', function(agent, min_x, max_x, minim_y, maxim_y)
        local x,y = agent:xcor(),agent:ycor()
    
        local min_y, max_y = minim_y or min_x, maxim_y or max_x
    
        local size_x, size_y = max_x-min_x, max_y-min_y
    
        if x > max_x then
            agent.pos[1] = agent.pos[1] - size_x
        elseif x < min_x then
            agent.pos[1] = agent.pos[1] + size_x
        end
    
        if y > max_y then
            agent.pos[2] = agent.pos[2] - size_y
        elseif y < min_y then
            agent.pos[2] = agent.pos[2] + size_y
        end
        return agent
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
            :set_param('heading',math.random(2*math.pi))
            :fd(7)
            :update_position(0,Config.xsize)
            :update_cell()
    end

    Choosen
        :face(Other)
        :fd(2)
        :update_position(0,Config.xsize)
        :update_cell()

    print_current_config()

    if Choosen.current_cells[1] == Other.current_cells[1] then
        print(Other.current_cells[1]:xcor(),Other.current_cells[1]:ycor())
        Config.go = false
    end

end)

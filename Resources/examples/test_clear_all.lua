-----------------

Interface:create_slider('N_agents', 0, 20, 1.0, 5)
Interface:create_boolean('random_ordered', true)
Interface:create_boolean('clean_families', true)


SETUP = function()

    if Interface.clean_families then
        Simulation:clear('all')
    end

    declare_FamilyMobil('Mobils')

    for i=1,Interface.N_agents do
        Mobils:new({
            ['pos']      = {0,0}
            ,['scale']   = 1.5
            ,['color']   = {1,0,0,1}
            ,['heading'] = math.pi / 2
        })
    end

    local x = 0

    local iter = Interface.random_ordered and shuffled or ordered

    for k,ag1 in iter(Mobils) do
        ag1:move_to({x,0})
        ag1.label = ag1.id
        x = x + 2
    end

end


STEP = function()
    if Interface.random_ordered then
        for _,ag in shuffled(Mobils) do
            ag:fd(1)
        end
    else
        for _,ag in ordered(Mobils) do
            ag:fd(1)
        end
    end
end

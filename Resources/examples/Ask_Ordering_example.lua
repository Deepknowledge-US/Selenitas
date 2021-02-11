-----------------
Interface:create_slider('N_agents', 0, 20, 1.0, 5)
Interface:create_boolean('random_ordered', true)
Interface:create_boolean('Reset', false)

SETUP = function()

    declare_FamilyMobile('Mobils')

    for i=1,Interface:get_value("N_agents") do
        Mobils:new({
            ['pos']      = {0,0}
            ,['scale']   = 1.5
            ,['color']   = {1,0,0,1}
            ,['heading'] = math.pi / 2
        })
    end

    local x = 0

    local iter = Interface:get_value('random_ordered') and shuffled or ordered

    for k,ag1 in iter(Mobils) do
        ag1:move_to({x,0})
        ag1.label = ag1.__id
        x = x + 2
    end

end


STEP = function()
    if Interface:get_value("random_ordered") then
        for _,ag in shuffled(Mobils) do
            ag:fd(1)
        end
    else
        for _,ag in ordered(Mobils) do
            ag:fd(1)
        end
    end
end
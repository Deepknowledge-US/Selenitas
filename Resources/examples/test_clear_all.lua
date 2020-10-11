-----------------

Interface:create_window('custom name', { -- By default the new window is created with a position and a width and height, but we can change this properties with this OPTIONAL TABLE
    ['width'] = 130,
    ['height'] = 250,
    ['x'] = 100,
    ['y'] = 100,
} )

Interface:create_slider('custom name', 'N_agents', 0, 20, 1.0, 5)
Interface:create_boolean('custom name', 'random_ordered', true)
Interface:create_boolean('custom name', 'clean_families', true)


SETUP = function()

    if Interface:get_value('custom name', "clean_families") then
        Simulation:clear('all')
    end

    declare_FamilyMobile('Mobils')

    for i=1,Interface:get_value('custom name', "N_agents") do
        Mobils:new({
            ['pos']      = {0,0}
            ,['scale']   = 1.5
            ,['color']   = {1,0,0,1}
            ,['heading'] = math.pi / 2
            ,['label']  = i
            ,['show_label'] = true
        })
    end

    local x = 0

    local iter = Interface:get_value('custom name', "random_ordered") and shuffled or ordered

    for k,ag1 in iter(Mobils) do
        ag1:move_to({x,0})
        x = x + 2
    end

end


STEP = function()
    if Interface:get_value('custom name', "random_ordered") then
        for _,ag in shuffled(Mobils) do
            ag:fd(1)
        end
    else
        for _,ag in ordered(Mobils) do
            ag:fd(1)
        end
    end
end
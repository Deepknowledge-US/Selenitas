-----------------
require 'Engine.utilities.utl_main'

Config:create_slider('N_agents', 0, 20, 1.0, 10)
Config:create_boolean('random_ordered', true)


SETUP = function()

    Mobils = FamilyMobil()
    Mobils:create_n( 5, function()
        return {
            ['pos']      = {0,0}
            ,['scale']   = 1.5
            ,['color']   = {1,0,0,1}
            ,['heading'] = math.pi / 2
        }
    end)

    print(Mobils.count)
    local x = 0
    for k,ag1 in shuffled(Mobils) do
        ag1:move_to({x,0})
        ag1.label = ag1.id
        x = x + 2
    end

end


RUN = function()
    -- Limitación de ask: no puede combinarse con otras variables que cambien en cada ciclo... algo que tiene sentido
    -- si se considera el ask como una ejecución paralela.
    if Config.random_ordered then
        for _,ag in shuffled(Mobils) do
            ag:fd(1)
        end
    else
        for _,ag in ordered(Mobils) do
            ag:fd(1)
        end
    end
end

-- Setup and start visualization
-- GraphicEngine.set_setup_function(SETUP)
-- GraphicEngine.set_step_function(RUN)
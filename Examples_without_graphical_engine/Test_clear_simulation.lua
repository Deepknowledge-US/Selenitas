-----------------
require "Engine.utilities.utl_main"

SETUP(
    function()
        -- math.randomseed(101)
        People = FamilyMobile()
        People:create_n(
            5000,
            function()
                return {}
            end
        )

    end
)

STEP(
    function()

        print("==========", Simulation.time,"===========\n")
        for k1, p1 in shuffled(n_of(5,People)) do
            print("k1:", k1, "id:", p1.id)
            for k2, p2 in shuffled(
                People:with( function(x) return x:xcor() > 0 end ) -- Empty Collection: all agents have xcor == 0
            ) do
                print("\t", "k2:", k2, "id2:", p2.id)
            end
        end

        -- print( '1', collectgarbage('count')/1024 )
        print( '1', collectgarbage('count')/1024 )

        clear('All')

        collectgarbage()
        -- print( '2', collectgarbage('count')/1024 )
        print( '2', collectgarbage('count')/1024 )

    end
)

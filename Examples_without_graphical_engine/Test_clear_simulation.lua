-----------------
require "Engine.utilities.utl_main"

Config =
    Params(
    {
        ["start"] = true,
        ["go"] = true,
        ["ticks"] = 2
    }
)


SETUP(
    function()
        -- math.randomseed(101)
        People = FamilyMobil()
        People:create_n(
            5000,
            function()
                return {}
            end
        )

        TT = 0
    end
)

STEP(
    function()

        print("==========",TT,"===========\n")
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


        TT = TT+1
    end
)

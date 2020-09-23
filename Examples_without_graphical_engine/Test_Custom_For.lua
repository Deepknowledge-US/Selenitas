-----------------
require "Engine.utilities.utl_main"

Config =
    Params(
    {
        ["start"] = true,
        ["go"] = true,
        ["ticks"] = 5
    }
)

SETUP(
    function()
        -- math.randomseed(101)
        People = FamilyMobil()
        People:create_n(
            5,
            function()
                return {}
            end
        )
    end
)

STEP(
    function()
        print("=======================\n")
        for k1, p1 in shuffled(People) do
            print("k1:", k1, "id:", p1.id)
            for k2, p2 in shuffled(
                People:with( function(x) return x:xcor() > -1 end )
            ) do
                print("\t", "k2:", k2, "id2:", p2.id)
            end
        end
    end
)

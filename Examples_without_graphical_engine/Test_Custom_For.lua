require "Engine.utilities.utl_main"

Config =
    Params(
    {
        ["start"] = true,
        ["go"] = true,
        ["ticks"] = 5
    }
)

-- local function producer(a_list, an_index)
--     return coroutine.create(
--         function()
--             local j = math.random(an_index)
--             a_list[an_index], a_list[j] = a_list[j], a_list[an_index]
--             coroutine.yield(a_list[an_index], an_index-1)
--         end
--     )
-- end

-- local function consumer(a_list, an_index)
--     local status, element, new_index = coroutine.resume(producer(a_list, an_index))
--     a_list[an_index] = nil
--     return new_index, element
-- end

-- local iter = 0
-- local function shuffled(fam_or_list)

--     -- iter = iter+1
--     -- print('iter:',iter)

--     local list
--     if fam_or_list.agents then
--         list = fam_to_list(fam_or_list)
--     else
--         list = list_copy(fam_or_list)
--     end

--     return consumer, list, #list
-- end


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

RUN(
    function()
        print("=======================\n")
        for k1, p1 in shuffled(People) do
            print("k1:", k1, "id:", p1.id)
            for k2, p2 in shuffled(People) do
                print("\t", "k2:", k2, "id2:", p2.id)
            end
        end
    end
)

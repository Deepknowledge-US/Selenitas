-----------------
require "Engine.utilities.utl_main"

Simulation.max_time = 1

-- fill A with random numbers between 1 and 100
local function randArray(A,n)
    for i = 1, n do
        A[i] = math.random(n)
    end
end

local function dist_to_origin(agent_position)
    return dist_euc_to(agent_position, {0,0})
end


SETUP(
    function()
        People = FamilyMobil()

        for i=1,5 do
            People:new({['pos'] = {i,i}})
        end
    end
)

STEP(
    function()
        print("=======================\n")

        -- local P_list = fam_to_list(People)
        -- local p = P_list
        local p = People

        for k,v in sorted(p,'id')do
            print(k,'id:',v.id)
        end
        print('\n')

        for k,v in sorted(p,'id',true)do
            print(k,'id:',v.id)
        end
        print('\n')

        for k,v in sorted(p,'pos', false, dist_to_origin)do
            print(k,'pos: {',v:xcor(),v:ycor(), '}' )
        end
        print('\n')

        for k,v in sorted(p,'pos', true, dist_to_origin)do
            print(k,'pos: {',v:xcor(),v:ycor(), '}' )
        end

        -- create a numbers array
        A = {}
        randArray(A,10)
        io.write("\n")

        for k,v in sorted(A,nil,true)do
            print(k,v)
        end

    end
)

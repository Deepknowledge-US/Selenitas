local pretty        = require 'pl.pretty'
local pd            = pretty.dump

local utl           = require 'pl.utils'
local lamb          = utl.bind1
local lambda        = utl.string_lambda

require 'Engine.utilities.utl_main'


-- The Configuration object.
Config = Params({
    ['start'] = true,
    ['go']    = true,
    ['ticks'] = 3,
    ['xsize'] = 60,
    ['ysize'] = 60
})

-- Optional: Create patches
Patches = create_patches(Config.xsize,Config.ysize)


-- This function count and print the number of agents in each patch.
-- Very naive representation of current configuration.
-- In the ask, you must replace "Agents" with the name of your collection

local function current_config()
    -- for i = Config.ysize,1,-1 do
    --     local line = ""
    --     for j = 1, Config.xsize do
    --         line = line .. Patches.all[j..','..i].label .. ', '
    --     end
    --     print(line)
    -- end
end



    ------------------------------------

    -- Write here your auxiliar functions

    ------------------------------------
__primes = {3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97}

local prime = 13
-- local prime = __primes[math.random(#__primes)]

local function custom_next(table, pos)
    if pos < #table then
        local next_elem = math.fmod(pos+prime,#table)
        -- print(prime, next_elem)
        next_elem = next_elem ~= 0 and next_elem or #table
        return next_elem, table[next_elem]
    end

end
-- local function custom_next(table, pos, prime)

--     if pos then
--         if pos >= #table then 
--             return nil
--         else
--             return table[pos], pos+1, prime
--         end
--     else
--         return table[1], 2, prime
--     end

-- end

-- The set up function. It consists in an anonymous function which is executed once by the
-- setup function defined in utilities.lua
setup(function()

    math.randomseed(os.time())
    ------------------------------------

    -- write your setup code here

    ------------------------------------

    Agents = FamilyMobil()
    for i=1,5 do
        Agents:add({
            ['pos'] = {
                math.random(Config.xsize),
                math.random(Config.ysize)
            }
        })
    end

    print('============================')

    local subset = Agents:with(function(x) return x:xcor()< Config.xsize / 2  end)
    if subset.size > 0 then
        ask(one_of(subset), function(x)
            print(x)
        end)
    end

    -- print(subset.family)
    print('============================')
    -- print(subset)
    -- for k,v in pairs(subset.agents) do
    --     print(v:is_a(Agent))
    --     print(v:is_a(Mobil))
    -- end


    -- Para prueba de custom_next basada en coprimos
    Numbers = {1,2,3,4,5,6,7,8,9}
end)


run(function()

    -- ask(one_of(Agents), function(x)
    --     local other = one_of(Agents:others(x))[1]
    --     local euc = x:dist_euc_to_agent( other )
    --     local manh = x:dist_manh_to_agent( other )

    --     -- print('ag1:')
    --     -- pd(x.pos)
    --     -- print('ag2:')
    --     -- pd(other.pos)
    --     -- print('euclidean: ',euc)
    --     -- print('manhathan:', manh)


    -- end)
    ------------------------------------

    -- write your run code here

    -- print('\n=============================================\n')

    -- if math.fmod(#Numbers,2) ~= 0 then
    --     table.insert(Numbers, -1)
    -- end

    -- -- shuffle(Numbers)

    -- local random_prime = {3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97}

    -- for k,v in custom_next, Numbers, 0 do
    --     print(k,v)
    -- end


    -- -- pd(Numbers)

    -- print('\n=============================================\n')

    ------------------------------------

    current_config()
end)



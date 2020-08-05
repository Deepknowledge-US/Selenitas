local Mobiles       = require 'Engine.classes.class_collection_mobil'
local Patches       = require 'Engine.classes.class_collection_relational'
local Params        = require 'Engine.classes.class_params'
local utl           = require 'pl.utils'
local lamb          = utl.bind1
local lambda        = utl.string_lambda
local pretty        = require 'pl.pretty'
local pd            = pretty.dump

local _main         = require 'Engine.utilities.utl_main'
local _coll         = require 'Engine.utilities.utl_collections'
local _fltr         = require 'Engine.utilities.utl_filters'
local _chk          = require 'Engine.utilities.utl_checks'
local _act          = require 'Engine.utilities.utl_actions'

local first_n       = _fltr.first_n
local last_n        = _fltr.last_n
local member_of     = _chk.member_of
local one_of        = _fltr.one_of
local n_of          = _fltr.n_of
local ask           = _coll.ask
local fd            = _act.fd
local rt            = _act.rt
local lt            = _act.lt

local setup         = _main.setup
local run           = _main.run
local create_patches= _coll.create_patches






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



-- The set up function. It consists in an anonymous function which is executed once by the
-- setup function defined in utilities.lua
setup(function()

    ------------------------------------

    -- write your setup code here

    ------------------------------------

    Agents = Mobiles()
    for i=1,10 do
        Agents:add({
            ['pos'] = {
                math.random(Config.xsize),
                math.random(Config.ysize)
            }
        })
    end

    -- pd(Agents.agents)
end)


run(function()

    ask(one_of(Agents), function(x)
        local other = one_of(Agents:others(x))[1]
        local euc = x:dist_euc_to_agent( other )
        local manh = x:dist_manh_to_agent( other )

        print('ag1:')
        pd(x.pos)
        print('ag2:')
        pd(other.pos)
        print('euclidean: ',euc)
        print('manhathan:', manh)
    end)
    ------------------------------------

    -- write your run code here

    ------------------------------------

    current_config()
end)



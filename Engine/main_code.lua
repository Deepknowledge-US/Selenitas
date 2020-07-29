local Collection    = require 'Engine.classes.class_collection'
local Agent         = require 'Engine.classes.class_agent'
local Params        = require 'Engine.classes.class_params'
local Link          = require 'Engine.classes.class_link'
local Patch         = require 'Engine.classes.class_patch'
local utils         = require 'Engine.utilities'
local utl           = require 'pl.utils'
local lamb          = utl.bind1
local lambda        = utl.string_lambda
local first_n       = utils.first_n
local last_n        = utils.last_n
local member_of     = utils.member_of
local one_of        = utils.one_of
local n_of          = utils.n_of
local ask           = utils.ask
local setup         = utils.setup
local run           = utils.run
local create_patches= utils.create_patches

-- The Configuration object.
Config = Params({
    ['start'] = true,
    ['go']    = true,
    ['ticks'] = 100,
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

end)


run(function()

    ------------------------------------

    -- write your run code here

    ------------------------------------

    current_config()
end)



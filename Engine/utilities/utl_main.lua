-- local Collection= require 'Engine.classes.class_collection'
-- local Patch     = require 'Engine.classes.class_patch'
-- local pretty    = require 'pl.pretty'
-- local utl       = require 'pl.utils'
-- local lambda    = utl.string_lambda

local utils = {}




-- This function encapsulates the anonymous function defined in the "setup" call of the
-- file main_code.lua.
-- It creates a grid of patches with the parameters defined in Config object.
-- Then, it executes once the anonymous function defined in the "setup" call of the main file.

function utils.setup( funct )
    math.randomseed(os.time())
    T = 1
    funct()
end



-- This function encapsulates the anonymous function defined in the "run" call of the
-- file main_code.lua.
-- It is running until one of the stop condition is reached.
-- Config.ticks simulate the ticks slider in netlogo.
-- Config.go simulate the go button in NetLogo interface.

function utils.run(funct)
    while Config.go do -- While the 'go' button is pushed
        if T <= Config.ticks then
            funct()
            T=T+1
        else
            Config.go = false
        end
    end
end



return utils
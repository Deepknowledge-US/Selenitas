
-- Global variables
Params      = require 'Engine.classes.Params'

Cell        = require 'Engine.classes.Cell'
Mobil       = require 'Engine.classes.Mobil'
Relational  = require 'Engine.classes.Relational'

Collection              = require 'Engine.classes.Collection'
CollectionCell          = require 'Engine.classes.CollectionCell'
CollectionMobil         = require 'Engine.classes.CollectionMobil'
CollectionRelational    = require 'Engine.classes.CollectionRelational'




local utils = {}




-- This function encapsulates the anonymous function defined in the "setup" call of the
-- file main_code.lua.
-- It creates a grid of patches with the parameters defined in Config object.
-- Then, it executes once the anonymous function defined in the "setup" call of the main file.

function utils.setup( funct )
    math.randomseed(os.time())
    __Ticks = 1
    funct()
end



-- This function encapsulates the anonymous function defined in the "run" call of the
-- file main_code.lua.
-- It is running until one of the stop condition is reached.
-- Config.ticks simulate the ticks slider in netlogo.
-- Config.go simulate the go button in NetLogo interface.

function utils.run(funct)
    while Config.go do -- While the 'go' button is pushed
        if __Ticks <= Config.ticks then
            funct()
            __Ticks = __Ticks+1
        else
            Config.go = false
        end
    end
end



return utils
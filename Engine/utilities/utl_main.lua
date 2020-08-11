
-- Global variables

Family           = require 'Engine.classes.Family'
FamilyCell       = require 'Engine.classes.FamilyCell'
FamilyMobil      = require 'Engine.classes.FamilyMobil'
FamilyRelational = require 'Engine.classes.FamilyRelational'

Agent           = require 'Engine.classes.Agent'
Cell            = require 'Engine.classes.Cell'
Mobil           = require 'Engine.classes.Mobil'
Relational      = require 'Engine.classes.Relational'
Params          = require 'Engine.classes.Params'

__str_fls       = require 'Engine.utilities.utl_strings_and_files'
lines_from      = __str_fls.lines_from
split           = __str_fls.split

__fam           = require 'Engine.utilities.utl_collections'
create_patches  = __fam.create_patches
clone_n_act     = __fam.clone_n_act
ask             = __fam.ask
die             = __fam.die

__fltr          = require 'Engine.utilities.utl_filters'
first_n         = __fltr.first_n
last_n          = __fltr.last_n
one_of          = __fltr.one_of
n_of            = __fltr.n_of

__chk           = require 'Engine.utilities.utl_checks'
member_of       = __chk.member_of

__act           = require 'Engine.utilities.utl_actions'
shuffle         = __act.shuffle
fd              = __act.fd
fd_grid         = __act.fd_grid
gtrn            = __act.gtrn
rt              = __act.rt
lt              = __act.lt


-- This function encapsulates the anonymous function defined in the "setup" call of the
-- file main_code.lua.
-- It creates a grid of patches with the parameters defined in Config object.
-- Then, it executes once the anonymous function defined in the "setup" call of the main file.

setup = function( funct )
    math.randomseed(os.time())
    __ticks = 1
    funct()
end



-- This function encapsulates the anonymous function defined in the "run" call of the
-- file main_code.lua.
-- It is running until one of the stop condition is reached.
-- Config.ticks simulate the ticks slider in netlogo.
-- Config.go simulate the go button in NetLogo interface.

run = function(funct)
    while Config.go do -- While the 'go' button is pushed
        if __ticks <= Config.ticks then
            funct()
            __ticks = __ticks+1
        else
            Config.go = false
        end
    end
end


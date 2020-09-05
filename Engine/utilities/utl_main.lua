------------------
-- The main module. It offers some methods as global variables and the setup and run functions
-- @module
-- main

-- Math constants

__2pi   = 2*math.pi



-- Global variables

Family              = require 'Engine.classes.Family'
FamilyCell          = require 'Engine.classes.FamilyCell'
FamilyMobil         = require 'Engine.classes.FamilyMobil'
FamilyRelational    = require 'Engine.classes.FamilyRelational'
Collection          = require 'Engine.classes.Collection'

Agent               = require 'Engine.classes.Agent'
Cell                = require 'Engine.classes.Cell'
Mobil               = require 'Engine.classes.Mobil'
Relational          = require 'Engine.classes.Relational'
Params              = require 'Engine.classes.Params'

__list_tables       = require 'Engine.utilities.utl_list_and_tables'
list_copy           = __list_tables.list_copy
list_remove         = __list_tables.list_remove
list_remove_index   = __list_tables.list_remove_index
fam_to_list         = __list_tables.fam_to_list


__str_fls           = require 'Engine.utilities.utl_strings_and_files'
lines_from          = __str_fls.lines_from
split               = __str_fls.split

__fam               = require 'Engine.utilities.utl_families'
create_grid         = __fam.create_grid
purge_agents        = __fam.purge_agents
clone_n             = __fam.clone_n
ask_ordered         = __fam.ask_ordered
ask_n               = __fam.ask_n
ask                 = __fam.ask
__producer          = __fam.__producer
__consumer          = __fam.__consumer

__fltr              = require 'Engine.utilities.utl_filters'
first_n             = __fltr.first_n
last_n              = __fltr.last_n
one_of              = __fltr.one_of
n_of                = __fltr.n_of
up_to_n_of          = __fltr.up_to_n_of
agents_in           = __fltr.agents_in
find_families       = __fltr.find_families

__chk               = require 'Engine.utilities.utl_checks'
is_instance         = __chk.is_instance
is_family           = __chk.is_family
is_agent            = __chk.is_agent
is_in_list          = __chk.is_in_list
same_rgb            = __chk.same_rgb
same_rgba           = __chk.same_rgba
same_pos            = __chk.same_pos

__act               = require 'Engine.utilities.utl_actions'
array_shuffle       = __act.array_shuffle
die                 = __act.die
fd                  = __act.fd
fd_grid             = __act.fd_grid
gtrn                = __act.gtrn
rt                  = __act.rt
lt                  = __act.lt

-- Utils from Penlight
tablex  = require 'pl.tablex'
pretty  = require 'pl.pretty'
pd      = pretty.dump

------------------
-- Beside run function this is one of the most important functions, It consist in an anonymous function where we have to define the initial configuration of the system.
-- @function setup
-- @param funct An anonymous function.
-- @return Nothing, unless we specified it in the anonymous function.
-- @usage
-- setup(function() 
--     Cells = create_patches(100,100)
--     Agents= FamilyMobil()
--     for i=1,50 do
--         Agents:add({
--             ['pos'] = one_of(Cells).pos
--         })
--     end
-- end)
-- -- This will result in a grid of 100x100, and 50 agents randomly positioned in the grid.
SETUP = function( funct )
    math.randomseed(os.time())
    __ticks = 1
    funct()
end



-- This function encapsulates the anonymous function defined in the "run" call of the
-- file main_code.lua.
-- It is running until one of the stop condition is reached.
-- Config.ticks simulate the ticks slider in netlogo.
-- Config.go simulate the go button in NetLogo interface.

------------------
-- This function is called until we reach a stop condition. Is one of the most important functions of the system and it consist in an anonymous function where we define the actions in every iteration.
-- @function run
-- @param funct, An anonymous function
-- @return Nothing
-- @usage
-- run(function()
--     if Agents.count == 0 then
--         Config.go = false
--     end
--
--     ask(Agents, function(ag)
--         ag:gtrn()
--         if(ag.pos == {0,0}) then die(ag) end
--     end)
--
--     purge_agents()
-- end)
RUN = function(funct)
    while Config.go do -- While the 'go' button is pushed
        if __ticks <= Config.ticks then
            funct()
            __ticks = __ticks+1
        else
            Config.go = false
        end
    end
end


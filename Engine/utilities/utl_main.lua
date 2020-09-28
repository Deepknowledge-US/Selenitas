------------------
-- The main module. It offers some methods as global variables and the setup and run functions
-- @module
-- main

-- Math constants
__pi    = math.pi
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
Observer            = require 'Engine.classes.Observer'
Interface           = require 'Engine.classes.Interface'
Simulation          = require 'Engine.classes.Simulation'

__list_tables       = require 'Engine.utilities.utl_list_and_tables'
list_copy           = __list_tables.list_copy
list_remove         = __list_tables.list_remove
list_remove_index   = __list_tables.list_remove_index
fam_to_list         = __list_tables.fam_to_list

__iterators         = require 'Engine.utilities.utl_iterators'
__producer          = __iterators.__producer
__consumer          = __iterators.__consumer
shuffled            = __iterators.shuffled
ordered             = __iterators.ordered
sorted              = __iterators.sorted

__numbers           = require 'Engine.utilities.utl_numbers_and_dist'
round               = __numbers.round
random_float        = __numbers.random_float
dist_euc_to         = __numbers.dist_euc_to

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
-- __producer          = __fam.__producer
-- __consumer          = __fam.__consumer

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
n_decimals          = __act.n_decimals
array_shuffle       = __act.array_shuffle
kill_and_purge      = __act.kill_and_purge
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


-- Init Params

Simulation  = Simulation()
Interface   = Interface()
Observer    = Observer()



--===========--
-- FUNCTIONS --
--===========--

------------------
-- This function removes from the system all agents and all families
-- @function clear_simulation
-- @return Nothing
-- @usage
-- clear_simulation()
clear = function(str)

    if string.lower(str) == 'all' then
        for k,v in ipairs(Simulation.families)do
            for _,ag in ordered(v)do
                ag = nil
            end
            v = nil
        end
        Simulation.families     = {}
        Simulation.num_agents   = 0

    end
end

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
    funct()
    Simulation:start()
end



-- This function encapsulates the anonymous function defined in the "run" call of the
-- file main_code.lua.
-- It is running until one of the stop condition is reached.

------------------
-- This function is called until we reach a stop condition. Is one of the most important functions of the system and it consist in an anonymous function where we define the actions in every iteration.
-- @function STEP
-- @param funct, An anonymous function
-- @return Nothing
-- @usage
-- TODO
STEP = function(funct)
    while Simulation.is_running do -- While the 'run' button is pushed
        if Simulation.max_time > 0 and Simulation.time < Simulation.max_time then
            Simulation.time = Simulation.time+1
            funct()
        else
            Simulation:stop()
        end
    end
end


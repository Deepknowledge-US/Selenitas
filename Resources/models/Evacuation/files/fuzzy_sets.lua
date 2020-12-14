require 'Engine.utilities.utl_main'



---------------------------------
-- Accident probability
---------------------------------

local acc_prob = luafuzzy()

-----------
-- Inputs
-----------

local dens = acc_prob:addinp( 'density', 0., 100. )
dens:addlingvar( 'low', gaussmf, { 30., 0. } )
dens:addlingvar( 'med', gaussmf, { 15., 50. } )
dens:addlingvar( 'high',gaussmf, { 10., 100. } )

local sp = acc_prob:addinp( 'speed', 0. , 100. )
sp:addlingvar( 'low', gaussmf, { 30., 0. } )
sp:addlingvar( 'med', gaussmf, { 10., 50. } )
sp:addlingvar( 'high',gaussmf, { 5., 100. } )

-----------
-- Output
-----------

local acc = acc_prob:addout( 'acc', 0., 100. )
acc:addlingvar( 'low', gaussmf, { 1., 0. } )
acc:addlingvar( 'med', gaussmf, { 20., 30. } )
acc:addlingvar( 'high',gaussmf, { 10., 100. } )

-----------
-- Rules
-----------

local r11 = acc_prob:addrule( 1, 'andmethod' )
r11:addpremise(false, 'density','high' )
r11:addpremise(false, 'speed',  'high' )
r11:addimplic( false, 'acc',    'high' )

local r12 = acc_prob:addrule( 1, 'ormethod' )
r12:addpremise(false, 'density','low' )
r12:addimplic( false, 'acc',    'low' )

local r13 = acc_prob:addrule( 1, 'andmethod' )
r13:addpremise(false, 'density','med' )
r13:addpremise(false, 'speed',  'low' )
r13:addimplic( false, 'acc',    'low' )

local r14 = acc_prob:addrule( 1, 'andmethod' )
r14:addpremise(false, 'density','med' )
r14:addpremise(false, 'speed',  'high' )
r14:addimplic( false, 'acc',    'med' )

local r15 = acc_prob:addrule( 1, 'andmethod' )
r15:addpremise(false, 'density','high')
r15:addpremise(false, 'speed',  'med' )
r15:addimplic( false, 'acc',    'med' )




---------------------------------
-- Danger probability
---------------------------------

local danger_prob = luafuzzy()

----------
-- Inputs
----------

risk = danger_prob:addinp( 'risk', 0., 100. )
risk:addlingvar( 'low', gaussmf, { 10., 0. } )
risk:addlingvar( 'med', gaussmf, { 10., 50. } )
risk:addlingvar( 'high',gaussmf, { 20., 100. } )

distance = danger_prob:addinp( 'distance', 0. , 100. )
distance:addlingvar( 'low', gaussmf, { 30., 0. } )
distance:addlingvar( 'med', gaussmf, { 10., 50. } )
distance:addlingvar( 'high',gaussmf, { 10., 100. } )

-----------
-- Outputs
-----------

danger = danger_prob:addout( 'danger', 0., 100. )
danger:addlingvar( 'low',  gaussmf, { 20. , 0. } )
danger:addlingvar( 'med',  gaussmf, { 15., 40. } )
danger:addlingvar( 'high', gaussmf, { 10., 100. } )

-----------
-- Rules
-----------

local r21 = danger_prob:addrule( 1, 'ormethod' )
r21:addpremise(false, 'risk',      'high' )
r21:addpremise(false, 'distance',  'low' )
r21:addimplic( false, 'danger',    'high' )

local r22 = danger_prob:addrule( 1, 'andmethod' )
r22:addpremise(false, 'risk',   'med' )
r22:addpremise(false, 'distance','med' )
r22:addimplic( false, 'danger', 'med' )

local r22 = danger_prob:addrule( 1, 'andmethod' )
r22:addpremise(false, 'risk',   'med' )
r22:addpremise(false, 'distance','high' )
r22:addimplic( false, 'danger', 'med' )

local r23 = danger_prob:addrule( 1, 'andmethod' )
r23:addpremise(false, 'risk',     'low' )
r23:addpremise(false, 'distance', 'high' )
r23:addimplic( false, 'danger',   'low' )




---------------------------------
-- Panic probability
---------------------------------

local panic_prob = luafuzzy()

-----------
-- Inputs
-----------

sensibility = panic_prob:addinp( 'sensibility', 0. , 100. )
sensibility:addlingvar( 'low',  gaussmf, { 10., 0. } )
sensibility:addlingvar( 'med',  gaussmf, { 25., 50. } )
sensibility:addlingvar( 'high', gaussmf, { 10.0, 100. } )

fear = panic_prob:addinp( 'fear', 0., 100. )
fear:addlingvar( 'low',  gaussmf, { 30., 0. } )
fear:addlingvar( 'med',  gaussmf, { 10., 50. } )
fear:addlingvar( 'high', gaussmf, { 5., 100. } )

-----------
-- Outputs
-----------

panic = panic_prob:addout( 'panic', 0., 100. )
panic:addlingvar( 'low',  gaussmf, { 1., 0. } )
panic:addlingvar( 'med',  gaussmf, { 25., 50. } )
panic:addlingvar( 'high', gaussmf, { 10., 100. } )

-----------
-- Rules
-----------

local r31 = panic_prob:addrule( 1, 'andmethod' )
r31:addpremise(false, 'fear',       'high' )
r31:addpremise(false, 'sensibility','high' )
r31:addimplic( false, 'panic',      'high' )

local r32 = panic_prob:addrule( 1, 'ormethod' )
r32:addpremise(false, 'fear', 'low' )
r32:addimplic( false, 'panic','low' )

local r33 = panic_prob:addrule( 1, 'andmethod' )
r33:addpremise(false, 'fear',       'med' )
r33:addpremise(false, 'sensibility','low' )
r33:addimplic( false, 'panic',      'low' )

local r34 = panic_prob:addrule( 1, 'andmethod' )
r34:addpremise(false, 'fear',       'med' )
r34:addpremise(false, 'sensibility','high' )
r34:addimplic( false, 'panic',      'med' )




return {
    accident    = function(density, speed) return acc_prob:solve(density, speed)    end,
    panic       = function(fear, sensibility) return panic_prob:solve(fear, sensibility) end,
    danger      = function(risk, distance) return danger_prob:solve(risk, distance) end
}




local ge = require "Visual.graphicengine"

if not arg[2] then
    -- Load default window
    ge.init()
    --dofile("Examples/Communication_T_T/main.lua")
else
    -- Run file specified by command line
    dofile(arg[2])
end
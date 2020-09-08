local ge = require "Visual.graphicengine"

-- Add Thirdparty folder to package path
love.filesystem.setRequirePath(love.filesystem.getRequirePath() .. ';Thirdparty/?.lua')
love.filesystem.setCRequirePath(love.filesystem.getCRequirePath() .. ';Native/?.so' .. ';Native/?.dll');

-- Load default window
ge.init()
--if arg[2] then
--    -- If file was specified in command line, load that file
--    ge.load_simulation_file(arg[2])
--end
local ge = require "Visual.graphicengine"

-- Add Thirdparty folder to package path
package.path = package.path .. ';Thirdparty/?.lua'

-- Load default window
ge.init()
--if arg[2] then
--    -- If file was specified in command line, load that file
--    ge.load_simulation_file(arg[2])
--end
------------------
-- Utilities to be used for client/server comunication
-- @module
-- paths


local utl_paths = {}


-- Adds a new path to package.path.
utl_paths.add_path = function(url)
    local path= ";" .. user_cwd .. url .. "?.lua"
    print(path)
    package.path= package.path .. path
end


return utl_paths
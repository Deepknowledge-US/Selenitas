------------------
-- Utilities to be used for client/server comunication
-- @module
-- web


local utl_web = {}

-- this needs to stay outside the function, or it'll re-sniff every time...
utl_web.open_cmd = nil


-- Attempts to open a given URL in the system default browser, regardless of Operating System.
utl_web.open_url = function(url)
    if not utl_web.open_cmd then
        if package.config:sub(1,1) == '\\' then -- windows
            utl_web.open_cmd = function()
                local cwd = love.filesystem.getRealDirectory("Visual_js")
                local path = cwd .. "/" .. url
				os.execute('start "" "' .. path .. '"')
            end
        -- the only systems left should understand uname...
        elseif (io.popen("uname -s"):read'*a') == "Darwin" then -- OSX/Darwin ? (I can not test.)
            utl_web.open_cmd = function()
                -- I cannot test, but this should work on modern Macs.
                os.execute(string.format('open "%s"', url))
            end
        else -- that ought to only leave Linux
            utl_web.open_cmd = function()
                -- should work on X-based distros.
                os.execute(string.format('xdg-open "%s"', url))
            end
        end
    end

    utl_web.open_cmd(url)
end


return utl_web
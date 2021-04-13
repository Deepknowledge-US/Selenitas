local thread_publisher = [[
    print("publisher start")

    local cwd = love.filesystem.getRealDirectory("Thirdparty")
    local windows_path = ";"..cwd.."/Thirdparty/mqtt/mqtt/?.lua"

    package.path = package.path .. ";./Thirdparty/mqtt/mqtt/?.lua" .. windows_path

    local sock  = require("socket")
    local mqtt  = require("mqtt")

    local path

    -- Check OS and set the proper path to cjson library
    if package.config:sub(1,1) == '\\' then -- windows
        path = cwd .. "/Thirdparty/cjson/bin/mingw64/clib/cjson.dll"

    elseif (io.popen("uname -s"):read'*a') == "Darwin" then -- OSX/Darwin ? (I can not test.)
        path = "./Thirdparty/cjson/bin/osx64/clib/cjson.so"
    
    else -- that ought to only leave Linux
        path = "./Thirdparty/cjson/bin/linux64/clib/cjson.so"
    end


    local cjson = package.loadlib(path, "luaopen_cjson")
    local cjson2 = cjson()
    cjson2.encode_sparse_array(true)


    local IP    = "127.0.0.1:1883"
    local ID    = tostring( math.floor( math.random() * 100 ) )

    local ping = mqtt.client{
        uri      = IP,
        username = ID ,
        clean    = true
    }

    ping:on{
        connect = function(connack)
            assert(connack.rc == 0)

            assert(ping:subscribe{ topic="from_client/#", qos=1, callback=function(suback)
                assert(suback.rc[1] > 0)
            end })
        end,

        error = function(err)
            print("ping MQTT client error:", err)
        end,
    }

    while true do
        local panels_channel = love.thread.getChannel( 'new_panel' )
        local panel_info = panels_channel:pop()
        if panel_info then
            ping = mqtt.client{ uri = IP, username = ID , clean = true }
            ping:start_connecting()
            assert(ping:publish{ topic = "from_server/evacuation/panel_info", payload = cjson2.encode(panel_info), qos = 1 })
        end

        local state_channel = love.thread.getChannel( 'new_state' )
        local state_info = state_channel:pop()
        if state_info then
            ping = mqtt.client{ uri = IP, username = ID , clean = true }
            ping:start_connecting()
            assert(ping:publish{ topic = "from_server/evacuation", payload = cjson2.encode(state_info), qos = 1 })
        end
        sock.sleep(0.001)
    end

    print("publisher end")
]]

return thread_publisher

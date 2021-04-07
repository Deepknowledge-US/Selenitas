local thread_publisher = [[
    print("publisher start")
    package.path = package.path .. ";./Thirdparty/mqtt/mqtt/?.lua"
    local sock  = require("socket")

    local mqtt  = require("mqtt")

    -- local cjson  = require "cjson"
    -- local cjson2 = cjson.new()
    -- cjson2.encode_sparse_array(true)

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
            assert(ping:publish{ topic = "from_server/evacuation/panel_info", payload = "mensaje MQTT", qos = 1 })
            -- assert(ping:publish{ topic = "from_server/evacuation/panel_info", payload = cjson2.encode(panel_info), qos = 1 })
        end

        local state_channel = love.thread.getChannel( 'new_state' )
        local state_info = state_channel:pop()
        if state_info then
            ping = mqtt.client{ uri = IP, username = ID , clean = true }
            ping:start_connecting()
            assert(ping:publish{ topic = "from_server/evacuation", payload = "mensajeB MQTT", qos = 1 })
            print("message send")
            -- assert(ping:publish{ topic = "from_server/evacuation", payload = cjson2.encode(state_info), qos = 1 })
        end
        sock.sleep(0.001)
    end

    print("publisher end")
]]

return thread_publisher

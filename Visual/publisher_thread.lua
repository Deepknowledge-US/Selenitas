local thread_publisher = [[
    local sock  = require "socket"
    local mqtt  = require "mqtt"

    local cjson  = require "cjson"
    local cjson2 = cjson.new()
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
        local state_channel = love.thread.getChannel( 'new_state' )
        local state = state_channel:pop()
        if state then
            ping = mqtt.client{ uri = IP, username = ID , clean = true }
            ping:start_connecting()
            assert(ping:publish{ topic = "from_server/evacuation", payload = cjson2.encode(state), qos = 1 })
        end
        sock.sleep(0.001)
    end

]]

return thread_publisher

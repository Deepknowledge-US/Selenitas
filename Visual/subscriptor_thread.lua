
local thread_subscriptor = [[
    print("subscriber start")

    local cwd = love.filesystem.getRealDirectory("Thirdparty")
    local windows_path = ";"..cwd.."/Thirdparty/mqtt/mqtt/?.lua"

    package.path = package.path .. ";./Thirdparty/mqtt/mqtt/?.lua" .. windows_path
    local mqtt = require("mqtt")
    local mqtt_ioloop = require("ioloop")

    local info_channel = love.thread.getChannel( 'info' )

    local pong = mqtt.client{
        uri = "127.0.0.1:1883",
        username = tostring( math.floor( math.random() * 100 ) ) ,
        clean = true
    }

    pong:on{
        connect = function(connack)
            assert(connack.rc == 0)

            assert(pong:subscribe{ topic="from_client/#", qos=1, callback=function(suback)
                assert(suback.rc[1] > 0)
            end })
        end,

        message = function(msg)
            info_channel:push(msg.payload)
            assert(pong:acknowledge(msg))
        end,
        error = function(err)
            print("pong MQTT client error:", err)
        end,
    }

    local ioloop = mqtt_ioloop.create()
    ioloop:add(pong)
    ioloop:run_until_clients()

    print("subscriber end")
]]

return thread_subscriptor

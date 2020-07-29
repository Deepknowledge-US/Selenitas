local pl            = require 'pl'
local Collection    = require 'Engine.classes.class_collection_agents'
local Params        = require 'Engine.classes.class_params'
local utils         = require 'Engine.utilities'
local ask           = utils.ask
local setup         = utils.setup
local run           = utils.run
local rt            = utils.rt
local gtrn          = utils.go_to_random_neighbour

Config = Params({
    ['start'] = true,
    ['go']    = true,
    ['ticks'] = 100,
    ['xsize'] = 60,
    ['ysize'] = 60

})


local histogram     = {}
local num_of_bars   = 7
local bar_breaks    = {}


local function n_decimals(num_dec, target)
    local res = math.floor(target * 10^num_dec)
    return res / 10^num_dec
end

local function set_intervals_and_init_histogram()
    local mod = Config.xsize / num_of_bars
    for i=1, num_of_bars do
        local limit = i~=num_of_bars and n_decimals(2,i*mod) or Config.xsize
        table.insert(bar_breaks, limit )
        histogram[limit] = 0
    end
end

local function reset_histogram()
    for k,v in pairs(histogram)do
        histogram[k] = 0
    end
end

local function print_current_config()

    reset_histogram()

    ask(Agents, function(agent)
        for k,v in ipairs(bar_breaks) do
            if agent.xcor <= v then
                histogram[v] = histogram[v] + 1
                break
            end
        end
    end)

    for k,v in ipairs(bar_breaks)do
        print(v, histogram[v])
    end

end



setup(function()
    -- Create a new collection
    Agents = Collection()

    -- Populate the collection with Agents.
    Agents:create_n( 5000, function()
        return {
            ['xcor']    = math.floor(Config.xsize / 2),
            ['ycor']    = math.floor(Config.ysize / 2)
        }
    end)

    set_intervals_and_init_histogram()

end)


run(function()

    print('========= tick '.. T ..' ==========')

    ask(Agents, function(x)
        rt(x,math.random(360))
        gtrn(x)
    end)

    print_current_config()

    print('===========================')

end)


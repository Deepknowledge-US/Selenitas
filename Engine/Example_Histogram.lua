local pl            = require 'pl'
local pretty        = require 'pl.pretty'
local config        = require 'Engine.config_file'
local Agent         = require 'Engine.classes.class_agent'
local Collection    = require 'Engine.classes.class_collection'
local Relational    = require 'Engine.classes.class_relational'
local Patch         = require 'Engine.classes.class_patch'
local utils         = require 'Engine.utilities'
local utl           = require 'pl.utils'
local lambda        = utl.string_lambda
local first_n       = utils.first_n
local last_n        = utils.last_n
local member_of     = utils.member_of
local one_of        = utils.one_of
local n_of          = utils.n_of
local ask           = utils.ask
local setup         = utils.setup
local run           = utils.run
local rt            = utils.rt
local gtrn          = utils.go_to_random_neighbour



local histogram     = {}
local num_of_bars   = 7
local bar_breaks    = {}

local distribution = {}

config.ticks = 500 -- This line overwrites the value in config_file

local function n_decimals(num_dec, target)
    local res = math.floor(target * 10^num_dec)
    return res / 10^num_dec
end

local function set_intervals_and_init_histogram()
    local mod = config.xsize / num_of_bars
    for i=1, num_of_bars do
        local limit = i~=num_of_bars and n_decimals(2,i*mod) or config.xsize
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

    -- Uncomment the following lines to show a naive representation of world in each iteration
    -- for i=config.ysize,1,-1 do
    --     local line = ""
    --     for j = 1,config.xsize do
    --         line = line .. distribution[j..','..i] .. ','
    --     end
    --     print(line)
    -- end

    for k,v in ipairs(bar_breaks)do
        print(v, histogram[v])
    end

end



setup(function()
    -- Create a new collection
    Agents = Collection()

    -- Populate the collection with Agents.
    Agents:create_n( 1000, function()
        return Agent({
            ['xcor']    = 30,
            ['ycor']    = 30
        })
    end)

    set_intervals_and_init_histogram()
    print('========= tick 0 ==========')
    print_current_config()
    print('===========================')
end)


run(function()

    ask(Agents, function(x)
        rt(x,math.random(360))
        gtrn(x)
    end)


    print_current_config()

end)


require 'Engine.utilities.utl_main'

local pl   = require 'pl'

Config = Params({
    ['start'] = true,
    ['go']    = true,
    ['ticks'] = 100,
    ['xsize'] = 60,
    ['ysize'] = 60

})

--[[
    In this example, we divide the space in 7 regions and count in every iteration the number
    of agents in them. The agents are positioned in the center of the grid in the setup.

]]--

local histogram     = {}
local num_of_bars   = 7
local bar_breaks    = {}

-- A round function 
local function n_decimals(num_dec, target)
    local res = math.floor(target * 10^num_dec)
    return res / 10^num_dec
end

-- Set the intervals in function of grid size and init the histogram table using this values as keys
local function set_intervals_and_init_histogram()
    local mod = Config.xsize / num_of_bars
    for i=1, num_of_bars do
        local limit = i~=num_of_bars and n_decimals(2,i*mod) or Config.xsize
        table.insert(bar_breaks, limit )
        histogram[limit] = 0
    end
end

-- A function to reset the values. We have to start a new count in each iteration.
local function reset_histogram()
    for k,v in pairs(histogram)do
        histogram[k] = 0
    end
end


local function print_current_config()

    print('========= tick ' .. __ticks .. ' ==========')
    reset_histogram()

    -- Each agent will increment the counter of the histogram table depending on its position.
    ask(Agents, function(agent)
        for k,v in ipairs(bar_breaks) do
            if agent:xcor() <= v then
                histogram[v] = histogram[v] + 1
                break
            end
        end
    end)

    for k,v in ipairs(bar_breaks)do
        print(v, histogram[v])
    end
    print('===========================')

end


setup(function()
    -- Create a new collection
    Agents = FamilyMobil()

    -- Populate the collection with Agents and move them to the center of the grid
    Agents:create_n( 1000, function()
        return {
            ['pos'] = {math.floor(Config.xsize / 2), math.floor(Config.ysize / 2)}
        }
    end)

    set_intervals_and_init_histogram()

end)


run(function()

    -- We are asking all agents to go to a random neighbour in the grid
    ask(Agents, function(x)
        x:gtrn()
    end)

    print_current_config()

end)


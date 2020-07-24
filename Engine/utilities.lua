local config    = require 'Engine.config_file'
local Collection= require 'Engine.classes.class_collection'
local Patch     = require 'Engine.classes.class_patch'
local pretty    = require 'pl.pretty'
local utl       = require 'pl.utils'
local lambda    = utl.string_lambda
local sin       = math.sin
local cos       = math.cos
local rad       = math.rad

local utils = {}
---------------------------------------------


-- ======================================= --
-- FUNCTIONS FOR READING FILES AND STRINGS --
-- ======================================= --

local function file_exists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end

function utils.lines_from(file)
    if not file_exists(file) then return {} end
    local lines = {}
    for line in io.lines(file) do
      lines[#lines + 1] = line
    end
    return lines
end


function utils.split(pString, pPattern)
    local Table = {}
    local fpat = "(.-)" .. pPattern
    local last_end = 1
    local s, e, cap = pString:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
        table.insert(Table,cap)
        end
        last_end = e+1
        s, e, cap = pString:find(fpat, last_end)
    end
    if last_end <= #pString then
        cap = pString:sub(last_end)
        table.insert(Table, cap)
    end
    return Table
end
--------------------------


-- ==================== --
-- UTILITIES FOR TABLES --
-- ==================== --

function utils.first_n(n,table)
    local res = {}
    if n >= #table then
        return table
    else
        for i=1,n do
            res[i] = table[i]
        end
    end
    return res
end


function utils.last_n(n,table)
    local res = {}
    if n >= #table then
        return table
    else
        for i = #table-(n-1) , #table do
            res[#res+1] = table[i]
        end
    end
    return res
end

-- Given an item and a set of elements or a collection, decide if item is included in the set.
function utils.member_of(item, elements)
    if elements.agents then
        if elements.agents[item.id] then return true end
    else
        for _,v in pairs(elements) do
            if v == item then return true end
        end
    end
    return false
end


-------------------------------

-- ========================= --
-- UTILITIES FOR COLLECTIONS --
-- ========================= --


function utils.create_patches()
    local patches  = Collection()

    local x,y      = config.xsize , config.ysize
    for i=1,x do
        for j = 1,y do
            local link_id = i .. ',' .. j
            patches:add( Patch({ ['id'] = link_id, ['xcor'] = i, ['ycor'] = j })  )
        end
    end
    patches:shuffle()
    return patches
end



-----------------------------------

-- ========================== --
-- NETLOGO INSPIRED FUNCTIONS --
-- ========================== --

-- It Applies a function to all elements. Works with collections or with tables.
function utils.ask(elements, funct)
    if elements.order then
        for _,v in pairs(elements.agents)do
            funct(v)
        end
    else
        for _,v in pairs(elements)do
            funct(v)
        end
    end
end

-- Removes an element in a collection
function utils.die(agent, Agents)
    Agents:kill(agent)
end

-- Caution!! this function returns a list which contains a single element
function utils.one_of(elements)
    if elements.order then
        local target = elements.order
        local chosen = math.random(#target)
        return {elements.agents[ elements.order[chosen] ]}
    else
        local target = elements
        local chosen = math.random(#target)
        return {elements[chosen]}
    end
    
end

-- Select n random elements in a collection
function utils.n_of(n,collection)
    local elements = collection.agents
    local res, aux = {},{}
    math.randomseed(os.time())

    if n <= #elements / 2 then
        while #res < n do 
            local chosen = elements[ math.random(#elements)]
            if not utils.member_of(chosen,res) then
                table.insert(res,chosen)
            end
        end
    else
        while #aux < #elements - n do
            local chosen = elements[ math.random(#elements)]
            if not utils.member_of(chosen,aux) then
                table.insert(aux,chosen)
            end
        end
        for _,v in pairs(elements) do 
            if not utils.member_of(v,aux) then
                table.insert(res,v)
            end
        end

    end
    return res
end

-- A right turn of "num" degrees
function utils.rt(agent, num)
    agent.head = agent.head + num
end

-- A left turn of "num" degrees
function utils.lt(agent, num)
    agent.head = (agent.head + num) % 360
end

-- Advance in the faced direction. The distance is specified with num
function utils.fd(agent, num)

    local s = sin(rad(agent.head))
    agent.xcor = agent.xcor + s * num

    local c = cos(rad(agent.head))
    agent.ycor = agent.ycor + c * num

end

-- Advance in a grid in the faced direction
function utils.fd_grid(agent, num)

    local s = sin(rad(agent.head))
    agent.xcor = math.ceil(agent.xcor + s * num)

    local c = cos(rad(agent.head))
    agent.ycor = math.ceil(agent.ycor + c * num)

end


-- This function encapsulates a call to the function clone_n_act in the collection given as parameter
function utils.clone_n_act(n,agent,collection, funct)
    return collection:clone_n_act(n,agent,funct)
end


-- 8 neighbours are considered.
--  0 0 0        0 0 x
--  0 x 0   ->   0 0 0
--  0 0 0        0 0 0
-- Extremes of the grid are conected.
function utils.go_to_random_neighbour(x)

    local changes = { {0,1},{0,-1},{1,0},{-1,0},{1,1},{1,-1},{-1,1},{-1,-1} }
    local choose  = math.random(#changes)

    -- Agents that cross a boundary will appear on the opposite side of the grid
    x.xcor = (x.xcor + changes[choose][1]) % config.xsize
    x.xcor = x.xcor > 0 and x.xcor or config.xsize

    x.ycor = (x.ycor + changes[choose][2]) % config.ysize
    x.ycor = x.ycor > 0 and x.ycor or config.ysize

end


-- This function encapsulates the anonymous function defined in the "setup" call of the
-- file main_code.lua.
-- It creates a grid of patches with the parameters defined by user in config_file.lua
-- Then it executes once the anonymous function defined in the "setup" call of the main_code.lua file.

function utils.setup( funct )
    funct()
end



-- This function encapsulates the anonymous function defined in the "run" call of the
-- file main_code.lua.
-- It is running until one of the stop condition is reached.
-- config.ticks simulate the ticks slider in netlogo.
-- config.go simulate the go button in NetLogo interface.

function utils.run(funct)
    math.randomseed(os.time())
    T = 0
    while config.go do -- While the 'go' button is pushed
        if T < config.ticks then
            funct()
            T=T+1
        else
            config.go = false
        end
    end
end



return utils
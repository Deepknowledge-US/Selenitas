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
-- UTILITIES FOR LISTS  --
-- ==================== --

-- This function returns the first n elements of a list
function utils.first_n(n,list)
    local res = {}
    if n >= #list then
        return list
    else
        for i=1,n do
            res[i] = list[i]
        end
    end
    return res
end


-- This function returns the last n elements of a list
function utils.last_n(n,list)
    local res = {}
    if n >= #list then
        return list
    else
        for i = #list-(n-1) , #list do
            res[#res+1] = list[i]
        end
    end
    return res
end
--------------------------


-- ==================== --
-- UTILITIES FOR TABLES --
-- ==================== --

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

-- Simple method to shuffle a list. It consist on permutations of the objects in a list.
function utils.shuffle(list)
    local array = list
    for i = #array,2, -1 do
        local j = math.random(i)
        array[i], array[j] = array[j], array[i]
    end
end;

-------------------------------

-- ========================= --
-- UTILITIES FOR COLLECTIONS --
-- ========================= --


--[[
    This function create a new collection of patches. The size of the grid is determined by x and y 
    TODO: 3rd dimension
]]
function utils.create_patches(x,y,z)
    local patches  = Collection()

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

-- Caution!! this function returns a list containing a single element. This is necessary becouse "ask" function receives
-- a table as the first parameter to iterate on its elements.
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

-- Select n random elements in a collection or a table
function utils.n_of(n,collection)

    local res, aux={},{}
    local elements = collection.order

    if elements ~= nil then
        utils.shuffle(elements)
        local n_ids = utils.first_n(n,elements)
        for _,v in pairs(n_ids) do
            table.insert(res,collection.agents[v])
        end
    else
        if n > #collection / 2 then
            while #aux < # collection - n do
                local chosen = collection[ math.random(#elements)]
                if not utils.member_of(chosen,aux) then
                    table.insert(aux,chosen)
                end
            end

            for _,v in pairs(elements) do 
                if not utils.member_of(v,aux) then
                    table.insert(res,v)
                end
            end
        else
            while #res < n do
                local chosen = collection[ math.random(#elements)]
                if not utils.member_of(chosen,res) then
                    table.insert(res,chosen)
                end
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
    agent.xcor = (agent.xcor + s * num) % Config.xsize

    local c = cos(rad(agent.head))
    agent.ycor = (agent.ycor + c * num) % Config.ysize

end

-- Advance in a grid in the faced direction
function utils.fd_grid(agent, num)

    local s = sin(rad(agent.head))
    agent.xcor = math.ceil( (agent.xcor + s * num) % Config.xsize )
    if agent.xcor == 0 then agent.xcor = Config.xsize end

    local c = cos(rad(agent.head))
    agent.ycor = math.ceil( (agent.ycor + c * num) % Config.ysize )
    if agent.ycor == 0 then agent.ycor = Config.ysize end

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
    x.xcor = (x.xcor + changes[choose][1]) % Config.xsize
    x.xcor = x.xcor > 0 and x.xcor or Config.xsize

    x.ycor = (x.ycor + changes[choose][2]) % Config.ysize
    x.ycor = x.ycor > 0 and x.ycor or Config.ysize

end


-- This function encapsulates the anonymous function defined in the "setup" call of the
-- file main_code.lua.
-- It creates a grid of patches with the parameters defined in Config object.
-- Then, it executes once the anonymous function defined in the "setup" call of the main file.

function utils.setup( funct )
    math.randomseed(os.time())
    T = 1
    funct()
end



-- This function encapsulates the anonymous function defined in the "run" call of the
-- file main_code.lua.
-- It is running until one of the stop condition is reached.
-- Config.ticks simulate the ticks slider in netlogo.
-- Config.go simulate the go button in NetLogo interface.

function utils.run(funct)
    while Config.go do -- While the 'go' button is pushed
        if T <= Config.ticks then
            funct()
            T=T+1
        else
            Config.go = false
        end
    end
end



return utils
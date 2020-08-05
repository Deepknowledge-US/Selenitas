local sin       = math.sin
local cos       = math.cos
local rad       = math.rad

local utl_actions = {}


-- Simple method to shuffle a list. It consist on permutations of the objects in a list.
function utl_actions.shuffle(list)
    local array = list
    for i = #array,2, -1 do
        local j = math.random(i)
        array[i], array[j] = array[j], array[i]
    end
end;


-- A right turn of "num" degrees
function utl_actions.rt(agent, num)
    agent.head = (agent.head + num) % 360
end

-- A left turn of "num" degrees
function utl_actions.lt(agent, num)
    agent.head = (agent.head + num) % 360
end

-- Advance in the faced direction. The distance is specified with num
function utl_actions.fd(agent, num)

    local s = sin(rad(agent.head))
    agent.pos[1] = (agent:xcor() + s * num) % Config.xsize

    local c = cos(rad(agent.head))
    agent.pos[2] = (agent:ycor() + c * num) % Config.ysize

end

-- Advance in a grid in the faced direction
function utl_actions.fd_grid(agent, num)

    local s = sin(rad(agent.head))
    agent.pos[1] = math.ceil( (agent:xcor() + s * num) % Config.xsize )
    if agent:xcor() == 0 then agent.pos[1] = Config.xsize end

    local c = cos(rad(agent.head))
    agent.pos[2] = math.ceil( (agent:ycor() + c * num) % Config.ysize )
    if agent:ycor() == 0 then agent.pos[2] = Config.ysize end

end


-- Agent will be moved to one of its patch neighbours (8 neighbours are considered).
--  0 0 0        0 0 x
--  0 x 0   ->   0 0 0
--  0 0 0        0 0 0
-- Extremes of the grid are conected.
function utl_actions.gtrn(x)

    local changes = { {0,1},{0,-1},{1,0},{-1,0},{1,1},{1,-1},{-1,1},{-1,-1} }
    local choose  = math.random(#changes)

    -- Agents that cross a boundary will appear on the opposite side of the grid
    x.pos[1] = (x:xcor() + changes[choose][1]) % Config.xsize
    x.pos[1] = x:xcor() > 0 and x:xcor() or Config.xsize

    x.pos[2] = (x:ycor() + changes[choose][2]) % Config.ysize
    x.pos[2] = x:ycor() > 0 and x:ycor() or Config.ysize

end



return utl_actions
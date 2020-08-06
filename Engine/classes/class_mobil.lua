local class  = require 'pl.class'
local sin       = math.sin
local cos       = math.cos
local rad       = math.rad
local pretty    = require 'pl.pretty'
local pd = pretty.dump

--[[
    When a new agent is created, it is given some properties (if we haven't already done so)

    with 'xcor' and 'ycor' we locate the agent in the space. -- TODO: zcor
    'head' is a parameter to know the direction the agent is facing (in a 2d space. 360º)
    'shape' and 'color' determines the aspect of the agent
    'linked' is a list of references to other agents (its neighbours)

    Caution!
    When an agent A has as neighbour an agent B, both agents will hold a reference to the other 
    object in its linked table.
    Some functions as pretty.dump() iterates recursively over the tables or metatables present 
    in an object, so if we try pretty.dump(A) it produces a cycle.
]]--

local Mobil = class.Mobil {
    _init = function(self,o)
        local c         = o or {}
        self            = c
        self.pos        = c.pos         or {0, 0, 0}
        self.color      = c.color       or {0.5,0.5,0.5,1}
        self.head       = c.head        or {0,0}
        self.shape      = c.shape       or 'triangle'
        self.size       = c.size        or 1
        self.visible    = c.visible     or true
        self.z_order    = c.z_order     or 1
        self.label      = c.label       or ''
        self.label_color= c.label_color or {1,1,1,1}

        return self
    end;

--[[
    This function applies to the agent a series of functions consecutively.
    The number of functions gived as parameters is not predetermined.
    Caution! we are assuming functions with one ore less parameters as inputs.
]]--
    does = function(self, ...)
        for i = 1,select('#', ...)do
            local funct = select( i, ... )
            funct(self)
        end
        return self
    end;

    xcor = function(self)
        return self.pos[1]
    end;

    ycor = function(self)
        return self.pos[2]
    end;

    zcor = function(self)
        return self.pos[3]
    end;



--[[
    Naive function to print Agents. When we call "print(instance_of_agent)" this function is
    colled to print the agent. Use print() instead of pretty.dump()
]]--
    __tostring = function(self)
        local res = "{\n"
        for k,v in pairs(self) do
            if type(v) == 'table' then
                res = res .. '\t'  .. k .. ': {\n'
                for k2,v2 in pairs(v) do
                    res = res .. '\t\t' .. k2 .. ': ' .. type(v2) .. '\n'
                end
                res = res .. '\t}\n'
            else
                res = res .. '\t' .. k .. ': ' .. v .. '\n'
            end
        end
        res = res .. '}'
        return res
    end;


    -- A right turn of "num" degrees
    rt = function(self, num)
        self.head[1] = (self.head[1] + num) % 360
        return self
    end;

    -- A left turn of "num" degrees
    lt = function(self, num)
        self.head[1] = (self.head[1] + num) % 360
        return self
    end;

    -- Advance in the faced direction. The distance is specified with num
    fd = function(self, num)

        local s = sin(rad(self.head[1]))
        self.pos[1] = (self:xcor() + s * num) % Config.xsize

        local c = cos(rad(self.head[1]))
        self.pos[2] = (self:ycor() + c * num) % Config.ysize

        return self
    end;

    -- Advance in a grid in the faced direction
    fd_grid = function(self, num)

        local s = sin(rad(self.head[1]))
        self.pos[1] = math.ceil( (self:xcor() + s * num) % Config.xsize )
        if self:xcor() == 0 then self.pos[1] = Config.xsize end

        local c = cos(rad(self.head[1]))
        self.pos[2] = math.ceil( (self:ycor() + c * num) % Config.ysize )
        if self:ycor() == 0 then self.pos[2] = Config.ysize end
        return self

    end;


    -- Agent will be moved to one of its patch neighbours (8 neighbours are considered).
    --  0 0 0        0 0 x
    --  0 x 0   ->   0 0 0
    --  0 0 0        0 0 0
    -- Extremes of the grid are conected.
    gtrn = function(self)

        local changes = { {0,1},{0,-1},{1,0},{-1,0},{1,1},{1,-1},{-1,1},{-1,-1} }
        local choose  = math.random(#changes)

        -- Agents that cross a boundary will appear on the opposite side of the grid
        self.pos[1] = (self:xcor() + changes[choose][1]) % Config.xsize
        self.pos[1] = self:xcor() > 0 and self:xcor() or Config.xsize

        self.pos[2] = (self:ycor() + changes[choose][2]) % Config.ysize
        self.pos[2] = self:ycor() > 0 and self:ycor() or Config.ysize

        return self

    end;

    move_to = function(self, another_agent)
        self.pos = another_agent.pos

        return self
    end;

    dist_euc = function(self, point)
        local pos = self.pos
        local res = 0
        if #pos ~= #point then
            -- pd(pos)
            -- pd(point)
            return 'Error in dist_euc: Diferent number of coordinates'
        end
        for i = 1,#pos do
            res = res + (pos[i] - point[i])^2
        end
        return math.sqrt(res)
    end;

    dist_euc_to_agent = function(self, agent)
        return self:dist_euc(agent.pos)
    end;

    dist_manh = function(self, point)
        local pos = self.pos
        local res = 0
        if #pos ~= #point then
            return 'Error in dist_euc: Diferent number of coordinates'
        end

        for i=1,#pos do
            local dist = pos[i] - point[i]
            dist = dist >= 0 and dist or dist * (-1)
            res = res + dist
        end
        return res
    end;

    dist_manh_to_agent = function(self,agent)
        return self:dist_manh(agent.pos)
    end

}

return Mobil
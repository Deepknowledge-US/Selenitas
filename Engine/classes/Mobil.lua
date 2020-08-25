------------------
-- Mobil agents have some methods to interact with the environment.
-- @classmod
-- Mobil
local class     = require 'Thirdparty.pl.class'
local sin       = math.sin
local cos       = math.cos
local rad       = math.rad


local Mobil = class.Mobil(Agent)

------------------
-- Mobil agents are are the most common agent to work with.
-- @function _init
-- @return A new instance of Agent class.
-- @usage new_instance = Mobil()
Mobil._init = function(self,o)

    self:super()

    for k,v in pairs(o) do
        self[k] = v
    end

    self.pos        = o.pos         or {0, 0, 0}
    self.color      = o.color       or {0.5,0.5,0.5,1}
    self.head       = o.head        or {0,0}
    self.shape      = o.shape       or 'triangle'
    self.scale      = o.scale       or 1
    self.visible    = o.visible     or true
    self.z_order    = o.z_order     or 1
    self.label      = o.label       or ''
    self.label_color= o.label_color or {1,1,1,1}

    return self
end

------------------
-- This function applies to the agent a series of functions consecutively. The number of functions gived as parameters is not predetermined. Caution! we are assuming functions with one ore less parameters as inputs.
-- @function does
-- @param ...
-- A list of functions that will be executed with the agent as first parameter
-- @return The agent that has executed the functions
-- @usage
-- local wander = function(x) x:rt(180) x:fd(2) end
-- local talk   = function(x) x.message = true end
-- one_of(Agents):does(wander,talk)
Mobil.does = function(self, ...)
    for i = 1,select('#', ...)do
        local funct = select( i, ... )
        funct(self)
    end
    return self
end

------------------
-- Getter function to get the x coordinate of the agent
-- @function xcor
-- @return Number.
-- @usage
-- an_agent:xcor()
Mobil.xcor = function(self)
    return self.pos[1]
end

------------------
-- Getter function to get the y coordinate of the agent
-- @function ycor
-- @return Number.
-- @usage
-- an_agent:ycor()
Mobil.ycor = function(self)
    return self.pos[2]
end


------------------
-- Getter function to get the z coordinate of the agent
-- @function zcor
-- @return Number.
-- @usage
-- an_agent:zcor()
Mobil.zcor = function(self)
    return self.pos[3]
end

Mobil.same_pos = function(self,ag2)
    return self:xcor() == ag2:xcor() and self:ycor() == ag2:ycor() and self:zcor() == ag2:zcor()
end

------------------
-- It produces a right turn in the agent
-- @function rt
-- @param num The number of degrees we want to turn the agent.
-- @return An Agent. The one who has called the function.
-- @usage
-- an_agent:rt(90)
Mobil.rt = function(self, num)
    self.head[1] = (self.head[1] + num) % 360
    return self
end

------------------
-- It produces a left turn in the agent
-- @function lt
-- @param num The number of degrees we want to turn the agent.
-- @return An Agent. The one who has called the function.
-- @usage
-- an_agent:lt(30)
Mobil.lt = function(self, num)
    self.head[1] = (self.head[1] + num) % 360
    return self
end

------------------
-- Advance in the faced direction. The distance is specified with num
-- @function fd
-- @param num The number of units we want the agent advance.
-- @return An Agent. The one who has called the function.
-- @usage
-- an_agent:fd(3)
Mobil.fd = function(self, num)

    local s = sin(rad(self.head[1]))
    self.pos[1] = (self:xcor() + s * num) % Config.xsize

    local c = cos(rad(self.head[1]))
    self.pos[2] = (self:ycor() + c * num) % Config.ysize

    return self
end

------------------
-- Advance in a grid in the faced direction.
-- @function fd_grid
-- @param num The number of units we want the agent advance.
-- @return An Agent. The one who has called the function.
-- @usage
-- an_agent:fd_grid(3)
Mobil.fd_grid = function(self, num)

    local s = sin(rad(self.head[1]))
    self.pos[1] = math.ceil( (self:xcor() + s * num) % Config.xsize )
    if self:xcor() == 0 then self.pos[1] = Config.xsize end

    local c = cos(rad(self.head[1]))
    self.pos[2] = math.ceil( (self:ycor() + c * num) % Config.ysize )
    if self:ycor() == 0 then self.pos[2] = Config.ysize end
    return self

end

------------------
-- Ask the agent to go to a random neighbor in a 2D grid, neighbors are determined by moore neighborhood.
-- @function gtrn
-- @return The Agent that has called the function.
-- @usage
-- an_agent:gtrn()
--
-- -- an_agent will be moved to one of its patch neighbours (8 neighbours are considered).
-- --  0 0 0        0 0 x
-- --  0 x 0   ->   0 0 0
-- --  0 0 0        0 0 0
-- -- Extremes of the grid are conected.
--
-- -- As the agent is returned, we can do something like that:
-- an_agent:gtrn():search_food()
-- -- Assuming that we have defined a method 'search_food' in our agents
Mobil.gtrn = function(self)

    local changes = { {0,1},{0,-1},{1,0},{-1,0},{1,1},{1,-1},{-1,1},{-1,-1} }
    local choose  = math.random(#changes)

    -- Agents that cross a boundary will appear on the opposite side of the grid
    self.pos[1] = (self:xcor() + changes[choose][1]) % Config.xsize
    self.pos[1] = self:xcor() > 0 and self:xcor() or Config.xsize

    self.pos[2] = (self:ycor() + changes[choose][2]) % Config.ysize
    self.pos[2] = self:ycor() > 0 and self:ycor() or Config.ysize

    return self

end

------------------
-- Moves to an agent to the position of other agent
-- @function move_to
-- @param another_agent The agent from whom we'll get the new position.
-- @return Agent, the one who has called the function.
-- @usage
-- an_agent:move_to(another_ag)
--
-- -- As the agent is returned, this allows us to do things like this:
-- an_ag:move_to(ag2):rt(90):fd(1)
--
-- -- This will position the agent near of another agent but not in the same position
Mobil.move_to = function(self, another_agent)
    self.pos = another_agent.pos

    return self
end

------------------
-- This function give us the euclidean distance from the agent to another point.
-- @function dist_euc
-- @param point The point to calculate the distance to the agent.
-- @return Number The euclidean distance to the point
-- @usage
-- ag:dist_euc( {23, 50.1, 7} )
Mobil.dist_euc = function(self, point)
    local pos = self.pos
    local res = 0
    if #pos ~= #point then
        return 'Error in dist_euc: Diferent number of coordinates'
    end
    for i = 1,#pos do
        res = res + (pos[i] - point[i])^2
    end
    return math.sqrt(res)
end

------------------
-- This function give us the euclidean distance from the agent to another agent.
-- @function dist_euc_to_agent
-- @param agent The agent to calculate the distance to the agent that is calling the function.
-- @return Number The euclidean distance to the agent
-- @usage
-- ag:dist_euc_to_agent( ag2 )
Mobil.dist_euc_to_agent = function(self, agent)
    return self:dist_euc(agent.pos)
end

------------------
-- This function give us the manhattan distance from the agent to another point.
-- @function dist_manh
-- @param point The point to calculate the distance to the agent.
-- @return Number The manhattan distance to the point
-- @usage
-- ag:dist_manh( {23, 50, 7} )
Mobil.dist_manh = function(self, point)
    local pos = self.pos
    local res = 0
    if #pos ~= #point then
        return 'Error in dist_manh: Diferent number of coordinates'
    end

    for i=1,#pos do
        local dist = pos[i] - point[i]
        dist = dist >= 0 and dist or dist * (-1)
        res = res + dist
    end
    return res
end

------------------
-- This function give us the manhattan distance from the agent to another agent.
-- @function dist_manh_to_agent
-- @param agent The agent to calculate the distance to the agent that is calling the function.
-- @return Number The manhattan distance to the agent
-- @usage
-- ag:dist_manh_to_agent( ag2 )
Mobil.dist_manh_to_agent = function(self,agent)
    return self:dist_manh(agent.pos)
end

return Mobil
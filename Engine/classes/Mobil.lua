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
-- @param Table with the properties we want in the agent.
-- @return A new instance of Agent class.
-- @usage new_instance = Mobil()
Mobil._init = function(self,a_table)

    self:super(a_table)

    local p_table = a_table or {}
    for k,v in pairs(p_table) do
        self[k] = v
    end

    self.pos            = p_table.pos           or {0, 0, 0}
    self.color          = p_table.color         or {0.5,0.5,0.5,1}
    self.heading        = p_table.heading       or 0
    self.shape          = p_table.shape         or 'triangle'
    self.scale          = p_table.scale         or 1
    self.z_order        = p_table.z_order       or 1
    self.label          = p_table.label         or ''
    self.label_color    = p_table.label_color   or {1,1,1,1}
    self.current_cells  = p_table.current_cells or {}

    -- if p_table.visible == nil then
    --     self.visible = true
    -- else
    --     self.visible = p_table.visible
    -- end

    -- if p_table.show_label == nil then
    --     self.show_label = false
    -- else
    --     self.show_label = p_table.show_label
    -- end

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




--==============--
--    GETERS    --
--==============--



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




--==============--
--    CHECKS    --
--==============--



------------------
-- Checks if the agent has the (exactly) same position as a vector or agent.
-- @function same_pos
-- @param ag_or_pos Agent or vector.
-- @usage
-- agent:same_pos({1,1})
Mobil.same_pos = function(self,ag_or_pos)
    return same_pos(self,ag_or_pos)
end



--==============--
--   ACTIONS    --
--==============--

------------------
-- Checks for FamiliCells and if is anyone, updates the parameter current_cell of the agent (if this is needed).
-- @function update_cell
-- @return the Agent who has update its cells.
-- @usage
-- agent:fd(4):update_cell()
Mobil.update_cell = function(self)
    for i=1,#self.current_cells do

        local cell      = self.current_cells[i]
        local new_cell  = cell.family:cell_of(self.pos)
        self.current_cells[i] = new_cell

        if new_cell and new_cell ~= cell then
            cell:come_out(self)
            new_cell:come_in(self)
        end
    end
    return self
end

------------------
-- It produces a right turn in the agent
-- @function rt
-- @param num The number of degrees we want to turn the agent.
-- @return An Agent. The one who has called the function.
-- @usage
-- an_agent:rt(90)
Mobil.rt = function(self, num)
    self.heading = (self.heading - num)
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
    self.heading = (self.heading + num)
    return self
end

------------------
-- It makes the agent points to another agent by modifiing the heading parameter of the first agent.
-- @function face
-- @param ag Agent, the one we want to face.
-- @return An Agent. The one who has called the function.
-- @usage
-- an_agent:face(another_agent)
Mobil.face = function(self, ag)
    local x,y    = ag:xcor()-self:xcor(),ag:ycor()-self:ycor()
    self.heading = math.atan2(y,x)
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

    local s,c = sin(self.heading), cos(self.heading)

    self.pos[1] = self:xcor() + c * num
    self.pos[2] = self:ycor() + s * num

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
Mobil.move_to = function(self, agent_or_vector)
    local new_pos = agent_or_vector.pos or agent_or_vector
    for i = 1,#new_pos do
        self.pos[i] = new_pos[i]
    end
    return self
end




--==============--
--  DISTANCES   --
--==============--



------------------
-- This function give us the euclidean distance from the agent to another agent or point.
-- @function dist_euc_to
-- @param ag_or_point The agent or point to calculate the distance to the agent.
-- @return Number The euclidean distance to the point
-- @usage
-- ag:dist_euc_to( {23, 50.1, 7} )
-- -- or:
-- dist_euc_to(ag, {23, 50.1, 7})
Mobil.dist_euc_to = function(self, ag_or_point)
    local pos = self.pos
    local point = ag_or_point.pos or ag_or_point
    local res = 0
    if #pos ~= #point then
        error('Error in dist_euc: Diferent number of dimensions')
    end
    for i = 1,#pos do
        res = res + (pos[i] - point[i])^2
    end
    return math.sqrt(res)
end

------------------
-- This function give us the manhattan distance from the agent to another point.
-- @function dist_manh
-- @param point The point to calculate the distance to the agent.
-- @return Number The manhattan distance to the point
-- @usage
-- ag:dist_manh( {23, 50, 7} )
Mobil.dist_manh_to = function(self, ag_or_point)
    local pos   = self.pos
    local point = ag_or_point.pos or ag_or_point
    local res   = 0
    if #pos ~= #point then
        error('Error in dist_manh: Diferent number of coordinates')
    end

    for i=1,#pos do
        local dist = pos[i] - point[i]
        dist = dist >= 0 and dist or dist * (-1)
        res = res + dist
    end
    return res
end

return Mobil
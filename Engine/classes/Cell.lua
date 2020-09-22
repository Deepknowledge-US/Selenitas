------------------
-- Cells are agents used to represent the space. They are also known as tiles or patches in other systems.
-- @classmod
-- Cell

local class = require 'Thirdparty.pl.class'

local Cell = class.Cell(Agent)



------------------
-- Cell constructor.
-- When a new Cell is created, some properties are given to it (If we do not have done it yet)
-- @function _init
-- @param p_table Table of pairs 'name_of_attribute:value'
-- @return Agent. A new instance of Cell class.
-- @usage new_instance = Cell( {} )
Cell._init = function(self,p_table)

    self:super()

    for k,v in pairs(p_table) do
        self[k] = v
    end

    self.pos        = p_table.pos         or {0,0,0}
    self.label      = p_table.label       or ''
    self.label_color= p_table.color       or {1,1,1,1}
    self.color      = p_table.color       or {1,1,1,1}
    self.shape      = p_table.shape       or 'square'
    self.width      = p_table.width       or 1
    self.height     = p_table.height      or 1
    self.region     = p_table.region      or {}
    self.neighbors  = p_table.neighbors   or Collection()
    self.my_agents  = p_table.my_agents   or Collection()
    self.z_order    = p_table.z_order     or 0

    if p_table.visible == nil then
        self.visible = true
    else
        self.visible = p_table.visible
    end

    return self
end;

------------------
-- It returns the x coordinate of the Cell
-- @function xcor
-- @return the first position of the vector 'pos'
-- @usage instance:xcor()
Cell.xcor = function(self)
    return self.pos[1]
end

------------------
-- It returns the y coordinate of the Cell
-- @function ycor
-- @return the second position of the vector 'pos'
-- @usage instance:ycor()
Cell.ycor = function(self)
    return self.pos[2]
end

------------------
-- It returns the z coordinate of the Cell
-- @function zcor
-- @return the third position of the vector 'pos'
-- @usage instance:zcor()
Cell.zcor = function(self)
    return self.pos[3]
end

------------------
-- A function to determine if a position is in the region of the Cell.
-- @function region
-- @param pos A vector of n dimensions.
-- @return true if pos is in the region of the cell. A square region of 1 unit side is considered by default.
-- @usage instance:region()
Cell.region = function(self,pos)
    local x,y = pos[1],pos[2]
    local width_limit, height_limit = self.width / 2, self.height / 2

    local x_right_limit, x_left_limit = self:xcor() + width_limit,  self:xcor() - width_limit
    local y_down_limit,  y_up_limit   = self:ycor() - height_limit, self:ycor() + height_limit

    if x_right_limit >= x and x > x_left_limit then
        if y_up_limit >= y and y > y_down_limit then
            return true
        end
    end
    return false
end

------------------
-- A function to update the Collection of agents in a Cell by adding an agent.
-- @function come_in
-- @param agent An Agent, new member of the Collection of agents with a position inside the region of the Cell.
-- @return Nothing
-- @usage
-- Cell:come_in(an_agent)
Cell.come_in = function(self, agent)
    self.my_agents:add(agent)
end

------------------
-- A function to update the Collection of agents in a Cell by removing an agent.
-- @function come_out
-- @param agent An Agent, current member of the Collection of agents with a position inside the region of the Cell. This agent will be removed of the Collection.
-- @return Nothing
-- @usage
-- Cell:come_out(an_agent)
Cell.come_out = function(self, agent)
    self.my_agents:remove(agent)
end

return Cell
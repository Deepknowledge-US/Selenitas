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
    self.color      = p_table.color       or {0,0,0,1}
    self.shape      = p_table.shape       or 'square'
    self.region     = p_table.region      or {}
    self.neighbors  = p_table.neighbors   or Collection(FamilyCell)
    self.residents  = p_table.residents   or Collection(FamilyCell)
    self.visible    = p_table.visible     or true
    self.z_order    = p_table.z_order     or 0

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

    local x_up_limit, x_down_limit = self:xcor() + 0.5, self:xcor() - 0.5
    local y_l_limit, y_r_limit     = self:ycor() - 0.5, self:ycor() + 0.5

    if x_up_limit >= x and x > x_down_limit then
        if y_r_limit >= y and y > y_l_limit then
            return true
        end
    end
    return false
end

return Cell
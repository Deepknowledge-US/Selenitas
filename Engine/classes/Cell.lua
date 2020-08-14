------------------
-- Cells are agents used to represent the space. They are also known as tiles or patches in other systems.
-- @classmod
-- Cell

local class = require 'Thirdparty.pl.class'
local Agent = require 'Engine.classes.Agent'

local Cell = class.Cell(Agent)



------------------
-- Cell constructor.
-- When a new Cell is created, some properties are given to it (If we do not have done it yet)
-- @function _init
-- @param p_table is a table of pairs 'name_of_attribute:value'
-- @return A new instance of Cell class
-- @usage new_instance = Cell( {table_of_attributes} )
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
    self.neighbors  = p_table.neighbors   or {}
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

return Cell
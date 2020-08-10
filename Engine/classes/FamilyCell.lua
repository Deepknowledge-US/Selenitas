local class     = require 'pl.class'
local Cell      = require 'Engine.classes.Cell'
local Family    = require'Engine.classes.Family'
local Collection= require 'Engine.classes.Collection'


local FC = class.FamilyCell(Family)

-- When a new patch collection is created, its father's init function is called.
-- This allows the new Collection_Patches to use all the methods of the Collection class.
FC._init = function(self,c)
    self:super(c)
    return self
end

-- This function overwrites the add method of the Collection class
FC.add = function(self,object,id)
    local new_agent
    local k         = Config.__num_agents
    Config.__num_agents = Config.__num_agents + 1

    -- If the input is a Patch, the object is added to the collection,
    -- otherwise, a new Patch is created using the input table.
    if pcall( function() return object:is_a(Cell) end ) then
        new_agent = object
    else
        new_agent = Cell(object)
    end

    table.insert(self.order,k)

    self.agents[k]        = new_agent
    self.agents[k].id     = k
    self.agents[k].family = self
end


-- This function overwrites the create_n method of the Collection class
FC.create_n = function(self,num, funct)
    for i=1,num do
        self:add( Cell( funct() ) )
    end
end


--[[
A filter function.
It returns a collection of agents of the family that satisfy the predicate gived as parameter.

Cells_1:with( function(cell)
    return cell:xcor() == 1 and cell:ycor() == 1
end)

This will result in a collection of Agents of the family Cells_1 with a value of 1 its xcor and 1 in its ycor

]]--
FC.with = function(self,funct)
    local res = Collection(self)
    for _,v in pairs(self.agents) do
        if funct(v) then
            res:add(v)
        end
    end
    return res
end


return FC
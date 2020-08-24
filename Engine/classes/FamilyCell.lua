------------------
-- A Family to hold Cell agents, new elements will be added to the collection as Cell instances.
-- @classmod
-- FamilyCell

local class     = require 'Thirdparty.pl.class'

local Collection= require 'Engine.classes.Collection'


local FC = class.FamilyCell(Family)

------------------
-- FamilyCell constructor. When a new Cell Family is created, its father's init function is called. This allows the new Collection_Patches to use all the methods of the Collection class.
-- @function _init
-- @return A new instance of FamilyCell class.
-- @usage New_Instance = FamilyCell()
FC._init = function(self,c)
    self:super(c)
    table.insert(Config.__all_families, self)
    return self
end

------------------
-- Add a new Cell to the family.
-- @function add
-- @param object A table with the params of the new Cell
-- @return Nothing
-- @usage
-- for i=1,100 do
--     for j=1,100 do
--          Cells_family:add( {['pos']={i,j}} )
--     end
-- end
FC.add = function(self,object)
    local new_agent
    local k  = Config:__new_id()

    -- If the input is a Cell, the object is added to the collection, otherwise, a new Cell is created using the input table.
    if pcall( function() return object:is_a(Cell) end ) then
        new_agent = object
    else
        new_agent = Cell(object)
    end

    new_agent.id     = k
    new_agent.family = self

    self.agents[k]   = new_agent
    self.count       = self.count + 1
end

------------------
-- Create n new Cells in the family.
-- @function create_n
-- @param num The number of agents that will be added to the family
-- @param funct An anonymous function that will be executed to create the Cell.
-- @return Nothing
-- @usage
-- Cells:create_n( 10, function()
--     return {
--         ['pos'] = {math.random[100],math.random[100]}
--     }
-- end)
--
-- -- If you are not confortable with anonymous functions you can use a 'for' to add new agents to the family. This is equivalent to:
-- for i=1,10 do
--     Cells:add({ ['pos'] = {math.random[100],math.random[100]} })
-- end
FC.create_n = function(self,num, funct)
    for i=1,num do
        self:add(Cell( funct() ))
    end
end

------------------
-- It returns a Collection of agents of the family that satisfy the predicate gived as parameter.
-- @function with
-- @param pred A predicate of pertenence to a set
-- @return A Collection of agents that satisfies a predicate
-- @usage
-- Cells_1:with( function(cell)
--     return cell:xcor() == 1 and cell:ycor() == 1
-- end)
-- -- This will result in a collection of Agents of the family Cells_1 with a value of 1 in its xcor and 1 in its ycor
FC.with = function(self,pred)
    local res = Collection(self)
    for _,v in pairs(self.agents) do
        if pred(v) then
            res:add(v)
        end
    end
    return res
end


return FC
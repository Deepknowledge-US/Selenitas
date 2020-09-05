------------------
-- A Family to hold Cell agents, new elements will be added to the collection as Cell instances.
-- @classmod
-- FamilyCell

local class     = require 'Thirdparty.pl.class'

local FC = class.FamilyCell(Family)

------------------
-- FamilyCell constructor. When a new Cell Family is created, its father's init function is called. This allows the new Collection_Patches to use all the methods of the Collection class.
-- @function _init
-- @return A new instance of FamilyCell class.
-- @usage New_Instance = FamilyCell()
FC._init = function(self,c)
    self:super(c)
    table.insert(Config.__all_families, self)
    self.z_order = 1
    self.cell_width = c.cell_width or 1
    self.cell_height= c.cell_height or 1
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

    new_agent.id      = k
    new_agent.family  = self
    new_agent.z_order = self.z_order

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
-- @see families.create_n
FC.create_n = function(self,num, funct)
    for i=1,num do
        self:add(Cell( funct() ))
    end
end

------------------
-- Produces the diffusion of a parameter of each Cell between its neighbors.
-- @function diffuse
-- @param param Name of an Agent parameter, the one we want to diffuse.
-- @param perc Percentage of param to be diffused in a [0,1] range
-- @param num Number. Optional parameter with 1 by default. The number of diffusions we want to do.
-- @usage
-- Cells = create_grid(3, 3)
-- ask_ordered(Cells, function(x)
--     x.val = 1
-- end)
-- Cells:diffuse('val', 0.1, 50)
-- 
-- --  1,1,1      0.67510935610916, 1.1250128361545, 0.67510935610916,
-- --  1,1,1  ->  1.1250128361545,  1.7995112309455, 1.1250128361545,
-- --  1,1,1      0.67510935610916, 1.1250128361545, 0.67510935610916,
--
-- --  The total sum of params is always the same (9 in this case).
FC.diffuse = function(self,param,perc,num)
    local param_table = {}
    local n = num or 1

    for i=1,n do
        self:ask_ordered(function(cell)
            param_table[cell.id] = cell[param] * (1-perc)
            cell[param] = cell[param] * perc / cell.neighbors.count
        end)
        self:ask_ordered( function(cell)
            ask_ordered(cell.neighbors, function(neigh)
                param_table[neigh.id] = param_table[neigh.id] + cell[param]
            end)
        end)
        self:ask_ordered(function(cell)
            cell[param] = param_table[cell.id]
        end)
    end
end

------------------
-- Given a vector position or an agent, it returns the Cell of the family to which the position belongs.
-- @function cell_of
-- @param table_ Agent or position vector
-- @usage
-- Family_of_cells = create_grid(10,10)
-- print(
--     Family_of_cells:cell_of( {3.16,5.98} )
-- )
-- => It will print the Cell with position {3,6}
FC.cell_of = function(self,table_)
    local pos = table_.pos or table_
    local x,y = pos[1],pos[2]
    local w,h = self.cell_width, self.cell_height

    local cell_x    = (x%w) <= w and math.floor(x/w) or math.floor(x/w) + 1
    local cell_y    = (y%h) <= h and math.floor(y/h) or math.floor(y/h) + 1
    local cell_pos  = {cell_x + w/2 ,cell_y + h/2}

    if self:cell_in_pos(cell_pos) then
        return self:cell_in_pos(cell_pos)
    else
        print('There is no Cell with position', cell_pos[1],cell_pos[2])
    end
end

------------------
-- It finds for a Cell in the family with the (exactly) same position as the one gived as parameter.
-- @function cell_in_pos
-- @param table_ Agent or position vector.
FC.cell_in_pos = function(self,table_)
    local pos = table_.pos or table_

    for k,v in pairs(self.agents) do
        if v.pos[1] == pos[1] and v.pos[2] == pos[2] and v.pos[3] == pos[3] then
            return v
        end
    end
end


return FC
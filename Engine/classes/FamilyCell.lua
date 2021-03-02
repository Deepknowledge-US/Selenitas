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
FC._init = function(self,name)
    self:super(name)
    self.z_order = 1
    return self
end

------------------
-- A function to create a bidimensional grid of patches quickily
-- @function create_grid
-- @param x_size Number. Dimension of x axis of the grid
-- @param y_size Number. Dimension of y axis of the grid
-- @param offset_x Number (Optional). The x point from where the grid starts (0 by default).
-- @param offset_y Number (Optional). The y point from where the grid starts (0 by default).
-- @param cell_width Number (Optional). The width of the cell (1 by default).
-- @param cell_height Number (Optional). The height of the cell (1 by default).
-- @return A FamilyCell instance
-- @usage
-- declare_FamilyCell('Patches')
-- Patches:create_grid(100,100,-50,-50)

-- Warning!!!!: When x_size or y_size are odd, it breaks!!!

FC.create_grid = function(self, x_size, y_size, offset_x, offset_y, cell_width, cell_height)
    local x      = x_size or 0
    local y      = y_size or 0
    local w      = cell_width or 1
    local h      = cell_height or 1
    local half_w = w / 2
    local half_h = h / 2

    local step_x = offset_x or 0
    local step_y = offset_y or 0

    self["cell_width"]  = w
    self["cell_height"] = h
    self["offset_x"]    = step_x
    self["offset_y"]    = step_y
    self["pos_index"]   = {}

    for i = 0 + step_x, x + step_x - 1 do
        self.pos_index[i + half_w] = {}
        for j = 0 + step_y, x + step_y - 1 do
            self.pos_index[i + half_w][j + half_h] = self:new(Cell({["pos"] = {i + half_w, j + half_h}}))
        end
    end
    
    local grid_neighs = {
        {-w, h}, {0, h}, {w, h},
        {-w, 0},         {w, 0},
        {-w,-h}, {0,-h}, {w,-h}
    }

    for _, cell in ordered(self) do
        local c_x, c_y = cell:xcor(), cell:ycor()

        for i = 1, 8 do
            local neigh_pos = {grid_neighs[i][1] + c_x, grid_neighs[i][2] + c_y}
            if
                neigh_pos[1] > 0 + step_x and neigh_pos[2] > 0 + step_y and neigh_pos[1] <= x + step_x and
                    neigh_pos[2] <= y + step_y
             then
                cell.neighbors:add(self.pos_index[neigh_pos[1]][neigh_pos[2]])
            end
        end
    end

    return self
end

--FC.create_grid = function(self, x_size, y_size, offset_x, offset_y, cell_width, cell_height)
--    local x      = x_size or 0
--    local y      = y_size or 0
--    local w      = cell_width or 1
--    local h      = cell_height or 1
--    local half_w = w / 2
--    local half_h = h / 2

--    local step_x = offset_x or 0
--    local step_y = offset_y or 0

--    self["cell_width"]  = w
--    self["cell_height"] = h
--    self["offset_x"]    = step_x
--    self["offset_y"]    = step_y
--    self["pos_index"]   = {}

--    local table = {}
--    for i = 0 + step_x, x + step_x - 1 do
--        table[i + half_w] = {}
--        --self.pos_index[i + half_w] = {}
--        for j = 0 + step_y, x + step_y - 1 do
----            local this_cell = self:new(Cell({["pos"] = {i + half_w, j + half_h}}))
----            table[i + half_w][j + half_h] = this_cell
--            table[i + half_w][j + half_h] = self:new(Cell({["pos"] = {i + half_w, j + half_h}}))
--          --self.pos_index[i + half_w][j + half_h] = this_cell.__id
--        end
--    end
    
--    self.pos_index = table

--    local grid_neighs = {
--        {-w, h}, {0, h}, {w, h},
--        {-w, 0},         {w, 0},
--        {-w,-h}, {0,-h}, {w,-h}
--    }

--    for _, cell in ordered(self) do
--        local c_x, c_y = cell:xcor(), cell:ycor()

--        for i = 1, 8 do
--            local neigh_pos = {grid_neighs[i][1] + c_x, grid_neighs[i][2] + c_y}
--            if
--                neigh_pos[1] > 0 + step_x and neigh_pos[2] > 0 + step_y and neigh_pos[1] <= x + step_x and
--                    neigh_pos[2] <= y + step_y
--             then
----                cell.neighbors:add(self:cell_in_pos(neigh_pos))
--                cell.neighbors:add(table[neigh_pos[1]][neigh_pos[2]])
--            end
--        end
--    end

--    return self
--end

------------------
-- Insert a new Cell to the family.
-- @function new
-- @param object A table with the params of the new Cell
-- @return Nothing
-- @usage
-- for i=1,100 do
--     for j=1,100 do
--          Cells_family:new( {['pos']={i,j}} )
--     end
-- end
FC.new = function(self,object)
    local new_agent
    local k  = Simulation:__new_id()

    -- If the input is a Cell, the object is added to the collection, otherwise, a new Cell is created using the input table.
    if pcall( function() return object:is_a(Cell) end ) then
        new_agent = object
    else
        new_agent = Cell(object)
    end

    new_agent.__id      = k
    new_agent.family  = self
    new_agent.z_order = self.z_order

    for prop, def_val in next, self.properties do
        new_agent[prop] = def_val
    end

    for name, funct in next, self.functions do
        new_agent[name] = funct
    end

    self.agents[k]   = new_agent
    self.count       = self.count + 1

    return self.agents[k]
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
        for _,cell in ordered(self.agents) do
            param_table[cell.__id] = cell[param] * (1-perc)
            cell[param] = cell[param] * perc / cell.neighbors.count            
        end

        for _,cell in ordered(self.agents) do
            for _,neigh in ordered(cell.neighbors) do
                param_table[neigh.__id] = param_table[neigh.__id] + cell[param]
            end
        end
        for _,cell in ordered(self.agents) do
            cell[param] = param_table[cell.__id]
        end

    end
end

------------------
-- Produces the diffusion of a several cell parameters simultaneously.
-- @function multi_diffuse
-- @param param list of pairs {Name, perc} of Agent's parameter want to diffuse.
-- @param num Number. Optional parameter with 1 by default. The number of diffusion iterations we want to do.
-- @usage
-- Cells = create_grid(3, 3)
-- ask_ordered(Cells, function(x)
--     x.val1 = 1
--     x.val2 = 2
-- end)
-- Cells:multi_diffuse({{'val', 0.1}, {'val2', 0.5}}, 50)
FC.multi_diffuse = function(self,param,num)
    local param_table = {}
    for i=1,#param do
      param_table[i]={}
    end
    local n = num or 1

    for i=1,n do
        for _,cell in ordered(self.agents) do
            for i,p in ipairs(param) do
              param_table[i][cell.__id] = cell[p[1]] * (1-p[2])
              cell[p[1]] = cell[p[1]] * p[2] / cell.neighbors.count            
            end
        end

        for _,cell in ordered(self.agents) do
          for i,p in ipairs(param) do
            for _,neigh in ordered(cell.neighbors) do
                param_table[i][neigh.__id] = param_table[i][neigh.__id] + cell[p[1]]
            end
          end
        end
        for _,cell in ordered(self.agents) do
          for i,p in ipairs(param) do
            cell[p[1]] = param_table[i][cell.__id]
          end
        end

    end
end

------------------
-- Given a vector position or an agent, it returns the Cell of the family to which the position belongs.
-- @function cell_of
-- @param table_ Agent or position vector
-- @usage
-- declare_FamilyCell('Family_of_cells')
-- Family_of_cells:create_grid(10,10)
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

    return self:cell_in_pos(cell_pos)
end

------------------
-- It looks for a Cell in the family with the (exactly) same position as the one given as parameter.
-- @function cell_in_pos
-- @param table_ Agent or position vector.
FC.cell_in_pos = function(self,table_)
    local pos = table_.pos or table_
--    local id = self.pos_index[pos[1]][pos[2]]
    return self.pos_index[pos[1]][pos[2]]
    --return self.agents[id]
    
--    for k,v in pairs(self.agents) do
--        if v.pos[1] == pos[1] and v.pos[2] == pos[2] then
--            return v
--        end
--    end
end


return FC
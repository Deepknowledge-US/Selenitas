------------------
-- A Family to hold Mobil agents, new elements will be added to the collection as Mobil instances.
-- @classmod
-- FamilyMobil

local class     = require 'Thirdparty.pl.class'

local FM = class.FamilyMobil(Family)

------------------
-- FamilyMobil constructor. When a new Mobil Family is created, its father's init function is called. This allows the new instance to use all the methods of the Family class.
-- @function _init
-- @return A new instance of FamilyMobil class.
-- @usage New_Instance = FamilyMobil()
FM._init = function(self)
    self:super()
    table.insert(Simulation.families, self)
    self.z_order = 3
    return self
end

------------------
-- Insert a new Mobil in the family.
-- @function new
-- @param object A table with the params of the new Mobil
-- @return Nothing
-- @usage
-- for i=1,100 do
--     Basic_agents:new({})
-- end
-- -- This will result in 100 new instances of Mobil class in the Family Basic_agents
FM.new = function(self,object)

    local new_agent
    local key  = Simulation:__new_id()

    -- If the input is a Mobil agent, the object is added to the collection, otherwise, a new Mobil is created using the input table.
    if pcall( function() return object.is_a(self,Mobil) end ) then
        new_agent = object
    else
        new_agent = Mobil(object)
    end

    new_agent.id      = key
    new_agent.family  = self
    new_agent.z_order = self.z_order

    self.agents[key]  = new_agent
    self.count        = self.count + 1

    local cell_fams = find_families(FamilyCell)
    for i=1,#cell_fams do
        local my_cell = cell_fams[i]:cell_of(self.agents[key].pos)
        if my_cell then
            self.agents[key].current_cells[i] = my_cell
            my_cell:come_in(self.agents[key])
        end

    end
    return self.agents[key]
end

------------------
-- Create n new Mobil agents in the family.
-- @function create_n
-- @param num The number of agents that will be added to the family
-- @param funct An anonymous function that will be executed to create the Mobil.
-- @return Nothing
-- @usage
-- Agents1:create_n( 10, function()
--     return {
--         ['heading'] = math.random(360),
--     }
-- end)
-- -- This will result in 10 agents each one with a random value (between 1 and 360) for the parameter heading.
FM.create_n = function(self,num, funct)
    local res = Collection()
    for i=1,num do
        local mobil = self:new( Mobil( funct() ) )
        res:add(mobil)
    end
    return res
end


return FM
------------------
-- A Family to hold Mobile agents, new elements will be added to the collection as Mobile instances.
-- @classmod
-- FamilyMobile

local class     = require 'Thirdparty.pl.class'

local FM = class.FamilyMobile(Family)

------------------
-- FamilyMobile constructor. When a new Mobile Family is created, its father's init function is called. This allows the new instance to use all the methods of the Family class.
-- @function _init
-- @return A new instance of FamilyMobile class.
-- @usage New_Instance = FamilyMobile()
FM._init = function(self,name)
    self:super(name)
    self.z_order = 3
    return self
end

------------------
-- Insert a new Mobile in the family.
-- @function new
-- @param object A table with the params of the new Mobile
-- @return Nothing
-- @usage
-- for i=1,100 do
--     Basic_agents:new({})
-- end
-- -- This will result in 100 new instances of Mobile class in the Family Basic_agents
FM.new = function(self,object)

    local new_agent
    local key  = Simulation:__new_id()

    -- If the input is a Mobile agent, the object is added to the collection, otherwise, a new Mobile is created using the input table.
    if pcall( function() return object.is_a(self,Mobile) end ) then
        new_agent = object
    else
        new_agent = Mobile(object)
    end

    new_agent.__id      = key
    new_agent.family  = self
    new_agent.z_order = self.z_order

    for prop, def_val in next, self.properties do
        new_agent[prop] = def_val
    end

    for name, funct in next, self.functions do
        new_agent[name] = funct
    end

    self.agents[key]  = new_agent
    self.count        = self.count + 1

    local cell_fams = find_families(FamilyCell)
    for i=1,#cell_fams do
        if cell_fams[i].count > 0 then
            local my_cell = cell_fams[i]:cell_of(self.agents[key].pos)
            if my_cell then
                self.agents[key].current_cells[i] = my_cell
                my_cell:come_in(self.agents[key])
            end
        end

    end

    return self.agents[key]
end

------------------
-- Create n new Mobile agents in the family.
-- @function create_n
-- @param num The number of agents that will be added to the family
-- @param funct An anonymous function that will be executed to create the Mobile.
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
        local mobil = self:new( Mobile( funct() ) )
        res:add(mobil)
    end
    return res
end


return FM
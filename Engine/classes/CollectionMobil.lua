local class     = require 'pl.class'
local pretty    = require 'pl.pretty'
local Mobil     = require 'Engine.classes.Mobil'
local Collection= require 'Engine.classes.Collection'


local CA = class.Collection_Mobil(Collection)


-- When a new agent collection is created, its father's init function is called.
-- This allows the new Collection_Agents to use all the methods of the Collection class.
CA._init = function(self,c)
    self:super(c)
    return self
end

-- This function overwrites the add method of the Collection class
CA.add = function(self,object)

    local new_agent
    local key = Config.__num_agents
    Config.__num_agents = Config.__num_agents + 1

    -- If the input is an Agent, the object is added to the collection,
    -- otherwise, a new Agent is created using the input table.
    if pcall( function() return object.is_a(self,Mobil) end ) then
        new_agent = object
    else
        new_agent = Mobil(object)
    end

    table.insert(self.order,key)

    self.agents[key]     = new_agent
    self.agents[key].id  = key
end

-- -- This function overwrites the add method of the Collection class
-- CA.add = function(self,object,id)
--     local tam       = self.size + 1
--     local k         = id or object.id or tam
--     local new_agent

--     -- If the input is an Agent, the object is added to the collection,
--     -- otherwise, a new Agent is created using the input table.
--     if pcall( function() return object.is_a(self,Mobil) end ) then
--         new_agent = object
--     else
--         new_agent = Mobil(object)
--     end

--     if not self.agents[k] then
--         table.insert(self.order,k)
--         self.size = tam
--     end

--     self.agents[k]     = new_agent
--     self.agents[k].id  = k
-- end


-- This function overwrites the create_n method of the Collection class
CA.create_n = function(self,num, funct)
    for i=1,num do
        self:add( Mobil( funct() ) )
    end
end




return CA
------------------
-- A Family to hold Mobil agents, new elements will be added to the collection as Mobil instances.
-- @classmod
-- FamilyMobil

local class     = require 'Thirdparty.pl.class'
local Collection= require 'Engine.classes.Collection'

local FM = class.FamilyMobil(Family)

------------------
-- FamilyMobil constructor. When a new Mobil Family is created, its father's init function is called. This allows the new instance to use all the methods of the Family class.
-- @function _init
-- @return A new instance of FamilyMobil class.
-- @usage New_Instance = FamilyMobil()
FM._init = function(self)
    self:super()
    table.insert(Config.__all_families, self)
    return self
end

------------------
-- Add a new Mobil to the family.
-- @function add
-- @param object A table with the params of the new Mobil
-- @return Nothing
-- @usage
-- for i=1,100 do
--     Basic_agents:add({})
-- end
-- -- This will result in 100 new instances of Mobil class in the Family Basic_agents
FM.add = function(self,object)

    local new_agent
    local key  = Config:__new_id()

    -- If the input is a Mobil agent, the object is added to the collection, otherwise, a new Mobil is created using the input table.
    if pcall( function() return object.is_a(self,Mobil) end ) then
        new_agent = object
    else
        new_agent = Mobil(object)
    end

    new_agent.id     = key
    new_agent.family = self

    self.agents[key]        = new_agent
    self.count = self.count + 1
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
--         ['head'] = math.random(360),
--     }
-- end)
-- -- This will result in 10 agents each one with a random value (between 1 and 360) for the parameter head.
FM.create_n = function(self,num, funct)
    for i=1,num do
        self:add( Mobil( funct() ) )
    end
    if funct ~= nil then
        --TODO
    end
end

------------------
-- A filter function. It returns a Collection of agents of the family that satisfy the predicate gived as parameter.
-- @function with
-- @param funct A predicate of pertenence to a set
-- @return A Collection of agents that satisfies a predicate
-- @usage
-- Agents1:with( function(target)
--     return target:xcor() >= 4
-- end)
-- -- This will result in a collection of Agents of the family Agents1 with a value of 4 or more in its xcor
-- FM.with = function(self,funct)
--     local res = Collection(self)
--     for _,v in pairs(self.agents) do
--         if funct(v) then
--             res:add(v)
--         end
--     end
--     return res
-- end



return FM
local class     = require 'Thirdparty.pl.class'
local Mobil     = require 'Engine.classes.Mobil'
local Collection= require 'Engine.classes.Collection'



local FM = class.FamilyMobil(Family)


-- When a new agent collection is created, its father's init function is called.
-- This allows the new Collection_Agents to use all the methods of the Collection class.
FM._init = function(self)
    self:super()
    return self
end

-- This function adds a new element to the collection.
FM.add = function(self,object)

    local new_agent
    local key  = Config:__new_id()

    -- If the input is a Mobil agent, the object is added to the collection, otherwise, a new Mobil is created using the input table.
    if pcall( function() return object.is_a(self,Mobil) end ) then
        new_agent = object
    else
        new_agent = Mobil(object)
    end

    table.insert(self.order,key)

    self.agents[key]        = new_agent
    self.agents[key].id     = key
    self.agents[key].family = self
end


--[[
The function "create_n" has 2 input params: A number of agents to create and an anonymous 
function that returns a table of params.
Anonymous function is needed to give a random values to each agent, otherwise (without a function) 
the same random value will be gived to all agents created.

Agents1:create_n( 10, function()
    return {
        ['head'] = math.random(360),
        ...
    }
end)

This will result in 10 agents each one with a random value (between 1 and 360) for the parameter head.
]]--
FM.create_n = function(self,num, funct)
    for i=1,num do
        self:add( Mobil( funct() ) )
    end
    if funct ~= nil then
        --TODO
    end
end


--[[
A filter function.
It returns a Collection of agents of the Family that satisfy the predicate gived as parameter.

Agents1:with( function(target)
    return target:xcor() >= 4
end)

This will result in a collection of Agents of the family Agents1 with a value of 4 or more in its xcor

]]--
FM.with = function(self,funct)
    local res = Collection(self)
    for _,v in pairs(self.agents) do
        if funct(v) then
            res:add(v)
        end
    end
    return res
end



return FM
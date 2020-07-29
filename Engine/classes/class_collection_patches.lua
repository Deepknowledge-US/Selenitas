local class     = require 'pl.class'
local pretty    = require 'pl.pretty'
local Patch     = require 'Engine.classes.class_patch'
local Collection= require'Engine.classes.class_collection'


local CP = class.Collection_Patches(Collection)

CP._init = function(self,c)
    self:super(c)
    return self
end

CP.add = function(self,object,id)
    local tam       = self.size + 1
    local k         = id or object.id or tam
    local new_agent

    -- If the input is a Patch, the object is added to the collection,
    -- otherwise, a new Patch is created using the input table.
    if pcall( function() return object.is_a(self,Patch) end ) then
        new_agent = object
    else
        new_agent = Patch(object)
    end

    if not self.agents[k] then
        table.insert(self.order,k)
        self.size = tam
    end

    self.agents[k]     = new_agent
    self.agents[k].id  = k
end


CP.create_n = function(self,num, funct)
    for i=1,num do
        self:add( Patch( funct() ) )
    end
end



return CP
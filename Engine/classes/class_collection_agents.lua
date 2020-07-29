local class     = require 'pl.class'
local pretty    = require 'pl.pretty'
local Agent     = require 'Engine.classes.class_agent'
local Collection= require'Engine.classes.class_collection'


local CA = class.Collection_Agents(Collection)

CA._init = function(self,c)
    self:super(c)
    return self
end

CA.add = function(self,object,id)
    local tam       = self.size + 1
    local k         = id or object.id or tam
    local new_agent

    -- If the input is an Agent, the object is added to the collection,
    -- otherwise, a new Agent is created using the input table.
    if pcall( function() return object.is_a(self,Agent) end ) then
        new_agent = object
    else
        new_agent = Agent(object)
    end

    if not self.agents[k] then
        table.insert(self.order,k)
        self.size = tam
    end

    self.agents[k]     = new_agent
    self.agents[k].id  = k
end


CA.create_n = function(self,num, funct)
    for i=1,num do
        self:add( Agent( funct() ) )
    end
end



return CA
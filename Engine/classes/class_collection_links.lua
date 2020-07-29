local class      = require 'pl.class'
local Collection = require 'Engine.classes.class_collection'
local Link       = require 'Engine.classes.class_link'
local pretty     = require 'pl.pretty'


local CL = class.Collection_Links(Collection)

CL._init = function(self,c)
    self:super(c)
    return self
end

CL.add = function(self,object,id)

    -- If the input is a Link, the object is added to the collection,
    -- otherwise, a new Link is created using the input table.
    if pcall( function() return object.end1 and object.end2 end ) then

        local o1,id1  = object.end1, object.end1.id
        local o2,id2  = object.end2, object.end2.id
        local link_id = id1..','..id2

        o1:add_neigh(o2)
        o2:add_neigh(o1)

        if not self.agents[link_id] then
            table.insert(self.order,link_id)
            self.size = self.size+1
        end

        self.agents[link_id] = object

    else
        print("Error while adding new link:", object)
    end
end;

CL.create_n = function(self,num, funct)
    for i=1,num do
        self:add( Link( funct() ) )
    end
end;


return CL

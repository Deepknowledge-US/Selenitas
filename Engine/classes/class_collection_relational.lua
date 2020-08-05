local class      = require 'pl.class'
local Collection = require 'Engine.classes.class_collection'
local Rel        = require 'Engine.classes.class_relational'


local CR = class.Collection_Relational(Collection)

-- When a new link collection is created, its father's init function is called.
-- This allows the new Collection_Links to use all the methods of the Collection class.
CR._init = function(self,c)
    self:super(c)
    return self
end

--[[
    This function overwrites the add method in the father's class
]]
CR.add = function(self,object,id)

    -- If the input is a Link, the object is added to the collection,
    -- otherwise, a new Link is created using the input table.
    if pcall( function() return object.end1 and object.end2 end ) then

        local id1  = object.end1.id
        local id2  = object.end2.id
        local link_id = id1..','..id2

        if not self.agents[link_id] then
            table.insert(self.order,link_id)
            self.size = self.size+1
        end

        self.agents[link_id] = object

    else
        print("Error while adding new link:", object)
    end
end;


-- This function overwrites the create_n method in the father's class
CR.create_n = function(self,num, funct)
    for i=1,num do
        self:add( Rel( funct() ) )
    end
end;


return CR

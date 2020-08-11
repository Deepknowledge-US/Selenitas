local class      = require 'Thirdparty.pl.class'
local Rel        = require 'Engine.classes.Relational'
local Collection = require 'Engine.classes.Collection'


local FR = class.FamilyRelational(Family)

-- When a new link collection is created, its father's init function is called.
-- This allows the new Collection_Links to use all the methods of the Collection class.
FR._init = function(self,c)
    self:super(c)
    return self
end

--[[
    This function overwrites the add method in the father's class.
    TODO
]]
FR.add = function(self,object)

    -- A new Link is created using the input table. If this table does not have a source and a target an error is returned.
    if pcall( function() return object.source and object.target end ) then

        local obj1,id1 = object.source, object.source.id
        local obj2,id2 = object.target, object.target.id

        local new_id  = Config:__new_id()

        local values  = {}
        for k,v in pairs(object) do
            values[k] = v
        end

        -- New link added to family. Update agents table, order list and size.
        self.agents[new_id] = Relational(values)
        self.agents[new_id].id = new_id
        table.insert(self.order, new_id)
        self.size = self.size + 1

        -- If first time being neighbors this way, create a table to the new neighbor
        if obj1.out_neighs[id2] == nil then
            obj1.out_neighs[id2] = {}
        end
        if obj2.in_neighs[id1] == nil then
            obj2.in_neighs[id1] = {}
        end

        -- Update the neighbors and links tables of the related agents
        table.insert(obj1.out_neighs[id2], new_id)
        table.insert(obj2.in_neighs[id1], new_id)

        table.insert(obj1.out_links, new_id)
        table.insert(obj2.in_links, new_id)

    else
        print("Error while adding new link:", object)
    end
end;


-- This function overwrites the create_n method in the father's class
FR.create_n = function(self,num, funct)
    for i=1,num do
        self:add( Rel( funct() ) )
    end
    if funct ~= nil then
        --TODO
    end
end;

--[[
A filter function.
It returns a collection of agents of the family that satisfy the predicate gived as parameter.

Links_1:with( function(l)
    return l.target == some_agent
end)

This will result in a collection of Agents of the family Links_1 with a target equals to the agent 'some_agent'
]]--
FR.with = function(self,funct)
    local res = Collection(self)
    for _,v in pairs(self.agents) do
        if funct(v) then
            res:add(v)
        end
    end
    return res
end

return FR

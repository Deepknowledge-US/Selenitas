local class      = require 'pl.class'
local Collection = require 'Engine.classes.Family'
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
    This function overwrites the add method in the father's class
]]
FR.add = function(self,object)

    -- If the input is a Link, the object is added to the collection,
    -- otherwise, a new Link is created using the input table.
    if pcall( function() return object.source and object.target end ) then

        local id1,id2 = object.source.id, object.target.id
        local values  = {}
        for k,v in pairs(object) do
            if k ~= 'source' and  k ~= 'target' then
                values[k] = v
            end
        end

        -- We have to create new tables if there is no links related to id1 or id2 yet
        if self.agents[id1] == nil then
            self.agents[id1] = { ['_in'] = {}, ['_out'] = {} }
        end
        if self.agents[id2] == nil then
            self.agents[id2] = { ['_in'] = {}, ['_out'] = {} }
        end

        self.agents[id1]._out[id2] = values
        self.agents[id2]._in[id1]  = values


        -- local id1  = object.end1.id
        -- local id2  = object.end2.id

        -- local link_id = id1..','..id2

        -- if not self.agents[link_id] then
        --     table.insert(self.order,link_id)
        --     self.size = self.size+1
        -- end

        -- self.agents[link_id] = object

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

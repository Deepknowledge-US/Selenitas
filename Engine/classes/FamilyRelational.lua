------------------
-- A Family to hold Relational agents, new elements will be added to the collection as Relational instances.
-- @classmod
-- FamilyRelational

local class      = require 'Thirdparty.pl.class'

local Collection = require 'Engine.classes.Collection'


local FR = class.FamilyRelational(Family)

------------------
-- FamilyRelational constructor. When a new Relational Family is created, its father's init function is called. This allows the new instance to use all the methods of the Family class.
-- @function _init
-- @return A new instance of FamilyRelational class.
-- @usage New_Instance = FamilyRelational()
FR._init = function(self,c)
    self:super(c)
    table.insert(Config.__all_families, self)
    return self
end

------------------
-- Add a new Relational agent to the family.
-- @function add
-- @param object A table with the params of the new Relational
-- @return Nothing
-- @usage
-- Links:add({
--     ['source'] = one_of(Nodes),
--     ['target'] = one_of(Nodes)
-- })
-- end
-- -- This will result in a new instance of Relational in the family Links
FR.add = function(self,object)

    -- A new Link is created using the input table. If this table does not have a source and a target an error is returned.
    if pcall( function() return object.source and object.target end ) then

        local obj1,id1 = object.source, object.source.id
        local obj2,id2 = object.target, object.target.id

        local new_id   = Config:__new_id()
        local new_rel  = {}

        for k,v in pairs(object) do
            new_rel[k] = v
        end
        new_rel.id = new_id
        new_rel.family = self

        -- New link added to family. Update agents table and size.
        self.agents[new_id] = Relational(new_rel)
        self.count = self.count + 1

        -- If first time being neighbors this way, create a table to the new neighbor.
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

------------------
-- Create n new Relational agents in the family.
-- @function create_n
-- @param num The number of agents that will be added to the family
-- @param funct An anonymous function that will be executed to create each Relational.
-- @return Nothing
-- @usage
-- Links:create_n( 10, function()
--     local src = one_of(Nodes)
--     local tgt = Nodes:one_of_others(src)
--     return {
--         ['source'] = src,
--         ['target'] = tgt
--     }
-- end)
-- -- This will result in 10 new links between 2 distinct agents of the family Nodes.
FR.create_n = function(self,num, funct)
    for i=1,num do
        self:add( Relational( funct() ) )
    end
    if funct ~= nil then
        --TODO
    end
end;

------------------
-- It returns a Collection of agents of the family that satisfy the predicate gived as parameter.
-- @function with
-- @param funct A predicate of pertenence to a set
-- @return A Collection of agents that satisfies a predicate
-- @usage
-- Links_1:with( function(l)
--     return l.target == some_agent
-- end)
-- This will result in a collection of Agents of the family Links_1 with a target equals to the agent 'some_agent'
-- FR.with = function(self,funct)
--     local res = Collection(self)
--     for _,v in pairs(self.agents) do
--         if funct(v) then
--             res:add(v)
--         end
--     end
--     return res
-- end

return FR

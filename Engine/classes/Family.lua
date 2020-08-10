local class  = require 'pl.class'

--[[
    Families are the main structures of the sistem. It consists in two tables of Agents and some methods to manipulate them
    self.agents is a table 'object_id: object' and we use it to find an element quickily
    self.order  is an ordered table 'position:id' and we use it to determine the actuation order in each iteration. This table is shuffled in each iteration.
    ]]--
local Family = class.Family()

Family._init = function(self)
    self.order  = {}
    self.agents = {}
    self.size = 0
    return self
end;


--[[
Killing an agent consist in giving a nil value to the keys of the tables related with it.
First we search for the object id in the position:id table, then we search the object in
the id:object table.
Finally, we remove the object in both tables and update the size of the collection.
]]--
Family.kill = function(self,agent)
    for k,v in ipairs(self.order) do
        if v == agent.id and self.agents[v] == agent then
            self.agents[agent.id] = nil
            table.remove(self.order, k)
            self.size = self.size-1
            break
        end
    end
end;



--[[
At the moment, this is our mechanism to randomize actuation turns in agents.
It consist in permutations of the ids in the position:id tables
]]--
Family.shuffle = function(self)
    local array = self.order
    for i = #array,2, -1 do
        local j = math.random(i)
        array[i], array[j] = array[j], array[i]
    end
end;



--[[
A filter function.
Given an agent, it returns all the other agents in the collection.
]]--
Family.others = function(self,agent)
    return self:with( function(x) return x ~= agent end )
end;



--[[
A filter function.
Given an agent, it returns,randomly, one of the other agents in the collection,
or nil if there is no other agent.
]]--
Family.one_of_others = function(self,agent)

    if #self.order < 2 then return nil end

    local candidate_id = math.random(#self.order)
    local candidate = self.agents[candidate_id]
    while candidate == agent do
        candidate_id = math.random(#self.order)
        candidate = self.agents[candidate_id]
    end
    return candidate
end;


--[[
This function returns a clone of the agent gived as parameter.
Is an auxiliar function used by "clone_n_act" to obtain an object that 
then is added to the collection.
]]--
Family.clone = function(self, agent ) -- deep-copy a table
    if type(agent) ~= "table" then return agent end
    local meta = getmetatable(agent)
    local target = {}
    for k, v in pairs(agent) do
        if type(v) == "table" and k ~= 'family' then
            target[k] = self:clone(v)
        else
            target[k] = v
        end
    end
    setmetatable(target, meta)
    return target
end;



--[[
This function creates a number of clones of an agent and then it applies a function to them.
It uses the auxiliar function "clone" to obtain the clones and the auxiliar 
function "search_free_id" to give a new id to the clones.

Agents1:clone_n_act(1, agent, function(x)
    x.color = 'red'
end)

If we just want to create same agents we can call this function without the last parameter:

Agents1:clone_n_act(3, agent)
]]--
Family.clone_n_act = function(self,num, agent, funct)
    local res = {}

    for i=1,num do
        local ag = self:clone(agent)
        self:add(ag)
        table.insert(res, ag)
    end

    if funct then
        for _,v in ipairs(res)do
            funct(v)
        end
    end
end;



--[[
A function to print the collection. If we do print( a_collection ) this function is called.
]]--
Family.__tostring = function(self)
    local res = "{\n"
    for k,v in pairs(self.agents) do

        if type(v) == 'table' then
            res = res .. '\t'  .. k .. ': {\n'
            for k2,v2 in pairs(v) do
                local v2_aux = type(v2) == 'table' and type(v2) or v2
                res = res .. '\t\t' .. k2 .. ': ' .. tostring(v2_aux) .. '\n'
            end
            res = res .. '\t}\n'
        else
            res = res .. '\t' .. k .. ': ' .. v .. '\n'
        end
    end
    res = res .. '}'
    return res
end;


return Family
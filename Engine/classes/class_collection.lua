local class  = require 'pl.class'


--[[

A collection is composed by two tables:

* The first one is a map id: object and is used to access to an object quickily
* The second one is a list position:id. It is usefull to randomize the order of actuation.
    TODO: Make it work with only one table or use a position:reference_to_object list instead
    of a position:id list to improve cpu time.



All the methods of a collection must be called with the ":" operator.
e.g.:  my_collection:kill(id_of_agent)


e.g. Create and populate collections:

    Agents1 = Collection()
    Agents1:create_n(1000, function()
        return {
            ['property_1'] = val_1
            ['property_2'] = val_2
            ...
        }
    end)

    Agents2 = Collection()
    for i=1,100 do
        Agents2:add( {
            ['property_1'] = val_1,
            ['property_2'] = val_2,
            ...
        } )
    end

    Notice that in the second case we do not need a function returning a table (see the created_n method)
]]--

local Collection = class.Collection {
    _init = function(self)
        self.order  = {}
        self.agents = {}
        self.size = 0
        return self
    end;



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
    create_n = function(self,num, funct)
        for i=1,num do
            local agent = funct()
            self:add(agent,agent.id)
        end
    end;




--[[
    Function to add new agents to the collection.

    Agents1:add({
        ['id'] = 3
        ['property_2'] = val_2
        ...
    })
    This will result in an agent like this: { id:3, property_2:val2, ... }


    But we can pass a second parameter as id:

    Agents1:add({
        ['id'] = 3
        ['property_2'] = val_2
        ...
    }, "new_id")

    This will result in an agent like this: { id:"new_id", property_2:val2, ... }
    Useful in some cases.

    if we have not passed a second parameter and the object does not have an id, it is 
    assigned a non currently used numerical id.
]]--
    add = function(self,object,id)
        local tam       = self.size + 1
        local k         = id or object.id or self:search_free_id(tam)
        if not self.agents[k] then
            table.insert(self.order,k)
            self.size = tam        end
        self.agents[k]     = object
        self.agents[k].id  = k
    end;



--[[
    Killing an agent consist in giving a nil value to the keys of the tables related with it.
    First we search for the object id in the position:id table, then we search the object in
    the id:object table.
    Finally, we remove the object in both tables and update the size of the collection.
]]--
    kill = function(self,agent)
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
    shuffle = function(self)
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
    others = function(self,agent)
        return self:with( function(x) return x ~= agent end )
    end;



--[[
    A filter function.
    Given an agent, it returns,randomly, one of the other agents in the collection,
    or nil if there is no other agent.
]]--
    one_of_others = function(self,agent)

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
    A filter function.
    It returns all the agents in the collection that satisfy the condition specified in the function
    gived as parameter.

    Agents1:with( function(target) 
        return target.xcor > 4
    end)
]]--
    with = function(self,funct)
        local res = {}
        for _,v in pairs(self.agents) do
            if funct(v) then
                res[#res+1] = v
            end
        end
        return res
    end;



--[[
    This function returns a clone of the agent gived as parameter.
    Is an auxiliar function used by "clone_n_act" to obtain an object that 
    then is added to the collection.
]]--
    clone = function(self, agent ) -- deep-copy a table
        if type(agent) ~= "table" then return agent end
        local meta = getmetatable(agent)
        local target = {}
        for k, v in pairs(agent) do
            if type(v) == "table" then
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
    clone_n_act = function(self,num, agent, funct)
        local res = {}

        for i=1,num do
            local ag = self:clone(agent)
            local new_id = self:search_free_id(#self.order + 1)
            ag.id = new_id
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
    This function searchs recursively for a non currently used id
]]--
    search_free_id = function(self, num)
        if self.agents[num] ~= nil then
            self:search_free_id(num+1)
        else
            return num
        end
    end;


--[[
    A function to print the collection. If we do print( a_collection ) this function is called.
]]--
    __tostring = function(self)
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

}


return Collection
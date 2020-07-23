local class  = require 'pl.class'
local pretty = require 'pl.pretty'
local Agent  = require 'Engine.classes.class_agent'


-- A collection is composed by two tables:

-- * The first one is a map  id: object
-- * The second one is a list in which we keep a concrete order for each id in the map table.

-- The first table is used to access to an object quickily, the second one is used to determine
-- the order of actuation in each iteration

-- All the methods of a collection must be called with the ":" operator. 
-- e.g  my_collection:remove(id_of_agent)
-- e.g. of creation and use:

-- Agents = Collection()
-- Agents:create_n(1000, function() 
--     return Agent({
--         ['property_1'] = val_1
--         ['property_2'] = val_2
--         ...
--     })
-- end)

local Collection = class.Collection {
    _init = function(self,c)
        self.order  = {}
        self.agents = c or {}
        if c then
            for k,_ in pairs(c)do
                self.order[#self.order+1] = k
            end
        end
        return self
    end;

    create_n = function(self,num, funct)
        for i=1,num do
            local agent = funct()
            if agent.id then
                self:add(agent,agent.id)
            else
                self:add(agent)
            end
        end
    end;

    __tostring = function(self)
        local res = ""
        for k,v in pairs(self) do

            if type(v) == 'table' then
                res = res .. k .. ': table\n'
            else
                res = res .. k .. ': ' .. v .. '\n'
            end
        end
        return res
    end;

    add = function(self,object,id)
        local tam       = #self.order + 1
        local k         = id or object.id or tam

        if not self.agents[k] then
            table.insert(self.order,k)
        end
        self.agents[k]     = object
        self.agents[k].id  = k
    end;

    kill = function(self,agent)
        for k,v in pairs(self.order) do
            if v == agent.id and self.agents[v] == agent then
                self.agents[agent.id] = nil
                table.remove(self.order, k)
                break
            end
        end
    end;

    shuffle = function(self)
        local array = self.order
        for i = #array,2, -1 do
            local j = math.random(i)
            array[i], array[j] = array[j], array[i]
        end
    end;

    with = function(self,funct)
        local res = {}
        for _,v in pairs(self.agents) do
            if funct(v) then
                res[#res+1] = v
            end
        end
        return res
    end;

    clone_n_act = function(self,num, agent, funct)
        local res = {}

        for i=1,num do
            local ag = self:clone(agent)
            local new_id = self:search_free_id(#self.order + 1)
            ag.id = new_id
            self:add(ag)
            table.insert(res, ag)
        end

        for _,v in ipairs(res)do
            funct(v)
        end
    end;

    clone = function(self, t ) -- deep-copy a table
        if type(t) ~= "table" then return t end
        local meta = getmetatable(t)
        local target = {}
        for k, v in pairs(t) do
            if type(v) == "table" then
                target[k] = self:clone(v)
            else
                target[k] = v
            end
        end
        setmetatable(target, meta)
        return target
    end;

    search_free_id = function(self, num)
        if self.agents[num] ~= nil then
            self:search_free_id(num+1)
        else
            return num
        end
    end;

}


return Collection
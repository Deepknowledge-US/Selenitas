------------------
-- Family Class is the basis class from which we build the families of agents.
-- Families are the main structures of the system. It consists in a table of Agents, a list of ids and some methods to manipulate the agents.
-- self.agents is a table 'object_id: object' and we use it to find an element quickily.
-- self.order  is an ordered table 'position:id' and we use it to determine the actuation order in each iteration. This table is shuffled in each iteration.
--
-- @classmod
-- Family

local class  = require 'Thirdparty.pl.class'

local Family = class.Family()

------------------
-- Family constructor.
-- @function _init
-- @return A new instance of Family class.
-- @usage New_Instance = Family()
Family._init = function(self)
    self.__to_purge = {}

    self.order  = {}
    self.agents = {}
    self.size   = 0

    return self
end;

------------------
-- Killing an agent consist in get its id out of the order list of the family, it also be included in a list of agents to purge and its parameter alive will be set to false.
-- @function kill
-- @return Nothing.
-- @usage Nodes:kill(a_node)
Family.kill = function(self,agent)
    for k,v in ipairs(self.order) do
        if v == agent.id then
            local target = self.agents[agent.id]
            target.alive = false
            table.insert(self.__to_purge, target)
            table.remove(self.order, k)
            self.size = self.size-1
            break
        end
    end
end;

------------------
-- To purge an agent consist in delete the agent of the family (A value of nil in the agents table) and delete all its links with other agents.
-- @function __purge_agents
-- @return Nothing.
-- @usage
-- -- This function is called by the method purge_agents(), so, to do a purge of died agents call 'purge_agents()' instead:
-- __purge_agents()
-- @see collections.purge_agents
Family.__purge_agents = function(self)
    for _,v in pairs(self.__to_purge) do
        v:__purge()
    end
    self.__to_purge = {}
end

------------------
-- It consist in permutations of the ids in the position:id tables using Fisher-Yates algorithm.
-- @function Instance:shuffle
-- @return Nothing.
-- @usage Instance:shuffle()
Family.shuffle = function(self)
    local array = self.order
    for i = #array,2, -1 do
        local j = math.random(i)
        array[i], array[j] = array[j], array[i]
    end
end;

------------------
-- Given an agent, it returns all the other agents in the family.
-- @function Instance:others
-- @param agent An Agent instance.
-- @return A Collection containing all Agents of the Family except the agent gived as parameter.
-- @usage Instance:others(agent)
Family.others = function(self,agent)
    return self:with( function(x) return x ~= agent end )
end;

------------------
-- Given an agent, it returns,randomly, one of the other agents in the family, or nil if there is no other agent.
-- @function Instance:one_of_others
-- @param agent is an Agent instance.
-- @return An Agent instance of the Family distinct of the agent gived as parameter.
-- @usage Instance:one_of_others(agent)
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

------------------
-- This function returns a clone of the agent gived as parameter. Is an auxiliar function used by 'clone_n_act' to obtain an object that is added to the Family later.
-- @function Instance:clone
-- @param agent is an Agent instance.
-- @return A new object, clone of the one gived as parameter. The only difference will be the id, unique for any agent or clone.
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

------------------
-- This function creates a number of clones of an agent and, if a function is gived as parameter, it applies a function to them. It uses the auxiliar function "clone" to obtain the clones and the auxiliar function "search_free_id" to give a new id to the clones.
-- @function Instance:clone_n_act
-- @param num is the number of clones we want.
-- @param agent is the Agent instance the clones are created from
-- @param funct is an optional param, and it is an anonymous function. If present, the function is applied to the clones.
-- @usage
--  Agents1:clone_n_act(1, agent, function(x)
--      x.color = 'red'
--  end)
--  -- If we just want to create same agents, we can call this function without the last parameter:
--  Agents1:clone_n_act(3, agent)
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

------------------
-- A function to print the Family.
-- @function __tostring
-- @return A string representation of the Family
-- @usage print(Instance)
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

Family.ask = function(self)end

Family.with = function(self,pred)
    for _,v in pairs(self.agents) do
        
    end
end

Family.n_of = function(self)end
Family.one_of = function(self)end
Family.up_to_n_of = function(self)end -- selecciona al azar hasta n agentes de col
Family.all = function(self)end
Family.exists = function(self)end -- devuelve true si algún agente de col verifica pd: col
Family.max_n_of = function(self)end --devuelve los n agentes de col con valores máximos de f: col -> Num .
Family.max_one_of = function(self)end

Family.min_n_of = function(self)end --devuelve los n agentes de col con valores mínimos de f: col -> Num .
Family.min_one_of = function(self)end


Family.with_max = function(self)end -- devuelve todos los agentes de col que toman el valor máximo de f: col -> Num .
Family.with_min = function(self)end -- devuelve todos los agentes de col que toman el valor mínimo de f: col -> Num 
Family.is_in = function(self)end -- devuelve true si el agente ag está en col


return Family
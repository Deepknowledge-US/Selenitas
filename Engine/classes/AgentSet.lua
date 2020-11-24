------------------
-- Family Class is the basis class from which we build the families of agents.
-- Families are the main structures of the system. It consists in a table of Agents, a list of ids and some methods to manipulate the agents.
-- self.agents is a table 'object_id: object' and we use it to find an element quickily.
--
-- @classmod
-- Family

local class = require "Thirdparty.pl.class"

local Family = class.Family()



--===========================--
--          ACTIONS          --
--===========================--

------------------
-- Family constructor.
-- @function _init
-- @return Family. A new instance of Family class.
-- @usage New_Instance = Family()
Family._init = function(self,name)
    self.name       = name or 'Collection'
    self.__to_purge = {}
    self.properties = {}
    self.functions  = {}
    self.agents     = {}
    self.count      = 0

    return self
end

------------------
-- This function adds a method in the Family, the added method can be used for every agent of the family.
-- @function add_method
-- @return Nothing.
-- @usage 
-- Nodes:add_method('method_name', function(node, an_agent) 
--     return dist_euc_to(an_agent) 
-- end )
--
-- a_node:method_name(an_agent)
-- -- The euclidean distance from a_node to an_agent is returned
Family.add_method = function(self, name, funct)

    self.functions[name] = funct
    for _,v in next,self.agents do
        v[name] = self.functions[name]
    end

end


Family.clone_table = function(tab) -- deep-copy a table
    if type(tab) ~= "table" then
        return tab
    end
    local meta = getmetatable(tab)
    local target = {}
    for k, v in pairs(tab) do
        if type(v) ~= "table" or is_instance(v,Agent) or is_instance(v,Family) then
            target[k] = v
        else
            target[k] = Family.clone_table(v)
        end
    end
    setmetatable(target, meta)
    return target
end

------------------
-- This function adds a property to the agents of the Family.
-- @function add_method
-- @return Nothing.
-- @usage TODO
Family.add_properties = function(self, tab)

    for prop_name, def_val in next, tab do
        self.properties[prop_name] = Family.clone_table(def_val)
    end

    for _,v in next, self.agents do
        for prop_name,def_val in next, self.properties do
            v[prop_name] = Family.clone_table(def_val)
        end
    end

end

------------------
-- Killing an agent consist in include its id in a list of agents to purge and its parameter 'alive' will be set to false.
-- @function kill
-- @return Nothing.
-- @usage Nodes:kill(a_node)
-- @see actions.die
Family.kill = function(self, agent)
    if agent ~= nil and agent.alive then
        self.agents[agent.id].alive = false
        table.insert(self.__to_purge, agent)
        self.count = self.count - 1
        if agent.current_cells then
            for i=1,#agent.current_cells do
                agent.current_cells[i]:come_out(agent)
            end
        end
    end
end

------------------
-- To purge an agent consist in delete the agent of the family (A value of nil in the agents table) and delete all its links with other agents.
-- @function __purge_agents
-- @return Nothing.
-- @usage
-- -- This function is called by the method purge_agents(), so, to do a purge of died agents call 'purge_agents()' instead:
-- __purge_agents()
-- @see families.purge_agents
Family.__purge_agents = function(self)
    for _, v in pairs(self.__to_purge) do
        v:__purge()
    end
    self.__to_purge = {}
end

------------------
-- This function kills and agent and removes it from the simulation.
-- @function kill_and_purge
-- @return Nothing.
-- @usage
-- Nodes:kill_and_purge(an_agent)
-- @see actions.kill_and_purge
Family.kill_and_purge = function(self,agent)
    self:kill(agent)
    agent:__purge()
end

------------------
-- This function creates a number of clones of an agent and, if a function is gived as parameter, it applies a function to them. It uses the auxiliar function "clone" to obtain the clones and the auxiliar function "search_free_id" to give a new id to the clones.
-- @function Instance:clone_n
-- @param num is the number of clones we want.
-- @param agent is the Agent instance the clones are created from
-- @param funct is an optional param, and it is an anonymous function. If present, the function is applied to the clones.
-- @return Nothing
-- @usage
--  Agents1:clone_n(1, agent, function(x)
--      x.color = 'red'
--  end)
--  -- If we just want to create same agents, we can call this function without the last parameter:
--  Agents1:clone_n(3, agent)
Family.clone_n = function(self, num, agent, funct)
    local res = {}

    for i = 1, num do
        local ag = self:clone(agent)
        self:new(ag)
        table.insert(res, ag)
    end

    if funct then
        for _, v in ipairs(res) do
            funct(v)
        end
    end
end



--===========================--
--          CHECKS           --
--===========================--

------------------
-- Returns true if any agent in the family validates a predicate.
-- @function Instance:exists
-- @param pred An anonymous function (boolean predicate).
-- @return Boolean and an Agent. True if there is at least one agent that validates the predicate.
-- @usage
-- local response = A_family:exists( function(x) x.label ~= '' end )
-- @see checks.exists
Family.exists = function(self, pred)
    for _, v in pairs(self.agents) do
        if pred(v) then
            return true, v
        end
    end
    return false
end

------------------
-- Checks if all agents in a family validates a condition.
-- @function Instance:all
-- @param pred Anonymous function (boolean predicate).
-- @return Boolean. True if all agents validate the condition.
-- @usage
-- A_family:all(function(ag) ag.label == '' end)
-- @see checks.all
Family.all = function(self, pred)
    for _, v in pairs(self.agents) do
        if not pred(v) then
            return false
        end
    end
    return true
end

------------------
-- Checks if an agent is member of the family.
-- @function Instance:is_in
-- @param agent The Agent instance we want to check.
-- @return Boolean. True if the agent is in the family
-- @usage
-- A_family:is_in(agent)
-- @see checks.is_in
Family.is_in = function(self,agent)
    if self.agents[agent.id] then
        return true
    else
        return false
    end
end




--===========================--
--          FILTERS          --
--===========================--

------------------
-- Given an agent, it returns all the other agents in the family.
-- @function Instance:others
-- @param agent An Agent instance.
-- @return A Collection containing all Agents of the Family except the agent gived as parameter.
-- @usage Instance:others(agent)
-- @see filters.others
Family.others = function(self, agent)
    return self:with(
        function(x)
            return x ~= agent
        end
    )
end

------------------
-- Given an agent, it returns,randomly, one of the other agents in the family, or nil if there is no other agent.
-- @function Instance:one_of_others
-- @param agent is an Agent instance.
-- @return An Agent instance of the Family distinct of the agent gived as parameter.
-- @usage Instance:one_of_others(agent)
-- @see filters.one_of_others
Family.one_of_others = function(self, agent)
    local candidates = self:alives_list()

    if #candidates < 2 then return nil end

    local candidate = candidates[math.random(#candidates)]

    while candidate == agent do
        candidate = candidates[math.random(#candidates)]
    end

    return candidate
end

------------------
-- Filter function.
-- @function Instance:with
-- @param pred Anonymous function (boolean predicate)
-- @return Collection of agents in the family satisfying the predicate.
-- @usage
-- local lower_agents = Agents:with( function(ag) return ag:ycor() < 2 end )
-- @see filters.with
Family.with = function(self, pred)
    local yes = Collection(self)
    local no  = Collection(self)
    for _, v in pairs(self.agents) do
        if pred(v) then
            yes:add(v)
        else
            no:add(v)
        end
    end
    return yes, no
end

------------------
-- Selects and returns a random alive agent of the family.
-- @function Instance:one_of
-- @return Agent. The type of agent depends on the type of family the agent belongs to.
-- @usage
-- local random_alive_agent = A_family:one_of()
-- @see filters.one_of
Family.one_of = function(self)
    local list_copy = self:alives_list()
    local target = self.count>0 and list_copy[math.random(self.count)] or nil
    -- local target = list_copy[math.random(#list_copy)]
    return target
end

------------------
-- Selects and returns n random alive agents of the family. If the number of agents of the family is minor that n this function returns an error message.
-- @function Instance:n_of
-- @param n Number of agents we want.
-- @return Collection with n random selected agents of the family, or error if not enough agents.
-- @see Family.up_to_n_of
-- @usage
-- local three_agents = A_family:n_of(3)
-- @see filters.n_of
Family.n_of = function(self, n)
    local res        = Collection(self)
    local list_copy  = self:alives_list()
    local num_agents = self.count

    if n > num_agents then
        error("Error: n_of -> not enoughs agents. n: " .. n .. ". Agents alives: " .. self.count)
    else
        for index = num_agents+1, num_agents - n + 2, -1 do
            local _,current = __consumer(list_copy, index)
            res:add(current)
        end
    end
    return res
end

------------------
-- This function selects n random agents of a family. When there are fewer than n agents in the family, this function returns all agents in the family.
-- @function Instance:up_to_n_of
-- @param n Number. Number of agents we want.
-- @return Collection
-- @usage
-- local ten_or_less_nodes = Nodes:up_to_n_of(10)
-- @see filters.up_to_n_of
Family.up_to_n_of = function(self, n)
    local res       = Collection(self)
    local list_copy = self:alives_list()
    local num_agents= self.count

    local stop = n >= num_agents and 1 or num_agents - (n - 1)

    for index = num_agents, stop, -1 do
        local current = __consumer(list_copy, index)
        res:add(current)
    end

    return res
end

------------------
-- Returns the agent with the minimum value for a gived function 
-- @function Instance:max_one_of
-- @param funct An anonimous function that will be applied to the agents to searching for the maximum.
-- @return Agent.
-- @usage
-- local olderer_agent = A_family:max_one_of( function(agent) return agent.age end )
-- -- Assuming that all agents in "A_family" have a parameter "age"
-- @see filters.max_one_of
Family.max_one_of = function(self, f)
    local res, max_value = nil, nil

    for _, v in pairs(self.agents) do
        local current, current_val = v, f(v)
        if max_value == nil or current_val > max_value then
            max_value = current_val
            res = current
        end
    end

    return res
end

------------------
-- Returns the n elements producing the maximum values for a gived function
-- @function Instance:max_n_of
-- @param num Number of agents we want
-- @param funct An anonimous function that will be applied to agents to compute the value
-- @return Collection.
-- @usage
-- local older_5_agents = A_family:max_n_of(5, function(ag) return ag.age end)
-- @see filters.max_n_of
Family.max_n_of = function(self, n, f)
    local copy = self:alives_list()
    table.sort(
        copy,
        function(x, y)
            return f(x) > f(y)
        end
    )

    local res = Collection(self)
    for i = 1, n do
        res:add(copy[i])
    end
    return res
end

------------------
-- Returns the n elements producing the minimum values for a gived function
-- @function Instance:min_n_of
-- @param num Number of agents we want
-- @param funct An anonimous function that will be applied to agents to compute the value
-- @return Collection of agents
-- @usage
-- local younger_5_agents = A_family:min_n_of(5, function(ag) return ag.age end)
-- @see filters.min_n_of
Family.min_n_of = function(self, num,funct)
    local copy = self:alives_list()
    table.sort(
        copy,
        function(x, y)
            return funct(x) < funct(y)
        end
    )

    local res = Collection(self)
    for i = 1, num do
        res:add(copy[i])
    end
    return res
end

------------------
-- Returns the agent with the minimum value for a gived function 
-- @function Instance:min_one_of
-- @param funct An anonimous function that will be applied to the agents to searching for the minimum.
-- @return An Agent. The type of agent depends on the type of family that has called the method.
-- @usage
-- local younger_agent = A_family:min_one_of( function(agent) return agent.age end )
-- -- Assuming that all agents in "A_family" have a parameter "age"
-- @see filters.min_one_of
Family.min_one_of = function(self, funct)
    local res, max_value = nil, nil

    for _, v in pairs(self.agents) do
        local current, current_val = v, funct(v)
        if max_value == nil or current_val < max_value then
            max_value = current_val
            res = current
        end
    end

    return res
end

------------------
-- Returns a Collection of agents with the min value for a gived function.
-- @function Instance:with_max
-- @param funct An anonymous function to calculate the value for each agent
-- @return Collection
-- @usage
-- local agents_in_the_right = A_family:with_max( function(agent) return agent:xcor() end )
-- @see filters.with_max
Family.with_max = function(self,funct)
    local res     = Collection(self)
    local ordered = self:alives_list()
    table.sort(ordered, function(x,y) return funct(x)>funct(y) end)
    local max_val = funct(ordered[1])

    for i=1,#ordered do
        if funct(ordered[i]) == max_val then
            res:add(ordered[i])
        else
            break
        end
    end

    return res
end

------------------
-- Returns a Collection of agents with the min value for a gived function.
-- @function Instance:with_min
-- @param funct An anonymous function to calculate the value for each agent
-- @return Collection
-- @usage
-- local agents_in_the_left = A_family:with_min( function(agent) return agent:xcor() end )
-- @see filters.with_min
Family.with_min = function(self,funct)
    local res     = Collection(self)
    local ordered = self:alives_list()
    table.sort(ordered, function(x,y) return funct(x)<funct(y) end)
    local max_val = funct(ordered[1])

    for i=1,#ordered do
        if funct(ordered[i]) == max_val then
            res:add(ordered[i])
        else
            break
        end
    end

    return res
end



--===========================--
--         UTILITIES         --
--===========================--

------------------
-- Returns the total number of agents in the family (alives and killed agents that have not been purged yet). If you want the number of agets with live you can use the parameter "count" of families (Family.count)
-- @function Instance:count_all
-- @return Number.
-- @usage local number = My_family:count_all()
Family.get = function(self, agent_id)
    return self.agents[agent_id]
end

------------------
-- Returns the total number of agents in the family (alives and killed agents that have not been purged yet). If you want the number of agets with live you can use the parameter "count" of families (Family.count)
-- @function Instance:count_all
-- @return Number.
-- @usage local number = My_family:count_all()
Family.count_all = function(self)
    return self.count + #self.__to_purge()
end

------------------
-- Returns the list of keys in the Family. It returns keys of not purgued agents, so, it is possible to have keys of dead agents in this list.
-- @function Instance:keys
-- @return List of numbers (the keys)
-- @usage local all_keys = Family:keys()
-- @see Family.alives_list
Family.keys = function(self)
    local res = {}
    for k, _ in pairs(self.agents) do
        table.insert(res, k)
    end
    return res
end

------------------
-- This function returns a clone of the table gived as parameter. Is an auxiliar function used by 'clone_n_act' to obtain an object that is added to the Family later.
-- @function Instance:clone
-- @param agent is an Agent instance.
-- @return A new object, clone of the one gived as parameter. The only difference will be the id, unique for any agent or clone.
Family.clone = function(self, agent) -- deep-copy a table
    if type(agent) ~= "table" then
        return agent
    end
    local meta = getmetatable(agent)
    local target = {}
    for k, v in pairs(agent) do
        if type(v) ~= "table" or is_instance(v,Agent) or is_instance(v,Family) then
            target[k] = v
        else
            target[k] = self:clone(v)
        end
    end
    setmetatable(target, meta)
    return target
end

------------------
-- Returns the list of alive agents in the Family
-- @function A_family:alives_list
-- @return List of agents
-- @usage
-- local current_agents = A_family:alives_list()
Family.alives_list = function(self)
    local res = {}
    for _, v in next, self.agents do
        if v.alive then
            table.insert(res, v)
        end
    end
    return res
end

------------------
-- A function to print the Family.
-- @function __tostring
-- @return A string representation of the Family
-- @usage print(Instance)
Family.__tostring = function(self)
    local res = "{\n"
    for k, v in pairs(self.agents) do
        if type(v) == "table" then
            res = res .. "\t" .. k .. ": {\n"
            for k2, v2 in pairs(v) do
                local v2_aux = type(v2) == "table" and type(v2) or v2
                res = res .. "\t\t" .. k2 .. ": " .. tostring(v2_aux) .. "\n"
            end
            res = res .. "\t}\n"
        else
            res = res .. "\t" .. k .. ": " .. v .. "\n"
        end
    end
    res = res .. "}"
    return res
end



return Family
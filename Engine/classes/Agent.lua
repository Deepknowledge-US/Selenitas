------------------
-- Base agent class,  Mobiles, Cells and Relationals are instances of Agent also.
-- @classmod
-- Agent

local class = require 'Thirdparty.pl.class'

local Agent = class.Agent()


------------------
-- When a new agent is created, some properties are given to it. An agent will have at least a 'family' field to know the family the agent belongs to, some tables to hold their possible neighbors and a field to know if the agent has die: 'alive'.
-- @function _init
-- @return A new instance of Agent class.
-- @usage agent_1 = Agent({})
Agent._init = function(self)

    self.family     = nil
    self.alive      = true
    self.in_links   = {}
    self.out_links  = {}
    self.in_neighs  = {}
    self.out_neighs = {}

    return self
end;

------------------
-- Auxiliar function used by families to purge agents, it is not recommended to use it directly to manipulate agents, use 'purge_agents()' instead.
-- @function __delete_in_neighs
-- @return Nothing.
Agent.is_in = function(self,fam)
    return fam:is_in(self)
end;

Agent.pick = function(self,fam_or_agent)
    return fam_or_agent
end

Agent.set_param = function(self,name,value)
    self[name] = value
    return self
end

Agent.link_neighbors = function(self,fam)
    local res = Collection()
    if fam then
        for i=1,#self.in_links do
            if self.in_links[i].family == fam then
                res:add(self.in_links[i].target)
            end
        end
        for i=1,#self.out_links do
            if self.out_links[i].family == fam then
                res:add(self.out_links[i].target)
            end
        end
    else
        for i=1,#self.in_links do
            res:add(self.in_links[i].target)
        end
        for i=1,#self.out_links do
            res:add(self.out_links[i].target)
        end
    end
    return res
end


Agent.in_link_neighbors  = function(self,fam)
    local res = Collection()
    if fam then
        for i=1,#self.in_links do
            if self.in_links[i].family == fam then
                res:add(self.in_links[i].target)
            end
        end
    else
        for i=1,#self.in_links do
            res:add(self.in_links[i].target)
        end
    end
    return res
end


Agent.out_link_neighbors = function(self,fam)
    local res = Collection()
    if fam then
        for i=1,#self.out_links do
            if self.out_links[i].family == fam then
                res:add(self.out_links[i].target)
            end
        end
    else
        for i=1,#self.out_links do
            local link = self.out_links[i]
            res:add(link.target)
        end
    end
    return res
end
------------------
-- Auxiliar function used by families to purge agents, it is not recommended to use it directly to manipulate agents, use 'purge_agents()' instead.
-- @function __delete_in_neighs
-- @return Nothing.
Agent.__delete_in_neighs = function(self)
    for k,_ in pairs(self.in_neighs)do
        local target = self.family.agents[k]
        local i = 1
        while target == nil do
            target = Config.__all_families[i].agents[k]
            i = i+1
        end
        if target ~= nil then
            target.out_neighs[self.id] = nil -- Delete references to the agent
        else
            print('ERROR while trying to delete_in_neighs. Target: ' .. k)
        end
    end
end;

------------------
-- Auxiliar function used by families to purge agents, it is not recommended to use it directly to manipulate agents, use 'purge_agents()' instead.
-- @function __delete_out_neighs
-- @return Nothing.
Agent.__delete_out_neighs = function(self)
    for k,_ in pairs(self.out_neighs)do
        local target = self.family.agents[k]
        local i = 1
        while target == nil do
            target = Config.__all_families[i].agents[k]
            i = i+1
        end
        if target ~= nil then
            target.in_neighs[self.id] = nil -- Delete references to the agent
        else
            print('ERROR while trying to delete_out_neighs. Target: ' .. k)
        end
    end
end;

------------------
-- Auxiliar function used by families to purge agents, it is not recommended to use it directly to manipulate agents, use 'purge_agents()' instead.
-- @function __delete_links
-- @return Nothing.
Agent.__delete_links = function(self, list_of_links)
    for i=1,#list_of_links do
        list_of_links[i]:__purge() -- Recursive link removal. If it is related to any other link, this relationship will be removed.
    end
end

-- ------------------
-- -- Auxiliar function used by families to purge agents, it is not recommended to use it directly to manipulate agents, use 'purge_agents()' instead.
-- -- @function __delete_links
-- -- @return Nothing.
-- Agent.__delete_links = function(self, list_of_ids)
--     local rel_families = {}
--     for _,v in pairs(Config.__all_families)do
--         if v:is_a(FamilyRelational) then
--             table.insert(rel_families,v)
--         end
--     end
--     for i=1,#list_of_ids do
--         local link_id = list_of_ids[i]

--         local iter = 1
--         local link = rel_families[iter].agents[link_id]

--         while link==nil do
--             iter = iter+1
--             link = rel_families[iter].agents[link_id]
--         end
--         if link ~= nil then
--             link:__purge() -- Recursive link removal. If it is related to any other link, this relationship will be removed.
--         else
--             print('ERROR while trying to delete_links. Target: ' .. link_id)
--         end
--     end
-- end

------------------
-- Auxiliar function used by families to purge agents, it is not recommended to use it directly to purge agents, use 'purge_agents()' instead.
-- @function __purge
-- @return Nothing.
Agent.__purge = function(self)
    -- Step 1: Delete references to me in my neighbors
    self:__delete_in_neighs()
    self:__delete_out_neighs()

    -- Step 2: Delete the links related to me
    self:__delete_links(self.in_links)
    self:__delete_links(self.out_links)

    -- Step 3: Delete myself
    self.family.agents[self.id] = nil
end

------------------
Agent.ask = function(self,funct)
    if self.alive then
        funct(self)
    end
end

------------------
-- A function to print the Agent. If we do print(an_agent) this function is called.
-- @function __tostring
-- @return A string representation of the agent.
-- @usage print(Instance)
Agent.__tostring = function(self)
    local res = "{\n"
    for k,v in pairs(self) do
        if type(v) == 'table' then
            res = res .. '\t'  .. k .. ': {\n'
            for k2,v2 in pairs(v) do
                res = res .. '\t\t' .. k2 .. ': ' .. type(v2) .. '\n'
            end
            res = res .. '\t}\n'
        else
            res = res .. '\t' .. k .. ': ' .. tostring(v) .. '\n'
        end
    end
    res = res .. '}'
    return res
end;

return Agent
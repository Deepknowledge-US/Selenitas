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
Agent._init = function(self, p_table)

    self.family     = nil
    self.__alive    = true
    self.in_links   = {}
    self.out_links  = {}
    self.in_neighs  = {}
    self.out_neighs = {}

    if p_table and p_table.visible == nil then
        self.visible = true
    else
        self.visible = p_table.visible
    end

    if p_table and p_table.show_label == nil then
        self.show_label = false
    else
        self.show_label = p_table.show_label
    end

    return self
end;

------------------
-- Checks if an agent is in a family.
-- @function is_in_in_neighs
-- @return Boolean, true if the agent is in the family.
Agent.is_in = function(self,fam)
    return fam:is_in(self)
end;

------------------
-- It gives a new value to some parameter of the agent.
-- @function set_param
-- @param name String, the name of the paprameter
-- @param value Anything. The new value of the paprameter could be a String, a number, a table ...
-- @return Agent. The one who calls this method
Agent.set_param = function(self,name,value)     --TODO CUIDADO CON LAS TABLAS !!!!!!!
    self[name] = value
    return self
end

------------------
-- It returns the neighbors of the agent.
-- @function link_neighbors
-- @param fam1 Optional parameter, if the name of a family is given, only the neighbors member of this family are returned.
-- @param fam2 Optional parameter, if the name of a family is given, only the neighbors member of fam1 related with caller by some link of this family are returned.
-- @return Collection of neighbors of the agent.
-- @usage
--      declare_FamilyMobile('Triangles')
--      declare_FamilyMobile('Squares')
--      
--      for i=1,5 do
--          Triangles:new({
--          })
--          Squares:new({
--              ['shape']      = 'square'
--          })
--      end
--      declare_FamilyRel('TS')

--      for _,t in sorted(Triangles)do
--          for _,s in sorted(Squares)do
--              TS:new({source=t,target=s})
--          end
--      end
--
--      my_neighs = an_agent:link_neighbors(Squares,TS)
Agent.link_neighbors = function(self,fam1, fam2)
    local res = Collection()
    if fam1 then
        for id_neigh,list_of_links in next,self.in_neighs do
            local current_neigh = list_of_links[1].source

            if current_neigh.family == fam1 then
                if fam2 then
                    for _,link in next,list_of_links do
                        if link.family == fam2 then
                            res:add(link.source)
                        end
                    end
                else
                    for _,link in next,list_of_links do
                        res:add(link.source)
                    end
                end
            end
        end
        for id_neigh,list_of_links in next,self.out_neighs do
            local current_neigh = list_of_links[1].target

            if current_neigh.family == fam1 then
                if fam2 then
                    for _,link in next,list_of_links do
                        if link.family == fam2 then
                            res:add(link.target)
                        end
                    end
                else
                    for _,link in next,list_of_links do
                        res:add(link.target)
                    end
                end
            end
        end

    else
        for id_neigh,links in next,self.in_neighs do
            res:add(links[1].source)
        end
        for id_neigh,links in next,self.out_neighs do
            res:add(links[1].target)
        end
    end
    return res
end

------------------
-- It returns the agents related with caller by a link that points to the agent.
-- @function in_link_neighbors
-- @param fam1 Optional parameter, if the name of a family is given, only the neighbors member of this family are returned.
-- @param fam2 Optional parameter, if the name of a family is given, only the neighbors member of fam1 related with caller by some link of this family are returned.
-- @return Collection of links of the agent.
Agent.in_link_neighbors  = function(self,fam1, fam2)

    local res = Collection()
    if fam1 then
        for id_neigh,list_of_links in next,self.in_neighs do
            local current_neigh = list_of_links[1].source

            if current_neigh.family == fam1 then
                if fam2 then
                    for _,link in next,list_of_links do
                        if link.family == fam2 then
                            res:add(link.source)
                        end
                    end
                else
                    for _,link in next,list_of_links do
                        res:add(link.source)
                    end
                end
            end
        end
    else
        for id_neigh,links in next,self.in_neighs do
            res:add(links[1].source)
        end
    end
    return res

end

------------------
-- It returns the other side of the out links with the caller as origin.
-- @function out_link_neighbors
-- @param fam1 Optional parameter, if the name of a family is given, only the neighbors member of this family are returned.
-- @param fam2 Optional parameter, if the name of a family is given, only the neighbors member of fam1 related with caller by some link of this family are returned.
-- @return Collection of neighs of the agent.
Agent.out_link_neighbors  = function(self,fam1, fam2)

    local res = Collection()
    if fam1 then
        for id_neigh,list_of_links in next,self.out_neighs do
            local current_neigh = list_of_links[1].target

            if current_neigh.family == fam1 then
                if fam2 then
                    for _,link in next,list_of_links do
                        if link.family == fam2 then
                            res:add(link.target)
                        end
                    end
                else
                    for _,link in next,list_of_links do
                        res:add(link.target)
                    end
                end
            end
        end
    else
        for id_neigh,links in next,self.out_neighs do
            res:add(links[1].target)
        end
    end
    return res

end

------------------
-- It returns the links of caller.
-- @function my_links
-- @param fam1 Optional parameter, if the name of a family is given, only the links member of this family are returned.
-- @param fam2 Optional parameter, if the name of a family is given, only the links member of fam1 with a member of fam2 in the other end of the link are returned.
-- @return Collection of neighbors of the agent.
Agent.my_links = function(self,fam1, fam2)
    local res = Collection()
    if fam1 then
        local pred_in,pred_out
        if fam2 then
            pred_in  = function(index) return self.in_links[index].family == fam1 and self.in_links[index].source.family == fam2 end
            pred_out = function(index) return self.out_links[index].family == fam1 and self.out_links[index].target.family == fam2 end
        else
            pred_in  = function(index) return self.in_links[index].family == fam1 end
            pred_out = function(index) return self.out_links[index].family == fam1 end
        end

        for i=1,#self.in_links do
            if pred_in(i) then
                res:add(self.in_links[i])
            end
        end
        for i=1,#self.out_links do
            if pred_out(i) then
                res:add(self.out_links[i])
            end
        end
    else
        for i=1,#self.in_links do
            res:add(self.in_links[i])
        end
        for i=1,#self.out_links do
            res:add(self.out_links[i])
        end
    end
    return res
end

------------------
-- It returns the links that points to caller.
-- @function my_in_links
-- @param fam1 Optional parameter, if the name of a family is given, only the links member of this family are returned.
-- @param fam2 Optional parameter, if the name of a family is given, only the links member of fam1 with a member of fam2 in the other end of the link are returned.
-- @return Collection of links of the agent.
Agent.my_in_links  = function(self,fam1, fam2)
    local res = Collection()
    if fam1 then
        local pred_in
        if fam2 then
            pred_in  = function(index) return self.in_links[index].family == fam1 and self.in_links[index].source.family == fam2 end
        else
            pred_in  = function(index) return self.in_links[index].family == fam1 end
        end
        for i=1,#self.in_links do
            if pred_in(i) then
                res:add(self.in_links[i])
            end
        end
    else
        for i=1,#self.in_links do
            res:add(self.in_links[i])
        end
    end
    return res
end

------------------
-- It returns the links with caller as origin.
-- @function my_out_links
-- @param fam1 Optional parameter, if the name of a family is given, only the links member of this family are returned.
-- @param fam2 Optional parameter, if the name of a family is given, only the links member of fam1 with a member of fam2 in the other end of the link are returned.
-- @return Collection of links of the agent.
Agent.my_out_links = function(self,fam1,fam2)
    local res = Collection()
    if fam1 then
        local pred_out
        if fam2 then
            pred_out = function(index) return self.out_links[index].family == fam1 and self.out_links[index].target.family == fam2 end
        else
            pred_out = function(index) return self.out_links[index].family == fam1 end
        end
        for i=1,#self.out_links do
            if pred_out(i) then
                res:add(self.out_links[i])
            end
        end
    else
        for i=1,#self.out_links do
            res:add(self.out_links[i])
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
            target.out_neighs[self.__id] = nil -- Delete references to the agent
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
            target.in_neighs[self.__id] = nil -- Delete references to the agent
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
    self.family.agents[self.__id] = nil
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
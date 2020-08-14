------------------
-- A base class from which all other agents come
-- @classmod
-- Agent

local class = require 'Thirdparty.pl.class'

------------------
-- Agent constructor.
-- @function _init
-- @return A new instance of Agent class.
-- @usage New_Instance = Agent()
local Agent = class.Agent()
Agent._init = function(self)

    self.in_links   = {}
    self.out_links  = {}
    self.in_neighs  = {}
    self.out_neighs = {}

    return self
end;

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
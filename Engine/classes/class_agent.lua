local class  = require 'pl.class'

--[[
    When a new agent is created, it is given some properties (if we haven't already done so)

    with 'xcor' and 'ycor' we locate the agent in the space. -- TODO: zcor
    'head' is a parameter to know the direction the agent is facing (in a 2d space. 360º)
    'shape' and 'color' determines the aspect of the agent
    'linked' is a list of references to other agents (its neighbours)

    Caution!
    When an agent A has as neighbour an agent B, both agents will hold a reference to the other 
    object in its linked table.
    Some functions as pretty.dump() iterates recursively over the tables or metatables present 
    in an object, so if we try pretty.dump(A) it produces a cycle.
]]--

local Agent = class.Agent {
    _init = function(self,o)
        local c         = o or {}
        self            = c
        self.xcor       = c.xcor    or 0
        self.ycor       = c.ycor    or 0
        self.head       = c.head    or 0
        self.shape      = c.shape   or 'triangle'
        self.color      = c.color   or 'yellow'
        self.linked     = c.linked  or {}

        return self
    end;

--[[
    This function applies to the agent a series of functions consecutively.
    The number of functions gived as parameters is not predetermined.
    Caution! we are assuming functions with one ore less parameters as inputs.
]]--
    does = function(self, ...)
        for i = 1,select('#', ...)do
            local funct = select( i, ... )
            funct(self)
        end
    end;


--[[
    Agents are able to keep a list of neighbors in their "linked" parameter.
    We can have more than one link between A and B, but B will appear only once in A.linked
    (the same for B.linked and A)
]]--
    add_neigh = function(self, agent)
        for i = 1, #self.linked do
            if self.linked[i] == agent then
                return
            end
        end
        self.linked[#self.linked+1] = agent
    end;


--[[
    Naive function to print Agents. When we call "print(instance_of_agent)" this function is
    colled to print the agent. Use print() instead of pretty.dump()
]]--
    __tostring = function(self)
        local res = "{\n"
        for k,v in pairs(self) do
            if type(v) == 'table' then
                res = res .. '\t'  .. k .. ': {\n'
                for k2,v2 in pairs(v) do
                    res = res .. '\t\t' .. k2 .. ': ' .. type(v2) .. '\n'
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

return Agent
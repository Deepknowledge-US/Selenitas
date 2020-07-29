local class  = require 'pl.class'

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

    add_neigh = function(self, agent)
        for i = 1, #self.linked do
            if self.linked[i] == agent then
                return
            end
        end
        self.linked[#self.linked+1] = agent
    end
}

return Agent
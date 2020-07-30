local class  = require 'pl.class'

local Link = class.Link{

    --[[
        When a new Link is created, some properties are given to it (If we do not have done it yet)
    ]]
    _init = function(self,o)
        local c   = o or {}
        self      = c
        self.end1 = c.end1 or {}
        self.end2 = c.end2 or {}
        return self
    end;

    -- This function is called when we do a print(a_link). String representation of the object.
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


return Link
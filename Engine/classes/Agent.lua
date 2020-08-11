local class     = require 'Thirdparty.pl.class'

--[[
    Mobiles, Relationals and Cells are Agents also.
]]--

local Agent = class.Agent {
    _init = function(self)
        
        self.in_links   = {}
        self.out_links  = {}
        self.in_neighs  = {}
        self.out_neighs = {}

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
                res = res .. '\t' .. k .. ': ' .. tostring(v) .. '\n'
            end
        end
        res = res .. '}'
        return res
    end;

}

return Agent
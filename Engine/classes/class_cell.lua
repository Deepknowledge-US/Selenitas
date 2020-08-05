local class  = require 'pl.class'

local Cell = class.Cell{

    --[[
        When a new Patch is created, some properties are given to it (If we do not have done it yet)
    ]]--
    _init = function(self,o)
        local c     = o or {}
        self        = c
        self.xcor   = c.xcor or 0
        self.ycor   = c.ycor or 0
        self.label  = c.label or ''
        self.color  = c.color or 'black'
        self.shape  = c.xcor or 'square'
        return self
    end;


    -- String representation of a Patch.
    -- To call this function just use "print(a_patch)".
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

return Cell
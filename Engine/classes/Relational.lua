local class  = require 'pl.class'

--[[

* Agentes Relacionales (*links*): Por ahora se consideran binarios (solo relacionan 2 *mobiles*) y dirigidos.
  * `id <Num>` : Identificador único que determina al agente.
  * `type <String>` : Indica si es de tipo dirigido (`dir`) o no dirigido (`undir`).
  * `source <Agent>` : Agente del que parte la relación.
  * `target <Agent>` : Agente al que llega la relación.
  * `color <R4>` : Un vector de 4 posiciones indicando `(r,g,b,a)`. Si solo se dan 3, se entenderá `a=1`.
  * `label <String>` : Cadena de texto que puede mostrar el agente en su visualización.
  * `label-color <R4>` : Un vector de 4 posiciones indicando `(r,g,b,a)`. Si solo se dan 3, se entenderá `a=1`.
  * `thickness <Num>` : Valor numérico que indica el grosor de la representación visual.
  * `shape <String>` : Una cadena indicando la representación visual del agente.
  * `visible? <Bool>` : Indica si el agente es visible o no en la representación visual.
  * `z_order <Num>` : Establece el orden de dibujado en la representación visual.

]]--

local Rel = class.Relational{

    --[[
        When a new Link is created, some properties are given to it (If we do not have done it yet)
    ]]
    _init = function(self,o)
        local c   = o or {}
        self      = c
        self.type       = c.type or 'standard'
        self.source     = c.source or {}
        self.target     = c.target or {}
        self.color      = c.color or {0.5, 0.5, 0.5, 1}
        self.label      = c.label or ''
        self.label_color= c.color or {1,1,1,1}
        self.thickness  = c.thickness or 1
        self.shape      = c.shape or 'line'
        self.visible    = c.visible or false
        self.z_order    = c.z_order or 0
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


return Rel
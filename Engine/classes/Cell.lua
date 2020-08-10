local class = require 'pl.class'
local Agent = require 'Engine.classes.Agent'


-- * Agentes Estructurales (*cells*):
--   * `id <Num>` : Identificador único que determina al agente.
--   * `pos <Rn>` : Vector n-dimensional que posiciona al agente en un espacio $\Re^n$ (en muchos casos, y atendiendo a la situación actual del GUI, $n=2$). Las primeras posiciones serán `pos=(xcor,ycor,zcor,...)`.
--   * `color <R4>` : Un vector de 4 posiciones indicando `(r,g,b,a)`. Si solo se dan 3, se entenderá `a=1`.
--   * `label <String>` : Cadena de texto que puede mostrar el agente en su visualización.
--   * `label-color <R4>` : Un vector de 4 posiciones indicando `(r,g,b,a)`. Si solo se dan 3, se entenderá `a=1`.
--   * `shape <String>` : Una cadena indicando la representación visual del agente.
--   * `region <pd : Rn -> Bool>` : Función que indica qué región del espacio es la que cubre la celda.
--   * `neighbors <Table>` : Indica las otras cells que son vecinas a ésta.
--   * `visible? <Bool>` : Indica si el agente es visible o no en la representación visual.
--   * `z_order <Num>` : Establece el orden de dibujado en la representación visual.

local Cell = class.Cell(Agent)


--[[
    When a new Patch is created, some properties are given to it (If we do not have done it yet)
]]--
Cell._init = function(self,o)
    self:super()
    local c     = o or {}
    self        = c
    self.pos    = c.pos   or {0,0,0}
    self.label  = c.label or ''
    self.label_color = c.color or {1,1,1,1}
    self.color  = c.color or {0,0,0,1}
    self.shape  = c.xcor or 'square'
    self.region = c.region or {}
    self.neighbors = c.neighbors or {}
    self.visible = c.visible or true
    self.z_order = c.z_order or 0

    return self
end;


Cell.xcor = function(self)
    return self.pos[1]
end

Cell.ycor = function(self)
    return self.pos[2]
end

Cell.zcor = function(self)
    return self.pos[3]
end

return Cell
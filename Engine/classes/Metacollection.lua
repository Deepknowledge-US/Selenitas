local class     = require 'pl.class'
local pretty    = require 'pl.pretty'
local Agent     = require 'Engine.classes.Mobil'
local Link      = require 'Engine.classes.Relational'
local Cell      = require 'Engine.classes.Cell'
local Collection= require 'Engine.classes.Collection'


local CG = class.Collection_Global(Collection)

CG._init = function(self,c)
    self:super()
    return self
end

-- TODO: This is a global collection. This collections will contain 
-- objects of diferent tipes.

return CG
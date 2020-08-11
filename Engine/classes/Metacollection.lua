local class     = require 'Thirdparty.pl.class'
local pretty    = require 'Thirdparty.pl.pretty'
local Agent     = require 'Engine.classes.Mobil'
local Link      = require 'Engine.classes.Relational'
local Cell      = require 'Engine.classes.Cell'
local Collection= require 'Engine.classes.Collection'


local CG = class.MetaCollection(Collection)

CG._init = function(self,c)
    self:super()
    return self
end

-- TODO: This collections will contain objects of different types.

return CG
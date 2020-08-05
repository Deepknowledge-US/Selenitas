local class     = require 'pl.class'
local pretty    = require 'pl.pretty'
local Agent     = require 'Engine.classes.class_agent'
local Link      = require 'Engine.classes.class_link'
local Patch     = require 'Engine.classes.class_patch'
local Collection= require 'Engine.classes.class_collection'


local CG = class.Collection_Global(Collection)

CG._init = function(self,c)
    self:super()
    return self
end

-- TODO: This is a global collection. This collections will contain 
-- objects of diferent tipes.

return CG
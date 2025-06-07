-- renderer/shapes/base.lua
-- Base implementation for shape renderers

local interfaces = require('renderer.interfaces')

local BaseShapeRenderer = {}
BaseShapeRenderer.__index = BaseShapeRenderer

-- Constructor for the base shape renderer
function BaseShapeRenderer.new(shapeType)
  local self = setmetatable({}, BaseShapeRenderer)
  self.shapeType = shapeType
  self.baseMesh = nil
  self.instanceMesh = nil
  self.instanceCount = 0
  return self
end

-- Create the base mesh for this shape
-- This should be overridden by specific shape renderers
function BaseShapeRenderer:createMesh()
  error("createMesh must be implemented by shape renderer")
end

-- Create instance data for a collection of shapes
-- This should be overridden by specific shape renderers
function BaseShapeRenderer:createInstanceData(instances)
  error("createInstanceData must be implemented by shape renderer")
end

-- Render all instances of this shape
-- This should be overridden by specific shape renderers
function BaseShapeRenderer:render(instances, cameraPosition)
  error("render must be implemented by shape renderer")
end

-- Verify this renderer implements the ShapeRenderer interface
assert(interfaces.implements(BaseShapeRenderer, interfaces.ShapeRenderer))

return BaseShapeRenderer

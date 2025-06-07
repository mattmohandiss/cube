-- renderer/billboards/base.lua
-- Base implementation for billboard renderers

local interfaces = require('renderer.interfaces')

local BaseBillboardRenderer = {}
BaseBillboardRenderer.__index = BaseBillboardRenderer

-- Constructor for the base billboard renderer
function BaseBillboardRenderer.new(billboardType)
  local self = setmetatable({}, BaseBillboardRenderer)
  self.billboardType = billboardType
  self.shader = nil
  self.initialized = false
  return self
end

-- Initialize the renderer
function BaseBillboardRenderer:init()
  if self.initialized then return true end
  
  -- This method should be overridden by specific billboard renderers
  -- to load necessary shaders and resources
  
  self.initialized = true
  return true
end

-- Create a mesh for a billboard
-- This should be overridden by specific billboard renderers
function BaseBillboardRenderer:createMesh(data)
  error("createMesh must be implemented by billboard renderer")
end

-- Render a collection of billboard instances
-- This should be overridden by specific billboard renderers
function BaseBillboardRenderer:render(instances, cameraPosition)
  error("render must be implemented by billboard renderer")
end

-- Update shader with camera information
function BaseBillboardRenderer:updateShader(cameraPosition)
  if not self.initialized or not self.shader then return end
  
  -- Default implementation that can be overridden
  self.shader:send("cameraPosition", {
    cameraPosition.x or 0,
    cameraPosition.y or 0,
    cameraPosition.z or 0
  })
end

-- Verify this renderer implements the BillboardRenderer interface
assert(interfaces.implements(BaseBillboardRenderer, interfaces.BillboardRenderer))

return BaseBillboardRenderer

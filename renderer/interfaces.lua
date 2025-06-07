-- renderer/interfaces.lua
-- Defines interfaces for different types of renderers

local interfaces = {}

-- Interface for shape renderers (cubes, etc.)
interfaces.ShapeRenderer = {
  -- Required methods:
  -- createMesh(data) - Create mesh for the shape
  -- createInstanceData(instances) - Create instance data
  -- render(instances, camera) - Render all instances
}

-- Interface for billboard renderers (sprites, etc.)
interfaces.BillboardRenderer = {
  -- Required methods:
  -- createMesh(data) - Create mesh for the billboard
  -- render(instances, camera) - Render all instances
}

-- Function to verify interface implementation
function interfaces.implements(obj, interface)
  for methodName, _ in pairs(interface) do
    if type(obj[methodName]) ~= "function" then
      error("Interface implementation missing method: " .. methodName)
    end
  end
  return true
end

return interfaces

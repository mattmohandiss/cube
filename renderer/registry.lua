-- renderer/registry.lua
-- Registry for managing different renderers

local registry = {
  shapeRenderers = {},
  billboardRenderers = {}
}

-- Register a new shape renderer
function registry.registerShapeRenderer(shapeType, renderer)
  registry.shapeRenderers[shapeType] = renderer
end

-- Register a new billboard renderer
function registry.registerBillboardRenderer(billboardType, renderer)
  registry.billboardRenderers[billboardType] = renderer
end

-- Get a shape renderer by type
function registry.getShapeRenderer(shapeType)
  return registry.shapeRenderers[shapeType]
end

-- Get a billboard renderer by type
function registry.getBillboardRenderer(billboardType)
  return registry.billboardRenderers[billboardType]
end

-- Get all registered shape renderers
function registry.getAllShapeRenderers()
  return registry.shapeRenderers
end

-- Get all registered billboard renderers
function registry.getAllBillboardRenderers()
  return registry.billboardRenderers
end

return registry

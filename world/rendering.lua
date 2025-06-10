-- world/rendering.lua
-- Rendering functionality for the world terrain using GPU-based rendering

local camera = require('camera')
local events = require('events')
local renderer = require('renderer')
local rendererCore = require('renderer.core')

local rendering = {}

-- Initialize the rendering module
function rendering.init()
  -- Set up any rendering-specific configuration
  rendering.viewDistance = 72 -- Maximum distance to render terrain
  
  -- Initialize cache variables for distance-based culling
  rendering.lastCameraX = 0
  rendering.lastCameraY = 0
  rendering.cachedVisibleCubes = {}
  rendering.cacheThreshold = 1.0 -- Distance the camera must move to invalidate cache
  
  -- Initialize renderer
  local rendererInitialized = renderer.init()
  renderer.viewDistance = rendering.viewDistance
  
  -- Check if renderer initialization was successful
  if not rendererInitialized then
    error("GPU rendering is required but not supported on this system")
  end
  
  -- Track outline state
  rendering.outlinesEnabled = true -- Initial state (matches the default in renderer/core.lua)
  
  -- Add toggle for cube outlines
  events.system.toggle_cube_outlines.listen(function()
    rendering.outlinesEnabled = not rendering.outlinesEnabled
    renderer.toggleOutlines(rendering.outlinesEnabled)
    events.debug.world_stats_updated.notify("Cube Outlines", 
                                     rendering.outlinesEnabled and "Enabled" or "Disabled")
  end)
  
  events.debug.world_stats_updated.notify("Terrain View Distance", rendering.viewDistance)
  events.debug.world_stats_updated.notify("Cube Outlines", rendering.outlinesEnabled and "Enabled" or "Disabled")
  events.debug.world_stats_updated.notify("Rendering Mode", "GPU Only")
end

-- Invalidate all caches when world structure changes
function rendering.invalidateCache()
  rendering.cachedVisibleCubes = {}
  rendering.lastCameraX = 0
  rendering.lastCameraY = 0
end

-- Cache settings defined in init()

-- Get a list of visible terrain cubes based on camera position
function rendering.getVisibleCubes(terrainCubes, cameraPosition)
  local cameraX, cameraY = cameraPosition.x, cameraPosition.y
  
  -- Check if we can use the cached result for filtering
  local cameraMoved = math.abs(cameraX - rendering.lastCameraX) > rendering.cacheThreshold or 
                      math.abs(cameraY - rendering.lastCameraY) > rendering.cacheThreshold
  
  if not cameraMoved and #rendering.cachedVisibleCubes > 0 then
    return rendering.cachedVisibleCubes
  end
  
  -- Cache miss, need to recalculate
  local visibleCubes = {}
  local maxDistanceSquared = rendering.viewDistance * rendering.viewDistance
  
  -- Filter cubes by view distance with early exit optimization
  for _, cube in ipairs(terrainCubes) do
    local distanceX = math.abs(cube.x - cameraX)
    
    -- Early exit: if x distance alone exceeds view distance, skip this cube
    if distanceX <= rendering.viewDistance then
      local distanceY = math.abs(cube.y - cameraY)
      
      -- Early exit: if y distance alone exceeds view distance, skip this cube
      if distanceY <= rendering.viewDistance then
        -- Only calculate squared distance if we're within range on both axes
        local distanceSquared = distanceX * distanceX + distanceY * distanceY
        
        if distanceSquared <= maxDistanceSquared then
          table.insert(visibleCubes, cube)
        end
      end
    end
  end
  
  -- Update cache
  rendering.lastCameraX = cameraX
  rendering.lastCameraY = cameraY
  rendering.cachedVisibleCubes = visibleCubes
  
  return visibleCubes
end

-- Render all visible terrain
function rendering.renderTerrain(terrainCubes, cameraPosition)
  -- Get only the cubes that are within view distance
  local visibleCubes = rendering.getVisibleCubes(terrainCubes, cameraPosition)
  
  -- Add shape type to cubes for the renderer
  for _, cube in ipairs(visibleCubes) do
    cube.type = "cube"
  end
  
  -- Use GPU renderer for shapes (cubes)
  local renderedCubes = renderer.renderShapes(visibleCubes, cameraPosition)
  
  -- Update debug information
  events.debug.world_stats_updated.notify("Visible Cubes", #visibleCubes)
  
  return renderedCubes
end

-- Render all visible entities
function rendering.renderEntities(entities, cameraPosition)
  -- If no entities, skip rendering
  if not entities or #entities == 0 then
    events.debug.world_stats_updated.notify("Entities for Rendering", "None")
    return entities
  end
  
  events.debug.world_stats_updated.notify("Entities Count", #entities)
  
  -- Debug output
  for i, entity in ipairs(entities) do
    events.debug.world_stats_updated.notify("Entity " .. i .. " Position", 
      entity.x .. "," .. entity.y .. "," .. entity.z)
    events.debug.world_stats_updated.notify("Entity " .. i .. " State", 
      entity.state or "none")
  end
  
  -- Filter entities by view distance (similar to cubes)
  local visibleEntities = {}
  local maxDistanceSquared = rendering.viewDistance * rendering.viewDistance
  
  for _, entity in ipairs(entities) do
    local distanceX = math.abs(entity.x - cameraPosition.x)
    
    -- Early exit: if x distance alone exceeds view distance, skip
    if distanceX <= rendering.viewDistance then
      local distanceY = math.abs(entity.y - cameraPosition.y)
      
      -- Early exit: if y distance alone exceeds view distance, skip
      if distanceY <= rendering.viewDistance then
        -- Only calculate squared distance if we're within range on both axes
        local distanceSquared = distanceX * distanceX + distanceY * distanceY
        
        if distanceSquared <= maxDistanceSquared then
          -- Add billboard type to entities for the renderer
          entity.type = "entity_billboard"
          table.insert(visibleEntities, entity)
        end
      end
    end
  end
  
  -- Use GPU renderer for billboards (entities)
  local renderedEntities = renderer.renderBillboards(visibleEntities, cameraPosition)
  
  -- Update debug information
  events.debug.world_stats_updated.notify("Visible Entities", #visibleEntities)
  
  return renderedEntities
end

-- Render the entire scene using our centralized rendering approach
function rendering.renderScene(terrainCubes, entities, cameraPosition)
  -- Get only the cubes that are within view distance
  local visibleCubes = rendering.getVisibleCubes(terrainCubes, cameraPosition)
  
  -- Add shape type to cubes for the renderer
  for _, cube in ipairs(visibleCubes) do
    cube.type = "cube"
  end
  
  -- Filter entities by view distance
  local visibleEntities = {}
  local maxDistanceSquared = rendering.viewDistance * rendering.viewDistance
  
  if entities and #entities > 0 then
    for _, entity in ipairs(entities) do
      local distanceX = math.abs(entity.x - cameraPosition.x)
      
      -- Early exit: if x distance alone exceeds view distance, skip
      if distanceX <= rendering.viewDistance then
        local distanceY = math.abs(entity.y - cameraPosition.y)
        
        -- Early exit: if y distance alone exceeds view distance, skip
        if distanceY <= rendering.viewDistance then
          -- Only calculate squared distance if we're within range on both axes
          local distanceSquared = distanceX * distanceX + distanceY * distanceY
          
          if distanceSquared <= maxDistanceSquared then
            -- Add billboard type to entities for the renderer
            entity.type = "entity_billboard"
            table.insert(visibleEntities, entity)
          end
        end
      end
    end
  end
  
  -- Create a scene object with all renderable elements
  local scene = {
    cubes = visibleCubes,
    entities = visibleEntities
  }
  
  -- Use the core renderer to render everything in the correct order
  rendererCore.renderScene(scene, cameraPosition)
  
  -- Update debug information
  events.debug.world_stats_updated.notify("Visible Cubes", #visibleCubes)
  events.debug.world_stats_updated.notify("Visible Entities", #visibleEntities)
  
  return true
end

return rendering

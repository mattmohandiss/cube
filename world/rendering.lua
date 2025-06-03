-- world/rendering.lua
-- Rendering functionality for the world terrain using GPU-based rendering

local camera = require('camera')
local events = require('events')
local renderer = require('renderer')

local rendering = {}

-- Initialize the rendering module
function rendering.init()
  -- Set up any rendering-specific configuration
  rendering.viewDistance = 64 -- Maximum distance to render terrain
  
  -- Initialize cache variables
  rendering.lastCameraX = 0
  rendering.lastCameraY = 0
  rendering.cachedVisibleCubes = {}
  rendering.cacheThreshold = 1.0 -- Distance the camera must move to invalidate cache
  rendering.lastVisibilityUpdateX = 0
  rendering.lastVisibilityUpdateY = 0
  rendering.visibilityUpdateThreshold = 2.0 -- Distance before updating cube face visibility
  
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
  events.toggle_shader_outlines.listen(function()
    rendering.outlinesEnabled = not rendering.outlinesEnabled
    renderer.toggleOutlines(rendering.outlinesEnabled)
    events.world_stats_updated.notify("Cube Outlines", 
                                     rendering.outlinesEnabled and "Enabled" or "Disabled")
  end)
  
  events.world_stats_updated.notify("Terrain View Distance", rendering.viewDistance)
  events.world_stats_updated.notify("Cube Outlines", rendering.outlinesEnabled and "Enabled" or "Disabled")
  events.world_stats_updated.notify("Rendering Mode", "GPU Only")
end

-- Invalidate all caches when world structure changes
function rendering.invalidateCache()
  rendering.cachedVisibleCubes = {}
  rendering.lastCameraX = 0
  rendering.lastCameraY = 0
  rendering.lastVisibilityUpdateX = 0
  rendering.lastVisibilityUpdateY = 0
end

-- Cache settings defined in init()

-- Get a list of visible terrain cubes based on camera position
function rendering.getVisibleCubes(terrainCubes, cameraPosition)
  local cameraX, cameraY = cameraPosition.x, cameraPosition.y
  
  -- Check if camera moved enough to require updating cube face visibility
  local visibilityUpdateNeeded = math.abs(cameraX - rendering.lastVisibilityUpdateX) > rendering.visibilityUpdateThreshold or 
                                 math.abs(cameraY - rendering.lastVisibilityUpdateY) > rendering.visibilityUpdateThreshold
  
  if visibilityUpdateNeeded then
    -- Update which faces are visible for each cube based on neighbors and view edge
    require('world').updateAllCubesVisibility(cameraPosition, rendering.viewDistance)
    
    -- Update last visibility update position
    rendering.lastVisibilityUpdateX = cameraX
    rendering.lastVisibilityUpdateY = cameraY
  end
  
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
  
  -- Use GPU renderer
  local renderedCubes = renderer.render(visibleCubes, cameraPosition)
  
  -- Update debug information
  events.world_stats_updated.notify("Visible Cubes", #visibleCubes)
  
  return renderedCubes
end

return rendering

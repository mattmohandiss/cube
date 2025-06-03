-- world/rendering.lua
-- Rendering functionality for the world terrain

local camera = require('camera')
local events = require('events')

local rendering = {}

-- Initialize the rendering module
function rendering.init()
  -- Set up any rendering-specific configuration
  rendering.viewDistance = 64 -- Maximum distance to render terrain
  
  events.world_stats_updated.notify("Terrain View Distance", rendering.viewDistance)
end

-- Get a list of visible terrain cubes based on camera position
function rendering.getVisibleCubes(terrainCubes, cameraPosition)
  local visibleCubes = {}
  local cameraX, cameraY = cameraPosition.x, cameraPosition.y
  
  -- Filter cubes by view distance
  for _, cube in ipairs(terrainCubes) do
    local distanceX = math.abs(cube.x - cameraX)
    local distanceY = math.abs(cube.y - cameraY)
    
    -- Use squared distance for efficiency (avoid square root)
    local distanceSquared = distanceX * distanceX + distanceY * distanceY
    
    -- Only include cubes within view distance
    if distanceSquared <= rendering.viewDistance * rendering.viewDistance then
      table.insert(visibleCubes, cube)
    end
  end
  
  return visibleCubes
end

-- Render all visible terrain
function rendering.renderTerrain(terrainCubes, cameraPosition)
  -- Get only the cubes that are within view distance
  local visibleCubes = rendering.getVisibleCubes(terrainCubes, cameraPosition)
  
  -- No need to sort here - terrainCubes are already pre-sorted by depth
  -- and visibleCubes maintains that order since we used table.insert
  
  -- Draw each visible cube
  for _, cube in ipairs(visibleCubes) do
    rendering.renderCube(cube)
  end
  
  -- Update debug information
  events.world_stats_updated.notify("Visible Cubes", #visibleCubes)
  
  return visibleCubes
end

-- Render a single terrain cube
function rendering.renderCube(cube)
  -- Use the cube module's draw function
  require('cube').drawCube(cube)
end

return rendering

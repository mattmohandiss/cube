-- camera/init.lua
-- Main camera module that brings together core and projection functionality

local events = require('events')

-- Internal module requires
local core = require('camera.core')
local projection = require('camera.projection')

-- Create the main camera object
local camera = {}

-- Initialize the camera module
function camera.init()
  -- Copy properties from internal modules
  camera.position = core.position
  camera.moveSpeed = core.moveSpeed
  camera.projection = projection  -- Store reference to entire projection module

  -- Emit initial camera settings
  events.debug.world_stats_updated.notify("Camera Tile Size", projection.tileSize)
end

-- CORE FUNCTIONS

-- Move the camera by the given delta
function camera.move(dx, dy)
  local px, py = core.move(dx, dy)
  -- Emit event for camera position update
  events.app.camera_moved.notify(px, py)
end

-- Calculate offset needed to position a world point at a screen point
function camera.getOffset(worldX, worldY, worldZ, screenX, screenY)
  return core.getOffset(worldX, worldY, worldZ, screenX, screenY, camera.iso)
end

-- PROJECTION FUNCTIONS

-- Function to project 3D coordinates to 2D isometric coordinates
function camera.iso(x, y, z)
  local sx, sy, projFactor = projection.iso(x, y, z, camera.position)
  -- Emit event for debug info
  events.app.projection_factor_updated.notify(projFactor)
  return sx, sy
end

-- Calculate isometric depth for sorting
-- This is kept for compatibility with existing code
function camera.calculateIsoDepth(x, y, z)
  -- This depth formula prioritizes x and y equally, with z having double impact
  -- Same formula as used in the vertex shader for depth calculations
  return - (x + y + 2*z)
end

-- Zoom the camera by adjusting the tile size
function camera.zoom(zoomDelta)
  local success, newZoom = projection.zoom(zoomDelta)
  
  if success then
    -- Emit event for camera zoom update
    events.app.camera_zoomed.notify(newZoom)
  end
  
  return success, newZoom
end

return camera

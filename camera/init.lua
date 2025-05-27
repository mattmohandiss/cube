-- camera/init.lua
-- Main camera module that brings together core, projection, and rendering functionality

local events = require('events')

-- Internal module requires
local core = require('camera.core')
local projection = require('camera.projection')
local rendering = require('camera.rendering')

-- Create the main camera object
local camera = {}

-- Initialize the camera module
function camera.init()
  -- Copy properties from internal modules
  camera.position = core.position
  camera.moveSpeed = core.moveSpeed
  camera.tileSize = projection.tileSize

  -- Emit initial camera settings
  events.world_stats_updated.notify("Camera Tile Size", camera.tileSize)
end

-- CORE FUNCTIONS

-- Get screen center coordinates
function camera.getScreenCenter()
  return core.getScreenCenter()
end

-- Move the camera by the given delta
function camera.move(dx, dy)
  local px, py = core.move(dx, dy)
  -- Emit event for camera position update
  events.camera_moved.notify(px, py)
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
  events.projection_factor_updated.notify(projFactor)
  return sx, sy
end

-- Function to project 3D corners to 2D
function camera.projectCorners(corners3D)
  return projection.projectCorners(corners3D, camera.iso)
end

-- RENDERING FUNCTIONS

-- Sort objects by their isometric depth (used for painter's algorithm)
function camera.sortByDepth(objects)
  return rendering.sortByDepth(objects)
end

-- Calculate depth for a face's center point
function camera.calculateFaceDepth(corners3D, faceVertices)
  return rendering.calculateFaceDepth(corners3D, faceVertices)
end

-- Draw a polygon with the specified vertices and color
function camera.drawPolygon(vertices, color, outlined)
  rendering.drawPolygon(vertices, color, outlined)
end

-- Save and restore color state
function camera.withColor(func)
  rendering.withColor(func)
end

-- Calculate isometric depth for sorting
function camera.calculateIsoDepth(x, y, z)
  return rendering.calculateIsoDepth(x, y, z)
end

return camera

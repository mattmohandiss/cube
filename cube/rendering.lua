-- cube/rendering.lua
-- Cube rendering and display functionality

local events = require('events')
local geometry = require('cube.geometry')

local rendering = {}

-- Store references to other modules
local camera

-- Initialize with dependencies
function rendering.init()
  camera = require('camera')
end

-- Brightness multipliers per face
rendering.faceBrightness = { 1.0, 0.5, 0.8, 0.6, 0.5, 0.7 }

-- Apply brightness to a base RGB color
function rendering.getFaceColor(base, fi)
  local b = rendering.faceBrightness[fi]
  return { base[1] * b, base[2] * b, base[3] * b }
end

-- Draw one face
function rendering.drawFace(proj, fi, baseColor)
  local verts = geometry.faces[fi]
  local col = rendering.getFaceColor(baseColor, fi)
  
  -- Extract the 2D points for this face
  local facePoints = {
    proj[verts[1]],
    proj[verts[2]],
    proj[verts[3]],
    proj[verts[4]]
  }
  
  -- Use the camera to draw the polygon
  camera.drawPolygon(facePoints, col, true)
end

-- Draw a cube with color wrapper
function rendering.drawCube(obj)
  camera.withColor(function()
    -- Use precomputed corners3D and visibleFaces from the cube object
    rendering.draw(obj.x, obj.y, obj.z, obj.color, obj.corners3D, obj.visibleFaces)
  end)
end

-- Draw a cube at world (x,y,z) using precomputed geometry
function rendering.draw(x, y, z, baseColor, corners3D, visibleFaces)
  baseColor = baseColor or { 1, 1, 1 }
  
  -- Project corners to 2D screen space
  local projected = camera.projectCorners(corners3D)
  
  -- Use precomputed visible faces, just calculate depths
  local toDraw = {}
  for _, faceInfo in ipairs(visibleFaces) do
    local face = geometry.faces[faceInfo.index]
    local depth = camera.calculateFaceDepth(corners3D, face)
    table.insert(toDraw, { idx = faceInfo.index, depth = depth })
  end

  -- Painter's algorithm: draw farther faces first
  table.sort(toDraw, function(a, b) return a.depth > b.depth end)

  -- Draw sorted faces
  for _, entry in ipairs(toDraw) do
    rendering.drawFace(projected, entry.idx, baseColor)
  end
end

return rendering

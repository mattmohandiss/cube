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

-- Draw one face, plus debug info and an outline
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
  
  -- Emit face info debug event
  local parts = {}
  for _, v in ipairs(verts) do parts[#parts + 1] = tostring(v) end
  -- Check if the event exists, and if not, just don't emit it
  if events.cube_face_info then
    events.cube_face_info.notify(fi, table.concat(parts, ","))
  end
end

-- Log each vertex
function rendering.logVertexDebugInfo(proj)
  for i = 1, 8 do
    local p = proj[i]
    -- Check if the event exists, and if not, just don't emit it
    if events.cube_vertex_info then
      events.cube_vertex_info.notify(i, string.format("(%.1f,%.1f)", p[1], p[2]))
    end
  end
end

-- Draw a cube with color wrapper
function rendering.drawCube(obj)
  camera.withColor(function()
    rendering.draw(obj.x, obj.y, obj.z, obj.color)
  end)
end

-- Draw a cube at world (x,y,z)
function rendering.draw(x, y, z, baseColor)
  -- Generate 3D corners and project them to 2D
  local corners3D = geometry.getCorners3D(x, y, z)
  local projected = camera.projectCorners(corners3D)
  baseColor = baseColor or { 1, 1, 1 }

  -- Collect only faces whose normals face the camera
  local toDraw = {}
  for idx, face in ipairs(geometry.faces) do
    if geometry.isFaceVisible(idx, corners3D) then
      local depth = camera.calculateFaceDepth(corners3D, face)
      table.insert(toDraw, { idx = idx, depth = depth })
    end
  end

  -- Painter's algorithm: draw farther faces first
  table.sort(toDraw, function(a, b) return a.depth > b.depth end)

  -- Draw sorted faces
  for _, entry in ipairs(toDraw) do
    rendering.drawFace(projected, entry.idx, baseColor)
  end

  -- Debug: log vertex positions
  rendering.logVertexDebugInfo(projected)
end

return rendering

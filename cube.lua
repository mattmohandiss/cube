-- cube.lua
-- Module to encapsulate cube drawing functionality with dynamic face depth-sorting

local camera        = require('camera')
local dbg           = require('dbg')
local cube          = {}

-- Cube corner offsets (x, y, z)
cube.cornerOffsets  = {
  { -0.5, -0.5, 0.5 }, -- 1 top-front-left
  { 0.5,  -0.5, 0.5 }, -- 2 top-front-right
  { 0.5,  0.5,  0.5 }, -- 3 top-back-right
  { -0.5, 0.5,  0.5 }, -- 4 top-back-left
  { -0.5, 0.5,  -0.5 }, -- 5 bottom-back-left
  { 0.5,  0.5,  -0.5 }, -- 6 bottom-back-right
  { 0.5,  -0.5, -0.5 }, -- 7 bottom-front-right
  { -0.5, -0.5, -0.5 }, -- 8 bottom-front-left
}

-- Faces as indices into cornerOffsets
cube.faces          = {
  { 1, 2, 3, 4 }, -- top
  { 8, 7, 6, 5 }, -- bottom
  { 1, 2, 7, 8 }, -- front
  { 2, 3, 6, 7 }, -- right
  { 3, 4, 5, 6 }, -- back
  { 4, 1, 8, 5 }, -- left
}

-- Brightness multipliers per face
cube.faceBrightness = { 1.0, 0.5, 0.8, 0.6, 0.5, 0.7 }

-- 3D → camera-space coords
function cube.getCorners3D(x, y, z)
  local out = {}
  for i, off in ipairs(cube.cornerOffsets) do
    out[i] = { x + off[1], y + off[2], z + off[3] }
  end
  return out
end

-- Apply brightness to a base RGB color
function cube.getFaceColor(base, fi)
  local b = cube.faceBrightness[fi]
  return { base[1] * b, base[2] * b, base[3] * b }
end

-- Dynamic backface culling with correct isometric view direction
function cube.isFaceVisible(faceIndex, corners3D)
  local f = cube.faces[faceIndex]
  local p1, p2, p3 = corners3D[f[1]], corners3D[f[2]], corners3D[f[3]]

  -- build two edge vectors
  local ux, uy, uz = p2[1] - p1[1], p2[2] - p1[2], p2[3] - p1[3]
  local vx, vy, vz = p3[1] - p2[1], p3[2] - p2[2], p3[3] - p2[3]

  -- face normal (cross product)
  local nx = uy * vz - uz * vy
  local ny = uz * vx - ux * vz
  local nz = ux * vy - uy * vx

  -- Isometric view direction (standard isometric viewing angle)
  -- For typical isometric view, camera looks from top-right-front
  local dx, dy, dz = 1, 1, -1

  -- visible if normal points "toward" camera
  return (nx * dx + ny * dy + nz * dz) < 0
end

-- Draw one face, plus debug info and an outline
function cube.drawFace(proj, fi, baseColor)
  local verts = cube.faces[fi]
  local col   = cube.getFaceColor(baseColor, fi)

  love.graphics.setColor(col)
  love.graphics.polygon("fill",
    proj[verts[1]][1], proj[verts[1]][2],
    proj[verts[2]][1], proj[verts[2]][2],
    proj[verts[3]][1], proj[verts[3]][2],
    proj[verts[4]][1], proj[verts[4]][2]
  )

  -- outline
  love.graphics.setColor(0, 0, 0, 0.2)
  love.graphics.setLineWidth(1)
  love.graphics.polygon("line",
    proj[verts[1]][1], proj[verts[1]][2],
    proj[verts[2]][1], proj[verts[2]][2],
    proj[verts[3]][1], proj[verts[3]][2],
    proj[verts[4]][1], proj[verts[4]][2]
  )

  -- safe debug string
  local parts = {}
  for _, v in ipairs(verts) do parts[#parts + 1] = tostring(v) end
  dbg.setValue("Face " .. fi, table.concat(parts, ","))
end

-- Log each vertex
function cube.logVertexDebugInfo(proj)
  for i = 1, 8 do
    local p = proj[i]
    dbg.setValue("V" .. i, string.format("(%.1f,%.1f)", p[1], p[2]))
  end
end

-- Draw a cube at world (x,y,z)
function cube.draw(x, y, z, baseColor)
  -- Generate 3D corners and project them to 2D
  local corners3D = cube.getCorners3D(x, y, z)
  local projected = camera.projectCorners(corners3D)
  baseColor = baseColor or { 1, 1, 1 }

  -- Collect only faces whose normals face the camera
  local toDraw = {}
  for idx, face in ipairs(cube.faces) do
    if cube.isFaceVisible(idx, corners3D) then
      -- Calculate center point of the face
      local centerX, centerY, centerZ = 0, 0, 0
      for _, v in ipairs(face) do
        centerX = centerX + corners3D[v][1]
        centerY = centerY + corners3D[v][2]
        centerZ = centerZ + corners3D[v][3]
      end
      centerX = centerX / #face
      centerY = centerY / #face
      centerZ = centerZ / #face
      
      -- Use same depth formula as in main.lua for consistency
      local depth = centerX + centerY - (centerZ * 2)
      table.insert(toDraw, { idx = idx, depth = depth })
    end
  end

  -- Painter's algorithm: draw farther faces first
  table.sort(toDraw, function(a, b) return a.depth > b.depth end)

  -- Draw sorted faces
  for _, entry in ipairs(toDraw) do
    cube.drawFace(projected, entry.idx, baseColor)
  end

  -- Debug: log vertex positions
  cube.logVertexDebugInfo(projected)
end

-- Factory & convenience draw
function cube.new(x, y, z, color)
  return { x = x or 0, y = y or 0, z = z or 0, color = color or { 1, 1, 1 } }
end

function cube.drawCube(obj)
  local r, g, b, a = love.graphics.getColor()
  cube.draw(obj.x, obj.y, obj.z, obj.color)
  love.graphics.setColor(r, g, b, a)
end

return cube

-- cube/geometry.lua
-- Cube geometry definitions and calculations

local geometry = {}

-- Cube corner offsets (x, y, z)
geometry.cornerOffsets = {
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
geometry.faces = {
  { 1, 2, 3, 4 }, -- top
  { 8, 7, 6, 5 }, -- bottom
  { 1, 2, 7, 8 }, -- front
  { 2, 3, 6, 7 }, -- right
  { 3, 4, 5, 6 }, -- back
  { 4, 1, 8, 5 }, -- left
}

-- 3D → camera-space coords
function geometry.getCorners3D(x, y, z)
  local out = {}
  for i, off in ipairs(geometry.cornerOffsets) do
    out[i] = { x + off[1], y + off[2], z + off[3] }
  end
  return out
end

-- Dynamic backface culling with correct isometric view direction
function geometry.isFaceVisible(faceIndex, corners3D)
  local f = geometry.faces[faceIndex]
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

return geometry

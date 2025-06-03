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

-- Note: The corner computation function has been removed
-- This is now handled by the GPU in the shader

-- Note: The backface culling function has been removed
-- This is now handled by the GPU in the shader

return geometry

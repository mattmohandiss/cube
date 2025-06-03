-- camera/projection.lua
-- 3D to 2D projection functions

local projection = {}

-- Tile dimensions for isometric rendering
projection.tileSize = 15

-- Function to project 3D coordinates to 2D isometric coordinates
function projection.iso(x, y, z, cameraPosition)
  -- Apply camera offset
  local wx = x - cameraPosition.x
  local wy = y - cameraPosition.y

  local sx = (wx - wy) * (projection.tileSize / 2)
  local sy = (wx + wy) * (projection.tileSize / 4) - z * (projection.tileSize / 2)

  -- Projection factor for debug info
  local projectionFactor = projection.tileSize / 2

  -- Center on screen
  local screenWidth, screenHeight = love.graphics.getDimensions()
  sx = sx + screenWidth / 2
  sy = sy + screenHeight / 2

  return sx, sy, projectionFactor
end

-- Function to project 3D corners to 2D
function projection.projectCorners(corners3D, iso)
  local pts2D = {}
  for i, p in ipairs(corners3D) do
    pts2D[i] = { iso(p[1], p[2], p[3]) }
  end
  return pts2D
end

return projection

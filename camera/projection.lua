-- camera/projection.lua
-- 3D to 2D projection functions

local projection = {}

-- Tile dimensions for isometric rendering
projection.tileSize = 16
projection.minTileSize = 10  -- Minimum zoom level (zoomed out)
projection.maxTileSize = 75  -- Maximum zoom level (zoomed in)

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


-- Function to adjust zoom level by changing tile size
-- Returns success (boolean) and the new tileSize value
function projection.zoom(zoomDelta)
    -- Calculate new tile size with the zoom delta
    local newTileSize = projection.tileSize + zoomDelta

    -- Enforce min and max zoom limits
    if newTileSize < projection.minTileSize then
        newTileSize = projection.minTileSize
    elseif newTileSize > projection.maxTileSize then
        newTileSize = projection.maxTileSize
    end
    
    -- Only update if actually changed
    if newTileSize ~= projection.tileSize then
        projection.tileSize = newTileSize
        return true, projection.tileSize
    end
    
    return false, projection.tileSize
end

return projection

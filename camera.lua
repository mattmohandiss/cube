local camera = {}
local dbg

-- Lazy load debug to avoid circular dependency
local function getDbg()
  if not dbg then
    dbg = require('dbg')
  end
  return dbg
end

-- Camera position and settings
camera.position = { x = 0, y = 0 }
camera.moveSpeed = 0.5 -- How much to move per keypress

-- Tile dimensions for isometric rendering
camera.tileSize = 100

-- Function to project 3D coordinates to 2D isometric coordinates
function camera.iso(x, y, z)
  -- Apply camera offset
  local wx = x - camera.position.x
  local wy = y - camera.position.y

  local sx = (wx - wy) * (camera.tileSize / 2)
  local sy = (wx + wy) * (camera.tileSize / 4) - z * (camera.tileSize / 2)


  -- Add debug value for the z-projection
  local debugModule = getDbg()
  debugModule.setValue("Projection Factor", camera.tileSize / 2)

  -- Center on screen
  local screenWidth, screenHeight = love.graphics.getDimensions()
  sx = sx + screenWidth / 2
  sy = sy + screenHeight / 2

  return sx, sy
end

-- Function to project 3D corners to 2D
function camera.projectCorners(corners3D)
  local pts2D = {}
  for i, p in ipairs(corners3D) do
    pts2D[i] = { camera.iso(p[1], p[2], p[3]) }
  end
  return pts2D
end

-- Get screen center coordinates
function camera.getScreenCenter()
  local screenWidth, screenHeight = love.graphics.getDimensions()
  return screenWidth / 2, screenHeight / 2
end

-- Calculate offset needed to position a world point at a screen point
function camera.getOffset(worldX, worldY, worldZ, screenX, screenY)
  -- Project the world point to screen coordinates
  local projectedX, projectedY = camera.iso(worldX, worldY, worldZ)

  -- Calculate the difference between where the point would be drawn and screen target
  local offsetX = screenX - projectedX
  local offsetY = screenY - projectedY

  return offsetX, offsetY
end

-- Move the camera by the given delta
function camera.move(dx, dy)
  camera.position.x = camera.position.x + dx
  camera.position.y = camera.position.y + dy

  -- Update debug info
  local debugModule = getDbg()
  debugModule.setValue("Camera Position", string.format("x=%.2f, y=%.2f", camera.position.x, camera.position.y))
end

-- Handle keyboard input for camera movement
function camera.handleInput(dt)
  if love.keyboard.isDown("up") then camera.move(0, -camera.moveSpeed * dt) end
  if love.keyboard.isDown("down") then camera.move(0, camera.moveSpeed * dt) end
  if love.keyboard.isDown("left") then camera.move(-camera.moveSpeed * dt, 0) end
  if love.keyboard.isDown("right") then camera.move(camera.moveSpeed * dt, 0) end
end

return camera

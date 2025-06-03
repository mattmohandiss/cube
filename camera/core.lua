-- camera/core.lua
-- Core camera functionality: position, movement, and viewport

local core = {}

-- Camera position and settings
core.position = { x = 0, y = 0 }
core.moveSpeed = 10 -- How much to move per keypress

-- Move the camera by the given delta
function core.move(dx, dy)
  core.position.x = core.position.x + dx
  core.position.y = core.position.y + dy

  -- This will be returned from init.lua as camera.moved event
  return core.position.x, core.position.y
end

-- Calculate offset needed to position a world point at a screen point
function core.getOffset(worldX, worldY, worldZ, screenX, screenY, iso)
  -- Project the world point to screen coordinates using the provided iso function
  local projectedX, projectedY = iso(worldX, worldY, worldZ)

  -- Calculate the difference between where the point would be drawn and screen target
  local offsetX = screenX - projectedX
  local offsetY = screenY - projectedY

  return offsetX, offsetY
end

return core

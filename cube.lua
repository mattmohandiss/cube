-- Cube module to encapsulate cube drawing functionality
local camera = require('camera')
local dbg = require('dbg')
local cube = {}

-- Function to get 3D corner coordinates for a cube at position (x, y, z)
function cube.getCorners3D(x, y, z)
  local corners = {
    {x-0.5, y-0.5, z+1},  -- top‐front‐left
    {x+0.5, y-0.5, z+1},  -- top‐front‐right
    {x+0.5, y+0.5, z+1},  -- top‐back‐right
    {x-0.5, y+0.5, z+1},  -- top‐back‐left
    {x-0.5, y+0.5, z},    -- bottom‐back‐left
    {x+0.5, y+0.5, z},    -- bottom‐back‐right
    {x+0.5, y-0.5, z},    -- bottom‐front‐right
    {x-0.5, y-0.5, z},    -- bottom‐front‐left
  }
  return corners
end

-- Function to draw a cube at position (x, y, z) with a specific color
function cube.draw(x, y, z, color)
  local corners3D = cube.getCorners3D(x, y, z)
  local c = camera.projectCorners(corners3D)
  
  color = color or {1, 1, 1}  -- Default to white if no color specified
  
  -- top face (1,2,3,4) - 100% brightness
  local topColor = {color[1], color[2], color[3]}
  love.graphics.setColor(topColor)
  love.graphics.polygon("fill", c[1][1],c[1][2], c[2][1],c[2][2],
                               c[3][1],c[3][2], c[4][1],c[4][2])

  -- left face (4,3,6,5) - 80% brightness
  local leftColor = {color[1] * 0.8, color[2] * 0.8, color[3] * 0.8}
  love.graphics.setColor(leftColor)
  love.graphics.polygon("fill", c[4][1],c[4][2], c[3][1],c[3][2],
                               c[6][1],c[6][2], c[5][1],c[5][2])

  -- right face (2,7,6,3) - 60% brightness
  local rightColor = {color[1] * 0.6, color[2] * 0.6, color[3] * 0.6}
  love.graphics.setColor(rightColor)
  love.graphics.polygon("fill", c[2][1],c[2][2], c[7][1],c[7][2],
                               c[6][1],c[6][2], c[3][1],c[3][2])
end

-- Create a new cube at the specified coordinates
function cube.new(x, y, z, color)
  return {
    x = x or 0,
    y = y or 0,
    z = z or 0,
    color = color or {1, 1, 1}  -- Default to white
  }
end

-- Draw an existing cube object
function cube.drawCube(cubeObj)
  -- Save current color
  local r, g, b, a = love.graphics.getColor()
  
  -- Draw the cube with its color
  cube.draw(cubeObj.x, cubeObj.y, cubeObj.z, cubeObj.color)
  
  -- Restore color
  love.graphics.setColor(r, g, b, a)
end

return cube

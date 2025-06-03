-- cube/core.lua
-- Core cube functionality: properties, creation, and initialization

local core = {}

-- Store references to other modules
local camera
local geometry

-- Initialize the cube module
function core.init()
  -- Load required modules
  camera = require('camera')
  geometry = require('cube.geometry')
end

-- Factory method for creating new cubes
function core.new(x, y, z, color)
  -- Default values
  x = x or 0
  y = y or 0
  z = z or 0
  color = color or { 1, 1, 1 }
  
  -- Add precomputed depth for sorting using the camera's function
  local depth = camera.calculateIsoDepth(x, y, z)
  
  -- With GPU rendering, we only need essential properties
  local cube = { 
    x = x, 
    y = y, 
    z = z, 
    color = color,
    depth = depth  -- Keep depth for sorting
  }
  
  return cube
end

-- Note: Face visibility function has been removed
-- as this is now handled by the GPU

return core

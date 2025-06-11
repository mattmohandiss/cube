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
  
  -- With GPU rendering, we only need essential properties
  -- Depth sorting is now handled entirely by the GPU
  local cube = { 
    x = x, 
    y = y, 
    z = z, 
    color = color,
    -- logicalZ = z   -- For compatibility with existing code, z is now the logical position
  }
  
  return cube
end

-- Note: Face visibility function has been removed
-- as this is now handled by the GPU

return core

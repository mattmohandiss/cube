-- cube/core.lua
-- Core cube functionality: properties, creation, and initialization

local core = {}

-- Store references to other modules
local camera

-- Initialize the cube module
function core.init()
  -- Load required modules
  camera = require('camera')
end

-- Factory method for creating new cubes
function core.new(x, y, z, color)
  -- Add precomputed depth for sorting
  local depth = -(x + y + 2*z)  -- Same formula as in camera.calculateIsoDepth
  
  return { 
    x = x or 0, 
    y = y or 0, 
    z = z or 0, 
    color = color or { 1, 1, 1 },
    depth = depth  -- Store precomputed depth
  }
end

return core

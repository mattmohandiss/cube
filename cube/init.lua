-- cube/init.lua
-- Main cube module that brings together core and geometry functionality

local events = require('events')

-- Internal module requires
local core = require('cube.core')
local geometry = require('cube.geometry')

-- Create the main cube object
local cube = {}

-- Initialize the cube module
function cube.init()
  -- Initialize internal modules
  core.init()
  
  -- Expose core functions
  cube.new = core.new
  
  -- Expose geometry properties and functions
  cube.cornerOffsets = geometry.cornerOffsets
  cube.faces = geometry.faces
end

return cube

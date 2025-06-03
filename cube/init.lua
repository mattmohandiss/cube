-- cube/init.lua
-- Main cube module that brings together core, geometry, and rendering functionality

local events = require('events')

-- Internal module requires
local core = require('cube.core')
local geometry = require('cube.geometry')
local rendering = require('cube.rendering')

-- Create the main cube object
local cube = {}

-- Initialize the cube module
function cube.init()
  -- Initialize internal modules
  core.init()
  rendering.init()
  
  -- Expose core functions
  cube.new = core.new
  cube.setVisibleFaces = core.setVisibleFaces
  
  -- Expose geometry properties and functions
  cube.cornerOffsets = geometry.cornerOffsets
  cube.faces = geometry.faces
  cube.getCorners3D = geometry.getCorners3D
  cube.isFaceVisible = geometry.isFaceVisible
  
  -- Expose rendering properties and functions
  cube.faceBrightness = rendering.faceBrightness
  cube.getFaceColor = rendering.getFaceColor
  cube.draw = rendering.draw
  cube.drawCube = rendering.drawCube
  cube.drawFace = rendering.drawFace
end

return cube

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
  
  -- Precompute 3D corner positions
  local corners3D = {}
  for i, offset in ipairs(geometry.cornerOffsets) do
    corners3D[i] = { 
      x + offset[1], 
      y + offset[2], 
      z + offset[3] 
    }
  end
  
  -- Get potentially visible faces based on camera angle
  local cameraVisibleFaces = {}
  for faceIndex, face in ipairs(geometry.faces) do
    if geometry.isFaceVisible(faceIndex, corners3D) then
      table.insert(cameraVisibleFaces, {
        index = faceIndex,
        vertices = face
      })
    end
  end
  
  local cube = { 
    x = x, 
    y = y, 
    z = z, 
    color = color,
    depth = depth,  -- Store precomputed depth
    corners3D = corners3D,  -- Store precomputed 3D corners
    visibleFaces = cameraVisibleFaces,  -- Store precomputed visible faces
    allVisibleFaces = cameraVisibleFaces  -- Keep a copy of all potentially visible faces
  }
  
  return cube
end

-- Set which faces should be visible based on neighbors and view circle
function core.setVisibleFaces(cubeObj, neighbors, isAtViewEdge)
  -- neighbors: table with keys "top", "bottom", "front", "back", "left", "right"
  -- isAtViewEdge: table with flags for which directions are at view edge
  
  -- Start with faces that are visible based on camera angle
  local visibleFaces = {}
  
  -- Face indices: 1=top, 2=bottom, 3=front, 4=right, 5=back, 6=left
  for _, faceInfo in ipairs(cubeObj.allVisibleFaces) do
    local faceIndex = faceInfo.index
    
    -- Check if this face should be hidden by a neighbor
    local shouldHide = false
    
    if faceIndex == 1 and neighbors.top then 
      shouldHide = true
    elseif faceIndex == 2 and neighbors.bottom then 
      shouldHide = true
    elseif faceIndex == 3 and neighbors.front then 
      shouldHide = true
    elseif faceIndex == 4 and neighbors.right then 
      shouldHide = true
    elseif faceIndex == 5 and neighbors.back then 
      shouldHide = true
    elseif faceIndex == 6 and neighbors.left then 
      shouldHide = true
    end
    
    -- If at view edge, show faces that point outward
    if shouldHide and isAtViewEdge then
      -- Show faces that point outward from the view distance
      if (faceIndex == 3 and isAtViewEdge.front) or
         (faceIndex == 4 and isAtViewEdge.right) or
         (faceIndex == 5 and isAtViewEdge.back) or
         (faceIndex == 6 and isAtViewEdge.left) then
        shouldHide = false
      end
      
      -- Also show side faces for cubes at the edge corners
      if isAtViewEdge.showSides and (faceIndex == 4 or faceIndex == 6) then
        shouldHide = false
      end
    end
    
    if not shouldHide then
      table.insert(visibleFaces, {
        index = faceIndex,
        vertices = faceInfo.vertices
      })
    end
  end
  
  cubeObj.visibleFaces = visibleFaces
  return cubeObj
end

return core

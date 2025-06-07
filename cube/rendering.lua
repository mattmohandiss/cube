-- cube/rendering.lua
-- Cube-specific renderer implementation

local BaseShapeRenderer = require('renderer.shapes.base')
local geometry = require('cube.geometry')
local rendererCore = require('renderer.core')
local dbg = require('dbg')
local events = require('events')

-- Create the cube renderer
local CubeRenderer = setmetatable({}, { __index = BaseShapeRenderer })
CubeRenderer.__index = CubeRenderer

-- Constructor
function CubeRenderer.new()
  local self = BaseShapeRenderer.new("cube")
  return setmetatable(self, CubeRenderer)
end

-- Initialize the cube renderer
function CubeRenderer:init()
  if self.initialized then return self end
  
  -- Load cube shader
  self.shader = rendererCore.loadShader("cube", 
    "renderer/shaders/cube/vertex.glsl", 
    "renderer/shaders/cube/fragment.glsl")
  
  -- Get tile size from camera module to ensure consistency
  local camera = require('camera')
  
  -- Set default uniform values
  self.shader:send("tileSize", camera.tileSize) -- Use camera's tile size
  self.shader:send("showDebugInfo", false)
  self.shader:send("enableOutlines", true) -- Enable cube outlines by default
  
  -- Create base cube mesh
  self.baseMesh = self:createMesh()
  
  -- Initialize instance tracking
  self.instanceMesh = nil
  self.instanceCount = 0
  
  -- Cube renderer is now initialized
  self.initialized = true
  
  -- Register for debug toggle
  events.debug_toggle.listen(function(isVisible)
    rendererCore.toggleShaderDebug(self.shader, isVisible)
  end)
  
  -- Add debug information
  dbg.setValue("GPU Cube Rendering", "Enabled")
  events.world_stats_updated.notify("GPU Cube Rendering", "Enabled")
  
  return self
end

-- Create a mesh for a cube
function CubeRenderer:createMesh()
  -- Define the vertices for all faces
  local vertices = {}
  
  -- Loop through each face of the cube
  for faceIndex, faceVertices in ipairs(geometry.faces) do
    -- Get face normal
    local normal = self:getFaceNormal(faceIndex)
    
    -- Each face is drawn as 2 triangles (6 vertices)
    -- Triangle 1: v1, v2, v3
    table.insert(vertices, {
      geometry.cornerOffsets[faceVertices[1]][1],
      geometry.cornerOffsets[faceVertices[1]][2],
      geometry.cornerOffsets[faceVertices[1]][3],
      normal[1], normal[2], normal[3],
      faceIndex,
      0.0, 0.0  -- Bottom-left texture coordinate
    })
    table.insert(vertices, {
      geometry.cornerOffsets[faceVertices[2]][1],
      geometry.cornerOffsets[faceVertices[2]][2],
      geometry.cornerOffsets[faceVertices[2]][3],
      normal[1], normal[2], normal[3],
      faceIndex,
      1.0, 0.0  -- Bottom-right texture coordinate
    })
    table.insert(vertices, {
      geometry.cornerOffsets[faceVertices[3]][1],
      geometry.cornerOffsets[faceVertices[3]][2],
      geometry.cornerOffsets[faceVertices[3]][3],
      normal[1], normal[2], normal[3],
      faceIndex,
      1.0, 1.0  -- Top-right texture coordinate
    })
    
    -- Triangle 2: v1, v3, v4
    table.insert(vertices, {
      geometry.cornerOffsets[faceVertices[1]][1],
      geometry.cornerOffsets[faceVertices[1]][2],
      geometry.cornerOffsets[faceVertices[1]][3],
      normal[1], normal[2], normal[3],
      faceIndex,
      0.0, 0.0  -- Bottom-left texture coordinate (same as first triangle)
    })
    table.insert(vertices, {
      geometry.cornerOffsets[faceVertices[3]][1],
      geometry.cornerOffsets[faceVertices[3]][2],
      geometry.cornerOffsets[faceVertices[3]][3],
      normal[1], normal[2], normal[3],
      faceIndex,
      1.0, 1.0  -- Top-right texture coordinate (same as first triangle)
    })
    table.insert(vertices, {
      geometry.cornerOffsets[faceVertices[4]][1],
      geometry.cornerOffsets[faceVertices[4]][2],
      geometry.cornerOffsets[faceVertices[4]][3],
      normal[1], normal[2], normal[3],
      faceIndex,
      0.0, 1.0  -- Top-left texture coordinate
    })
  end
  
  -- Define the vertex format for our mesh
  local vertexFormat = {
    {"VertexPosition", "float", 3},  -- x, y, z
    {"VertexNormal", "float", 3},    -- nx, ny, nz
    {"VertexFaceIndex", "float", 1}, -- face index (1-6)
    {"VertexTexCoord", "float", 2}   -- u, v texture coordinates for wireframe
  }
  
  -- Create the mesh
  local mesh = love.graphics.newMesh(vertexFormat, vertices, "triangles", "static")
  return mesh
end

-- Get the normal for a specific face
function CubeRenderer:getFaceNormal(faceIndex)
  -- Pre-defined normals for each face
  -- These match the order in geometry.faces
  local normals = {
    {0, 0, 1},    -- top (1)
    {0, 0, -1},   -- bottom (2)
    {0, -1, 0},   -- front (3)
    {1, 0, 0},    -- right (4)
    {0, 1, 0},    -- back (5)
    {-1, 0, 0}    -- left (6)
  }
  
  return normals[faceIndex]
end

-- Create instance data for an array of cubes
function CubeRenderer:createInstanceData(cubes)
  -- Create a table to hold instance data
  local instanceData = {}
  
  for _, cube in ipairs(cubes) do
    -- With GPU rendering, all faces are potentially visible
    -- Set all bits to 1 (63 = all 6 face bits set)
    local visibilityFlags = 63  -- 2^0 + 2^1 + 2^2 + 2^3 + 2^4 + 2^5
    
    -- Add this cube's instance data
    table.insert(instanceData, {
      cube.x, cube.y, cube.z,              -- InstancePosition
      cube.color[1], cube.color[2], cube.color[3], 1.0,  -- InstanceColor
      visibilityFlags                       -- InstanceVisibility
    })
  end
  
  -- Create a mesh with the instance data
  local format = {
    {"InstancePosition", "float", 3},
    {"InstanceColor", "float", 4},
    {"InstanceVisibility", "float", 1}
  }
  
  -- Create new instance mesh
  local instanceMesh = love.graphics.newMesh(format, instanceData, nil, "dynamic")
  return instanceMesh, #instanceData
end

-- Render all cube instances
function CubeRenderer:render(cubes, cameraPosition)
  if not self.initialized then
    self:init()
  end
  
  if not self.baseMesh then
    error("Cube renderer not properly initialized")
  end
  
  -- Update shader uniforms
  rendererCore.updateShaderCamera(self.shader, cameraPosition, self.viewDistance)
  
  -- Create or update instance data
  local newInstanceMesh, newInstanceCount = self:createInstanceData(cubes)
  
  -- Update state
  if self.instanceMesh then
    self.instanceMesh:release() -- Release previous mesh to avoid memory leaks
  end
  
  self.instanceMesh = newInstanceMesh
  self.instanceCount = newInstanceCount
  
  -- Attach instance attributes to the base mesh
  self.baseMesh:attachAttribute("InstancePosition", self.instanceMesh, "perinstance")
  self.baseMesh:attachAttribute("InstanceColor", self.instanceMesh, "perinstance")
  self.baseMesh:attachAttribute("InstanceVisibility", self.instanceMesh, "perinstance")
  
  -- Enable depth testing and depth writing
  love.graphics.setDepthMode("lequal", true)
  
  -- Ensure we're using the correct blend mode (no alpha blending)
  love.graphics.setBlendMode("alpha", "premultiplied")
  
  -- Render all cubes in a single draw call
  love.graphics.setShader(self.shader)
  
  -- Force shader to use the latest uniform values
  love.graphics.flushBatch()
  
  -- Draw the instanced cubes
  love.graphics.drawInstanced(self.baseMesh, self.instanceCount)
  
  -- Reset the shader and graphics state
  love.graphics.setShader()
  love.graphics.setDepthMode()
  love.graphics.setBlendMode("alpha")
  
  -- Update debug stats
  dbg.setValue("Instances Rendered", self.instanceCount)
  dbg.setValue("Total Triangles", self.instanceCount * 12) -- 12 triangles per cube (2 per face)
  
  return cubes
end

-- Toggle cube outlines
function CubeRenderer:toggleOutlines(enabled)
  if not self.initialized then return false end
  
  -- Send the value to the shader
  rendererCore.toggleShaderOutlines(self.shader, enabled)
  return true
end

-- Set view distance
function CubeRenderer:setViewDistance(distance)
  self.viewDistance = distance
end

-- Create a singleton instance
local cubeRenderer = CubeRenderer.new()

-- Register the cube renderer
local registry = require('renderer.registry')
registry.registerShapeRenderer("cube", cubeRenderer)

return cubeRenderer

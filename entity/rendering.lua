-- entity/rendering.lua
-- Entity-specific rendering implementation

local BaseBillboardRenderer = require('renderer.billboards.base')
local rendererCore = require('renderer.core')
local camera = require('camera')
local events = require('events')

-- Create the entity billboard renderer
local EntityRenderer = {}
EntityRenderer.__index = EntityRenderer
setmetatable(EntityRenderer, { __index = BaseBillboardRenderer })

-- Constructor
function EntityRenderer.new()
  local self = BaseBillboardRenderer.new("entity_billboard")
  self.initialized = false
  return setmetatable(self, EntityRenderer)
end

-- Initialize the billboard renderer
function EntityRenderer:init()
  if self.initialized then return self end
  
  -- Load shader for billboard sprites from external files
  self.shader = rendererCore.loadShader("entity_billboard", 
                                       "renderer/shaders/billboard/vertex.glsl", 
                                       "renderer/shaders/billboard/fragment.glsl")
  
  -- Set view distance property (matching cube renderer)
  self.viewDistance = 100.0
  
  -- Create the base mesh once - will be reused for all rendering
  self.baseMesh = self:createMesh()
  
  -- Listen for window resize events to update shader
  events.system.window_resized.listen(function(width, height)
    self.shader:send("screenSize", {width, height})
  end)
  
  self.initialized = true
  return self
end

-- Create a mesh for a billboard entity
function EntityRenderer:createMesh()
  -- Create a simple quad mesh with LÖVE's default format
  -- LÖVE automatically handles VertexPosition and VertexTexCoord
  -- Flip the Y texture coordinates to correct the upside-down sprite issue
  -- Set origin at bottom-middle (feet of sprite) instead of center
  local mesh = love.graphics.newMesh({
    {-0.5, 0, 0, 1},     -- Bottom-left corner (x,y,u,v) - v flipped to 1
    { 0.5, 0, 1, 1},     -- Bottom-right corner - v flipped to 1
    { 0.5, 1, 1, 0},     -- Top-right corner - v flipped to 0
    {-0.5, 1, 0, 0}      -- Top-left corner - v flipped to 0
  }, "fan", "static")
  
  return mesh
end

-- Create instance data for a collection of entities with the same spritesheet
function EntityRenderer:createInstanceData(entities, spritesheet)
  -- Pre-allocate instance data table with known size for better performance
  local instanceData = {}
  local count = 0
  
  -- All entities passed to this function should already have valid quads
  -- This was checked during the filtering stage in the render function
  for _, entity in ipairs(entities) do
    -- Get the current animation frame's quad
    local quad = entity:getCurrentQuad()
    
    -- Get quad viewport (UV coordinates)
    local x, y, w, h = quad:getViewport()
    
    -- Calculate normalized UV coordinates
    local u = x / spritesheet.total_width
    local v = y / spritesheet.total_height
    local uw = w / spritesheet.total_width
    local vh = h / spritesheet.total_height
    
    -- Get scale from entity
    local scaleX = entity.sprite_info.scale or 1
    local scaleY = entity.sprite_info.scale or 1
    
    -- Add this entity's instance data
    count = count + 1
    instanceData[count] = {
      entity.x, entity.y, entity.z,                    -- EntityPosition
      entity.width * scaleX, entity.height * scaleY,   -- EntitySize
      u, v, uw, vh                                     -- EntityUV
    }
  end
  
  -- Create a mesh with the instance data
  local format = {
    {"EntityPosition", "float", 3},
    {"EntitySize", "float", 2},
    {"EntityUV", "float", 4}
  }
  
  -- Create new instance mesh
  local instanceMesh = love.graphics.newMesh(format, instanceData, nil, "dynamic")
  return instanceMesh, count
end

-- Update shader with camera information
function EntityRenderer:updateShader(cameraPosition)
  if not self.initialized then return end
  
  -- Update all shader uniforms using the renderer core function
  -- This is the same approach used by the cube renderer
  rendererCore.updateShaderCamera(self.shader, cameraPosition, self.viewDistance)
  
  -- Log minimal debug info
  events.debug.world_stats_updated.notify("Camera Position", 
    cameraPosition.x .. "," .. cameraPosition.y .. "," .. (cameraPosition.z or 0))
end

-- Render a collection of billboard entities using GPU instancing
function EntityRenderer:render(entities, cameraPosition)
  if not self.initialized then
    self:init()
  end
  
  if not entities or #entities == 0 then 
    events.debug.world_stats_updated.notify("Rendering Entities", "None to render")
    return 
  end
  
  -- Update shader with camera information
  self:updateShader(cameraPosition)
  
  -- No need to sort entities by depth anymore - GPU depth buffer handles this
  -- We still keep the depth property on entities for debugging purposes
  
  -- Filter and group entities by spritesheet
  local entity_groups = {}
  local valid_entity_count = 0
  
  for _, entity in ipairs(entities) do
    -- Only process entities with valid spritesheets and quads
    if entity.spritesheet and entity.spritesheet.image and entity:getCurrentQuad() then
      local sheet = entity.spritesheet
      local sheet_id = tostring(sheet)
      
      if not entity_groups[sheet_id] then
        entity_groups[sheet_id] = {
          spritesheet = sheet,
          entities = {}
        }
      end
      
      table.insert(entity_groups[sheet_id].entities, entity)
      valid_entity_count = valid_entity_count + 1
    end
  end
  
  -- Basic performance metric
  events.debug.world_stats_updated.notify("Rendering Entities", valid_entity_count .. " / " .. #entities)
  
  -- Track how many entities we've drawn
  local drawn_count = 0
  
  -- Draw each group with instanced rendering
  for sheet_id, group in pairs(entity_groups) do
    -- Create instance data for this group
    local instanceMesh, instanceCount = self:createInstanceData(group.entities, group.spritesheet)
    
    -- Set the texture for this batch
    self.baseMesh:setTexture(group.spritesheet.image)
    
    -- Attach instance attributes to the base mesh
    self.baseMesh:attachAttribute("EntityPosition", instanceMesh, "perinstance")
    self.baseMesh:attachAttribute("EntitySize", instanceMesh, "perinstance")
    self.baseMesh:attachAttribute("EntityUV", instanceMesh, "perinstance")
    
    -- Set proper depth testing mode for sprite objects
    -- Test against AND write to depth buffer (alpha testing will handle transparency)
    love.graphics.setDepthMode("lequal", true)
    
    -- Reset scissor testing to ensure full screen rendering
    love.graphics.setScissor()
    
    -- Send all required uniforms to the shader with safety checks
    -- This ensures consistent handling with other renderers
    if self.shader:hasUniform("viewDistance") then
        self.shader:send("viewDistance", self.viewDistance)
    end
    
    if self.shader:hasUniform("depthScale") then
        self.shader:send("depthScale", rendererCore.depthConfig.standardScale)
    end
    
    if self.shader:hasUniform("billboardOffset") then
        self.shader:send("billboardOffset", rendererCore.depthConfig.billboardOffset)
    end
    
    -- Send tile size for consistent scaling
    local camera = require('camera')
    if self.shader:hasUniform("tileSize") then
        self.shader:send("tileSize", camera.projection.tileSize)
    end
    
    -- Set the shader and draw all entities in this group
    love.graphics.setShader(self.shader)
    
    -- Force a clean graphics state before drawing
    love.graphics.setScissor()  -- Disable any scissor testing
    love.graphics.drawInstanced(self.baseMesh, instanceCount)
    
    -- Reset graphics state
    love.graphics.setShader()
    love.graphics.setDepthMode()
    
    -- Release the instance mesh to avoid memory leaks
    instanceMesh:release()
    
    drawn_count = drawn_count + instanceCount
  end
  
  -- Update debug info
  events.debug.world_stats_updated.notify("Entities Drawn", drawn_count)
end

-- Create a singleton instance
local entityRenderer = EntityRenderer.new()

-- Register the billboard renderer
local registry = require('renderer.registry')
registry.registerBillboardRenderer("entity_billboard", entityRenderer)

return entityRenderer

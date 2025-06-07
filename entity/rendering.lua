-- entity/rendering.lua
-- Entity-specific rendering implementation

local BaseBillboardRenderer = require('renderer.billboards.base')
local rendererCore = require('renderer.core')
local camera = require('camera')
local events = require('events')

-- Create the entity billboard renderer
local EntityRenderer = setmetatable({}, { __index = BaseBillboardRenderer })
EntityRenderer.__index = EntityRenderer

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
  -- Create and register shader
  self.shader = rendererCore.loadShader("entity_billboard", 
                                       "renderer/shaders/billboard/vertex.glsl", 
                                       "renderer/shaders/billboard/fragment.glsl")
  
  -- Set initial shader uniforms
  local w, h = love.graphics.getDimensions()
  self.shader:send("screenSize", {w, h})
  
  -- Get tile size from camera module to ensure consistency
  local camera = require('camera')
  self.shader:send("tileSize", camera.tileSize)  -- Use camera's tile size
  
  -- Listen for window resize events to update shader
  events.window_resized.listen(function(width, height)
    self.shader:send("screenSize", {width, height})
  end)
  
  self.initialized = true
  return self
end

-- Create a mesh for a billboard entity
function EntityRenderer:createMesh()
  -- Create a simple quad mesh with LÖVE's default format
  -- LÖVE automatically handles VertexPosition and VertexTexCoord
  local mesh = love.graphics.newMesh({
    {-0.5, -0.5, 0, 0},  -- Bottom-left corner (x,y,u,v)
    { 0.5, -0.5, 1, 0},  -- Bottom-right corner
    { 0.5,  0.5, 1, 1},  -- Top-right corner
    {-0.5,  0.5, 0, 1}   -- Top-left corner
  }, "fan", "static")
  
  return mesh
end

-- Create instance data for a collection of entities with the same spritesheet
function EntityRenderer:createInstanceData(entities, spritesheet)
  -- Table to hold instance data
  local instanceData = {}
  
  for _, entity in ipairs(entities) do
    -- Get the current animation frame's quad
    local quad = entity:getCurrentQuad()
    
    if quad then
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
      table.insert(instanceData, {
        entity.x, entity.y, entity.z,                    -- EntityPosition
        entity.width * scaleX, entity.height * scaleY,   -- EntitySize
        u, v, uw, vh                                     -- EntityUV
      })
    end
  end
  
  -- Create a mesh with the instance data
  local format = {
    {"EntityPosition", "float", 3},
    {"EntitySize", "float", 2},
    {"EntityUV", "float", 4}
  }
  
  -- Create new instance mesh
  local instanceMesh = love.graphics.newMesh(format, instanceData, nil, "dynamic")
  return instanceMesh, #instanceData
end

-- Update shader with camera information
function EntityRenderer:updateShader(cameraPosition)
  if not self.initialized then return end
  
  -- Update camera position in shader
  self.shader:send("cameraPosition", {
    cameraPosition.x or 0,
    cameraPosition.y or 0,
    cameraPosition.z or 0
  })
  
  -- Ensure all necessary uniforms are up to date
  local w, h = love.graphics.getDimensions()
  self.shader:send("screenSize", {w, h})
  
  -- Get tile size from camera module to ensure consistency
  local camera = require('camera')
  self.shader:send("tileSize", camera.tileSize)
  
  -- Debug: Log shader uniforms
  events.world_stats_updated.notify("Shader Uniforms", 
    "Camera: (" .. cameraPosition.x .. "," .. cameraPosition.y .. "," .. (cameraPosition.z or 0) .. "), " ..
    "Screen: " .. w .. "x" .. h .. ", " ..
    "TileSize: " .. camera.tileSize)
end

-- Temporary flag for debugging - set to false to use GPU rendering
local USE_DIRECT_DRAWING = true

-- Render a collection of billboard entities
function EntityRenderer:render(entities, cameraPosition)
  if not self.initialized then
    self:init()
  end
  
  if not entities or #entities == 0 then 
    events.world_stats_updated.notify("Rendering Entities", "None to render")
    return 
  end
  
  events.world_stats_updated.notify("Rendering Entities", #entities)
  
  -- Update shader with camera information
  self:updateShader(cameraPosition)
  
  -- Sort entities by depth
  table.sort(entities, function(a, b)
    return a.depth > b.depth
  end)
  
  -- Group entities by spritesheet
  local entity_groups = {}
  for _, entity in ipairs(entities) do
    if entity.spritesheet and entity.spritesheet.image then
      -- Use the entity's spritesheet object itself as the key
      local sheet = entity.spritesheet
      local sheet_id = tostring(sheet)
      
      if not entity_groups[sheet_id] then
        entity_groups[sheet_id] = {
          spritesheet = sheet,
          entities = {}
        }
      end
      table.insert(entity_groups[sheet_id].entities, entity)
      
      -- Debug entity position
      events.world_stats_updated.notify("Entity at " .. entity.x .. "," .. entity.y .. "," .. entity.z,
        "State: " .. entity.state .. ", Depth: " .. entity.depth)
    else
      events.world_stats_updated.notify("Entity Error", "Missing spritesheet or image")
    end
  end
  
  -- Track how many entities we've drawn
  local drawn_count = 0
  
  if USE_DIRECT_DRAWING then
    -- FALLBACK: Use direct LÖVE2D drawing for debugging
    events.world_stats_updated.notify("Rendering Method", "Direct Drawing (Debug Mode)")
    
    -- Draw each group
    for sheet_id, group in pairs(entity_groups) do
      -- Sort entities by depth
      table.sort(group.entities, function(a, b)
        return a.depth > b.depth
      end)
      
      -- Draw each entity
      for _, entity in ipairs(group.entities) do
        -- Get the current animation frame
        local quad = entity:getCurrentQuad()
        
        if quad then
          -- Draw the entity
          local screenX, screenY = camera.iso(entity.x, entity.y, entity.z)
          
          -- Get scale from entity if present, otherwise use default of 1
          local scaleX = entity.sprite_info.scale or 1
          local scaleY = entity.sprite_info.scale or 1
          
          -- Debug: Draw a colored background to show entity position
          love.graphics.setColor(0, 0.5, 0, 0.5) -- semi-transparent green
          love.graphics.rectangle("fill", 
            screenX - (entity.width*scaleX)/2, 
            screenY - entity.height*scaleY, 
            entity.width*scaleX, 
            entity.height*scaleY)
          
          -- Reset color to white for sprite drawing
          love.graphics.setColor(1, 1, 1, 1)
          
          -- Draw the entity sprite
          love.graphics.draw(
            entity.spritesheet.image,
            quad,
            -- Center the entity at its position
            screenX, screenY,
            0,              -- Rotation (billboards don't rotate)
            scaleX, scaleY, -- Scale factors from entity
            entity.width/2, -- Origin X (center of sprite)
            entity.height   -- Origin Y (bottom of sprite)
          )
          
          -- Debug: Draw a frame around the entity
          love.graphics.setColor(1, 0, 0, 0.8) -- bright red
          love.graphics.rectangle("line", 
            screenX - (entity.width*scaleX)/2, 
            screenY - entity.height*scaleY, 
            entity.width*scaleX, 
            entity.height*scaleY)
          
          -- Debug: Print entity info
          love.graphics.setColor(1, 1, 1, 1)
          love.graphics.print(
            entity.state .. " (" .. entity.x .. "," .. entity.y .. "," .. entity.z .. ")",
            screenX - 40, 
            screenY - entity.height*scaleY - 15
          )
          
          -- Reset color
          love.graphics.setColor(1, 1, 1, 1)
          
          drawn_count = drawn_count + 1
        else
          events.world_stats_updated.notify("Entity Error", "Missing quad for entity")
        end
      end
    end
  else
    -- GPU-BASED RENDERING
    events.world_stats_updated.notify("Rendering Method", "GPU Instancing")
    
    -- Create base mesh if needed
    if not self.baseMesh then
      self.baseMesh = self:createMesh()
    end
    
    -- Draw each group with instanced rendering
    for sheet_id, group in pairs(entity_groups) do
      -- Create instance data for this group
      local instanceMesh, instanceCount = self:createInstanceData(group.entities, group.spritesheet)
      
      -- Debug instance data
      for i, entity in ipairs(group.entities) do
        local quad = entity:getCurrentQuad()
        if quad then
          local x, y, w, h = quad:getViewport()
          local sheet = entity.spritesheet
          events.world_stats_updated.notify("Instance " .. i, 
            "UV: " .. x/sheet.total_width .. "," .. y/sheet.total_height .. "," .. 
            w/sheet.total_width .. "," .. h/sheet.total_height)
        end
      end
      
      -- Set the texture for this batch
      self.baseMesh:setTexture(group.spritesheet.image)
      
      -- Attach instance attributes to the base mesh
      self.baseMesh:attachAttribute("EntityPosition", instanceMesh, "perinstance")
      self.baseMesh:attachAttribute("EntitySize", instanceMesh, "perinstance")
      self.baseMesh:attachAttribute("EntityUV", instanceMesh, "perinstance")
      
      -- Debug: Disable depth testing temporarily
      -- love.graphics.setDepthMode("lequal", true)
      
      -- Set the shader and draw all entities in this group
      love.graphics.setShader(self.shader)
      
      -- Force shader to use the latest uniform values
      love.graphics.flushBatch()
      
      -- Draw the instanced billboards
      love.graphics.drawInstanced(self.baseMesh, instanceCount)
      
      -- Reset graphics state
      love.graphics.setShader()
      love.graphics.setDepthMode()
      
      -- Release the instance mesh to avoid memory leaks
      instanceMesh:release()
      
      drawn_count = drawn_count + instanceCount
    end
  end
  
  -- Update debug info
  events.world_stats_updated.notify("Entities Drawn", drawn_count)
end

-- Create a singleton instance
local entityRenderer = EntityRenderer.new()

-- Register the billboard renderer
local registry = require('renderer.registry')
registry.registerBillboardRenderer("entity_billboard", entityRenderer)

return entityRenderer

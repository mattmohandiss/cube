-- entity/core.lua
-- Core entity functionality: properties, creation, and initialization

local core = {}

-- Store references to other modules
local camera
local events

-- Initialize the entity module
function core.init()
  -- Load required modules
  camera = require('camera')
  events = require('events')
end

-- Factory method for creating new base entities
function core.new(x, y, z, sprite_info)
  -- Default values
  x = x or 0
  y = y or 0
  z = z or 0
  sprite_info = sprite_info or {}
  
  -- Add precomputed depth for sorting using the camera's function
  local depth = camera.calculateIsoDepth(x, y, z)
  
  -- Create the entity with basic properties
  local entity = { 
    x = x, 
    y = y, 
    z = z,
    width = sprite_info.width or 16,   -- Default sprite width
    height = sprite_info.height or 16, -- Default sprite height
    sprite_info = sprite_info,
    depth = depth,                     -- Keep depth for sorting
    -- Animation state
    state = "idle",                    -- Current animation state
    frame = 1,                         -- Current animation frame
    frame_timer = 0,                   -- Timer for animation
    -- Movement
    velocity = {x = 0, y = 0, z = 0},  -- Movement velocity
    -- Core methods
    update = function(self, dt)
      -- Base update function to be extended
      self:updateAnimation(dt)
      self:updatePosition(dt)
      -- Recalculate depth if position changed
      self.depth = camera.calculateIsoDepth(self.x, self.y, self.z)
    end,
    updateAnimation = function(self, dt)
      -- Animation update logic to be implemented in animation.lua
    end,
    updatePosition = function(self, dt)
      -- Update position based on velocity
      self.x = self.x + self.velocity.x * dt
      self.y = self.y + self.velocity.y * dt
      self.z = self.z + self.velocity.z * dt
    end,
    move = function(self, dx, dy, dz)
      -- Direct position adjustment
      self.x = self.x + (dx or 0)
      self.y = self.y + (dy or 0)
      self.z = self.z + (dz or 0)
      -- Recalculate depth
      self.depth = camera.calculateIsoDepth(self.x, self.y, self.z)
    end,
    setPosition = function(self, x, y, z)
      -- Set absolute position
      self.x = x or self.x
      self.y = y or self.y
      self.z = z or self.z
      -- Recalculate depth
      self.depth = camera.calculateIsoDepth(self.x, self.y, self.z)
    end,
    setVelocity = function(self, vx, vy, vz)
      -- Set velocity components
      self.velocity.x = vx or self.velocity.x
      self.velocity.y = vy or self.velocity.y
      self.velocity.z = vz or self.velocity.z
    end,
    setState = function(self, state)
      -- Change animation state
      if self.state ~= state then
        self.state = state
        self.frame = 1
        self.frame_timer = 0
      end
    end
  }
  
  return entity
end

-- Extend an entity with additional properties and methods
function core.extend(entity, extensions)
  if not extensions then return entity end
  
  -- Copy extension properties and methods to the entity
  for key, value in pairs(extensions) do
    entity[key] = value
  end
  
  return entity
end

return core

-- game/entities/worker.lua
-- Worker entity type implementation

local entity = require('entity')
local camera = require('camera')

local worker = {}

function worker.new(x, y, z, config)
  config = config or {}
  
  -- Create base entity with correct animation row mappings
  -- Use a cube size of 1.0 to match the block size
  
  -- Calculate the scale based on the camera's tileSize
  -- The ideal size is for the worker to be 1 tile wide
  -- If sprite is 16px wide and we want it to cover a tile width (tileSize/2 in screen space)
  -- Multiply by 2 to make it twice as large for better visibility
  local scaleFactor = (camera.projection.tileSize / 16) * 5
  
  local worker_entity = entity.create(x, y, z, {
    spritesheet = "assets/worker.png",
    width = 16,  -- Corrected sprite size - each sprite is 16x16 pixels
    height = 16, -- Corrected sprite size - each sprite is 16x16 pixels
    scale = scaleFactor, -- Dynamically calculated scale to match one tile size
    animations = {
      -- Walking animations with correct row mappings (5 frames each)
      walk_south = {row = 1, frames = 5, duration = 0.5},
      walk_north = {row = 2, frames = 5, duration = 0.5},
      walk_east = {row = 3, frames = 5, duration = 0.5}, 
      walk_west = {row = 4, frames = 5, duration = 0.5},
      
      -- Idle animations (single frame)
      idle_south = {row = 1, frames = 1, duration = 1.0},
      idle_north = {row = 2, frames = 1, duration = 1.0},
      idle_east = {row = 3, frames = 1, duration = 1.0},
      idle_west = {row = 4, frames = 1, duration = 1.0}
    }
  })
  
  -- Add worker-specific properties
  worker_entity.direction = config.direction or "south"  -- Default facing direction
  worker_entity.speed = config.speed or 2                -- Default movement speed
  worker_entity.task = nil                               -- Current task
  
  -- Override update method to handle direction-based animation
  local base_update = worker_entity.update
  worker_entity.update = function(self, dt)
    -- Call base update to handle position and basic animation
    base_update(self, dt)
    
    -- Update animation based on movement and direction
    if math.abs(self.velocity.x) > 0.01 or math.abs(self.velocity.y) > 0.01 then
      -- Determine direction based on velocity
      self:updateDirection()
      
      -- Set walking animation for current direction
      self:setState("walk_" .. self.direction)
    else
      -- Set idle animation for current direction
      self:setState("idle_" .. self.direction)
    end
  end
  
  -- Add method to update direction based on velocity
  worker_entity.updateDirection = function(self)
    local vx, vy = self.velocity.x, self.velocity.y
    
    -- Determine primary direction of movement (using the larger component)
    if math.abs(vx) > math.abs(vy) then
      -- Moving primarily east/west
      self.direction = vx > 0 and "east" or "west"
    else
      -- Moving primarily north/south
      self.direction = vy > 0 and "south" or "north"
    end
  end
  
  -- Add convenience methods for movement
  worker_entity.moveNorth = function(self, speed)
    self.direction = "north"
    speed = speed or self.speed
    self:setVelocity(0, -speed, 0)
    return self
  end
  
  worker_entity.moveSouth = function(self, speed)
    self.direction = "south"
    speed = speed or self.speed
    self:setVelocity(0, speed, 0)
    return self
  end
  
  worker_entity.moveEast = function(self, speed)
    self.direction = "east"
    speed = speed or self.speed
    self:setVelocity(speed, 0, 0)
    return self
  end
  
  worker_entity.moveWest = function(self, speed)
    self.direction = "west"
    speed = speed or self.speed
    self:setVelocity(-speed, 0, 0)
    return self
  end
  
  worker_entity.stop = function(self)
    self:setVelocity(0, 0, 0)
    return self
  end
  
  -- Path finding and movement to target
  worker_entity.moveTo = function(self, target_x, target_y, target_z)
    -- Calculate direction vector
    local dx = target_x - self.x
    local dy = target_y - self.y
    local dz = target_z - self.z
    
    -- Normalize for consistent speed
    local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
    if dist < 0.1 then
      -- Already at target
      self:stop()
      return true
    end
    
    -- Set velocity based on direction
    local speed = self.speed
    self:setVelocity(
      (dx / dist) * speed,
      (dy / dist) * speed,
      (dz / dist) * speed
    )
    
    -- Update facing direction
    self:updateDirection()
    
    return false -- Not yet at target
  end
  
  -- Face a specific direction without moving
  worker_entity.face = function(self, direction)
    if direction == "north" or direction == "south" or
       direction == "east" or direction == "west" then
      self.direction = direction
      self:setState("idle_" .. self.direction)
    end
    return self
  end
  
  -- Set a task for the worker
  worker_entity.setTask = function(self, task_name, task_data)
    self.task = {
      name = task_name,
      data = task_data or {},
      progress = 0
    }
    return self
  end
  
  -- Clear the current task
  worker_entity.clearTask = function(self)
    self.task = nil
    return self
  end
  
  return worker_entity
end

return worker

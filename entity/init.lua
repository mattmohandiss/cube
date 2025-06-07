-- entity/init.lua
-- Entity module initialization and API

local camera = require('camera')
local entity = {}

-- Load submodules
entity.core = require('entity.core')
entity.animation = require('entity.animation')
entity.rendering = require('entity.rendering')

-- Registered entity types
entity.types = {}

-- Initialize the entity module
function entity.init()
  -- Initialize submodules
  entity.core.init()
  entity.animation.init()
  entity.rendering:init()
  
  return entity
end

-- Register an entity type
function entity.registerType(type_name, creator_function)
  if entity.types[type_name] then
    error("Entity type already registered: " .. type_name)
  end
  
  entity.types[type_name] = creator_function
end

-- Create a new entity
function entity.create(x, y, z, sprite_info)
  -- Create base entity
  local new_entity = entity.core.new(x, y, z, sprite_info)
  
  -- Apply animation system
  entity.animation.apply(new_entity)
  
  -- Initialize with a default state
  if new_entity.sprite_info and new_entity.sprite_info.animations then
    -- Find the first animation and set it as default
    for state, _ in pairs(new_entity.sprite_info.animations) do
      new_entity:setState(state)
      break
    end
  end
  
  return new_entity
end

-- Create an entity of a specific type
function entity.createType(type_name, x, y, z, config)
  if not entity.types[type_name] then
    error("Unknown entity type: " .. type_name)
  end
  
  -- Call the type-specific creator function
  return entity.types[type_name](x, y, z, config)
end

-- Update a collection of entities
function entity.updateAll(entities, dt)
  for _, entity in ipairs(entities) do
    entity:update(dt)
  end
end

-- Draw a collection of entities
function entity.drawAll(entities)
  entity.rendering:render(entities, camera.position)
end

-- Update renderer with camera information
function entity.updateRenderer(camera_position, view_distance)
  entity.rendering:updateShader(camera_position)
end

return entity

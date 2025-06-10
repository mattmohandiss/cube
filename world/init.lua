-- world/init.lua
-- Main world module that brings together core, terrain, entities, and rendering functionality

local events = require('events')
local camera = require('camera')

-- Internal module requires
local core = require('world.core')
local terrain = require('world.terrain')
local rendering = require('world.rendering')

-- Create the main world object
local world = {}

-- Initialize the world module
function world.init(options)
  -- Initialize internal modules
  core.init(options)
  rendering.init()
  
  -- Initialize the terrain generator with the seed
  terrain.init(core.config.terrain.seed)
  
  -- Generate the terrain
  world.generate()
  
  -- Expose core functions
  world.getHeight = core.getHeight
  world.getTerrainColor = core.getTerrainColor
  world.getTerrainCubes = core.getTerrainCubes
  
  -- Expose rendering functions
  world.renderTerrain = function(cameraPosition)
    return rendering.renderTerrain(core.terrainCubes, cameraPosition)
  end
  
  world.renderEntities = function(cameraPosition)
    return rendering.renderEntities(core.getEntities(), cameraPosition)
  end
  
  -- Add unified rendering function that uses our enhanced core
  world.renderScene = function(cameraPosition)
    return rendering.renderScene(core.terrainCubes, core.getEntities(), cameraPosition)
  end
  
  -- Notify of world initialization
  events.world_stats_updated.notify("World Module", "Initialized")
end

-- Generate a new world
function world.generate(seed)
  -- Update seed if provided
  if seed then
    core.config.terrain.seed = seed
    terrain.init(seed)
  end
  
  -- Generate the terrain heightmap
  local heightmap = terrain.generateHeightmap(
    core.config.size.width,
    core.config.size.length,
    {
      scale = core.config.terrain.scale,
      octaves = core.config.terrain.octaves,
      persistence = core.config.terrain.persistence,
      baseHeight = core.config.terrain.baseHeight,
      maxHeight = core.config.size.height
    }
  )
  
  -- Store the heightmap in the core module
  core.terrain = heightmap
  
  -- Create cubes from the terrain
  core.createTerrainCubes()
  
  -- Return the number of terrain cubes created
  return #core.terrainCubes
end

-- Update world (called each frame)
function world.update(dt)
  -- Update all entities
  core.updateEntities(dt)
end

-- Get all terrain cubes
function world.getCubes()
  return core.getTerrainCubes()
end

-- This function was removed as part of GPU rendering optimization
-- Face visibility is now handled by the GPU

-- Add a new cube to the world
function world.addCube(x, y, z, color)
  return core.addCube(x, y, z, color)
end

-- Remove a cube from the world
function world.removeCube(x, y, z)
  return core.removeCube(x, y, z)
end

-- Get a cube at the specified position
function world.getCubeAt(x, y, z)
  return core.getCubeAt(x, y, z)
end

-- Render the world with the current camera position
function world.render(cameraPosition)
  -- Use our new centralized rendering approach
  -- This handles proper depth sorting and transparency in one unified pass
  return rendering.renderScene(core.terrainCubes, core.getEntities(), cameraPosition)
end

-- Add an entity to the world
function world.addEntity(entity)
  return core.addEntity(entity)
end

-- Remove an entity from the world
function world.removeEntity(entity)
  return core.removeEntity(entity)
end

-- Get all entities
function world.getEntities()
  return core.getEntities()
end

-- Export the world configuration for external access
world.config = core.config

return world

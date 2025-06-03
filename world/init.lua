-- world/init.lua
-- Main world module that brings together core, terrain, and rendering functionality

local events = require('events')

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
  -- Currently no per-frame updates needed
  -- Could be used for animations or dynamic terrain in the future
end

-- Get all terrain cubes
function world.getCubes()
  return core.getTerrainCubes()
end

-- Render the world with the current camera position
function world.render(cameraPosition)
  return rendering.renderTerrain(core.terrainCubes, cameraPosition)
end

-- Export the world configuration for external access
world.config = core.config

return world

-- world/core.lua
-- Core functionality for world generation and management

local events = require('events')
local cube = require('cube')

local core = {}

-- World configuration
core.config = {
  -- World dimensions
  size = {
    width = 32,  -- Width of the world in blocks
    length = 32, -- Length of the world in blocks
    height = 8   -- Maximum height of terrain
  },
  
  -- Terrain generation parameters
  terrain = {
    scale = 0.25,     -- Scale factor for noise (smaller = more gradual changes)
    octaves = 8,     -- Number of noise octaves to combine
    persistence = 0.5, -- How much each octave contributes
    baseHeight = 0,  -- Minimum height of the terrain
    seed = os.time() -- Random seed for terrain generation
  }
}

-- World state
core.terrain = {} -- Will store height map data
core.terrainCubes = {} -- Will store cube objects
core.cubeMap = {} -- 2D lookup table for quick neighbor finding

-- Initialize the world
function core.init(options)
  -- Apply any custom options
  if options then
    -- Override config with custom options
    for key, value in pairs(options) do
      if type(value) == "table" then
        for subKey, subValue in pairs(value) do
          core.config[key][subKey] = subValue
        end
      else
        core.config[key] = value
      end
    end
  end
  
  -- Notify of world initialization
  events.debug.world_stats_updated.notify("World Size", 
    core.config.size.width .. "x" .. core.config.size.length)
  events.debug.world_stats_updated.notify("Terrain Seed", core.config.terrain.seed)
end

-- Generate the terrain height map
function core.generateTerrain()
  -- This will be filled by the terrain module
  core.terrain = {}
  core.terrainCubes = {}
  core.cubeMap = {}
end

-- Function to add a cube to the lookup map
function core.addCubeToMap(x, y, z, terrainCube)
  if not core.cubeMap[x] then core.cubeMap[x] = {} end
  if not core.cubeMap[x][y] then core.cubeMap[x][y] = {} end
  core.cubeMap[x][y][z] = terrainCube
end

-- Function to get a cube from the map
-- Note: z should be an integer value (the logical height)
function core.getCubeAt(x, y, z)
  return core.cubeMap[x] and core.cubeMap[x][y] and core.cubeMap[x][y][z]
end

-- Face visibility is now handled by GPU

-- Create cube objects from terrain data
function core.createTerrainCubes()
  -- Clear existing cubes and cube map
  core.terrainCubes = {}
  core.cubeMap = {}
  
  -- Create a cube for each point in the terrain
  for x = 1, core.config.size.width do
    for y = 1, core.config.size.length do
      local height = core.getHeight(x, y)
      
      -- Adjust coordinates to center the map
      local worldX = x - core.config.size.width/2
      local worldY = y - core.config.size.length/2
      
      -- Check if this is the spawn point (0,0) or a terrain point with height > 0
      if height > 0 or (worldX == 0 and worldY == 0) then
        -- If it's the spawn point but has no height, give it a default height of 1
        if worldX == 0 and worldY == 0 and height == 0 then
          height = 1
        end
        
        -- Get terrain color based on world coordinates and height
        local color = core.getTerrainColor(worldX, worldY, height)
        local worldZ = height / 2 -- Place the cube with its bottom at ground level
        
        -- Create the cube and add it to our collection
        -- worldZ is now the logical position directly (not half the height)
        local terrainCube = cube.new(worldX, worldY, height, color)
        table.insert(core.terrainCubes, terrainCube)
        
        -- Add to lookup map using integer coordinates for quick neighbor access
        core.addCubeToMap(worldX, worldY, height, terrainCube)
      end
    end
  end
  
  -- No need to sort cubes by depth anymore - GPU depth buffer handles this
  
  -- Update debug information
  events.debug.world_stats_updated.notify("Terrain Cubes", #core.terrainCubes)
end

-- Function to add a new cube to the world
function core.addCube(x, y, z, color)
  -- Create a new cube (z is the logical height directly)
  local cube = require('cube')
  local newCube = cube.new(x, y, z, color)
  
  -- Add to terrain cubes array
  table.insert(core.terrainCubes, newCube)
  
  -- Add to lookup map using logical coordinates for quick neighbor access
  core.addCubeToMap(x, y, z, newCube)
  
  -- No need to sort cubes by depth anymore - GPU depth buffer handles this
  
  -- Invalidate world caches
  require('world.rendering').invalidateCache()
  
  return newCube
end

-- Function to remove a cube from the world
function core.removeCube(x, y, z)
  
  -- Find the cube in the terrain cubes array
  local cubeToRemove = core.getCubeAt(x, y, z)
  if not cubeToRemove then
    return false -- Cube not found
  end
  
  -- Remove from terrain cubes array
  for i, cube in ipairs(core.terrainCubes) do
    if cube == cubeToRemove then
      table.remove(core.terrainCubes, i)
      break
    end
  end
  
  -- Remove from cube map
  if core.cubeMap[x] and core.cubeMap[x][y] then
    core.cubeMap[x][y][z] = nil
  end
  
  -- Invalidate world caches
  require('world.rendering').invalidateCache()
  
  return true
end

-- Face visibility is now handled by GPU

-- Face visibility is now handled by GPU

-- Get terrain height at given coordinates
function core.getHeight(x, y)
  -- Default to 0 if coordinates are out of bounds
  if x < 1 or x > core.config.size.width or 
     y < 1 or y > core.config.size.length then
    return 0
  end
  
  -- Return the height at these coordinates
  return core.terrain[x] and core.terrain[x][y] or 0
end

-- Get terrain color based on world coordinates and height
function core.getTerrainColor(worldX, worldY, height)
  -- Check if this is the spawn point (0,0)
  if worldX == 0 and worldY == 0 then
    -- Spawn point (orange)
    return {1.0, 0.5, 0.0}
  end

  -- Different colors for different height ranges
  local maxHeight = core.config.size.height
  local normalizedHeight = height / maxHeight
  
  if normalizedHeight < 0.2 then
    -- Sand/beach (light yellow)
    return {0.9, 0.8, 0.5}
  elseif normalizedHeight < 0.4 then
    -- Grass/plains (green)
    return {0.3, 0.8, 0.3}
  elseif normalizedHeight < 0.7 then
    -- Forest/hills (dark green)
    return {0.2, 0.6, 0.2}
  elseif normalizedHeight < 0.9 then
    -- Mountain (gray)
    return {0.6, 0.6, 0.6}
  else
    -- Snow peak (white)
    return {0.9, 0.9, 0.9}
  end
end

-- Get all terrain cubes for rendering
function core.getTerrainCubes()
  return core.terrainCubes
end

-- Entity storage
core.entities = {} -- Will store active entities

-- Add an entity to the world
function core.addEntity(entity)
  table.insert(core.entities, entity)
  return entity
end

-- Remove an entity from the world
function core.removeEntity(entity)
  for i, e in ipairs(core.entities) do
    if e == entity then
      table.remove(core.entities, i)
      return true
    end
  end
  return false
end

-- Get all entities for rendering and updates
function core.getEntities()
  return core.entities
end

-- Update all entities
function core.updateEntities(dt)
  for _, entity in ipairs(core.entities) do
    entity:update(dt)
  end
end

return core

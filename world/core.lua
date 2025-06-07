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
  events.world_stats_updated.notify("World Size", 
    core.config.size.width .. "x" .. core.config.size.length)
  events.world_stats_updated.notify("Terrain Seed", core.config.terrain.seed)
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
      if height > 0 then
        -- Get terrain color based on height
        local color = core.getTerrainColor(height)
        
        -- Create a cube at this position with appropriate height
        -- Adjust coordinates to center the map
        local worldX = x - core.config.size.width/2
        local worldY = y - core.config.size.length/2
        local worldZ = height / 2 -- Place the cube with its bottom at ground level
        
        -- Create the cube and add it to our collection
        local terrainCube = cube.new(worldX, worldY, worldZ, color)
        table.insert(core.terrainCubes, terrainCube)
        
        -- Add to lookup map for quick neighbor access
        core.addCubeToMap(worldX, worldY, worldZ, terrainCube)
      end
    end
  end
  
  -- Sort all terrain cubes once by depth (farthest first)
  table.sort(core.terrainCubes, function(a, b)
    return a.depth > b.depth
  end)
  
  -- Update debug information
  events.world_stats_updated.notify("Terrain Cubes", #core.terrainCubes)
end

-- Function to add a new cube to the world
function core.addCube(x, y, z, color)
  -- Create a new cube
  local cube = require('cube')
  local newCube = cube.new(x, y, z, color)
  
  -- Add to terrain cubes array
  table.insert(core.terrainCubes, newCube)
  
  -- Add to lookup map for quick neighbor access
  core.addCubeToMap(x, y, z, newCube)
  
  -- Re-sort all terrain cubes by depth (farthest first)
  table.sort(core.terrainCubes, function(a, b)
    return a.depth > b.depth
  end)
  
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

-- Get terrain color based on height
function core.getTerrainColor(height)
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

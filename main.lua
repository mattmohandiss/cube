-- Require modules
local dbg = require('dbg')
local input = require('input')
local camera = require('camera')
local cube = require('cube')
local entity = require('entity')
local events = require('events')
local world = require('world')
local game = require('game')
local worldCore = require('world.core')

-- LÖVE load callback
function love.load()
  -- Initialize modules
  dbg.init()
  input.init()
  cube.init()
  camera.init()
  entity.init()
  game.init()
  
  -- Set up world with terrain generation options
  local worldOptions = {
    size = {
      width = 250,
      length = 250,
      height = 16
    },
    terrain = {
      scale = 0.05,
      octaves = 7,
      persistence = 0.3,
      baseHeight = 1,
      seed = os.time() -- Random seed for unique terrain each time
    }
  }
  
  -- Initialize the world module with our options
  world.init(worldOptions)

  -- Initial camera position event
  events.camera_moved.notify(camera.position.x, camera.position.y)

  -- Add debug values via events
  events.world_stats_updated.notify("Number of Terrain Cubes", #world.getCubes())
  events.world_stats_updated.notify("Movement Speed", camera.moveSpeed)
  
  -- Calculate the middle of the grid (in grid coordinates)
  local middleGridX = math.floor(worldCore.config.size.width/2)
  local middleGridY = math.floor(worldCore.config.size.length/2)
  
  -- Function to get terrain height at a position (in world coordinates)
  local function getTerrainHeight(x, y)
    local terrainHeight = 0
    local terrainCube = world.getCubeAt(x, y, 0)
    if terrainCube then
      events.world_stats_updated.notify("Terrain Cube at " .. x .. "," .. y, 
        "Found at z=" .. terrainCube.z)
      terrainHeight = terrainCube.z + 1 -- Position one block above the terrain
    else
      events.world_stats_updated.notify("Terrain Cube at " .. x .. "," .. y, 
        "NOT FOUND - Using z=1")
      terrainHeight = 1 -- Fallback if no terrain found
    end
    return terrainHeight
  end
  
  -- Define four positions and directions for workers (in grid coordinates)
  local workerPositions = {
    {gridX = middleGridX, gridY = middleGridY, direction = "east"},      -- East worker
    -- {gridX = middleGridX - 5, gridY = middleGridY, direction = "west"},      -- West worker
    -- {gridX = middleGridX, gridY = middleGridY - 5, direction = "north"},     -- North worker
    -- {gridX = middleGridX, gridY = middleGridY + 5, direction = "south"}      -- South worker
  }
  
  -- Create and add workers
  for i, pos in ipairs(workerPositions) do
    -- Convert grid coordinates to world coordinates (same transformation as used for cubes)
    local worldX = pos.gridX - worldCore.config.size.width/2
    local worldY = pos.gridY - worldCore.config.size.length/2
    
    -- Get terrain height at this position
    local terrainHeight = getTerrainHeight(0, 0)
    
    -- Create worker with world coordinates
    local worker = game.createWorker(worldX, worldY, terrainHeight)
    
    -- Set worker direction and state
    worker:setState("idle_" .. pos.direction)
    worker.frame = 1
    worker.frame_timer = 0
    worker:face(pos.direction)
    worker:stop() -- Ensure zero velocity to stay in idle state
    
    -- Add the worker to the world
    world.addEntity(worker)
    
    -- Debug info
    events.world_stats_updated.notify(
      "Worker " .. i,
      "Position: " .. worldX .. "," .. worldY .. "," .. terrainHeight .. 
      " | Grid: " .. pos.gridX .. "," .. pos.gridY ..
      " | Facing: " .. pos.direction
    )
  end
  
  -- Add debug values
  events.world_stats_updated.notify("Entities", #world.getEntities())
end

-- LÖVE update callback
function love.update(dt)
  -- Handle camera movement with arrow keys
  input.handleCameraMovement(dt)
  
  -- Update world
  world.update(dt)

  -- Update debug information
  dbg.update(dt)
end

-- LÖVE draw callback
function love.draw()
  -- Clear screen
  love.graphics.clear(0.1, 0.1, 0.2)

  -- Render terrain with the current camera position
  world.render(camera.position)

  -- Draw debug overlay
  dbg.draw()
end

-- LÖVE keypressed callback
function love.keypressed(key)
  -- Pass key events to modules
  dbg.keypressed(key)
  input.keypressed(key)
end

-- LÖVE resize callback
function love.resize(width, height)
  -- Notify all listeners that the window has been resized
  events.window_resized.notify(width, height)
end

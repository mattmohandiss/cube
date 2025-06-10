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
  events.app.camera_moved.notify(camera.position.x, camera.position.y)

  -- Add debug values via events
  events.debug.world_stats_updated.notify("Number of Terrain Cubes", #world.getCubes())
  events.debug.world_stats_updated.notify("Movement Speed", camera.moveSpeed)
  
  -- Function to get terrain height at a position (in world coordinates)
  local function getTerrainHeight(x, y)
    -- Try all possible heights to find the cube
    for z = 1, worldCore.config.size.height do
      local terrainCube = world.getCubeAt(x, y, z)
      if terrainCube then
        -- Use the logical height (integer) for calculations
        local logicalZ = terrainCube.logicalZ or z
        events.debug.world_stats_updated.notify("Terrain Cube at " .. x .. "," .. y, 
          "Found at z=" .. logicalZ)
        return logicalZ + 1 -- Position one block above the terrain
      end
    end
    
    -- If no cube found after checking all heights
    events.debug.world_stats_updated.notify("Terrain Cube at " .. x .. "," .. y, 
      "NOT FOUND - Using z=10")
    return 10 -- Default height if no cube found
  end
  
  -- Create a single worker at position x=0, y=0, z=height+1
  local worldX = 0
  local worldY = 0
  
  -- Find the cube at (0,0) and get its z value
  local terrainHeight = getTerrainHeight(worldX, worldY)
  
  -- Create worker with world coordinates
  local worker = game.createWorker(worldX, worldY, terrainHeight)
  
  -- Set worker direction and state
  worker:setState("idle_east")
  worker.frame = 1
  worker.frame_timer = 0
  worker:face("east")
  worker:stop() -- Ensure zero velocity to stay in idle state
  
  -- Add the worker to the world
  world.addEntity(worker)
  
  -- Debug info
  events.debug.world_stats_updated.notify(
    "Worker",
    "Position: " .. worldX .. "," .. worldY .. "," .. terrainHeight
  )
  
  -- Add debug values
  events.debug.world_stats_updated.notify("Entities", #world.getEntities())
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

-- LÖVE wheelmoved callback for mouse wheel events
function love.wheelmoved(x, y)
  -- Pass wheel movement to input module for zoom handling
  input.wheelmoved(x, y)
end

-- LÖVE resize callback
function love.resize(width, height)
  -- Notify all listeners that the window has been resized
  events.system.window_resized.notify(width, height)
end

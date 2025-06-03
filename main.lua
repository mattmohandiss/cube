-- Require modules
local dbg = require('dbg')
local input = require('input')
local camera = require('camera')
local cube = require('cube')
local events = require('events')
local world = require('world')

-- LÖVE load callback
function love.load()
  -- Initialize modules
  dbg.init()
  input.init()
  cube.init()
  camera.init()
  
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

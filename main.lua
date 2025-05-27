-- Require modules
local dbg = require('dbg')
local input = require('input')
local camera = require('camera')
local cube = require('cube')
local events = require('events')

-- World data
local world = {
  cubes = {} -- Will hold all our cubes
}

-- LÖVE load callback
function love.load()
  -- Initialize modules
  dbg.init()
  input.init()
  cube.init()
  camera.init()

  -- Initial camera position event
  events.camera_moved.notify(camera.position.x, camera.position.y)

  -- Create some cubes at different positions
  table.insert(world.cubes, cube.new(0, 0, 0, { 1, 1, 1 }))      -- Center white cube
  -- table.insert(world.cubes, cube.new(1, 0, 0, { 1, 0.5, 0.5 }))  -- Red cube to the east
  table.insert(world.cubes, cube.new(0, 1, 0, { 0.5, 1, 0.5 }))  -- Green cube to the south
  table.insert(world.cubes, cube.new(-1, 0, 0, { 0.5, 0.5, 1 })) -- Blue cube to the west
  table.insert(world.cubes, cube.new(0, -1, 0, { 1, 1, 0.5 }))   -- Yellow cube to the north
  table.insert(world.cubes, cube.new(0, 0, 1, { 1, 0.5, 1 }))    -- Purple cube on top of center

  -- Add debug values via events
  events.world_stats_updated.notify("Number of Cubes", #world.cubes)
  events.world_stats_updated.notify("Movement Speed", camera.moveSpeed)
end

-- LÖVE update callback
function love.update(dt)
  -- Handle camera movement with arrow keys
  input.handleCameraMovement(dt)

  -- Update debug information
  dbg.update(dt)
end

-- LÖVE draw callback
function love.draw()
  -- Clear screen
  love.graphics.clear(0.1, 0.1, 0.2)

  -- Sort cubes for proper isometric rendering (back to front)
  camera.sortByDepth(world.cubes)

  -- Draw all cubes
  for _, cubeObj in ipairs(world.cubes) do
    cube.drawCube(cubeObj)
  end

  -- Draw debug overlay
  dbg.draw()
end

-- LÖVE keypressed callback
function love.keypressed(key)
  -- Pass key events to modules
  dbg.keypressed(key)
  input.keypressed(key)
end

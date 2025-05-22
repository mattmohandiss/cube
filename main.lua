-- Require modules
local camera = require('camera')
local cube = require('cube')
local dbg = require('dbg')

-- World data
local world = {
  cubes = {}  -- Will hold all our cubes
}

-- LÖVE load callback
function love.load()
  -- Initialize debug module
  dbg.init()
  
  -- Set up initial camera position for debug display
  local debugModule = require('dbg')
  debugModule.setValue("Camera Position", string.format("x=%.2f, y=%.2f", camera.position.x, camera.position.y))
  
  -- Create some cubes at different positions
  table.insert(world.cubes, cube.new(0, 0, 0, {1, 1, 1}))       -- Center white cube
  table.insert(world.cubes, cube.new(1, 0, 0, {1, 0.5, 0.5}))   -- Red cube to the east
  table.insert(world.cubes, cube.new(0, 1, 0, {0.5, 1, 0.5}))   -- Green cube to the south
  table.insert(world.cubes, cube.new(-1, 0, 0, {0.5, 0.5, 1}))  -- Blue cube to the west
  table.insert(world.cubes, cube.new(0, -1, 0, {1, 1, 0.5}))    -- Yellow cube to the north
  table.insert(world.cubes, cube.new(0, 0, 1, {1, 0.5, 1}))     -- Purple cube on top of center
  
  -- Add debug values
  debugModule.setValue("Number of Cubes", #world.cubes)
  debugModule.setValue("Movement Speed", camera.moveSpeed)
end

-- LÖVE update callback
function love.update(dt)
  -- Handle camera movement with arrow keys
  camera.handleInput()
  
  -- Update debug information
  dbg.update(dt)
end

-- LÖVE draw callback
function love.draw()
  -- Clear screen
  love.graphics.clear(0.1, 0.1, 0.2)
  
  -- Sort cubes by distance for proper rendering (back to front)
  -- Include z-value in the sorting algorithm for proper 3D depth sorting
  table.sort(world.cubes, function(a, b)
    return (a.x + a.y + a.z) > (b.x + b.y + b.z)
  end)
  
  -- Draw all cubes
  for _, cubeObj in ipairs(world.cubes) do
    cube.drawCube(cubeObj)
  end
  
  -- Draw debug overlay
  dbg.draw()
end

-- LÖVE keypressed callback
function love.keypressed(key)
  -- Pass key events to debug module
  dbg.keypressed(key)
  
  -- Exit on escape
  if key == "escape" then
    love.event.quit()
  end
  
  -- Adjust camera speed
  if key == "pageup" then
    camera.moveSpeed = camera.moveSpeed * 1.5
    dbg.setValue("Movement Speed", camera.moveSpeed)
  elseif key == "pagedown" then
    camera.moveSpeed = camera.moveSpeed * 0.75
    dbg.setValue("Movement Speed", camera.moveSpeed)
  end
end

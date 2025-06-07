-- entity/examples/worker_example.lua
-- Example usage of worker entity type

local entity = require('entity').init()
local worker_type = require('entity.types.worker')

-- Register the worker type with the entity system
entity.registerType("worker", worker_type.new)

-- Example functions demonstrating worker entity usage
local worker_example = {}

-- Create a worker entity
function worker_example.createWorker(x, y, z)
  -- Create a worker at specified position
  local worker = entity.createType("worker", x, y, z, {
    direction = "south", -- Initial direction
    speed = 3            -- Movement speed
  })
  
  return worker
end

-- Example of worker movement
function worker_example.demonstrateMovement(worker)
  -- Move the worker in different directions
  worker:moveEast()      -- Start moving east
  
  -- After 1 second, change direction
  love.timer.setTimeout(1, function()
    worker:moveSouth()   -- Change to moving south
  end)
  
  -- After 2 seconds, stop
  love.timer.setTimeout(2, function()
    worker:stop()        -- Stop movement
    worker:face("north") -- Face north while standing still
  end)
  
  -- After 3 seconds, use moveTo for pathfinding
  love.timer.setTimeout(3, function()
    -- Move to target position (10, 10, 0)
    local target_reached = worker:moveTo(10, 10, 0)
    if target_reached then
      print("Worker reached target immediately")
    else
      print("Worker moving to target")
    end
  end)
end

-- Example of worker task assignment
function worker_example.assignTask(worker)
  -- Assign a harvesting task
  worker:setTask("harvest", {
    crop_type = "wheat",
    location = {x = 15, y = 15, z = 0},
    quantity = 10
  })
  
  -- Print current task
  if worker.task then
    print("Worker assigned task: " .. worker.task.name)
    print("Crop type: " .. worker.task.data.crop_type)
  else
    print("Worker has no task")
  end
  
  -- After 5 seconds, clear the task
  love.timer.setTimeout(5, function()
    worker:clearTask()
    print("Worker task cleared")
  end)
end

-- Example of updating and rendering worker entities
local workers = {}

function worker_example.initializeExample()
  -- Create several workers at different positions
  table.insert(workers, worker_example.createWorker(5, 5, 0))
  table.insert(workers, worker_example.createWorker(10, 5, 0))
  table.insert(workers, worker_example.createWorker(15, 5, 0))
  
  -- Set different directions for each worker
  workers[1]:face("south")
  workers[2]:face("east")
  workers[3]:face("west")
  
  -- Start movement for first worker
  worker_example.demonstrateMovement(workers[1])
  
  -- Assign task to second worker
  worker_example.assignTask(workers[2])
  
  -- Make third worker move to a target
  workers[3]:moveTo(20, 10, 0)
end

-- Update function to be called in love.update
function worker_example.update(dt)
  -- Update all workers
  entity.updateAll(workers, dt)
  
  -- Check if any moving workers reached their targets
  for i, worker in ipairs(workers) do
    if worker.task and worker.task.name == "moving_to_target" then
      -- Example of checking if target reached during moveTo
      local target = worker.task.data.target
      if worker:moveTo(target.x, target.y, target.z) then
        print("Worker " .. i .. " reached target!")
        worker:clearTask()
      end
    end
  end
end

-- Draw function to be called in love.draw
function worker_example.draw(camera_position, view_distance)
  -- Update entity renderer with camera information
  entity.updateRenderer(camera_position, view_distance)
  
  -- Draw all workers
  entity.drawAll(workers)
end

return worker_example

-- input/keyboard.lua
-- Keyboard input handling

local events = require('events')

local keyboard = {}
-- Track debug visualization state
local debugVisualizationEnabled = false

-- Handle worker movement with WASD keys
function keyboard.handleWorkerMovement(core, key)
    local entities = core.world.getEntities()
    if #entities > 0 then
        local worker = entities[1]
        
        -- Worker movement controls
        if key == "w" then
            worker:moveNorth()
            events.debug.world_stats_updated.notify("Worker Movement", "North")
        elseif key == "s" then
            worker:moveSouth()
            events.debug.world_stats_updated.notify("Worker Movement", "South")
        elseif key == "a" then
            worker:moveWest()
            events.debug.world_stats_updated.notify("Worker Movement", "West")
        elseif key == "d" then
            worker:moveEast()
            events.debug.world_stats_updated.notify("Worker Movement", "East")
        elseif key == "space" then
            worker:stop()
            events.debug.world_stats_updated.notify("Worker Movement", "Stopped")
        end
    end
end

-- Handle keyboard input for camera movement
function keyboard.handleCameraMovement(core, dt)
    -- Get speed directly from camera
    local speed = core.camera.moveSpeed
    
    if love.keyboard.isDown("up") then 
        core.camera.move(0, -speed * dt) 
    end
    if love.keyboard.isDown("down") then 
        core.camera.move(0, speed * dt) 
    end
    if love.keyboard.isDown("left") then 
        core.camera.move(-speed * dt, 0) 
    end
    if love.keyboard.isDown("right") then 
        core.camera.move(speed * dt, 0) 
    end
end

-- Handle key press events
function keyboard.keypressed(core, key)
    -- Worker movement
    keyboard.handleWorkerMovement(core, key)
    
    -- Adjust camera speed
    if key == "pageup" then
        core.camera.moveSpeed = core.camera.moveSpeed * 1.5
        events.debug.world_stats_updated.notify("Movement Speed", core.camera.moveSpeed)
    elseif key == "pagedown" then
        core.camera.moveSpeed = core.camera.moveSpeed * 0.75
        events.debug.world_stats_updated.notify("Movement Speed", core.camera.moveSpeed)
    elseif key == "escape" then
        love.event.quit()
    -- Toggle debug visualization
    elseif key == "`" then
        -- Toggle the debug state
        debugVisualizationEnabled = not debugVisualizationEnabled
        events.system.debug_toggle.notify(debugVisualizationEnabled)
    -- Toggle cube outlines
    elseif key == "o" then
        events.system.toggle_cube_outlines.notify()
    end
end

return keyboard

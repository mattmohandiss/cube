-- input/keyboard.lua
-- Keyboard input handling

local events = require('events')

local keyboard = {}

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
    -- Adjust camera speed
    if key == "pageup" then
        core.camera.moveSpeed = core.camera.moveSpeed * 1.5
        events.world_stats_updated.notify("Movement Speed", core.camera.moveSpeed)
    elseif key == "pagedown" then
        core.camera.moveSpeed = core.camera.moveSpeed * 0.75
        events.world_stats_updated.notify("Movement Speed", core.camera.moveSpeed)
    elseif key == "escape" then
        love.event.quit()
    end
end

return keyboard

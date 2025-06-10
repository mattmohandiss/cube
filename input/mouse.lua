-- input/mouse.lua
-- Mouse input handling

local events = require('events')

local mouse = {}

-- Zoom speed factor - how much each wheel movement affects zoom
mouse.zoomSpeed = 1

-- Handle mouse wheel for camera zooming
function mouse.handleCameraZoom(core, y)
    -- Pass the wheel movement to the camera zoom function
    -- Positive y means scrolling up (zoom in), negative means scrolling down (zoom out)
    local success, newZoom = core.camera.zoom(y * mouse.zoomSpeed)
    
    -- Notify of zoom change via events for debug display
    if success then
        events.debug.world_stats_updated.notify("Camera Zoom", newZoom)
    end
end

return mouse

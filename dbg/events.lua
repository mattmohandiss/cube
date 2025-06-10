-- dbg/events.lua
-- Event handling and subscriptions for debug information

local events = require('events')

local eventHandlers = {}

-- Initialize event handlers
function eventHandlers.init(setValue)
    -- Subscribe to camera movement events
    events.app.camera_moved.listen(function(x, y)
        setValue("Camera Position", string.format("x=%.2f, y=%.2f", x, y))
    end)
    
    -- Subscribe to projection events
    events.app.projection_factor_updated.listen(function(factor)
        setValue("Projection Factor", factor)
    end)
    
    -- Subscribe to world stats events
    events.debug.world_stats_updated.listen(function(statName, value)
        setValue(statName, value)
    end)
    
    -- Add handlers for any cube-related events if they exist
    if events.debug.cube_face_info then
        events.debug.cube_face_info.listen(function(faceIndex, vertices)
            setValue("Cube Face", string.format("%d: %s", faceIndex, vertices))
        end)
    end
    
    if events.debug.cube_vertex_info then
        events.debug.cube_vertex_info.listen(function(vertexIndex, position)
            setValue("Cube Vertex " .. vertexIndex, position)
        end)
    end
end

return eventHandlers

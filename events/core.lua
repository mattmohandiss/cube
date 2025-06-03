-- events/core.lua
-- Core event system functionality

local core = {}

-- List of valid events
core.validEvents = {
  "camera_moved",
  "world_stats_updated", 
  "projection_factor_updated",
  "cube_face_info",
  "cube_vertex_info",
  "terrain_generated",
  "world_cube_created",
  "toggle_shader_rendering",
  "toggle_shader_outlines",
  "debug_toggle",
  "window_resized"
}

-- Internal storage for event listeners
core.listeners = {}

-- Initialize the event system
function core.init()
  -- Initialize listener arrays for each valid event
  for _, event in ipairs(core.validEvents) do
    core.listeners[event] = {}
  end
end

-- Add a listener to an event
function core.addListener(eventName, callback)
  -- Check if this is a valid event
  if not core.listeners[eventName] then
    error("Attempted to listen to unknown event: " .. eventName)
  end
  
  table.insert(core.listeners[eventName], callback)
end

-- Trigger an event with parameters
function core.triggerEvent(eventName, ...)
  -- Check if this is a valid event
  if not core.listeners[eventName] then
    error("Attempted to trigger unknown event: " .. eventName)
  end
  
  for _, callback in ipairs(core.listeners[eventName]) do
    callback(...)
  end
end

return core

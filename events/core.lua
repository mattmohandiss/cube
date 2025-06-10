-- events/core.lua
-- Core event system functionality with categorical support

local core = {}

-- Events organized by category
core.validEvents = {
  system = {
    "window_resized",
    "toggle_cube_outlines",
    "debug_toggle"
  },
  app = {
    "camera_moved",
    "camera_zoomed",
    "projection_factor_updated",
    "terrain_generated",
    "world_cube_created"
  },
  debug = {
    "world_stats_updated", 
    "cube_face_info",
    "cube_vertex_info"
  }
}

-- Initialize the event system
function core.init()
  -- Create listeners table with categories
  core.listeners = {}
  
  -- Initialize listener arrays for each category and event
  for category, events in pairs(core.validEvents) do
    core.listeners[category] = {}
    for _, eventName in ipairs(events) do
      core.listeners[category][eventName] = {}
    end
  end
  
  -- Provide a validation function for checking event existence
  function core.isValidEvent(category, eventName)
    return core.listeners[category] and core.listeners[category][eventName] ~= nil
  end
end

-- Add a listener to an event
function core.addListener(category, eventName, callback)
  -- Check if this is a valid event
  if not core.isValidEvent(category, eventName) then
    error("Attempted to listen to unknown event: " .. category .. "." .. eventName)
  end
  
  table.insert(core.listeners[category][eventName], callback)
  return callback  -- Return the callback for potential cancellation later
end

-- Trigger an event with parameters
function core.triggerEvent(category, eventName, ...)
  -- Check if this is a valid event
  if not core.isValidEvent(category, eventName) then
    error("Attempted to trigger unknown event: " .. category .. "." .. eventName)
  end
  
  -- Execute all callbacks for this event
  for _, callback in ipairs(core.listeners[category][eventName]) do
    callback(...)
  end
end

-- Remove a specific listener
function core.removeListener(category, eventName, callback)
  if not core.isValidEvent(category, eventName) then
    error("Attempted to remove listener from unknown event: " .. category .. "." .. eventName)
  end
  
  local eventListeners = core.listeners[category][eventName]
  for i = #eventListeners, 1, -1 do
    if eventListeners[i] == callback then
      table.remove(eventListeners, i)
      return true
    end
  end
  return false
end

return core

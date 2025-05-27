-- events/interface.lua
-- User-friendly interface for the event system

local core = require('events.core')

local interface = {}

-- Create the event interface
function interface.create()
  -- Create events table
  local events = {}
  
  -- Metatable for the main events table
  local eventsMT = {
    __index = function(tbl, key)
      -- Check if this is a valid event
      if not core.listeners[key] then
        error("Attempted to access unknown event: " .. key)
      end
      
      -- Create an event object with listen/notify methods
      -- Using closures to capture the event name (key)
      local eventObj = {
        listen = function(callback)
          core.addListener(key, callback)
        end,
        
        notify = function(...)
          core.triggerEvent(key, ...)
        end
      }
      
      -- Cache it for future access
      rawset(tbl, key, eventObj)
      
      return eventObj
    end
  }
  
  -- Apply the metatable
  setmetatable(events, eventsMT)
  
  return events
end

return interface

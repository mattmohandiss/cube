-- events/interface.lua
-- User-friendly interface for the categorized event system

local core = require('events.core')

local interface = {}

-- Create the event interface with categories
function interface.create()
  -- Create main events table
  local events = {}
  
  -- For each category, create a subtable with events
  for category, eventList in pairs(core.validEvents) do
    local categoryTable = {}
    events[category] = categoryTable
    
    -- Metatable for category tables
    local categoryMT = {
      __index = function(tbl, eventName)
        -- Check if this is a valid event
        if not core.isValidEvent(category, eventName) then
          error("Attempted to access unknown event: " .. category .. "." .. eventName)
        end
        
        -- Create an event object with listen/notify methods
        local eventObj = {
          -- Register a listener
          listen = function(callback)
            return core.addListener(category, eventName, callback)
          end,
          
          -- Trigger the event
          notify = function(...)
            core.triggerEvent(category, eventName, ...)
          end,
          
          -- Remove a specific listener
          unlisten = function(callback)
            return core.removeListener(category, eventName, callback)
          end
        }
        
        -- Cache the event object for future access
        rawset(tbl, eventName, eventObj)
        
        return eventObj
      end
    }
    
    -- Apply the metatable
    setmetatable(categoryTable, categoryMT)
  end
  
  return events
end

return interface

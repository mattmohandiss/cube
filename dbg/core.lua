-- dbg/core.lua
-- Core debug functionality: state management and value storage

local core = {}
local events = require('events')

-- Debug state properties
core.visible = true      -- Whether debug info is visible
core.values = {}         -- Table to store custom debug values
core.updateInterval = 0.5 -- How often to update slower-changing values
core.timeSinceUpdate = 0  -- Time accumulator for updates

-- Initialize core debug functionality
function core.init()
    -- Initialize fonts
    core.font = love.graphics.getFont()
    core.debugFont = love.graphics.newFont(12)
    
    -- Setup debug toggle event
    events.debug_toggle.listen(function(isVisible)
        -- If parameter is provided, set to that value, otherwise toggle
        if isVisible ~= nil then
            core.visible = isVisible
        else
            core.toggle()
        end
        
        -- Notify about state change
        events.world_stats_updated.notify("Debug Mode", core.visible and "Enabled" or "Disabled")
    end)
end

-- Set a custom debug value
function core.setValue(name, value)
    core.values[name] = value
end

-- Toggle debug display visibility
function core.toggle()
    core.visible = not core.visible
end

return core

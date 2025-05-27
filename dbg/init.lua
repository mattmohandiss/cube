-- dbg/init.lua
-- Debug module to display performance metrics and debug information

-- Internal module requires
local core = require('dbg.core')
local metrics = require('dbg.metrics')
local eventHandlers = require('dbg.events')
local rendering = require('dbg.rendering')

-- Create the main debug object
local dbg = {}

-- Initialize the debug module
function dbg.init()
    -- Initialize core components
    core.init()
    metrics.init()
    
    -- Set up initial debug values
    core.setValue("Average Frame Time", "0 ms")
    core.setValue("Camera Tile Size", 0)
    
    -- Initialize event handlers with setValue function
    eventHandlers.init(core.setValue)
    
    -- Expose properties
    dbg.visible = core.visible
    dbg.setValue = core.setValue
    dbg.toggle = core.toggle
end

-- Update debug values
function dbg.update(dt)
    -- Update metrics
    local fps, memory, avgFrameTime = metrics.update(dt)
    
    -- Update slower-changing values less frequently
    core.timeSinceUpdate = core.timeSinceUpdate + dt
    if core.timeSinceUpdate >= core.updateInterval then
        core.timeSinceUpdate = 0
        
        -- Update average frame time display
        core.setValue("Average Frame Time", string.format("%.2f ms", avgFrameTime * 1000))
    end
end

-- Draw debug information
function dbg.draw()
    rendering.draw(core, metrics)
end

-- Handle keypresses for debug functionality
function dbg.keypressed(key)
    if key == "f3" then
        core.toggle()
    end
end

return dbg

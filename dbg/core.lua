-- dbg/core.lua
-- Core debug functionality: state management and value storage

local core = {}

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

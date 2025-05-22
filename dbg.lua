-- Debug module to display performance metrics and debug information
local dbg = {
    visible = true,     -- Whether debug info is visible
    values = {},        -- Table to store custom debug values
    fps = 0,            -- Current FPS
    memoryUsage = 0,    -- Memory usage in KB
    updateInterval = 0.5, -- How often to update slower-changing values (in seconds)
    timeSinceUpdate = 0   -- Time accumulator for updates
}

-- Initialize the debug module
function dbg.init()
    -- Debug state
    dbg.font = love.graphics.getFont()
    dbg.debugFont = love.graphics.newFont(12)
    dbg.frameTime = 0
    dbg.frameCount = 0
    dbg.frameTimes = {}
    dbg.avgFrameTime = 0
    
    -- Add some default debug values
    dbg.setValue("Camera Tile Size", 0)
    dbg.setValue("Average Frame Time", "0 ms")
end

-- Update debug values
function dbg.update(dt)
    -- Track frame time for performance metrics
    dbg.frameTime = dt
    dbg.frameCount = dbg.frameCount + 1
    
    -- Keep track of recent frame times for averaging (last 30 frames)
    table.insert(dbg.frameTimes, dt)
    if #dbg.frameTimes > 30 then
        table.remove(dbg.frameTimes, 1)
    end
    
    -- Calculate average frame time
    local sum = 0
    for _, time in ipairs(dbg.frameTimes) do
        sum = sum + time
    end
    dbg.avgFrameTime = sum / #dbg.frameTimes
    
    -- Update FPS every frame
    dbg.fps = love.timer.getFPS()
    
    -- Update slower-changing values less frequently
    dbg.timeSinceUpdate = dbg.timeSinceUpdate + dt
    if dbg.timeSinceUpdate >= dbg.updateInterval then
        dbg.timeSinceUpdate = 0
        
        -- Update memory usage
        dbg.memoryUsage = collectgarbage("count")
        
        -- Update camera tile size from the camera module
        local camera = require("camera")
        dbg.setValue("Camera Tile Size", camera.tileSize)
        
        -- Update average frame time
        dbg.setValue("Average Frame Time", string.format("%.2f ms", dbg.avgFrameTime * 1000))
    end
end

-- Set a custom debug value
function dbg.setValue(name, value)
    dbg.values[name] = value
end

-- Toggle debug display visibility
function dbg.toggle()
    dbg.visible = not dbg.visible
end

-- Draw debug information
function dbg.draw()
    if not dbg.visible then
        return
    end
    
    -- Store current graphics state
    local prevFont = love.graphics.getFont()
    local r, g, b, a = love.graphics.getColor()
    
    -- Set drawing properties for debug info
    love.graphics.setFont(dbg.debugFont)
    love.graphics.setColor(1, 1, 1, 0.8)
    
    -- Start position
    local x, y = 10, 10
    local lineHeight = 15
    
    -- Draw performance section
    love.graphics.print("Performance:", x, y)
    y = y + lineHeight
    love.graphics.print(string.format(" • FPS: %d", dbg.fps), x, y)
    y = y + lineHeight
    love.graphics.print(string.format(" • Memory: %.2f MB", dbg.memoryUsage / 1024), x, y)
    y = y + lineHeight
    
    -- Draw system section
    love.graphics.print("System:", x, y)
    y = y + lineHeight
    local screenWidth, screenHeight = love.graphics.getDimensions()
    love.graphics.print(string.format(" • Screen: %dx%d", screenWidth, screenHeight), x, y)
    y = y + lineHeight
    
    -- Draw custom debug values
    love.graphics.print("Application:", x, y)
    y = y + lineHeight
    
    for name, value in pairs(dbg.values) do
        local valueStr = tostring(value)
        -- Format tables to show their contents
        if type(value) == "table" then
            valueStr = "table"
        end
        
        love.graphics.print(string.format(" • %s: %s", name, valueStr), x, y)
        y = y + lineHeight
    end
    
    -- Restore previous graphics state
    love.graphics.setFont(prevFont)
    love.graphics.setColor(r, g, b, a)
end

-- Handle keypresses for debug functionality
function dbg.keypressed(key)
    if key == "f3" then
        dbg.toggle()
    end
end

return dbg

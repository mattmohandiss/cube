-- dbg/rendering.lua
-- Debug information display and rendering

local rendering = {}

-- Draw debug information
function rendering.draw(core, metrics)
    if not core.visible then
        return
    end

    -- Store current graphics state
    local prevFont = love.graphics.getFont()
    local r, g, b, a = love.graphics.getColor()

    -- Set drawing properties
    love.graphics.setFont(core.debugFont)
    love.graphics.setColor(1, 1, 1, 0.8)

    -- Start position and layout
    local x, y = 10, 10
    local lineHeight = 15

    -- Draw performance section
    y = rendering.drawPerformanceSection(x, y, lineHeight, metrics)
    
    -- Draw system section
    y = rendering.drawSystemSection(x, y, lineHeight)
    
    -- Draw custom values section
    rendering.drawCustomValuesSection(x, y, lineHeight, core.values)

    -- Restore previous graphics state
    love.graphics.setFont(prevFont)
    love.graphics.setColor(r, g, b, a)
end

-- Draw performance metrics
function rendering.drawPerformanceSection(x, y, lineHeight, metrics)
    love.graphics.print("Performance:", x, y)
    y = y + lineHeight
    love.graphics.print(string.format(" • FPS: %d", metrics.fps), x, y)
    y = y + lineHeight
    love.graphics.print(string.format(" • Memory: %.2f MB", metrics.memoryUsage / 1024), x, y)
    y = y + lineHeight
    love.graphics.print(string.format(" • Frame Time: %.2f ms", metrics.avgFrameTime * 1000), x, y)
    y = y + lineHeight
    return y
end

-- Draw system information
function rendering.drawSystemSection(x, y, lineHeight)
    love.graphics.print("System:", x, y)
    y = y + lineHeight
    local screenWidth, screenHeight = love.graphics.getDimensions()
    love.graphics.print(string.format(" • Screen: %dx%d", screenWidth, screenHeight), x, y)
    y = y + lineHeight
    return y
end

-- Draw custom debug values
function rendering.drawCustomValuesSection(x, y, lineHeight, values)
    love.graphics.print("Application:", x, y)
    y = y + lineHeight

    for name, value in pairs(values) do
        local valueStr = tostring(value)
        -- Format tables to show their contents
        if type(value) == "table" then
            valueStr = "table"
        end

        love.graphics.print(string.format(" • %s: %s", name, valueStr), x, y)
        y = y + lineHeight
    end
    
    return y
end

return rendering

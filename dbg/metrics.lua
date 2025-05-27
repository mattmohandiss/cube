-- dbg/metrics.lua
-- Performance metrics tracking and calculation

local metrics = {}

-- Initialize performance metrics
function metrics.init()
    metrics.fps = 0
    metrics.memoryUsage = 0
    metrics.frameTime = 0
    metrics.frameCount = 0
    metrics.frameTimes = {}
    metrics.avgFrameTime = 0
end

-- Update performance metrics
function metrics.update(dt)
    -- Track frame time
    metrics.frameTime = dt
    metrics.frameCount = metrics.frameCount + 1
    
    -- Update frame time tracking
    table.insert(metrics.frameTimes, dt)
    if #metrics.frameTimes > 30 then
        table.remove(metrics.frameTimes, 1)
    end
    
    -- Calculate average
    local sum = 0
    for _, time in ipairs(metrics.frameTimes) do
        sum = sum + time
    end
    metrics.avgFrameTime = sum / #metrics.frameTimes
    
    -- Update FPS
    metrics.fps = love.timer.getFPS()
    
    -- Update memory usage
    metrics.memoryUsage = collectgarbage("count")
    
    return metrics.fps, metrics.memoryUsage, metrics.avgFrameTime
end

return metrics

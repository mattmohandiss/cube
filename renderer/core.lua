-- renderer/core.lua
-- Core rendering shader loading and management functionality

local core = {}
local events = require('events')

-- Initialize all shaders
function core.init()
    -- Load cube rendering shader
    core.cube = core.load("renderer/shaders/cube/vertex.glsl", "renderer/shaders/cube/fragment.glsl")
    
    -- Set default uniform values
    local screenWidth, screenHeight = love.graphics.getDimensions()
    core.cube:send("screenSize", {screenWidth, screenHeight})
    core.cube:send("tileSize", 15) -- Same as in camera module
    core.cube:send("showDebugInfo", false)
    core.cube:send("enableOutlines", true) -- Enable cube outlines by default
    
    -- Subscribe to window resize events
    events.window_resized.listen(function(width, height)
        core.cube:send("screenSize", {width, height})
    end)
    
    return core
end

-- Load a shader from external files
function core.load(vertexPath, fragmentPath)
    -- Read shader files
    local vertexSource = love.filesystem.read(vertexPath)
    local fragmentSource = love.filesystem.read(fragmentPath)
    
    if not vertexSource then
        error("Could not load vertex shader: " .. vertexPath)
    end
    
    if not fragmentSource then
        error("Could not load fragment shader: " .. fragmentPath)
    end
    
    -- Create shader object
    local shader = love.graphics.newShader(vertexSource, fragmentSource)
    
    -- Check for errors
    if not shader then
        error("Failed to create shader")
    end
    
    return shader
end

-- Update shader uniforms
function core.updateCubeShader(cameraPosition, viewDistance)
    -- Ensure we have a valid z-coordinate (default to 0 if missing)
    local z = cameraPosition.z or 0
    core.cube:send("cameraPosition", {cameraPosition.x, cameraPosition.y, z})
    core.cube:send("viewDistance", viewDistance)
end

-- Toggle debug visualization
function core.toggleDebug(enabled)
    core.cube:send("showDebugInfo", enabled)
end

-- Toggle cube outlines
function core.toggleOutlines(enabled)
    -- Print debug info to help troubleshoot
    print("Toggling cube outlines: " .. tostring(enabled))
    
    -- Send the value to the shader
    core.cube:send("enableOutlines", enabled)
    
    -- Force the GPU to apply the uniform change immediately
    love.graphics.flushBatch()
    
    -- Ensure the value is set properly
    local value = enabled and "true" or "false"
    print("Shader uniform 'enableOutlines' set to: " .. value)
end

return core

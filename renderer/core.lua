---@diagnostic disable: missing-fields
-- renderer/core.lua
-- Core rendering shader loading and management functionality

local core = {}
local events = require('events')
local registry = require('renderer.registry')

-- Registered shaders collection
core.shaders = {}

-- Initialize renderer core
function core.init()
    -- Initialize registry
    core.registry = registry
    
    -- Get screen dimensions
    local screenWidth, screenHeight = love.graphics.getDimensions()
    
    -- Subscribe to window resize events
    events.window_resized.listen(function(width, height)
        -- Update all registered shaders with new screen size
        for _, shader in pairs(core.shaders) do
            if shader then
                shader:send("screenSize", {width, height})
            end
        end
    end)
    
    return core
end

-- Load a shader from external files and register it by name
function core.loadShader(name, vertexPath, fragmentPath)
    -- Create shader object
    local shader = love.graphics.newShader(vertexPath, fragmentPath)
    
    -- Check for errors
    if not shader then
        error("Failed to create shader")
    end
    
    -- Set default screen size
    local screenWidth, screenHeight = love.graphics.getDimensions()
    shader:send("screenSize", {screenWidth, screenHeight})
    
    -- Register the shader
    core.shaders[name] = shader
    
    return shader
end

-- Get a registered shader by name
function core.getShader(name)
    return core.shaders[name]
end

-- Update shader uniform values
function core.updateShaderCamera(shader, cameraPosition, viewDistance)
    if not shader then return end
    
    -- Ensure we have a valid z-coordinate (default to 0 if missing)
    local z = cameraPosition.z or 0
    
    -- Send camera position to shader
    if shader:hasUniform("cameraPosition") then
        shader:send("cameraPosition", {cameraPosition.x, cameraPosition.y, z})
    end
    
    -- Send view distance to shader if it has that uniform
    if viewDistance and shader:hasUniform("viewDistance") then
        shader:send("viewDistance", viewDistance)
    end
end

-- Toggle debug visualization on a shader
function core.toggleShaderDebug(shader, enabled)
    if not shader then return end
    
    if shader:hasUniform("showDebugInfo") then
        shader:send("showDebugInfo", enabled)
    end
end

-- Toggle outlines on a shader
function core.toggleShaderOutlines(shader, enabled)
    if not shader then return end
    
    if shader:hasUniform("enableOutlines") then
        -- Send the value to the shader
        shader:send("enableOutlines", enabled)
        
        -- Force the GPU to apply the uniform change immediately
        love.graphics.flushBatch()
    end
end

-- Render shapes using the appropriate renderers
function core.renderShapes(shapes, cameraPosition)
    -- Group shapes by type
    local shapesByType = {}
    
    for _, shape in ipairs(shapes) do
        local shapeType = shape.type or "default"
        
        if not shapesByType[shapeType] then
            shapesByType[shapeType] = {}
        end
        
        table.insert(shapesByType[shapeType], shape)
    end
    
    -- Render each shape type using its registered renderer
    for shapeType, instances in pairs(shapesByType) do
        local renderer = registry.getShapeRenderer(shapeType)
        if renderer then
            renderer:render(instances, cameraPosition)
        end
    end
end

-- Render billboards using the appropriate renderers
function core.renderBillboards(billboards, cameraPosition)
    -- Group billboards by type
    local billboardsByType = {}
    
    for _, billboard in ipairs(billboards) do
        local billboardType = billboard.type or "default"
        
        if not billboardsByType[billboardType] then
            billboardsByType[billboardType] = {}
        end
        
        table.insert(billboardsByType[billboardType], billboard)
    end
    
    -- Render each billboard type using its registered renderer
    for billboardType, instances in pairs(billboardsByType) do
        local renderer = registry.getBillboardRenderer(billboardType)
        if renderer then
            renderer:render(instances, cameraPosition)
        end
    end
end

return core

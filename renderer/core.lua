---@diagnostic disable: missing-fields
-- renderer/core.lua
-- Core rendering shader loading and management functionality

local core = {}
local events = require('events')
local registry = require('renderer.registry')

-- Registered shaders collection
core.shaders = {}

-- Configuration for unified depth handling
core.depthConfig = {
    standardScale = 200.0,  -- The divisor used to normalize world depth to NDC
    zFighting = 0.001,      -- Small offset to prevent Z-fighting
    billboardOffset = 0.01  -- Slight offset for billboards to prevent Z-fighting with cubes
}

-- Initialize renderer core
function core.init()
    -- Initialize registry
    core.registry = registry
    
    -- Get screen dimensions
    local screenWidth, screenHeight = love.graphics.getDimensions()
    
    -- Subscribe to window resize events
    events.system.window_resized.listen(function(width, height)
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

-- Unified depth calculation function
function core.calculateDepth(x, y, z, objectType)
    local worldDepth = -x - y - z * 2
    
    -- Apply slight offsets based on object type to prevent Z-fighting
    if objectType == "billboard" then
        worldDepth = worldDepth + core.depthConfig.billboardOffset
    end
    
    -- Normalize to NDC space (-1 to 1)
    return worldDepth / core.depthConfig.standardScale
end

-- Function to set depth testing mode based on object properties
function core.setDepthMode(transparent)
    if transparent then
        -- For transparent objects: test against depth buffer but don't write to it
        love.graphics.setDepthMode("lequal", false)
    else
        -- For opaque objects: test against and write to depth buffer
        love.graphics.setDepthMode("lequal", true)
    end
end

-- Central function to update all registered shaders with camera information
function core.updateAllShadersWithCamera(cameraPosition)
    for name, shader in pairs(core.shaders) do
        if shader then
            -- Update camera position
            if shader:hasUniform("cameraPosition") then
                shader:send("cameraPosition", {
                    cameraPosition.x or 0,
                    cameraPosition.y or 0,
                    cameraPosition.z or 0
                })
            end
            
            -- Update screenSize (in case it changed)
            if shader:hasUniform("screenSize") then
                local w, h = love.graphics.getDimensions()
                shader:send("screenSize", {w, h})
            end
            
            -- Update tileSize if the shader uses it
            if shader:hasUniform("tileSize") then
                local camera = require('camera')
                shader:send("tileSize", camera.projection.tileSize)
            end
            
            -- Update depthScale if the shader uses it
            if shader:hasUniform("depthScale") then
                shader:send("depthScale", core.depthConfig.standardScale)
            end
        end
    end
    
    -- Force GPU to apply the uniform changes
    love.graphics.flushBatch()
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

-- Rendering pass types
core.PASS = {
    OPAQUE = 1,      -- Fully opaque objects that write to depth buffer
    TRANSPARENT = 2  -- Objects with transparency that don't write to depth
}

-- Function to perform rendering in the correct order
function core.renderScene(scene, cameraPosition)
    -- Update all shaders with camera info
    core.updateAllShadersWithCamera(cameraPosition)
    
    -- FIRST PASS: Render opaque objects
    -- Clear depth buffer before first pass
    love.graphics.clear(false, true)
    
    -- Render opaque cubes
    if scene.cubes and #scene.cubes > 0 then
        local cubeRenderer = registry.getShapeRenderer("cube")
        if cubeRenderer then
            -- Set depth mode for opaque objects
            core.setDepthMode(false)
            cubeRenderer:render(scene.cubes, cameraPosition)
        end
    end
    
    -- SECOND PASS: Render transparent objects
    -- Billboards are typically transparent
    if scene.entities and #scene.entities > 0 then
        local entityRenderer = registry.getBillboardRenderer("entity_billboard")
        if entityRenderer then
            -- Sort entities by depth (back to front is important for transparency)
            table.sort(scene.entities, function(a, b)
                return a.depth > b.depth
            end)
            
            -- Set depth mode for transparent objects
            core.setDepthMode(true)
            entityRenderer:render(scene.entities, cameraPosition)
        end
    end
    
    -- Reset graphics state
    love.graphics.setDepthMode()
    love.graphics.setBlendMode("alpha")
    love.graphics.setShader()
end

return core

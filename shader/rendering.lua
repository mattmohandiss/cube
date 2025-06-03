-- shader/rendering.lua
-- GPU-based cube rendering system using shaders and instanced drawing

local rendering = {}

local events = require('events')
local dbg = require('dbg')
local camera = require('camera')
local shaderCore = require('shader.core')
local shaderMesh = require('shader.mesh')

-- Configuration
rendering.enabled = true
rendering.viewDistance = 64

-- Internal state
local baseCubeMesh = nil
local instanceMesh = nil
local instanceCount = 0

-- Initialize the shader renderer
function rendering.init()
    -- Check if instanced rendering is supported
    local supported = love.graphics.getSupported()
    -- for key, value in pairs(supported) do
    --     print(key .. ": " .. tostring(value))
    -- end
    if not supported.instancing then
        print("Warning: Instanced rendering is not supported on this GPU.")
        print("Falling back to CPU-based rendering.")
        rendering.enabled = false
        events.world_stats_updated.notify("Shader Rendering", "Not Supported")
        return false
    end
    
    -- Initialize shaders
    shaderCore.init()
    
    -- Create base cube mesh
    baseCubeMesh = shaderMesh.create()
    
    -- Add debug information
    dbg.setValue("Shader Rendering", "Enabled")
    events.world_stats_updated.notify("Shader Rendering", "Enabled")
    dbg.setValue("Draw Calls (Shader)", 0)
    dbg.setValue("Instances Rendered", 0)
    dbg.setValue("Total Triangles", 0)
    
    -- Subscribe to debug toggle
    events.debug_toggle.listen(function(isVisible)
        shaderCore.toggleDebug(isVisible)
    end)
    
    return true
end

-- Create or update instance data
function rendering.updateInstanceData(visibleCubes)
    -- Create new instance data
    local newInstanceMesh, newInstanceCount = shaderMesh.createInstanceData(visibleCubes)
    
    -- Update state
    if instanceMesh then
        instanceMesh:release() -- Release previous mesh to avoid memory leaks
    end
    
    instanceMesh = newInstanceMesh
    instanceCount = newInstanceCount
    
    -- Attach instance attributes to the base mesh
    baseCubeMesh:attachAttribute("InstancePosition", instanceMesh, "perinstance")
    baseCubeMesh:attachAttribute("InstanceColor", instanceMesh, "perinstance")
    baseCubeMesh:attachAttribute("InstanceVisibility", instanceMesh, "perinstance")
    
    return instanceCount
end

-- Render cubes using the shader
function rendering.render(cubes, cameraPosition)
    if not rendering.enabled or not baseCubeMesh then
        return cubes -- pass through to standard renderer if disabled or not initialized
    end
    
    -- Update shader uniforms
    shaderCore.updateCubeShader(cameraPosition, rendering.viewDistance)
    
    -- Update instance data
    rendering.updateInstanceData(cubes)
    
    -- Render all cubes in a single draw call
    love.graphics.setShader(shaderCore.cube)
    
    -- Ensure outline settings are correctly applied before drawing
    local worldRendering = require('world.rendering')
    shaderCore.cube:send("enableOutlines", worldRendering.outlinesEnabled)
    
    -- Force shader to use the latest uniform values
    love.graphics.flushBatch()
    
    -- Debug information for troubleshooting
    print("Rendering with outlines: " .. tostring(worldRendering.outlinesEnabled))
    
    -- Draw the instanced cubes
    love.graphics.drawInstanced(baseCubeMesh, instanceCount)
    
    -- Reset the shader state
    love.graphics.setShader()
    
    -- Update debug stats
    local stats = love.graphics.getStats()
    dbg.setValue("Draw Calls (Shader)", stats.drawcalls)
    dbg.setValue("Instances Rendered", instanceCount)
    dbg.setValue("Total Triangles", instanceCount * 12) -- 12 triangles per cube (2 per face)
    
    return cubes
end

return rendering

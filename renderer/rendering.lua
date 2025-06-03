-- renderer/rendering.lua
-- GPU-based cube rendering system using shaders and instanced drawing

local rendering = {}

local events = require('events')
local dbg = require('dbg')
local camera = require('camera')
local shaderCore = require('renderer.core')
local shaderMesh = require('renderer.mesh')

-- Configuration
rendering.viewDistance = 64

-- Internal state
local baseCubeMesh = nil
local instanceMesh = nil
local instanceCount = 0

-- Initialize the renderer
function rendering.init()
    -- Check if instanced rendering is supported
    local supported = love.graphics.getSupported()
    
    if not supported.instancing then
        print("Error: Instanced rendering is not supported on this GPU.")
        print("GPU-based rendering is required for this application.")
        events.world_stats_updated.notify("GPU Rendering", "Not Supported")
        return false
    end
    
    -- Initialize shaders
    shaderCore.init()
    
    -- Create base cube mesh
    baseCubeMesh = shaderMesh.create()
    
    -- Add debug information
    dbg.setValue("GPU Rendering", "Enabled")
    events.world_stats_updated.notify("GPU Rendering", "Enabled")
    dbg.setValue("Draw Calls", 0)
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
    if not baseCubeMesh then
        error("Rendering system not properly initialized")
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
    
    -- Draw the instanced cubes
    love.graphics.drawInstanced(baseCubeMesh, instanceCount)
    
    -- Reset the shader state
    love.graphics.setShader()
    
    -- Update debug stats
    local stats = love.graphics.getStats()
    dbg.setValue("Draw Calls", stats.drawcalls)
    dbg.setValue("Instances Rendered", instanceCount)
    dbg.setValue("Total Triangles", instanceCount * 12) -- 12 triangles per cube (2 per face)
    
    return cubes
end

-- Function to toggle cube outlines
function rendering.toggleOutlines(enabled)
    return shaderCore.toggleOutlines(enabled)
end

return rendering

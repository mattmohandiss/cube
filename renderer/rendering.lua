-- renderer/rendering.lua
-- Core rendering system that delegates to shape-specific renderers

local rendering = {}

local events = require('events')
local dbg = require('dbg')
local camera = require('camera')
local rendererCore = require('renderer.core')
local registry = require('renderer.registry')

-- Configuration
rendering.viewDistance = 64

-- Initialize the renderer
function rendering.init()
    -- Check if instanced rendering is supported
    local supported = love.graphics.getSupported()
    
    if not supported.instancing then
        print("Error: Instanced rendering is not supported on this GPU.")
        print("GPU-based rendering is required for this application.")
        events.debug.world_stats_updated.notify("GPU Rendering", "Not Supported")
        return false
    end
    
    -- Initialize core renderer
    rendererCore.init()
    
    -- Load shape-specific renderers
    -- The cube renderer will register itself when loaded
    local cubeRenderer = require('cube.rendering')
    cubeRenderer:setViewDistance(rendering.viewDistance)
    
    -- Load billboard-specific renderers
    -- The entity billboard renderer will register itself when loaded
    local entityRenderer = require('entity.rendering')
    
    -- Add debug information
    dbg.setValue("GPU Rendering", "Enabled")
    events.debug.world_stats_updated.notify("GPU Rendering", "Enabled")
    dbg.setValue("Draw Calls", 0)
    
    return true
end

-- Render shapes using the registered shape renderers
-- This delegates to the appropriate shape renderers based on shape type
function rendering.renderShapes(shapes, cameraPosition)
    -- Delegate to core renderer
    rendererCore.renderShapes(shapes, cameraPosition)
    
    -- Update debug stats
    local stats = love.graphics.getStats()
    dbg.setValue("Draw Calls", stats.drawcalls)
    
    return shapes
end

-- Render billboards using the registered billboard renderers
-- This delegates to the appropriate billboard renderers based on billboard type
function rendering.renderBillboards(billboards, cameraPosition)
    -- Delegate to core renderer
    rendererCore.renderBillboards(billboards, cameraPosition)
    
    return billboards
end

-- Function to toggle shape outlines
function rendering.toggleOutlines(enabled)
    -- Get the cube renderer
    local cubeRenderer = registry.getShapeRenderer("cube")
    if cubeRenderer then
        return cubeRenderer:toggleOutlines(enabled)
    end
    return false
end

return rendering

-- shader/init.lua
-- Module entry point for shader system

-- Internal module requires
local core = require('shader.core')
local mesh = require('shader.mesh')
local rendering = require('shader.rendering')

-- Initialize the module
local function init()
    -- Call core init which sets up shaders
    core.init()
    
    -- Return the public API
    return {
        -- Configuration options
        enabled = rendering.enabled,
        viewDistance = rendering.viewDistance,
        
        -- Core functions
        init = rendering.init,
        render = rendering.render,
        toggleOutlines = core.toggleOutlines,
        
        -- Export child modules
        core = core,
        mesh = mesh
    }
end

-- Return the initialized module
return init()

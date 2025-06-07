-- input/core.lua
-- Core input functionality and initialization

local core = {}

-- Store references to other modules
core.camera = nil
core.world = nil  -- Add world module reference

-- Initialize core input functionality
function core.init()
    -- Load required modules and set up references
    core.camera = require('camera')
    core.world = require('world')  -- Add world module
end

return core

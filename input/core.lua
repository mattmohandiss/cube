-- input/core.lua
-- Core input functionality and initialization

local core = {}

-- Store references to other modules
core.camera = nil

-- Initialize core input functionality
function core.init()
    -- Load required modules and set up references
    core.camera = require('camera')
end

return core

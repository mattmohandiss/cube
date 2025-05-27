-- input/init.lua
-- Module to handle keyboard and other input

-- Internal module requires
local core = require('input.core')
local keyboard = require('input.keyboard')

-- Create the main input object
local input = {}

-- Initialize the input module
function input.init()
    -- Initialize core components
    core.init()
end

-- Handle keyboard input for camera movement
function input.handleCameraMovement(dt)
    keyboard.handleCameraMovement(core, dt)
end

-- Handle key press events
function input.keypressed(key)
    keyboard.keypressed(core, key)
end

return input

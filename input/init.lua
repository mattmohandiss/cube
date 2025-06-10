-- input/init.lua
-- Module to handle keyboard and other input

-- Internal module requires
local core = require('input.core')
local keyboard = require('input.keyboard')
local mouse = require('input.mouse')

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

-- Handle mouse wheel movement for zooming
function input.wheelmoved(x, y)
    mouse.handleCameraZoom(core, y)
end

return input

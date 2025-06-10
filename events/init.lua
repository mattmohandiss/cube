-- events/init.lua
-- Categorized event system using metatables to provide autocomplete and type safety

-- Internal module requires
local core = require('events.core')
local interface = require('events.interface')

-- Initialize the core system
core.init()

-- Create and return the public interface
return interface.create()

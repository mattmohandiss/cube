-- game/init.lua
-- Game module initialization and API

local game = {}

-- Load submodules
game.core = require('game.core')
game.entities = {}  -- Will contain entity types

-- Initialize the game module
function game.init()
  -- Initialize core functionality
  game.core.init()
  
  -- Register entity types with the entity system
  local entity = require('entity')
  
  -- Register the worker entity type
  entity.registerType('worker', require('game.entities.worker').new)
  
  return game
end

-- Create a worker entity at the specified position
function game.createWorker(x, y, z, config)
  return require('entity').createType('worker', x, y, z, config)
end

return game

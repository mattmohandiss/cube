-- game/core.lua
-- Core game functionality

local core = {}

-- Store references to other modules
local entity
local world

-- Initialize the game core
function core.init()
  -- Load required modules
  entity = require('entity')
  world = require('world')
end

-- Get a list of all available entity types
function core.getEntityTypes()
  local types = {}
  for typeName, _ in pairs(entity.types) do
    table.insert(types, typeName)
  end
  return types
end

return core

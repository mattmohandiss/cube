-- renderer/init.lua
-- Main entry point for the renderer module

-- Core rendering functionality
local rendering = require('renderer.rendering')

-- Create the public API
local renderer = {
  -- Initialization
  init = rendering.init,
  
  -- View distance configuration (may be adjusted by other modules)
  viewDistance = rendering.viewDistance,
  
  -- Rendering functions
  renderShapes = rendering.renderShapes,
  renderBillboards = rendering.renderBillboards,
  
  -- Visual options
  toggleOutlines = rendering.toggleOutlines
}

return renderer

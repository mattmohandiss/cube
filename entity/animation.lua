-- entity/animation.lua
-- Entity animation handling: spritesheets, frames, and state management

local animation = {}

-- Cached spritesheets
local spritesheets = {}

-- Initialize the animation system
function animation.init()
  -- Initialize animation system if needed
  spritesheets = {}
end

-- Load a spritesheet and cache it
function animation.loadSpritesheet(path, sprite_width, sprite_height)
  -- Check if already cached
  if spritesheets[path] then
    return spritesheets[path]
  end
  
  -- Load the image
  local image = love.graphics.newImage(path)
  if not image then
    error("Failed to load spritesheet: " .. path)
    return nil
  end
  
  -- Create the spritesheet data
  local sheet = {
    image = image,
    width = sprite_width or 16,
    height = sprite_height or 16,
    total_width = image:getWidth(),
    total_height = image:getHeight(),
    quads = {}
  }
  
  -- Calculate rows and columns
  sheet.cols = math.floor(sheet.total_width / sheet.width)
  sheet.rows = math.floor(sheet.total_height / sheet.height)
  
  -- Create quads for each sprite in the sheet
  for row = 0, sheet.rows - 1 do
    sheet.quads[row + 1] = {}
    for col = 0, sheet.cols - 1 do
      sheet.quads[row + 1][col + 1] = love.graphics.newQuad(
        col * sheet.width,
        row * sheet.height,
        sheet.width,
        sheet.height,
        sheet.total_width,
        sheet.total_height
      )
    end
  end
  
  -- Cache the spritesheet
  spritesheets[path] = sheet
  
  return sheet
end

-- Get a specific quad from a spritesheet
function animation.getQuad(spritesheet, row, col)
  if not spritesheet then return nil end
  if not spritesheet.quads[row] then return nil end
  return spritesheet.quads[row][col]
end

-- Get the current animation frame for an entity
function animation.getCurrentFrame(entity)
  if not entity or not entity.sprite_info then return nil end
  
  -- Get the animation definition for the current state
  local anim = entity.sprite_info.animations and 
               entity.sprite_info.animations[entity.state]
  
  if not anim then
    -- Default to first row, current frame
    return 1, entity.frame
  end
  
  -- Return the row and current frame
  return anim.row or 1, entity.frame
end

-- Apply animation system to an entity
function animation.apply(entity)
  -- Skip if no spritesheet info
  if not entity.sprite_info or not entity.sprite_info.spritesheet then
    return entity
  end
  
  -- Load the spritesheet if needed
  local sheet_path = entity.sprite_info.spritesheet
  local sheet = animation.loadSpritesheet(
    sheet_path,
    entity.sprite_info.width or entity.width,
    entity.sprite_info.height or entity.height
  )
  
  -- Store the sheet reference
  entity.spritesheet = sheet
  
  -- Override the updateAnimation method
  entity.updateAnimation = function(self, dt)
    -- Get the animation definition for the current state
    local anim = self.sprite_info.animations and 
                 self.sprite_info.animations[self.state]
    
    if not anim then
      -- No animation defined for this state, stay on frame 1
      self.frame = 1
      return
    end
    
    -- Update animation timer
    self.frame_timer = self.frame_timer + dt
    local duration = anim.duration or 1.0
    local frames = anim.frames or 1
    
    -- Check if it's time for the next frame
    if self.frame_timer >= (duration / frames) then
      -- Advance to next frame
      self.frame = self.frame + 1
      if self.frame > frames then
        self.frame = 1  -- Loop animation
      end
      -- Reset timer
      self.frame_timer = 0
    end
  end
  
  -- Add method to get current sprite quad
  entity.getCurrentQuad = function(self)
    local row, col = animation.getCurrentFrame(self)
    if not row or not col then return nil end
    return animation.getQuad(self.spritesheet, row, col)
  end
  
  return entity
end

-- Preload all spritesheets from a directory
function animation.preloadSpritesheets(directory, default_width, default_height)
  local items = love.filesystem.getDirectoryItems(directory)
  for _, item in ipairs(items) do
    local path = directory .. "/" .. item
    local info = love.filesystem.getInfo(path)
    if info and info.type == "file" then
      local ext = path:match("%.(%w+)$")
      if ext and (ext == "png" or ext == "jpg" or ext == "jpeg") then
        animation.loadSpritesheet(path, default_width, default_height)
      end
    end
  end
end

return animation

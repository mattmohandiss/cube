-- world/terrain.lua
-- Terrain generation using Perlin noise

local events = require('events')

local terrain = {}

-- Permutation table for Perlin noise
terrain.perm = {}

-- Initialize the terrain generator
function terrain.init(seed)
  -- Set up the permutation table with the given seed
  math.randomseed(seed)
  
  -- Create permutation table (standard Perlin noise uses a shuffled 0-255 sequence)
  local p = {}
  for i = 0, 255 do
    p[i] = i
  end
  
  -- Shuffle the array
  for i = 255, 1, -1 do
    local j = math.floor(math.random() * (i + 1))
    p[i], p[j] = p[j], p[i]
  end
  
  -- Duplicate the permutation table to avoid overflow
  terrain.perm = {}
  for i = 0, 255 do
    terrain.perm[i] = p[i % 256]
    terrain.perm[i + 256] = p[i % 256]
  end
  
  events.debug.world_stats_updated.notify("Terrain Generator", "Initialized with seed " .. seed)
end

-- Fade function for Perlin noise
-- Smooths the final output
function terrain.fade(t)
  return t * t * t * (t * (t * 6 - 15) + 10)
end

-- Linear interpolation
function terrain.lerp(t, a, b)
  return a + t * (b - a)
end

-- Gradient function for Perlin noise
-- Returns dot product of distance and gradient vectors
function terrain.grad(hash, x, y, z)
  local h = hash % 16
  local u, v
  
  -- Convert hash value to one of 16 gradient directions
  if h < 8 then
    u = x
  else
    u = y
  end
  
  if h < 4 then
    v = y
  elseif h == 12 or h == 14 then
    v = x
  else
    v = z
  end
  
  local result = ((h % 2) == 0 and u or -u) + 
                 ((h % 4) < 2 and v or -v)
  
  return result
end

-- Perlin noise function (3D)
function terrain.noise(x, y, z)
  -- Find unit cube that contains the point
  local X = math.floor(x) % 256
  local Y = math.floor(y) % 256
  local Z = math.floor(z) % 256
  
  -- Find relative position within the cube
  x = x - math.floor(x)
  y = y - math.floor(y)
  z = z - math.floor(z)
  
  -- Compute fade curves
  local u = terrain.fade(x)
  local v = terrain.fade(y)
  local w = terrain.fade(z)
  
  -- Hash coordinates of cube corners
  local A  = terrain.perm[X] + Y
  local AA = terrain.perm[A] + Z
  local AB = terrain.perm[A + 1] + Z
  local B  = terrain.perm[X + 1] + Y
  local BA = terrain.perm[B] + Z
  local BB = terrain.perm[B + 1] + Z
  
  -- Blend the gradients and return value between -1 and 1
  return terrain.lerp(w, 
    terrain.lerp(v, 
      terrain.lerp(u, 
        terrain.grad(terrain.perm[AA], x, y, z),
        terrain.grad(terrain.perm[BA], x-1, y, z)
      ),
      terrain.lerp(u, 
        terrain.grad(terrain.perm[AB], x, y-1, z),
        terrain.grad(terrain.perm[BB], x-1, y-1, z)
      )
    ),
    terrain.lerp(v, 
      terrain.lerp(u, 
        terrain.grad(terrain.perm[AA+1], x, y, z-1),
        terrain.grad(terrain.perm[BA+1], x-1, y, z-1)
      ),
      terrain.lerp(u, 
        terrain.grad(terrain.perm[AB+1], x, y-1, z-1),
        terrain.grad(terrain.perm[BB+1], x-1, y-1, z-1)
      )
    )
  )
end

-- Generate a heightmap using multiple octaves of Perlin noise (FBM - Fractal Brownian Motion)
function terrain.generateHeightmap(width, length, options)
  local heightmap = {}
  
  -- Default options
  local scale = options.scale or 0.1
  local octaves = options.octaves or 3
  local persistence = options.persistence or 0.5
  local baseHeight = options.baseHeight or 0
  local maxHeight = options.maxHeight or 8
  
  events.debug.world_stats_updated.notify("Generating Terrain", width .. "x" .. length)
  
  -- Initialize the heightmap array
  for x = 1, width do
    heightmap[x] = {}
  end
  
  -- Generate the heightmap using Perlin noise
  for x = 1, width do
    for y = 1, length do
      local amplitude = 1.0
      local frequency = 1.0
      local noiseHeight = 0
      local maxValue = 0
      
      -- Accumulate noise from multiple octaves
      for i = 1, octaves do
        -- Sample the noise at the current frequency
        local sampleX = x * scale * frequency
        local sampleY = y * scale * frequency
        
        -- Add the noise value to our height, scaled by the current amplitude
        -- Using 2D noise by keeping z at 0
        local noiseValue = terrain.noise(sampleX, sampleY, 0)
        noiseHeight = noiseHeight + noiseValue * amplitude
        
        -- Track the maximum possible value for normalization later
        maxValue = maxValue + amplitude
        
        -- Prepare for the next octave
        amplitude = amplitude * persistence
        frequency = frequency * 2
      end
      
      -- Normalize the height value
      noiseHeight = noiseHeight / maxValue
      
      -- Convert the noise value (-1 to 1) to a height value
      -- Map from [-1,1] to [0,1], then scale to desired height range
      local height = (noiseHeight + 1) * 0.5 * maxHeight + baseHeight
      
      -- Round to integer for block-based terrain
      heightmap[x][y] = math.floor(height + 0.5)
    end
  end
  
  events.debug.world_stats_updated.notify("Terrain Generated", "Complete")
  
  return heightmap
end

return terrain

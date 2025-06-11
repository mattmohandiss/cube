// Billboard entity fragment shader
// Updated to work with the redesigned vertex shader

// LÖVE automatically provides:
// - 'tex' uniform for the texture
// - VaryingTexCoord for texture coordinates from vertex shader

// Custom variables from vertex shader
varying float vDepth;  // Depth value for potential post-processing

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
  // Sample texture using the coordinates from the vertex shader
  vec4 texColor = Texel(tex, VaryingTexCoord.xy);
  
  // Discard transparent pixels with stronger threshold
  // This ensures proper depth buffer handling for sprites with transparent backgrounds
  if (texColor.a < 0.1) discard;
  
  // Return texture color multiplied by the LÖVE color
  return texColor * color;
}

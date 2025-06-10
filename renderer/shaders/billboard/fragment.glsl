// Billboard entity fragment shader

// Using LÖVE's built-in 'tex' uniform
// No need to redefine it

// VaryingTexCoord is automatically passed from the vertex shader (LÖVE built-in)
// Only declare our custom variables
varying float vDepth;  // Our custom depth variable

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
  // Debug visualization to confirm shader is running
  // Draws a red square in the top-left corner of the screen
  if (screen_coords.x < 50.0 && screen_coords.y < 50.0) {
    return vec4(1.0, 0.0, 0.0, 1.0); // Red
  }
  
  // Sample texture using LÖVE's built-in 'tex' uniform and VaryingTexCoord (which is a vec4)
  vec4 texColor = Texel(tex, VaryingTexCoord.xy);
  
  // Discard fully transparent pixels
  if (texColor.a < 0.01) discard;
  
  // Return texture color
  return texColor * color;
}

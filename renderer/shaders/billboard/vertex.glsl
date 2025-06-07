// Billboard entity vertex shader

// Camera and world information
uniform vec2 screenSize;
uniform float tileSize; // This should match camera.projection.tileSize (currently 50)
uniform vec3 cameraPosition;

// VertexPosition and VaryingTexCoord are automatically provided by LÖVE
// No need to redefine them

// Per-instance attributes
attribute vec3 EntityPosition;  // 3D world position
attribute vec2 EntitySize;      // Width and height in pixels
attribute vec4 EntityUV;        // Texture coordinates (x, y, w, h)

// Only declare our custom output variables
varying float vDepth;  // Custom depth variable for fragment shader

vec2 project(vec3 pos) {
  // Apply camera offset
  vec3 view = pos - cameraPosition;
  
  // Isometric projection
  float x = (view.x - view.y) * tileSize;
  float y = (view.x + view.y) * (tileSize/2) - view.z * tileSize;
  
  // Center on screen
  x = x + screenSize.x / 2;
  y = y + screenSize.y / 2;
  
  return vec2(x, y);
}

vec4 position(mat4 transform_projection, vec4 vertex_position) {
  // Project entity position to screen space
  vec2 screenPos = project(EntityPosition);
  
  // Scale the quad by entity size
  vec2 scaledPos = vertex_position.xy * EntitySize;
  
  // Billboard always faces camera
  vec2 finalPos = screenPos + scaledPos;
  
  // Calculate depth for correct ordering
  vDepth = -EntityPosition.x - EntityPosition.y - EntityPosition.z * 2;
  
  // Calculate texture coordinates using LÖVE's standard varying
  // VaryingTexCoord is a built-in variable in LÖVE shaders and is a vec4
  VaryingTexCoord = vec4(EntityUV.xy + VertexTexCoord.xy * EntityUV.zw, 0.0, 0.0);
  
  // Return final position
  return vec4(finalPos, 0.0, 1.0);
}

// Vertex shader for isometric cube rendering with instancing

// Global uniforms
uniform vec2 screenSize;        // Window dimensions
uniform vec3 cameraPosition;    // Camera position in world space
uniform float tileSize;         // Base tile size for scaling

// Per-instance attributes
attribute vec3 InstancePosition; // Cube position (x,y,z)
attribute vec4 InstanceColor;    // Cube color (r,g,b,a)
attribute float InstanceVisibility; // Visibility flags for faces

// Additional vertex attributes - VertexPosition and VertexTexCoord are provided by LÖVE
attribute vec3 VertexNormal;    // Vertex normal
attribute float VertexFaceIndex; // Which face this vertex belongs to (1-6)
// VertexTexCoord is already defined by LÖVE

// Outputs to fragment shader
varying vec3 vPosition;         // World position
varying vec3 vNormal;           // Face normal
varying vec4 vColor;            // Face color
varying float vFaceIndex;       // Face index
varying vec2 vTexCoord;         // Normalized position within face (0-1 on each axis)

// Constants for isometric projection
// const float ISO_X_FACTOR = 0.866025;  // True Isometric (sqrt(3)/2)
// const float ISO_Y_FACTOR = 0.5; // True Isometric
const float ISO_X_FACTOR = 0.5;  // Matches CPU tileSize/2 scaling
const float ISO_Y_FACTOR = 0.25; // Matches CPU tileSize/4 scaling

// Isometric projection function
vec2 projectIsometric(vec3 pos) {
    float projX = (pos.x - pos.y) * ISO_X_FACTOR;
    float projY = (pos.x + pos.y) * ISO_Y_FACTOR - pos.z * 0.5; // Adjust Z factor to match CPU's tileSize/2
    return vec2(projX, projY);
}

// LÖVE vertex shader function
vec4 position(mat4 transform_projection, vec4 vertex_position) {
    // Calculate face visibility
    float faceVisibilityBit = pow(2.0, VertexFaceIndex - 1.0);
    bool isFaceVisible = mod(floor(InstanceVisibility / faceVisibilityBit), 2.0) == 1.0;
    
    // If face is not visible, move vertex off-screen
    if (!isFaceVisible) {
        return vec4(-10.0, -10.0, 0.0, 1.0);
    }
    
    // Extract the xyz components from vertex_position (which is a vec4)
    vec3 worldPosition = vertex_position.xyz + InstancePosition;
    
    // Apply camera offset
    vec3 relativePosition = worldPosition - cameraPosition;
    
    // Store data for fragment shader
    vPosition = worldPosition;
    vNormal = VertexNormal;
    vColor = InstanceColor;
    vFaceIndex = VertexFaceIndex;
    
    // Pass texture coordinates for wireframe outlines
    // These map vertices to corners of a unit square (0,0), (1,0), (1,1), (0,1)
    // Extract just x,y from VertexTexCoord (which is a vec4 in LÖVE)
    vTexCoord = VertexTexCoord.xy;
    
    // Project to isometric 2D
    vec2 isoPos = projectIsometric(relativePosition);
    
    // Apply tile scaling and center on screen
    vec2 screenPos = isoPos * tileSize + screenSize * 0.5;
    
    // Convert to normalized device coordinates (-1 to 1)
    vec2 ndcPos = (screenPos / screenSize) * 2.0 - 1.0;
    
    // Final position (y is inverted in screen space)
    return vec4(ndcPos.x, -ndcPos.y, 0.0, 1.0);
}

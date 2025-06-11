// Billboard entity vertex shader
// Clean implementation focused on consistent rendering and depth handling

// Global uniforms
uniform vec2 screenSize;        // Window dimensions
uniform vec3 cameraPosition;    // Camera position in world space
uniform float tileSize;         // Base tile size for scaling
uniform float viewDistance;     // Maximum render distance
uniform float depthScale = 200.0; // Scale factor for depth calculations (matches renderer core)
uniform float billboardOffset = 0.001; // Depth offset for billboards (from core.depthConfig.billboardOffset)

// Per-instance attributes
attribute vec3 EntityPosition;  // 3D world position (logical position - feet/bottom center)
attribute vec2 EntitySize;      // Width and height in pixels
attribute vec4 EntityUV;        // Texture coordinates (x, y, w, h)

// Output to fragment shader
varying float vDepth;           // Depth value for fragment shader

// Constants for isometric projection - exactly matching cube shader
const float ISO_X_FACTOR = 0.5;  
const float ISO_Y_FACTOR = 0.25;

// Scale factor for billboards
const float BILLBOARD_SCALE = 0.02;

// Isometric projection function - exactly matching cube shader
vec2 projectIsometric(vec3 pos) {
    float projX = (pos.x - pos.y) * ISO_X_FACTOR;
    float projY = (pos.x + pos.y) * ISO_Y_FACTOR - pos.z * 0.5;
    return vec2(projX, projY);
}

vec4 position(mat4 transform_projection, vec4 vertex_position) {
    // 1. Calculate world position using logical coordinates
    // The z-coordinate in EntityPosition is the logical z (feet position)
    vec3 worldPosition = EntityPosition;
    
    // 2. Apply camera offset
    vec3 relativePosition = worldPosition - cameraPosition;
    
    // 3. Calculate billboard dimensions in world units
    float billboardWidth = EntitySize.x * BILLBOARD_SCALE;
    float billboardHeight = EntitySize.y * BILLBOARD_SCALE;
    
    // 4. Create a 3D vertex offset, anchoring billboard at feet (bottom center)
    // Adjust z-coordinate in world space to simulate height for projection
    vec3 vertexOffset = vec3(
        vertex_position.x * billboardWidth,  // X offset (horizontal)
        0.0,                                 // Y offset (none in world space)
        vertex_position.y * billboardHeight  // Z offset (vertical height in world space)
    );
    
    // 5. Apply vertex offset to get actual vertex position in 3D
    vec3 finalVertexPosition = relativePosition + vertexOffset;
    
    // 6. Project to isometric 2D using identical projection math as cube shader
    vec2 isoPos = projectIsometric(finalVertexPosition);
    
    // 7. Apply tile scaling and center on screen
    vec2 screenPos = isoPos * tileSize + screenSize * 0.5;

    
    // 8. Convert to normalized device coordinates
    vec2 ndcPos = (screenPos / screenSize) * 2.0 - 1.0;
    
    // 9. Calculate depth for consistent sorting with cubes
    // IMPORTANT: Since billboards are anchored at their feet but cubes at their center,
    // we need to adjust the Z component to ensure proper depth calculation
    
    // Adjust the z-position to account for the billboard being anchored at its feet
    // Adding half the billboard height to Z makes it behave as if anchored at center (like cubes)
    float adjustedZ = relativePosition.z + (billboardHeight * 0.5);
    
    // Now use the same formula as the cube shader with our adjusted Z
    float depth = -(relativePosition.x + relativePosition.y + 2.0 * adjustedZ) / (viewDistance * 3.0);
    
    // Apply a consistent offset to prevent Z-fighting with cubes
    depth = depth + billboardOffset;
    
    // Ensure depth stays within valid range
    depth = clamp(depth, -0.99, 0.99);
    
    // Store depth for fragment shader
    vDepth = depth;
    
    // 10. Set texture coordinates
    VaryingTexCoord = vec4(
        EntityUV.x + VertexTexCoord.x * EntityUV.z,
        EntityUV.y + VertexTexCoord.y * EntityUV.w,
        0.0,
        0.0
    );
    
    // 11. Return final position with y-inversion for LÖVE's coordinate system
    return vec4(ndcPos.x, -ndcPos.y, depth, 1.0);
}

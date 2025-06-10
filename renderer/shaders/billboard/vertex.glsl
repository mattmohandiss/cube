// Billboard entity vertex shader

// Camera and world information
uniform vec2 screenSize;
uniform float tileSize; // This should match camera.projection.tileSize (currently 50)
uniform vec3 cameraPosition;
uniform float depthScale; // Scale factor for normalizing depth (from core.depthConfig.standardScale)
uniform float viewDistance; // Same as cube shader for consistency

// VertexPosition and VaryingTexCoord are automatically provided by LÖVE
// No need to redefine them

// Per-instance attributes
attribute vec3 EntityPosition;  // 3D world position
attribute vec2 EntitySize;      // Width and height in pixels
attribute vec4 EntityUV;        // Texture coordinates (x, y, w, h)

// Only declare our custom output variables
varying float vDepth;  // Custom depth variable for fragment shader

// Constants for isometric projection - EXACTLY matching cube shader
const float ISO_X_FACTOR = 0.5;  // Matches cube shader ISO_X_FACTOR
const float ISO_Y_FACTOR = 0.25; // Matches cube shader ISO_Y_FACTOR

// Isometric projection function - EXACTLY matching cube shader
vec2 projectIsometric(vec3 pos) {
    float projX = (pos.x - pos.y) * ISO_X_FACTOR;
    float projY = (pos.x + pos.y) * ISO_Y_FACTOR - pos.z * 0.5; // Z-factor matching cube shader
    return vec2(projX, projY);
}

vec4 position(mat4 transform_projection, vec4 vertex_position) {
    // 1. Calculate world position for a vertical billboard
    // For correct camera movement, we need to position the billboard in full 3D space
    // The key insight is that we need to calculate world coordinates similar to how cube vertices are positioned
    float vertexOffsetScale = 0.02; // Scale factor to make entities reasonable size
    
    // The billboard vertices should be positioned like a cube face, varying in both X and Y world coordinates
    // For a vertical billboard facing the camera, we'll use a front-facing approach:
    vec3 worldPosition = vec3(
        EntityPosition.x + vertex_position.x * EntitySize.x * vertexOffsetScale,        // X varies for width
        EntityPosition.y + vertex_position.x * EntitySize.x * vertexOffsetScale * 0.5,  // Y varies with X to maintain isometric angle (matching cube faces)
        EntityPosition.z + vertex_position.y * EntitySize.y * vertexOffsetScale      // Z varies for height (removed negation to fix upside-down issue)
    );
    
    // 2. Apply camera offset (EXACTLY like cube shader)
    vec3 relativePosition = worldPosition - cameraPosition;
    
    // 3. Project to isometric 2D (EXACTLY like cube shader)
    vec2 isoPos = projectIsometric(relativePosition);
    
    // 4. Apply tile scaling and center on screen (EXACTLY like cube shader)
    vec2 screenPos = isoPos * tileSize + screenSize * 0.5;
    
    // 5. Convert to normalized device coordinates (EXACTLY like cube shader)
    vec2 ndcPos = (screenPos / screenSize) * 2.0 - 1.0;
    
    // 6. Calculate depth (EXACTLY like cube shader)
    // Use the isometric depth calculation to ensure proper depth ordering
    float depth = -(relativePosition.x + relativePosition.y + 2.0 * relativePosition.z) / (viewDistance * 3.0);
    
    // Add a small offset to prevent Z-fighting with cubes
    depth = depth + 0.001;
    
    // Store depth for fragment shader
    vDepth = depth;
    
    // Calculate texture coordinates using LÖVE's standard varying
    VaryingTexCoord = vec4(EntityUV.xy + VertexTexCoord.xy * EntityUV.zw, 0.0, 0.0);
    
    // Final position - inverted Y like cube shader
    return vec4(ndcPos.x, -ndcPos.y, depth, 1.0);
}

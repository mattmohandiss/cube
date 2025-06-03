// Fragment shader for isometric cube rendering

// Lighting and debug settings
uniform vec3 lightDirection = vec3(0.3, 0.3, -0.9);  // Adjusted light direction for more even lighting
uniform bool showDebugInfo = false;                  // Toggle debug visualization
uniform float viewDistance;                          // Maximum render distance
uniform bool enableOutlines = true;                  // Toggle face outlines

// Inputs from vertex shader
varying vec3 vPosition;         // World position
varying vec3 vNormal;           // Face normal
varying vec4 vColor;            // Face color
varying float vFaceIndex;       // Face index (1-6)
varying vec2 vTexCoord;         // Normalized position within face (0-1)

// Face brightness factors (increased for better visibility)
const float faceBrightness[6] = float[6](
    1.0,  // top (1)
    0.7,  // bottom (2) - increased from 0.5
    0.9,  // front (3) - increased from 0.8
    0.8,  // right (4) - increased from 0.6
    0.7,  // back (5) - increased from 0.5
    0.85  // left (6) - increased from 0.7
);

// LÖVE pixel shader function
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    // Calculate distance from camera origin (assumed at world center)
    float distToCenter = length(vPosition.xy);
    
    // Edge detection for visual boundary
    float edgeFactor = smoothstep(viewDistance - 2.0, viewDistance - 0.5, distToCenter);
    bool isAtEdge = edgeFactor > 0.0;
    
    // Apply face-specific brightness
    int faceIdx = int(vFaceIndex) - 1; // Convert to 0-based for array access
    float brightness = faceBrightness[faceIdx];
    
    // Apply lighting model with higher ambient minimum
    float nDotL = max(0.6, dot(normalize(vNormal), normalize(-lightDirection)));
    vec3 litColor = vColor.rgb * brightness * nDotL;
    
    // Edge highlighting effect for cubes at view boundary
    if (isAtEdge) {
        // Enhance edge cubes slightly to make them pop
        litColor = mix(litColor, litColor * 1.2, edgeFactor * 0.5);
    }
    
    // Debug visualization mode
    if (showDebugInfo) {
        // Show face indices with different colors
        vec3 debugColors[6] = vec3[6](
            vec3(1.0, 0.0, 0.0), // top - red (1)
            vec3(0.0, 1.0, 0.0), // bottom - green (2)
            vec3(0.0, 0.0, 1.0), // front - blue (3)
            vec3(1.0, 1.0, 0.0), // right - yellow (4)
            vec3(1.0, 0.0, 1.0), // back - magenta (5)
            vec3(0.0, 1.0, 1.0)  // left - cyan (6)
        );
        
        // Show a grid pattern on each face for debugging
        vec2 faceCoord = fract(vPosition.xy * 0.5);
        bool isGrid = any(lessThan(faceCoord, vec2(0.05))) || any(greaterThan(faceCoord, vec2(0.95)));
        
        if (isGrid) {
            // Draw grid lines
            return vec4(debugColors[faceIdx], 1.0);
        } else {
            // Fill face with semi-transparent color
            return vec4(mix(litColor, debugColors[faceIdx], 0.3), 0.8);
        }
    } else {
    // WIREFRAME OUTLINE APPROACH
    // Calculate distance to nearest edge of the face
    vec2 coords = vTexCoord;
    vec2 distToEdge = min(coords, 1.0 - coords); // Distance to nearest edge (0 at edges, 0.5 in center)
    
    // Create visible, crisp lines
    float lineWidth = 0.1;
    // Add slight anti-aliasing with a modified smoothstep
    float wireframe = 1.0 - smoothstep(0.0, lineWidth, min(distToEdge.x, distToEdge.y));
    
    if (enableOutlines && wireframe > 0.0) {
        // Create a slightly thicker, more visible black outline
        return vec4(mix(litColor, vec3(0.0), 0.3 * wireframe), 1.0);
    } else {
        // Normal rendering for face interior
        return vec4(litColor, 1.0);
    }
    }
}

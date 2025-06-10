# Entity Module Architecture

## Overview

The entity module provides a comprehensive system for managing and rendering living entities in an isometric environment. It handles entity creation, animation, and billboard sprite rendering, allowing for dynamic characters and creatures to exist alongside the cube-based environment.

The module serves as a bridge between traditional 2D sprite animation and 3D isometric space, providing the data structures and algorithms needed to represent animated sprites with proper depth integration. It abstracts the complexities of billboard rendering while offering a clean interface for the rest of the application.

## Module Structure

The entity module is divided into four logical components, each with a specific responsibility:

1. **Core**: Manages entity properties, creation, and basic functionality. Handles the fundamental data structures that represent an entity and provides the public API for entity instantiation.
2. **Animation**: Implements spritesheet management, frame selection, and animation state handling. Responsible for loading textures and calculating the correct sprite frame to display based on entity state.
3. **Rendering**: Implements GPU-accelerated billboard rendering for entities, using shaders to efficiently display entities in the isometric world.
4. **Types**: Contains definitions for different entity types with their specialized behaviors and animations.

## Key Features / Algorithms

### Billboard Sprite Rendering
The entity rendering system uses billboard sprites that always face the camera:

1. **Isometric Projection**: Entities are positioned in 3D space but rendered as 2D sprites.
2. **Consistent Orientation**: Sprites always face the camera, regardless of the entity's position in the world.
3. **Depth Integration**: Entities are properly depth-sorted with cubes and other world objects.

### Spritesheet Animation
The animation system manages multi-frame animations from spritesheets:

1. **State-Based Animation**: Different animations (idle, walking, etc.) are triggered based on entity state.
2. **Time-Based Frame Selection**: Animation frames advance based on elapsed time and configured animation speed.
3. **Row-Column Organization**: Spritesheets are organized with different animation sequences in rows and frames in columns.
4. **Pixel Art Optimized**: Uses nearest-neighbor filtering for crisp, clean pixel art scaling without blurring.

### Entity Position Management
Entities exist in the same coordinate space as cubes:

1. **3D Position**: Entities have x, y, and z coordinates in the world.
2. **Depth Calculation**: The same depth formula used for cubes ensures proper visual layering.
3. **Velocity-Based Movement**: Support for smooth movement with velocity components.

## Data Flow

1. **Creation**: An entity is instantiated with position and sprite configuration
2. **Initialization**: The animation system loads and configures the spritesheet
3. **State Management**: Entity states trigger different animations
4. **Update Cycle**: Entity positions and animations are updated each frame
5. **Depth Calculation**: Proper depth is calculated for sorting with world objects
6. **Rendering**: Entities are rendered as billboards with the current animation frame

## Integration with Other Modules

1. **Renderer Module**: The entity module implements the renderer module's billboard renderer interface, allowing the renderer to delegate entity-specific billboard rendering back to the entity module.
2. **Camera Module**: Uses the same isometric projection and depth calculation to ensure entities properly integrate with the world view.
3. **World Module**: Entities can be managed by the world alongside terrain and other elements.
4. **Event System**: Entity state changes and important events can be broadcast through the existing event system.

## Performance Considerations

- **Texture Caching**: Spritesheets are loaded once and cached for reuse
- **Sprite Batching**: Entities using the same spritesheet can be rendered together to reduce draw calls
- **Efficient Animation Updates**: Only process animation changes when necessary
- **GPU-Accelerated Billboard Rendering**: Shaders handle the billboard effect efficiently on the GPU
- **Pixel-Perfect Rendering**: Nearest-neighbor filtering ensures pixel art maintains its crisp appearance when scaled
- **Depth Pre-sorting**: Entities are sorted by depth for proper layering with minimal CPU overhead
- **Texture Atlas Support**: The spritesheet system supports texture atlases for efficient GPU memory usage
- **Minimal State Changes**: Rendering is organized to minimize texture and shader state changes
- **Culling By Distance**: Entities outside the view distance are not processed or rendered

## Extendability

The architecture is designed to be extended in several ways:

1. **Entity Types**: New entity types can be registered with specialized behavior and animations
2. **Animation States**: Additional animation states can be defined for more complex entity behavior
3. **Rendering Effects**: The billboard shader can be extended to support effects like outlines, glow, or shading
4. **Interaction Systems**: The entity framework can be extended to support interactions between entities or with the world
5. **Physics Integration**: Movement systems can be enhanced with physics-based behavior
6. **AI Behaviors**: Entities can be given autonomous behavior through AI systems
7. **Attribute Systems**: RPG-like attributes and stats can be added to entities

## Implementation Details

### Billboard Renderer Implementation
The module implements a billboard renderer that follows the renderer module's interface:

1. **Interface Implementation**: Implements the billboard renderer interface defined by the renderer module, allowing for consistent integration.
2. **Entity-Specific Billboard Rendering**: Efficiently renders entity billboards with proper depth integration.
3. **Shader Management**: Manages entity-specific shader parameters and uniforms.
4. **Texture Management**: Handles multiple spritesheets efficiently with proper batching.
5. **Depth Sorting**: Ensures entities are properly sorted by depth for correct visual layering.
6. **Memory Management**: Properly releases resources to prevent memory leaks.

### Shader-Based Billboard System
The billboard rendering uses vertex and fragment shaders:

1. **Vertex Transformation**: The vertex shader positions sprites in screen space based on their 3D world position.
2. **UV Coordinate Mapping**: Proper texture coordinates are calculated for the current animation frame.
3. **Alpha Blending**: Transparent pixels in sprites are properly handled for clean visuals.
4. **Consistent Interface**: The shader system follows the same patterns as other renderers, making it easier to maintain.

### Entity Type Registration
The module provides a type registration system:

1. **Factory Pattern**: Entity types are created through factory functions that configure base entities.
2. **Property Extension**: Type-specific properties and methods can be added to base entities.
3. **Configuration Options**: Types can define their own configuration parameters.

### Animation State Management
The animation system uses a simple but effective state machine:

1. **State Transitions**: Changing an entity's state automatically resets animation and selects the appropriate frames.
2. **Frame Timing**: Each animation can specify its own timing for frame advancement.
3. **Default Behaviors**: Sensible defaults are provided for missing animation configurations.

# Renderer Module Architecture

## Overview

The renderer module provides a shape-agnostic, flexible rendering system that supports different geometries (such as cubes) and billboard sprites. It abstracts the complexities of GPU programming while focusing on the core mechanics of rendering rather than specific shape details.

This module serves as the foundation for all rendering in the application, providing a unified interface for rendering different types of objects while delegating shape-specific rendering logic to the appropriate shape modules.

## Module Structure

The renderer module is divided into several logical components, each with a specific responsibility:

1. **Core**: Manages shader loading, compilation, and uniform updates. Handles the foundational shader operations and provides a generic interface for rendering different types of objects.
2. **Interfaces**: Defines the interfaces for different types of renderers (shape renderers, billboard renderers) to ensure consistent implementation.
3. **Registry**: Manages registration and lookup of different renderer implementations to support extensibility.
4. **Shapes**: Contains base implementations and utilities for shape renderers, but delegates shape-specific details to their respective modules.
5. **Billboards**: Provides base implementations and utilities for billboard renderers to support sprite-based entities.

## Key Features / Algorithms

### Generic Shader Management
The module provides a unified system for shader management:

1. **Centralized Shader Loading**: Loads and compiles shaders from external files with consistent error handling.
2. **Shader Registry**: Manages shaders by name for easy reference by different renderers.
3. **Uniform Management**: Provides utilities for updating shader uniforms with consistent patterns.

### Renderer Interface System
The module defines clear interfaces for different types of renderers:

1. **Shape Renderer Interface**: Defines the contract for renderers that handle 3D shapes.
2. **Billboard Renderer Interface**: Defines the contract for renderers that handle 2D billboards in 3D space.
3. **Interface Validation**: Ensures that renderer implementations adhere to the defined interfaces.

### Renderer Registry
For extensibility and modularity:

1. **Type-Based Registration**: Allows different renderers to register themselves by the type of object they render.
2. **Lookup System**: Efficiently matches objects with their appropriate renderers.
3. **Dynamic Dispatch**: Routes rendering calls to the appropriate renderer based on object type.

### Rendering Pipeline
For efficient rendering across different object types:

1. **Object Grouping**: Groups objects by type for batch rendering.
2. **Delegated Rendering**: Delegates rendering to specialized renderers for each object type.
3. **State Management**: Handles graphics state transitions between different renderers.

## Data Flow

1. **Initialization**: 
   - Core renderer is initialized
   - Shape and billboard renderers register themselves with the registry
   - Shader programs are loaded and compiled

2. **Object Preparation**:
   - World module determines visible objects (shapes and billboards)
   - Objects are tagged with their type for routing to appropriate renderers

3. **Rendering Dispatch**:
   - Objects are grouped by type
   - Each group is sent to its registered renderer

4. **Shape-Specific Rendering**:
   - Shape renderers handle mesh creation and instance data management
   - Camera information is passed to shape-specific shaders
   - Shape-specific rendering logic is executed

5. **Billboard-Specific Rendering**:
   - Billboard renderers manage sprite rendering
   - Billboards are sorted by depth
   - Sprite sheets are managed efficiently

6. **Debug Information**:
   - Performance metrics are collected from various renderers
   - Consolidated metrics are displayed

## Integration with Other Modules

1. **World Module**: Receives visible objects from the world module and dispatches them to appropriate renderers.
2. **Cube Module**: The cube module provides its own cube-specific renderer implementation.
3. **Entity Module**: The entity module provides its own billboard-specific renderer implementation.
4. **Camera Module**: Coordinates with the camera module for proper projection and view transformations.
5. **Debug Module**: Collects and provides performance metrics and visual debugging options.
6. **Events System**: Listens for window resize and debug toggle events.

## Performance Considerations

- **Delegated Responsibility**: Each renderer is responsible for optimizing its specific rendering path
- **Type-Based Batching**: Objects are grouped by type to minimize state changes
- **Resource Management**: Centralized shader management reduces redundant resource creation
- **Interface-Based Design**: Clear interfaces allow for specialized optimization without breaking the system
- **Memory Management**: Proper resource cleanup across all renderers
- **Hardware Support Detection**: Checks for required hardware features and provides clear error messages
- **Shader Reuse**: Reuses shader programs where appropriate to minimize compilation overhead
- **Specialized Implementations**: Each shape type can have specialized rendering optimizations
- **View Distance Optimization**: Filtering of objects by distance is performed before dispatching to renderers

## Extendability

The architecture is designed to be highly extensible:

1. **New Shape Types**: Add new shape renderers by implementing the shape renderer interface
2. **New Billboard Types**: Add new billboard renderers by implementing the billboard renderer interface
3. **Shader Effects**: Add post-processing, shadows, or other visual enhancements
4. **Material System**: Extend to support different materials with varying properties
5. **Advanced Rendering Techniques**: Add new rendering techniques without changing the core architecture
6. **Custom Pipeline Stages**: Extend the rendering pipeline with new stages as needed
7. **Texture Systems**: Add texture management for different object types
8. **Dynamic Lighting**: Implement more advanced lighting models with proper light sources
9. **Rendering Passes**: The centralized rendering system supports additional passes for effects like shadows or reflections

## Hybrid Rendering Approach

The renderer now uses a hybrid approach that balances specialized renderers with centralized coordination:

1. **Specialized Renderers**: Each object type (cubes, billboards) has its own specialized renderer optimized for its specific needs
2. **Centralized Coordination**: The core renderer orchestrates the overall rendering process with features like:
   - **Unified Depth Management**: Standardized depth calculation and handling
   - **Multi-Pass Rendering**: Opaque objects first, transparent objects second
   - **Consistent Camera Integration**: Central management of camera state across all renderers
   - **Shared Resource Management**: Common shader uniforms and state management

This hybrid approach provides:
- **Performance**: Through specialized renderers for each object type
- **Consistency**: Through centralized depth and camera handling
- **Maintainability**: Through clear separation of concerns
- **Extensibility**: Through well-defined interfaces and central coordination

### Depth Management

The renderer implements a standardized approach to depth handling:
- Depth values are calculated consistently across all renderers
- Small offsets are applied to prevent Z-fighting between different object types
- Transparent objects use depth testing but not depth writing
- Opaque objects both test against and write to the depth buffer

## Implementation Details

### Interface Implementation
The module uses Lua's metatables to implement interfaces:

1. **Interface Definitions**: Clear definitions of required methods for each renderer type
2. **Implementation Verification**: Runtime checking that interfaces are properly implemented
3. **Inheritance Support**: Base implementations that can be extended by specific renderers

### Registry System
The registry system provides flexible lookup capabilities:

1. **Type-Based Registration**: Renderers register themselves by the types they can render
2. **Dynamic Discovery**: New renderers can be added at runtime
3. **Fallback Handling**: Support for default renderers when specific ones aren't available

### Shader Management
The centralized shader system provides:

1. **External File Loading**: Shaders are stored in separate GLSL files for better organization
2. **Error Handling**: Robust error checking during shader compilation and linking
3. **Uniform Management**: Standardized approach to updating shader uniforms
4. **Screen Resize Handling**: Automatic updates of shader uniforms on window resize

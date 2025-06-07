# Game Module Architecture

## Overview
The Game module serves as the central gameplay management system, defining and controlling game entities, rules, and interactions. It bridges the entity management system with the world environment, providing high-level game mechanics and entity types specific to the game.

## Module Structure
- **game/init.lua**: Main entry point for the module, initializes the game system and exposes the API
- **game/core.lua**: Core functionality for the game system, handling initialization and entity type registration
- **game/entities/**: Directory containing specialized entity implementations
  - **game/entities/worker.lua**: Worker entity implementation with movement and task capabilities

## Key Features / Algorithms
- **Entity Type Registration**: Registers custom entity types with the entity system
- **Worker Entity Implementation**: Specialized entity with directional movement, animation states, and task management
- **Direction-Based Animation**: Changes animation state based on movement direction
- **Task System**: Rudimentary task assignment and tracking for entities

## Data Flow
1. Game module initializes and registers entity types with the entity system
2. Entity types (like worker) are created through the game API
3. Entities are added to the world and updated each frame
4. Entities handle their own state updates (animation, movement, tasks)
5. The rendering system displays entities in the world

## Integration with Other Modules
- **Entity Module**: Uses the entity system as a foundation for game-specific entities
- **World Module**: Entities are placed in and interact with the world
- **Renderer Module**: Entities are rendered using the billboard rendering system
- **Camera Module**: Used for positioning entities in screen space

## Performance Considerations
- Entity updates are optimized to only change state when needed
- Movement calculations use normalized vectors for consistent speed
- Animation frames are updated only at specified intervals

## Extendability
The Game module is designed to be extended with:
- Additional entity types (buildings, resources, etc.)
- More complex task systems
- Entity relationships and interactions
- Game rules and objectives
- Resource management systems

## Implementation Details
- Worker entities maintain their own state (direction, task, animation)
- Animations are tied to movement state (idle vs walking)
- Direction is determined by velocity vector, choosing the dominant axis
- Tasks are stored as name/data/progress triplets on entities

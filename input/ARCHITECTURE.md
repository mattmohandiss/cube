# Input Module Architecture

## Overview

The input module manages user interaction with the application, primarily through keyboard controls. It translates user actions into application behaviors, such as camera movement and speed adjustments.

This module serves as the interface between the user and the application, capturing keyboard input and converting it into meaningful operations within the 3D environment. It abstracts the low-level input handling and provides a consistent way for user actions to affect the application state.

## Module Structure

The input module is divided into two logical components:

1. **Core**: Manages module initialization and camera module reference. Provides the foundation for input processing and maintains references to other modules that need to be controlled.
2. **Keyboard**: Handles specific keyboard interactions and mapping. Implements the logic for translating keyboard events into application actions.

## Key Features / Algorithms

### Camera Control
The module provides intuitive camera movement through:

1. **Directional Movement**: Arrow keys for panning the camera in the isometric space, translating 2D input into 3D movement.
2. **Speed Adjustment**: Page Up/Down keys to adjust movement sensitivity, allowing users to control how quickly the camera responds to input.

### Worker Entity Control
The module provides controls for the worker entities in the world:

1. **Directional Movement**: WASD keys for moving workers in cardinal directions (North, South, West, East).
2. **Stop Movement**: Space key to halt worker movement.
3. **Entity Selection**: Currently controls the first worker entity in the world.

### Visual Toggles
The module provides controls for toggling various visualization options:

1. **Debug Visualization**: The '`' key toggles debug visualization mode, tracking state between toggle operations.
2. **Shader Rendering**: The 'S' key toggles between different shader rendering modes.
3. **Cube Outlines**: The 'O' key toggles the visibility of cube outlines in the rendering.

### Event Integration
The input module integrates with the event system to:

1. **Broadcast Changes**: Notify other modules of user-initiated changes, ensuring the application state remains consistent.
2. **Update UI**: Keep the debug display updated with current movement speed, providing feedback to the user.

### Input Processing Pipeline
The core algorithm for input processing follows this sequence:

1. **Detection**: Detecting key presses and holds via LÖVE's keyboard API
2. **Mapping**: Translating keyboard events to application actions
3. **Execution**: Calling appropriate functions based on mapped actions
4. **Notification**: Broadcasting changes via the event system

## Data Flow

1. **Input Detection**: Keyboard events are captured from the LÖVE framework
2. **Mapping Process**: Keys are mapped to specific actions based on predefined configurations
3. **Camera Interaction**: Movement commands are sent to the camera module to update position
4. **State Broadcasting**: Changes in state (like speed adjustments) are broadcast via events
5. **UI Updates**: Debug display is refreshed to reflect current settings
6. **Continuous Monitoring**: The process repeats each frame to capture ongoing input

## Integration with Other Modules

1. **Camera Module**: The input module directly controls the camera, sending movement commands and adjusting position based on user input.
2. **World Module**: The input module accesses the world module to retrieve entities for worker control.
3. **Entity Module**: The input module sends movement commands to worker entities.
4. **Event System**: Events are dispatched to notify other modules about changes in input state, such as movement speed adjustments and worker movement.
5. **Debug Module**: Movement speed and other input-related metrics are sent to the debug display for monitoring. The module also controls the debug visualization toggle state.
6. **Renderer Module**: The input module interacts with the renderer by toggling shader features such as debug visualization and outlines.

## Performance Considerations

The input handling is designed to be efficient:

- **Direct Access**: Accessing camera properties directly when needed, avoiding unnecessary indirection
- **Rate Limiting**: Movement is tied to frame delta time for consistent speed regardless of frame rate
- **Minimal State**: Maintaining only essential state information to reduce memory overhead
- **Event Optimization**: Using events selectively to avoid performance impact from excessive event broadcasting

## State Management

The input module maintains state for various toggle features:

1. **Debug Visualization State**: Tracks whether debug visualization is enabled or disabled, ensuring consistent behavior when toggling.
2. **Toggle Persistence**: The state of toggles is maintained between key presses, allowing features to be turned on and off.

## Extendability

The architecture can be extended in several ways:

1. Add support for additional input devices (mouse, gamepad)
2. Implement key rebinding or custom control schemes
3. Add gesture recognition for touch devices
4. Implement more complex input sequences or combinations
5. Create context-sensitive input handling for different application states

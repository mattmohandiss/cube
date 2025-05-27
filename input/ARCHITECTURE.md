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
2. **Event System**: Events are dispatched to notify other modules about changes in input state, such as movement speed adjustments.
3. **Debug Module**: Movement speed and other input-related metrics are sent to the debug display for monitoring.

## Performance Considerations

The input handling is designed to be efficient:

- **Direct Access**: Accessing camera properties directly when needed, avoiding unnecessary indirection
- **Rate Limiting**: Movement is tied to frame delta time for consistent speed regardless of frame rate
- **Minimal State**: Maintaining only essential state information to reduce memory overhead
- **Event Optimization**: Using events selectively to avoid performance impact from excessive event broadcasting

## Extendability

The architecture can be extended in several ways:

1. Add support for additional input devices (mouse, gamepad)
2. Implement key rebinding or custom control schemes
3. Add gesture recognition for touch devices
4. Implement more complex input sequences or combinations
5. Create context-sensitive input handling for different application states

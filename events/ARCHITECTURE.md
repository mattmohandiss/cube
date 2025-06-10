# Event System Architecture

## Overview

The event system provides a lightweight, type-safe publish-subscribe pattern implementation. It facilitates decoupled communication between different modules of the application, allowing components to broadcast and react to events without direct dependencies.

This system serves as the communication backbone of the application, enabling modules to interact without creating tight coupling. By implementing the observer pattern with categorical organization, it promotes a modular architecture where components can evolve independently while still coordinating their behaviors.

## Module Structure

The event system is divided into two logical components:

1. **Core**: Manages the fundamental event registration and triggering mechanisms. Implements the internal logic for maintaining listener lists and dispatching events to registered callbacks.
2. **Interface**: Provides a user-friendly API with metatable-based autocompletion. Creates a clean, intuitive interface for other modules to interact with the event system.

## Key Features / Algorithms

### Categorical Organization
The event system organizes events into logical categories:

1. **System Events**: Core system events like window resizing or debug toggling
2. **Application Events**: Game-specific events like camera movement or terrain generation
3. **Debug Events**: Events specifically for debugging and monitoring

### Type Safety and Autocompletion
The event system employs Lua metatables to provide:

1. **Predefined Event Types**: Only recognized events can be accessed, preventing typos and invalid event names.
2. **Error Detection**: Attempts to use undefined events produce clear error messages, making debugging easier.
3. **IDE Autocompletion**: The event names become available as properties, improving developer experience through editor support.

### Efficient Event Handling
The implementation optimizes for common event system operations:

1. **Lazy Initialization**: Event objects are created on first access, avoiding unnecessary object creation.
2. **Caching**: Once accessed, event objects are stored for future use, improving performance for frequently used events.
3. **Linear Dispatch**: Callbacks are executed in registration order, providing predictable execution sequencing.

### Metatable Implementation
The system uses metatables to create a dynamic, user-friendly interface:

1. **__index Metamethod**: Intercepts access to undefined properties, enabling the dynamic creation of event objects.
2. **Dynamic Object Creation**: Generates event objects with appropriate closures when events are first accessed.
3. **Property Caching**: Adds created objects to the base table to optimize subsequent accesses.

## Data Flow

1. **Initialization**: The event system initializes with categories and a list of valid event types per category
2. **Registration**: Modules register callback functions for specific events using `events.category.event_name.listen(callback)`
3. **Triggering**: When an event occurs, the source module calls `events.category.event_name.notify(param1, param2, ...)`
4. **Dispatch**: The event system iterates through all registered callbacks for the event
5. **Execution**: Each callback is invoked with the provided parameters
6. **Result**: All listeners receive the event and can react accordingly

## Integration with Other Modules

1. **Camera Module**: The camera module broadcasts position and projection changes through application events, allowing other modules to react to camera movements without direct coupling.
2. **Cube Module**: Publishes face and vertex information through debug events, enabling monitoring of geometry calculations without modifying the core cube logic.
3. **Debug Module**: Subscribes to various debug events to display state information, creating a comprehensive debug view without requiring direct access to other modules' internals.
4. **Input Module**: Broadcasts user input events that can be consumed by any interested module, decoupling input detection from input handling.

## Performance Considerations

The event system is designed to be lightweight:

- **Minimal Overhead**: The metatable approach adds negligible performance impact compared to direct function calls
- **No Runtime Type Checking**: After initialization, event triggering has no validation overhead, maintaining efficiency during operation
- **Direct Function Calls**: Event notification uses direct function calls without indirection, minimizing dispatch costs
- **Optimized Data Structures**: Uses simple arrays for listener storage, providing efficient iteration for the expected number of listeners

## Extendability

The architecture can be extended in several ways:

1. Add new event categories for domain-specific events (e.g., UI, Audio, Networking)
2. Add new event types to existing categories to expand functionality
3. Implement event prioritization for ordered callback execution
4. Add wildcard event subscriptions for logging or debugging purposes
5. Implement one-time event listeners that automatically unregister after being triggered
6. Add event buffering capabilities for replay or testing scenarios

# Event System Architecture

## Overview

The event system provides a lightweight, type-safe publish-subscribe pattern implementation. It facilitates decoupled communication between different modules of the application, allowing components to broadcast and react to events without direct dependencies.

This system serves as the communication backbone of the application, enabling modules to interact without creating tight coupling. By implementing the observer pattern, it promotes a modular architecture where components can evolve independently while still coordinating their behaviors.

## Module Structure

The event system is divided into two logical components:

1. **Core**: Manages the fundamental event registration and triggering mechanisms. Implements the internal logic for maintaining listener lists and dispatching events to registered callbacks.
2. **Interface**: Provides a user-friendly API with metatable-based autocompletion. Creates a clean, intuitive interface for other modules to interact with the event system.

## Key Features / Algorithms

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

1. **Initialization**: The event system initializes with a list of valid event types
2. **Registration**: Modules register callback functions for specific events using `events.event_name.listen(callback)`
3. **Triggering**: When an event occurs, the source module calls `events.event_name.notify(param1, param2, ...)`
4. **Dispatch**: The event system iterates through all registered callbacks for the event
5. **Execution**: Each callback is invoked with the provided parameters
6. **Result**: All listeners receive the event and can react accordingly

## Integration with Other Modules

1. **Camera Module**: The camera module broadcasts position and projection changes through events, allowing other modules to react to camera movements without direct coupling.
2. **Cube Module**: Publishes face and vertex information for debugging purposes, enabling monitoring of geometry calculations without modifying the core cube logic.
3. **Debug Module**: Subscribes to various events to display state information, creating a comprehensive debug view without requiring direct access to other modules' internals.
4. **Input Module**: Broadcasts user input events that can be consumed by any interested module, decoupling input detection from input handling.

## Performance Considerations

The event system is designed to be lightweight:

- **Minimal Overhead**: The metatable approach adds negligible performance impact compared to direct function calls
- **No Runtime Type Checking**: After initialization, event triggering has no validation overhead, maintaining efficiency during operation
- **Direct Function Calls**: Event notification uses direct function calls without indirection, minimizing dispatch costs
- **Optimized Data Structures**: Uses simple arrays for listener storage, providing efficient iteration for the expected number of listeners

## Extendability

The architecture can be extended in several ways:

1. Add new event types by updating the valid events list, allowing the system to grow with application needs
2. Implement event prioritization for ordered callback execution, enabling more control over execution sequence
3. Add wildcard event subscriptions for logging or debugging purposes
4. Implement one-time event listeners that automatically unregister after being triggered
5. Add event buffering capabilities for replay or testing scenarios

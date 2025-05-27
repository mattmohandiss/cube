# Debug Module Architecture

## Overview

The debug module provides a comprehensive system for monitoring, displaying, and tracking performance metrics and application state. It offers real-time visualization of critical information to aid in development and debugging.

This module serves as a crucial tool for developers, enabling them to observe the inner workings of the application and identify potential issues or bottlenecks. By providing a consistent interface for displaying debug information, it significantly simplifies the development and maintenance process.

## Module Structure

The debug module is divided into four logical components, each with a specific responsibility:

1. **Core**: Manages basic debug state, visibility, and value storage. Provides the central registry for debug values and controls the overall state of the debug system.
2. **Metrics**: Tracks performance data like FPS, memory usage, and frame times. Implements the algorithms for measuring and calculating various performance indicators.
3. **Events**: Handles subscriptions and event processing. Connects the debug module to the rest of the application through the event system.
4. **Rendering**: Implements the drawing and visual representation of debug info. Transforms the collected data into a readable, organized display.

## Key Features / Algorithms

### Performance Monitoring
The metrics component tracks several key performance indicators:

1. **Frames Per Second (FPS)**: Real-time measurement of rendering speed, calculated by counting frames over time intervals.
2. **Memory Usage**: Tracking of Lua's garbage collection state, including total allocated memory and garbage collection cycles.
3. **Frame Time**: Measurement of time taken to process each frame, providing insights into performance bottlenecks.
4. **Rolling Averages**: Calculation of smoothed metrics over multiple frames to reduce noise and provide more stable readings.

### Event Integration
The events component connects the debug module to the rest of the application:

1. **Event Subscriptions**: Listening for important application events using the event system's subscription mechanism.
2. **Automatic Updates**: Refreshing debug values based on system changes, ensuring the display always shows current information.
3. **Cross-Module Communication**: Capturing state from other modules without creating direct dependencies.

### Interactive Controls
The module provides runtime control over the debug display:

1. **Visibility Toggle**: Keyboard shortcut to show/hide the debug overlay, allowing quick access during development.
2. **Custom Value Registration**: API for other modules to register debug values, enabling extensible debugging capabilities.

### Visual Display
The rendering component provides a structured display of information:

1. **Categorized Sections**: Grouping related information (performance, system, application) for easier comprehension.
2. **Hierarchical Layout**: Clear organization of metrics and values in a logical structure.
3. **Non-Intrusive Overlay**: Semi-transparent display that minimizes interference with the main application view.

## Data Flow

1. **Data Collection**: Metrics are gathered from various sources (LÖVE API, application state, events)
2. **Processing**: Raw data is processed into meaningful metrics (averaging, formatting, organizing)
3. **Storage**: Processed values are stored in the core component's registry
4. **Event Handling**: External events trigger updates to specific debug values
5. **Visibility Control**: User input toggles the visibility state of the debug display
6. **Rendering**: When visible, the rendering component draws the current debug state to the screen
7. **Periodic Updates**: Time-based refresh of metrics that need regular updating

## Integration with Other Modules

1. **Camera Module**: The debug module displays position and projection information from the camera, helping visualize the camera state and movement.
2. **Cube Module**: Face and vertex debug information from the cube module is captured and displayed, aiding in geometry troubleshooting.
3. **Event System**: By subscribing to application-wide events, the debug module stays updated with changes across the application without direct coupling.
4. **Input Module**: Keyboard shortcuts are processed to control debug visibility and interact with debug features.

## Performance Considerations

The debug module is designed to have minimal impact on application performance:

- **Throttled Updates**: Less-frequently changing values are updated at longer intervals, reducing processing overhead
- **Conditional Rendering**: Debug information is only drawn when visible, eliminating rendering costs when not in use
- **Efficient State Management**: Avoiding unnecessary calculations and using optimized data structures for value storage
- **Lazy Evaluation**: Some expensive metrics are only calculated when the debug display is visible

## Extendability

The architecture is designed to be extended in several ways:

1. Add new metrics or performance indicators for monitoring additional aspects of the application
2. Implement additional visualization modes such as different layouts or specialized views
3. Enhance the display with graphs or charts for visualizing trends over time
4. Create specialized debugging tools for specific application components
5. Add export functionality to save debug information for offline analysis

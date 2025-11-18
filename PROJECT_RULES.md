# 📋 Project Rules - Random Pomodoro Timer

This document outlines the comprehensive rules and guidelines for the Random Pomodoro Timer Flutter project. Follow these rules to maintain consistency, code quality, and project structure.

---

## 🏗️ Architecture Rules

### Project Structure
- **📁 Folder Organization**
  - `lib/pages/` - All screen/page widgets
  - `lib/widgets/` - Reusable custom widgets
  - `lib/services/` - Business logic and data management services
  - `lib/main.dart` - Application entry point

- **📄 File Naming**
  - Use `snake_case` for file names (e.g., `home_page.dart`, `timer_page.dart`)
  - Page files should end with `_page.dart`
  - Widget files should end with `_widget.dart`
  - Service files should end with `_storage.dart` or `_service.dart`

### Widget Architecture
- **StatefulWidget vs StatelessWidget**
  - Use `StatefulWidget` when the widget needs to manage state or handle user interactions
  - Use `StatelessWidget` for static or presentation-only widgets
  - Prefer composition over inheritance

- **State Management**
  - Use `setState()` for local widget state
  - Use `SharedPreferences` for persistent data storage
  - Keep state as close to where it's used as possible
  - Initialize state in `initState()` and clean up in `dispose()`

- **Service Layer**
  - Business logic should be separated into service classes
  - Services should be static utility classes when appropriate
  - Use async/await for asynchronous operations
  - Handle errors gracefully with try-catch blocks

### Navigation
- **Navigation Pattern**
  - Use `Navigator.push()` for navigating to new screens
  - Use `MaterialPageRoute` for route definitions
  - Always check `mounted` before calling `setState()` after async operations
  - Use `IndexedStack` in bottom navigation to preserve state

### Data Persistence
- **SharedPreferences Usage**
  - Store user preferences and simple key-value data
  - Use consistent key naming: `snake_case` with descriptive prefixes
  - Always handle date-based resets (e.g., daily spin limits)
  - Validate data when reading from SharedPreferences

---

## 🎨 Styling Rules

### Theme Configuration
- **Material 3**
  - Always use `useMaterial3: true` in ThemeData
  - Define color scheme using `ColorScheme.fromSeed()`
  - Use consistent seed color: `Colors.deepPurple`
  - Customize theme in `main.dart` only

- **Color Scheme**
  - Primary: `Colors.deepPurple`
  - Secondary: `Colors.blue`
  - Surface: `Colors.white`
  - Error: `Colors.red.shade400`
  - Use opacity variations (`.withOpacity()`) for subtle effects

### UI Components

#### AppBar
- **Consistent Styling**
  - Always use `centerTitle: true`
  - Set `elevation: 0` for flat design
  - Use `backgroundColor: Colors.deepPurple`
  - Use `foregroundColor: Colors.white`
  - Title text: `fontSize: 20`, `fontWeight: FontWeight.bold`

#### Buttons
- **ElevatedButton**
  - Use gradient backgrounds for primary actions
  - Border radius: `28` or `30` for rounded buttons
  - Padding: `horizontal: 32, vertical: 16`
  - Font size: `18`, `fontWeight: FontWeight.bold`
  - Add box shadows for depth: `blurRadius: 12`, `offset: Offset(0, 6)`
  - Use `letterSpacing: 0.5` or `1` for better readability

- **OutlinedButton**
  - Use for secondary actions (e.g., Reset button)
  - Border width: `2`
  - Match border radius with ElevatedButton

#### Cards and Containers
- **Card Styling**
  - Border radius: `12` to `20` for cards
  - Elevation: `2` for subtle depth
  - Margin: `horizontal: 16, vertical: 8`
  - Use gradient backgrounds for visual interest

- **Container Decoration**
  - Use `BoxDecoration` for custom styling
  - Apply gradients for visual appeal
  - Add box shadows: `blurRadius: 8-20`, `spreadRadius: 0-5`
  - Use border with opacity: `borderColor.withOpacity(0.3)`

#### Input Fields
- **InputDecoration**
  - Border radius: `12`
  - Use `filled: true` for better visibility
  - Use `OutlineInputBorder` for consistent borders

### Typography
- **Text Styles**
  - Headings: `fontSize: 24-28`, `fontWeight: FontWeight.bold`
  - Body: `fontSize: 16-18`, `fontWeight: FontWeight.w500-w600`
  - Captions: `fontSize: 14-16`, `color: Colors.grey.shade600`
  - Timer display: `fontSize: 56`, `fontWeight: FontWeight.bold`
  - Use `letterSpacing: 0.5-2` for better readability
  - Use `FontFeature.tabularFigures()` for numbers

### Spacing
- **Padding and Margins**
  - Screen padding: `24.0` for main content
  - Card padding: `16-24` horizontal, `16-20` vertical
  - Button spacing: `16` between buttons
  - Section spacing: `32-48` between major sections
  - Small spacing: `8-12` for related elements

### Visual Effects
- **Gradients**
  - Use `LinearGradient` for buttons and containers
  - Common gradient: `Colors.deepPurple` to `Colors.blue`
  - Use opacity variations: `.withOpacity(0.1-0.2)` for subtle backgrounds
  - Direction: `begin: Alignment.topLeft, end: Alignment.bottomRight`

- **Shadows**
  - Button shadows: `blurRadius: 12`, `offset: Offset(0, 6)`
  - Card shadows: `blurRadius: 8-20`, `offset: Offset(0, 4-10)`
  - Use opacity: `0.2-0.4` for shadow colors

- **Borders**
  - Border width: `2-3` for emphasis
  - Use opacity: `0.3` for subtle borders
  - Border radius: Match container radius

### Mobile Optimization
- **Touch Targets**
  - Minimum touch target size: `48x48` dp
  - Use `SizedBox` to enforce minimum sizes
  - Increase padding for better touch accessibility
  - Use `materialTapTargetSize: MaterialTapTargetSize.shrinkWrap` when needed

- **Responsive Design**
  - Use `MediaQuery` for screen size detection
  - Test on different screen sizes
  - Use `SingleChildScrollView` for scrollable content
  - Ensure content is accessible on small screens

---

## 📝 Code Conventions

### Naming Conventions
- **Variables**
  - Use `camelCase` for variable names
  - Use descriptive names: `_remainingSeconds` not `_time`
  - Prefix private variables with `_`
  - Use `_is`, `_has`, `_can` prefixes for boolean variables

- **Constants**
  - Use `lowerCamelCase` for private constants
  - Use `UPPER_SNAKE_CASE` for public constants
  - Define constants at the top of the class
  - Use `static const` for compile-time constants

- **Functions**
  - Use `camelCase` for function names
  - Use verb prefixes: `_load`, `_save`, `_handle`, `_on`
  - Event handlers: `_onEventName()` (e.g., `_onSpinPressed()`)
  - Async functions: Use `async`/`await`, not `.then()`

- **Classes**
  - Use `PascalCase` for class names
  - Use descriptive names: `TimerPage` not `Page1`
  - State classes: `_ClassNameState` pattern

### Code Organization
- **Import Order**
  1. Dart SDK imports
  2. Flutter package imports
  3. Third-party package imports
  4. Local project imports (relative paths)

- **Class Structure**
  ```dart
  class MyWidget extends StatefulWidget {
    // Constants
    // Constructor
    // Override methods (createState, etc.)
  }
  
  class _MyWidgetState extends State<MyWidget> {
    // Constants
    // Variables
    // Lifecycle methods (initState, dispose)
    // Helper methods
    // Build method
  }
  ```

### State Management
- **State Initialization**
  - Initialize in `initState()`
  - Load async data in `initState()` using async functions
  - Set `_isLoading = true` during async operations
  - Always check `mounted` before `setState()` after async

- **State Updates**
  - Always use `setState()` to update UI
  - Group related state updates in single `setState()` call
  - Avoid calling `setState()` in build method

- **Cleanup**
  - Cancel timers in `dispose()`
  - Close controllers in `dispose()`
  - Remove listeners in `dispose()`
  - Always call `super.dispose()` at the end

### Error Handling
- **Async Operations**
  - Use try-catch for async operations
  - Handle errors gracefully
  - Show user-friendly error messages
  - Log errors for debugging

- **Null Safety**
  - Use null-aware operators (`?.`, `??`)
  - Use `!` operator only when absolutely certain
  - Provide default values with `??`
  - Check for null before operations

### Widget Best Practices
- **Widget Composition**
  - Break down large widgets into smaller ones
  - Extract reusable widgets to separate files
  - Use `const` constructors when possible
  - Avoid deep widget nesting (max 3-4 levels)

- **Performance**
  - Use `const` widgets for static content
  - Avoid rebuilding entire tree unnecessarily
  - Use `ListView.builder` for long lists
  - Dispose controllers and timers properly

### Comments and Documentation
- **Code Comments**
  - Use comments to explain "why", not "what"
  - Add comments for complex logic
  - Use `// TODO:` for future improvements
  - Document public APIs with doc comments

- **Documentation**
  - Use `///` for public API documentation
  - Explain parameters and return values
  - Provide usage examples for complex widgets

### Animation
- **Animation Patterns**
  - Use `AnimationController` for controlled animations
  - Dispose animation controllers in `dispose()`
  - Use `SingleTickerProviderStateMixin` for single animations
  - Use `TickerProviderStateMixin` for multiple animations

- **Animation Timing**
  - Standard duration: `500ms` for transitions
  - Use `Curves.easeOutCubic` for smooth animations
  - Add delays for staggered animations: `index * 100ms`

### Testing Considerations
- **Testable Code**
  - Separate business logic from UI
  - Use dependency injection where possible
  - Make functions pure when possible
  - Avoid hard-coded values (use constants)

---

## 🔧 Specific Implementation Rules

### Timer Implementation
- **Timer Logic**
  - Use `Timer.periodic(Duration(seconds: 1))` for countdown
  - Always cancel timers in `dispose()`
  - Handle timer completion in callback
  - Reset timer state properly

- **Time Formatting**
  - Use `MM:SS` format for display
  - Use `padLeft(2, '0')` for zero-padding
  - Create helper function: `_formatTime(int seconds)`

### Roulette Implementation
- **Random Selection**
  - Use `Random().nextInt()` for selection
  - Store selected index before animation
  - Handle animation completion in callback
  - Update state after animation ends

- **Daily Limits**
  - Check date before allowing spins
  - Reset counter at midnight
  - Store date in `yyyy-MM-dd` format
  - Show clear feedback when limit reached

### Storage Implementation
- **SharedPreferences**
  - Use consistent key naming convention
  - Handle date-based resets automatically
  - Provide default values
  - Make storage operations async

### Navigation Flow
- **Page Transitions**
  - Use `MaterialPageRoute` for standard transitions
  - Pass required data via constructor
  - Handle back navigation properly
  - Reload data when returning to previous page

---

## ✅ Checklist for New Features

When adding new features, ensure:

- [ ] Follows folder structure conventions
- [ ] Uses consistent naming conventions
- [ ] Implements proper state management
- [ ] Handles errors gracefully
- [ ] Uses theme colors and styles
- [ ] Implements mobile touch optimization
- [ ] Adds proper cleanup in dispose()
- [ ] Includes loading states
- [ ] Follows Material 3 design guidelines
- [ ] Tests on different screen sizes
- [ ] Adds appropriate animations
- [ ] Documents complex logic

---

## 🚫 Anti-Patterns to Avoid

- ❌ Don't use `setState()` in build method
- ❌ Don't forget to dispose controllers/timers
- ❌ Don't hard-code colors (use theme)
- ❌ Don't create widgets in build method
- ❌ Don't ignore null safety
- ❌ Don't use magic numbers (use constants)
- ❌ Don't nest widgets too deeply
- ❌ Don't forget to check `mounted` after async
- ❌ Don't use `.then()` instead of async/await
- ❌ Don't create large monolithic widgets

---

**Last Updated**: 2024
**Version**: 1.0.0


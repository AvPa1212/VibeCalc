# VibeCalc

A powerful, visually appealing multi-platform calculator app built with Flutter. VibeCalc combines essential calculator functionality with advanced features like graphing, unit conversion, calculus operations, matrix mathematics, and complex number support.

## Features

### 📊 Calculator Modes
- **Basic Mode**: Standard arithmetic operations with clean, responsive interface
- **Scientific Mode**: Advanced mathematical functions including:
  - Trigonometric functions (sin, cos, tan, arcsin, arccos, arctan)
  - Logarithmic functions (log, ln, log₂)
  - Complex number calculations
  - Factorial, modulo, and power operations
  - Parentheses support for complex expressions

### 📈 Graphing
- Interactive function graphing powered by fl_chart
- Real-time graph visualization
- Customizable axis ranges and divisions
- Support for complex mathematical expressions

### 🔄 Unit Converter
- Convert between various unit categories:
  - Length (m, km, cm, mm, ft, in, yd, mi)
  - Mass (kg, g, mg, lb, oz, t)
  - Time (s, ms, μs, min, hr, day, week)
  - Temperature (°C, °F, K)
  - Volume and other common units
- Instant conversion with formatted output

### ∫ Calculus
- Numerical derivatives and differentiation
- Definite integral calculations
- Custom interval control
- Precision-based result formatting

### 🔣 Matrix Operations
- Matrix input and manipulation
- Basic matrix arithmetic
- Determinant and inverse calculations
- Support for various matrix sizes

### 🎨 Themes
Multiple beautiful themes with Material Design 3:
- Vibe Dark (default)
- Sunset
- Midnight
- Forest

Each theme includes optimized color schemes for easy calculation with reduced eye strain.

### 💾 Persistent Data
- Automatic history storage
- Settings persistence (theme preference)
- Expression memory

## Platforms

VibeCalc runs on:
- ✅ Windows (Desktop)
- ✅ macOS (Desktop)
- ✅ Linux (Desktop)
- ✅ Android (Mobile)
- ✅ iOS (Mobile)
- ✅ Web (Browser - Edge, Chrome, Firefox)

## Getting Started

### Prerequisites
- Flutter SDK (3.3.0 or higher)
- Dart SDK
- Platform-specific requirements:
  - **Windows**: Visual Studio Build Tools or Visual Studio Community
  - **macOS**: Xcode Command Line Tools
  - **Linux**: build-essential, clang, cmake
  - **Android**: Android Studio or Android SDK
  - **iOS**: Xcode

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd vibecalc
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   # Development build
   flutter run
   
   # or run on specific device
   flutter run -d <device-id>
   ```

### Building for Release

**Windows:**
```bash
flutter build windows
# Output: build/windows/runner/Release/vibecalc.exe
```

**macOS:**
```bash
flutter build macos
# Output: build/macos/Build/Products/Release/vibecalc.app
```

**Linux:**
```bash
flutter build linux
# Output: build/linux/x64/release/bundle/vibecalc
```

**Android:**
```bash
flutter build apk
# or for App Bundle:
flutter build appbundle
```

**iOS:**
```bash
flutter build ios
# Open in Xcode for distribution
```

**Web:**
```bash
flutter build web
# Output: build/web/
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── core/
│   ├── app_router.dart      # Navigation routing
│   └── constants.dart       # App-wide constants
├── models/
│   ├── calculator_model.dart    # State management
│   └── memory_model.dart        # Memory operations
├── screens/
│   ├── home_screen.dart         # Main navigation
│   ├── calculator_screen.dart   # Basic + Scientific modes
│   ├── graph_screen.dart        # Graphing interface
│   ├── converter_screen.dart    # Unit conversion
│   ├── calculus_screen.dart     # Derivative/Integral
│   ├── matrix_screen.dart       # Matrix operations
│   ├── about_screen.dart        # App information
│   └── settings_screen.dart     # User preferences
├── services/
│   ├── math_engine.dart         # Basic math operations
│   ├── complex_engine.dart      # Complex number math
│   ├── expression_evaluator.dart # Expression parsing
│   ├── graph_engine.dart        # Function graphing
│   ├── calculus_engine.dart     # Derivative/Integral
│   ├── matrix_engine.dart       # Matrix operations
│   ├── unit_engine.dart         # Unit conversion
│   └── persistence_service.dart # Data persistence
├── theme/
│   ├── theme_provider.dart      # Theme state management
│   └── themes.dart              # Theme definitions
└── widgets/
    ├── animated_calc_button.dart # Custom button widget
    ├── display_panel.dart        # Calculation display
    ├── history_drawer.dart       # History panel
    └── theme_picker.dart         # Theme selection
```

## State Management

VibeCalc uses **Provider** for state management:
- `CalculatorModel`: Manages calculator state and expression history
- `ThemeProvider`: Handles theme switching and persistence

## Key Dependencies

- **flutter**: UI framework
- **provider**: State management
- **math_expressions**: Mathematical expression parsing and evaluation
- **fl_chart**: Charting library for graphing
- **shared_preferences**: Local data persistence

## Usage Tips

1. **Switch Modes**: Use the tabs in the calculator to switch between Basic and Scientific modes
2. **Change Theme**: Open Settings to select your preferred theme
3. **View History**: Swipe from the left edge to open the history drawer
4. **Graph Functions**: Enter expressions like `sin(x)` or `x^2` for visualization
5. **Complex Numbers**: Use `i` or `j` for imaginary unit in scientific mode

## Known Limitations

- Graph rendering limited to functions of a single variable
- Calculation precision depends on Dart's double precision (15-17 significant digits)
- Matrix operations limited to practical sizes for performance

## Contributing

Contributions are welcome! Please feel free to:
- Report bugs
- Suggest new features
- Submit pull requests

## License

This project is provided as-is for educational and personal use.

## Support

For issues or questions:
1. Check the app's About screen for version information
2. Review this README for common issues
3. Check the GitHub issues page

---

**VibeCalc** - Calculate with style! ✨

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

言意合一 (yanyiheyi) is a Flutter cross-platform writing activity tracking application that visualizes daily writing activities in a calendar format. The app supports Android, iOS, Web, Windows, macOS, and Linux platforms.

## Common Commands

### Development
```bash
flutter pub get              # Install dependencies
flutter run                  # Run the app
flutter run -d <device>      # Run on specific device
```

### Building
```bash
flutter build apk            # Android APK
flutter build appbundle      # Android App Bundle
flutter build ios            # iOS application
flutter build web            # Web application
flutter build windows        # Windows application
flutter build macos          # macOS application
```

### Testing and Quality
```bash
flutter test                 # Run unit tests
flutter test --coverage      # Generate test coverage
flutter analyze              # Run static analysis (linting)
```

### Dependencies
```bash
flutter pub outdated         # Check for outdated dependencies
flutter pub upgrade          # Upgrade dependencies
```

## Architecture

### State Management
The app uses a lightweight state management approach with `ValueNotifier`:
- **ThemeController**: Manages light/dark theme mode with `ValueNotifier<ThemeMode>`
- Persists theme preferences using `SharedPreferences`
- Reactive updates via `ValueListenableBuilder` without full app rebuild
- No complex state management libraries (Provider, Bloc, Riverpod) are currently used

### Directory Structure
```
lib/
├── main.dart                 # App entry point with mock data generation
├── core/
│   └── theme/               # Centralized theme management
│       ├── app_colors.dart  # Color constants for light/dark themes
│       ├── app_theme.dart   # Complete theme definitions
│       └── theme_controller.dart # Theme state management
├── widgets/                 # Reusable UI components
│   ├── custom_app_bar.dart  # App bar with logo and theme toggle
│   ├── expandable_fab.dart  # Expandable floating action button
│   ├── page_container.dart  # Unified page container (consistent padding)
│   ├── theme_mode_button.dart # Theme toggle button
│   └── writing_activity_calendar.dart # Main calendar widget
└── assets/
    └── icon.svg             # App icon
```

### Theme System
The theme system is fully centralized in `core/theme/`:
- **AppColors**: Private constructor with color constants for both themes
- **AppTheme**: Private constructor with complete ThemeData definitions
- **ThemeController**: ValueNotifier-based controller for theme switching
- Access current theme with `Theme.of(context)` throughout the app
- Complete light/dark theme support for all components

### Widget Patterns
- **PageContainer**: Use this wrapper for all page content to maintain consistent padding
- **CustomAppBar**: Standardized app bar with logo and theme toggle button
- **StatelessWidget**: Preferred for most components; use dependency injection for controllers
- **ValueListenableBuilder**: For reactive updates (especially theme changes)
- **Private constructors**: Utility classes use private constructors (e.g., `AppColors._()`, `AppTheme._()`)

### Data Layer
- Currently uses **mock data** with a fixed seed (1704067200000) for reproducible testing
- Data model: `ActivityData` class with JSON serialization support
- No API service layer yet - all data is generated in `main.dart`
- Mock data covers 365 days with activity levels 0-4 and randomized counts

### Navigation
- Currently a **single-page application** with only `HomePage`
- No navigation framework (Navigator, routing packages) implemented yet
- The architecture is designed for future expansion to multi-page

## Key Dependencies

- **flutter_svg**: ^2.2.3 - For SVG icon rendering
- **intl**: ^0.19.0 - For date formatting (Chinese locale)
- **shared_preferences**: ^2.2.2 - For theme persistence
- **flutter_lints**: ^6.0.0 - Standard Flutter linting rules

## Coding Conventions

1. **Language**: Chinese comments for domain-specific concepts; code in English
2. **Widget Structure**: Small, focused widgets with single responsibilities
3. **Theme Access**: Always use `Theme.of(context)` to access theme colors/styles
4. **State Management**: Use `ValueListenableBuilder` for reactive updates to avoid full rebuilds
5. **Dependency Injection**: Pass controllers through constructor parameters
6. **Mock Data**: When adding test data, use fixed seeds for reproducibility

## Important Implementation Notes

- The expandable FAB (ExpandableFAB) has custom positioning parameters that differ from defaults
- Activity calendar uses 4 levels (0-4) for activity visualization with color gradients
- Date formatting uses Chinese locale: `DateFormat('yyyy-MM-dd')`
- Theme controller must be initialized in `main()` before `runApp()` using `WidgetsFlutterBinding.ensureInitialized()`

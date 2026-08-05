# Contributing to RPG Workout App

Thank you for your interest in contributing to the RPG Workout App! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Git Workflow](#git-workflow)
- [Code Generation](#code-generation)
- [Reporting Issues](#reporting-issues)

## Development Setup

### Prerequisites

- Flutter SDK 3.22.0 or higher
- Dart 3.4.0 or higher
- Android Studio / VS Code with Flutter extensions
- Git

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/owdvertsbot/Workout-flutter-app.git
   cd Workout-flutter-app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate database code:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. Run the app:
   ```bash
   flutter run
   ```

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Running Analysis

```bash
# Run static analysis
flutter analyze

# Run with all warnings treated as errors
flutter analyze --fatal-warnings
```

## Project Structure

```
lib/
├── core/              # Core utilities and constants
├── database/          # Drift database configuration
├── models/            # Data models
├── providers/         # Riverpod state management
├── screens/           # UI screens
├── services/          # Business logic services
└── main.dart          # App entry point
```

### Key Technologies

- **State Management**: Riverpod with code generation
- **Database**: Drift (SQLite) with offline-first approach
- **UI**: Material Design 3 with Google Fonts (Inter, Space Grotesk)

## Coding Standards

### Dart/Flutter Conventions

1. **Naming**
   - Use `camelCase` for variables and functions
   - Use `PascalCase` for classes and types
   - Use `snake_case` for file names

2. **Imports**
   - Group imports: `dart:` → `package:` → relative
   - Use `part`/`part of` for related files

3. **Widgets**
   - Use `const` constructors where possible
   - Keep widgets focused and small
   - Extract reusable widgets to separate files

4. **Providers**
   - Follow Riverpod naming conventions (`*Provider`, `*Notifier`)
   - Use code generation (`@riverpod` annotation)

### Error Handling

- Use custom exception classes in `lib/core/exceptions.dart`
- Use `Result<T>` type for operations that can fail
- Handle errors at the appropriate level (don't swallow exceptions)

### Code Style

```dart
// ✅ Good
final user = await database.getUser(id);

// ❌ Avoid
final user = database.getUser(id);
```

## Testing

### Unit Tests

Place tests in the `test/` directory following the same structure as `lib/`:

```
test/
├── models_test.dart
├── providers_test.dart
└── widgets/
    └── screens_test.dart
```

### Writing Tests

```dart
test('calculates XP correctly for working set', () {
  final set = SetEntryModel(
    id: 'test-1',
    sessionId: 'session-1',
    exerciseId: 'ex-1',
    weightKg: 100.0,
    reps: 10,
    setType: SetType.working,
    isCompleted: true,
  );
  expect(set.calculateXp(), equals(17));
});
```

### Widget Tests

```dart
testWidgets('SplashScreen shows loading state', (WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: RPGWorkoutApp()));
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

## Git Workflow

### Branch Naming

- `fix/` - Bug fixes (e.g., `fix/xp-formula-bug`)
- `feature/` - New features (e.g., `feature/dark-mode`)
- `refactor/` - Code refactoring (e.g., `refactor/theme-colors`)
- `docs/` - Documentation changes

### Commit Messages

Follow conventional commits:

```
type(scope): description

[optional body]

[optional footer]
```

Examples:
- `fix(models): correct XP formula power function`
- `docs(readme): update installation instructions`
- `refactor(colors): extract hardcoded colors to AppColors class`

### Pull Requests

1. Create a branch from `main`
2. Make your changes
3. Ensure CI passes (analyze + tests)
4. Open a PR with a clear description
5. Reference related issues with `Fixes #123` or `Relates to #456`

### PR Description Template

```markdown
## Summary
Brief description of the changes.

## Changes
- Change 1
- Change 2

## Testing
- [ ] Test A
- [ ] Test B

## Screenshots (if UI changes)
[Add screenshots here]
```

## Code Generation

This project uses code generation for:

1. **Drift Database** - Generates type-safe SQL code
2. **Riverpod** - Generates provider code

### Running Code Generators

```bash
# Generate all code
dart run build_runner build --delete-conflicting-outputs

# Watch for changes (during development)
dart run build_runner watch --delete-conflicting-outputs
```

### When to Regenerate

Run `build_runner` after:
- Adding/modifying database tables
- Adding/modifying Riverpod providers
- Updating model classes

## Reporting Issues

### Bug Reports

Include:
- Flutter version
- Steps to reproduce
- Expected vs actual behavior
- Device/emulator info
- Error logs

### Feature Requests

Include:
- Use case description
- Proposed solution (optional)
- Mockups/screenshots (optional)

### Security Issues

**Please do not report security vulnerabilities through public GitHub issues.**

If you discover a security issue, please email the maintainers directly.

## Questions?

Feel free to open an issue for questions about contributing.

---

Thank you for contributing! 🎮💪

# Adaptive Health

**Evidence-based digital health coach for complete beginners**

Adaptive Health is a modern, minimal health app that automatically prescribes personalized daily plans based on scientific exercise, nutrition, and recovery principles. The app adapts continuously based on workout performance, recovery, sleep, and simple feedback.

![Adaptive Health](https://img.shields.io/badge/version-3.0.0-blue) ![Flutter](https://img.shields.io/badge/Flutter-3.22.0-green) ![License](https://img.shields.io/badge/license-MIT-purple)

## ✨ Features

### 🎯 Automatic Personalization
- **Comprehensive Assessment**: Captures age, height, weight, activity level, goals, equipment, injuries, allergies, budget, and cooking skills
- **Evidence-Based Prescriptions**: All recommendations powered by scientific research
- **Continuous Adaptation**: Adjusts plans based on performance, recovery, sleep, and feedback
- **"Why?" Explanations**: Every recommendation includes transparent scientific rationale

### 🏋️ Movement
- Auto-prescribed daily exercises (no manual selection needed)
- Accessibility-based substitutions for injuries and disabilities
- Progressive adaptation based on performance
- Clean, beginner-friendly interface

### 🥗 Nutrition
- Personalized calorie and macro targets
- Meal timing recommendations
- Hydration tracking
- Budget-conscious meal guidance

### 😴 Recovery
- Sleep optimization guidance
- Readiness scoring
- Recovery activity suggestions
- Stress management

### 📚 Education
- Science-backed health content
- Understanding the "why" behind recommendations
- Habit formation guidance

### 💫 Progress System (Adapted)
- XP represents effective adaptation
- Levels show overall progress
- Ranks indicate training maturity
- Achievements celebrate health milestones

*Note: We retained the progression system as motivational visualization while removing fantasy themes, currencies, and game-like interfaces.*

### 🔄 Offline-First
- SQLite database for local storage
- No internet required for core features
- Cloud sync ready for future implementation

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.22.0 or higher
- Dart 3.4.0 or higher
- Android Studio / VS Code with Flutter extensions

### Installation

```bash
# Clone the repository
git clone https://github.com/owdvertsbot/Workout-flutter-app.git
cd Workout-flutter-app

# Install dependencies
flutter pub get

# Generate Drift database code (if needed)
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Building

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release
```

## 📁 Project Structure

```
lib/
├── core/                    # Error handling, constants
│   └── errors.dart         # Custom exceptions and Result types
├── database/               # SQLite database (Drift)
│   ├── database.dart       # Database definitions
│   └── database.g.dart     # Generated Drift code
├── health/                 # NEW: Adaptive Health module
│   ├── core/
│   │   └── theme.dart     # Material 3 design system
│   ├── models/
│   │   ├── user_profile.dart      # User data model
│   │   ├── prescriptions.dart     # Exercise/nutrition prescriptions
│   │   └── adaptation.dart       # Performance tracking
│   ├── providers/
│   │   ├── prescription_providers.dart  # Prescription generation
│   │   └── adaptation_providers.dart    # Performance/feedback
│   ├── evidence/
│   │   └── evidence_service.dart        # Scientific explanations
│   └── screens/
│       └── main_shell.dart     # Four-pillar navigation
├── models/                 # Legacy models (being migrated)
├── providers/              # State management (Riverpod)
├── screens/               # Legacy UI screens (being migrated)
└── main.dart              # App entry point
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| flutter_riverpod | State management |
| drift | SQLite database |
| sqlite3_flutter_libs | SQLite native bindings |
| shared_preferences | Simple key-value storage |
| google_fonts | Typography (Inter) |
| uuid | Unique ID generation |

## 🔒 Security

- No secrets committed to the repository
- `.gitignore` configured for sensitive files
- Drift parameterized queries (SQL injection safe)

## 📄 License

MIT License - see LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📞 Support

For issues and feature requests, please open a GitHub issue.

---

*Formerly known as RPG Workout App. The app is being transformed into Adaptive Health with a focus on evidence-based, beginner-friendly health coaching.*

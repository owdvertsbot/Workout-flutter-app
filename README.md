# RPG Workout App

A gamified workout tracking app that transforms fitness into an RPG-like experience. Track your workouts, earn XP, level up your character, and complete quests!

![RPG Workout](https://img.shields.io/badge/version-2.4.0-blue) ![Flutter](https://img.shields.io/badge/Flutter-3.27.0-green) ![License](https://img.shields.io/badge/license-MIT-purple)

## ✨ Features

### 🎮 Gamification
- **XP System**: Earn experience points for every set, workout, and PR
- **Leveling**: Progress through levels as you train (Level 1 → Legendary Champion)
- **Gold & Rewards**: Earn gold from completing workout plans
- **RPG Stats**: Strength, Dexterity, Vitality, Endurance

### 💪 Workout Tracking
- Log sets with weight, reps, and RPE (Rate of Perceived Exertion)
- 4 set types: Warmup, Working, Drop Set, Failure
- Rest timer between sets
- Exercise library with 1,300+ exercises

### 🏆 Quest Missions
- Pre-built workout plans (Beginner → Advanced)
- Daily and weekly challenges
- Muscle group focused routines

### 📊 Analytics
- Workout history and progress charts
- Personal Records (PR) tracking
- Volume and consistency metrics

### 🔄 Offline-First
- SQLite database for local storage
- No internet required for core features
- Data persists across sessions

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.27.0 or higher
- Dart 3.6.0 or higher
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
```

## 📁 Project Structure

```
lib/
├── core/                    # Error handling, constants
│   └── errors.dart         # Custom exceptions and Result types
├── database/                # SQLite database (Drift)
│   ├── database.dart       # Database definitions
│   └── database.g.dart     # Generated Drift code
├── models/                 # Data models
│   └── models.dart        # Exercise, Set, Player, Quest models
├── providers/              # State management (Riverpod)
│   └── providers.dart     # All providers (~1,170 lines)
├── screens/               # UI screens
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── dashboard_screen.dart
│   ├── exercise_library_screen.dart
│   ├── active_workout_screen.dart
│   ├── workout_plans_screen.dart
│   ├── progress_analytics_screen.dart
│   └── profile_screen.dart
└── main.dart              # App entry point
```

## 🎯 XP & Leveling System

| Source | XP Formula |
|--------|-----------|
| Set Completed | `reps × 10 + set_type_multiplier` |
| Workout Complete | `volume / 100 + streak_days × 5` |
| All-Time PR | +250 XP |
| 2-Month PR | +100 XP |
| Volume PR | +50 XP |

**Level Formula**: `250 × level^1.5 + 500` XP per level

### Character Titles
| Level | Title |
|-------|-------|
| 1-4 | Novice Trainee |
| 5-9 | Apprentice |
| 10-19 | Skilled Warrior |
| 20-29 | Veteran Adventurer |
| 30-39 | Elite Fighter |
| 40-49 | Master Warrior |
| 50+ | Legendary Champion |

## 🏋️ Exercise Data

Exercises are loaded from `assets/exercises.json` (~13 MB, 1,300+ exercises).

The dataset includes:
- Exercise name, category, body part
- Primary and secondary muscles
- Equipment required
- Step-by-step instructions

## 🔧 Configuration

### Environment Variables
Create a `.env` file for API keys (if using cloud features):
```env
API_KEY=your_api_key_here
```

### Database
The app uses Drift (SQLite) with offline storage. Schema version is tracked for future migrations.

## 📱 Screens

| Screen | Purpose |
|--------|---------|
| Splash | App initialization, session recovery |
| Onboarding | First-time user setup |
| Dashboard | Daily overview, quick actions |
| Exercise Library | Browse/search 1,300+ exercises |
| Active Workout | Log sets, rest timer, complete workout |
| Quest Missions | Pre-built workout plans |
| Progress | Charts, history, PRs |
| Profile | Character stats, settings |

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
| google_fonts | Typography |
| fl_chart | Charts and graphs |
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

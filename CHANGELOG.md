# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New health module architecture for evidence-based prescriptions
- Four-pillar navigation: Movement, Nutrition, Recovery, Education
- Comprehensive user profile model with personalization data
- Evidence service with scientific explanations for recommendations
- Accessibility-based exercise substitutions
- Clean Material 3 theme design

### Changed
- **Breaking**: Renamed package from `rpg_workout_app` to `adaptive_health`
- **Breaking**: Renamed app from "RPG Workout" to "Adaptive Health"
- Removed RPG/fantasy theming in favor of clean, evidence-based design
- Retained progress system (XP/levels) as motivational layer only

### Deprecated
- RPG theming elements (neon colors, fantasy icons)
- Game-like interfaces and currencies

## [1.2.0] - 2024-08-06

### Added
- Improved accessibility with semantic labels on icons
- Release automation workflow for GitHub Actions
- Auto-update GitHub Pages on release
- APK/AAB builds with release notes

### Changed
- Updated providers.dart comments for clarity

## [1.1.0] - 2024-07-15

### Added
- Settings providers extraction
- Onboarding flow improvements

## [1.0.0] - 2024-06-01

### Added
- Initial release
- RPG gamification system (XP, levels, achievements)
- Exercise library with 1300+ exercises
- Workout tracking with sets, reps, weight
- Workout plans/quest missions
- Progress analytics
- Dark/light theme support
- Offline-first SQLite database

[Unreleased]: https://github.com/owdvertsbot/Workout-flutter-app/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/owdvertsbot/Workout-flutter-app/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/owdvertsbot/Workout-flutter-app/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/owdvertsbot/Workout-flutter-app/releases/tag/v1.0.0

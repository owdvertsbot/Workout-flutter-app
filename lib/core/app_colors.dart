import 'package:flutter/material.dart';

/// Centralized color definitions for the app.
/// Use these colors instead of hardcoded values throughout the codebase.

class AppColors {
  AppColors._();

  // Brand Colors
  static const Color primary = Color(0xFF00E676);
  static const Color secondary = Color(0xFF7C4DFF);
  static const Color tertiary = Color(0xFFFFD700);

  // Background Colors (Dark Theme)
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF1E1E1E);

  // Background Colors (Light Theme)
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Colors.white;
  static const Color cardLight = Colors.white;

  // Difficulty Colors
  static const Color difficultyBeginner = Color(0xFF00E676);
  static const Color difficultyIntermediate = Color(0xFFFFB300);
  static const Color difficultyAdvanced = Color(0xFFFF5252);

  // Semantic Colors
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF2196F3);

  // XP & Level Colors
  static const Color xpGold = Color(0xFFFFD700);
  static const Color xpOrange = Color(0xFFFF8C00);
  static const Color primaryDark = Color(0xFF00C853);
  static const Color levelPurple = Color(0xFF7C4DFF);

  // Gradient Colors
  static const Color gradientPurple = Color(0xFF6366F1);
  static const Color gradientViolet = Color(0xFF8B5CF6);
  static const Color borderDark = Color(0xFF2D2D2D);

  // Medal Colors
  static const Color medalGold = Color(0xFFFFD700);
  static const Color medalSilver = Color(0xFFC0C0C0);
  static const Color medalBronze = Color(0xFFCD7F32);

  // Text Colors
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  static const Color textPrimaryLight = Colors.black;
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Border Colors
  static const Color borderDark = Color(0xFF2D2D2D);
  static const Color borderLight = Color(0xFFE0E0E0);

  // Helper method to get color for difficulty
  static Color getDifficultyColor(String difficulty) {
    switch (difficulty.toUpperCase()) {
      case 'BEGINNER':
        return difficultyBeginner;
      case 'INTERMEDIATE':
        return difficultyIntermediate;
      case 'ADVANCED':
        return difficultyAdvanced;
      default:
        return Colors.grey;
    }
  }

  // Helper method to get background color based on brightness
  static Color getBackgroundColor(Brightness brightness) {
    return brightness == Brightness.dark ? backgroundDark : backgroundLight;
  }

  // Helper method to get surface color based on brightness
  static Color getSurfaceColor(Brightness brightness) {
    return brightness == Brightness.dark ? surfaceDark : surfaceLight;
  }

  // Helper method to get card color based on brightness
  static Color getCardColor(Brightness brightness) {
    return brightness == Brightness.dark ? cardDark : cardLight;
  }

  // Helper method to get text primary color based on brightness
  static Color getTextPrimaryColor(Brightness brightness) {
    return brightness == Brightness.dark ? textPrimaryDark : textPrimaryLight;
  }

  // Helper method to get text secondary color based on brightness
  static Color getTextSecondaryColor(Brightness brightness) {
    return brightness == Brightness.dark ? textSecondaryDark : textSecondaryLight;
  }

  // Helper method to get text muted color based on brightness
  static Color getTextMutedColor(Brightness brightness) {
    return brightness == Brightness.dark ? textMutedDark : textMutedLight;
  }
}

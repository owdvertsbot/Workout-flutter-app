// Adaptive Health - Core Theme
// Material 3 design system with clean, accessible styling

import 'package:flutter/material.dart';

/// Adaptive Health color palette
/// Clean, modern colors suitable for a health-focused application
class HealthColors {
  HealthColors._();

  // Primary palette - Calming teal/green for health
  static const Color primary = Color(0xFF0D9488);
  static const Color primaryLight = Color(0xFF5EEAD4);
  static const Color primaryDark = Color(0xFF0F766E);
  
  // Secondary palette - Warm coral for energy/action
  static const Color secondary = Color(0xFFF97316);
  static const Color secondaryLight = Color(0xFFFDBA74);
  static const Color secondaryDark = Color(0xFFEA580C);
  
  // Neutral palette - Clean grays
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  
  // Dark theme surfaces
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceVariantDark = Color(0xFF334155);
  
  // Semantic colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFEAB308);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Text colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Dark text
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);
  
  // Pillar colors - Four core areas
  static const Color movement = Color(0xFF3B82F6);    // Blue
  static const Color nutrition = Color(0xFF22C55E);   // Green
  static const Color recovery = Color(0xFF8B5CF6);    // Purple
  static const Color education = Color(0xFFF59E0B);    // Amber
  
  // Progress/motivation colors (adapted from RPG system, without game aesthetics)
  static const Color progress = Color(0xFF0D9488);    // Same as primary
  static const Color streak = Color(0xFFEF4444);      // Red for urgency
  static const Color milestone = Color(0xFFF59E0B);   // Amber for celebrations
}

/// Adaptive Health typography
/// Clean, readable fonts with proper hierarchy
class HealthTypography {
  HealthTypography._();
  
  static const String fontFamily = 'Inter';
  
  // Display styles for large headings
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );
  
  // Headlines
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );
  
  // Titles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.27,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.5,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );
  
  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );
  
  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );
}

/// Adaptive Health spacing system
class HealthSpacing {
  HealthSpacing._();
  
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  
  // Specific use cases
  static const double cardPadding = 16;
  static const double screenPadding = 20;
  static const double sectionGap = 24;
  static const double itemGap = 12;
}

/// Adaptive Health border radius
class HealthRadius {
  HealthRadius._();
  
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;
}

/// Adaptive Health shadows
class HealthShadows {
  HealthShadows._();
  
  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get elevated => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}

/// Build the Adaptive Health theme
class HealthTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: HealthColors.primary,
        brightness: Brightness.light,
        primary: HealthColors.primary,
        onPrimary: HealthColors.textOnPrimary,
        secondary: HealthColors.secondary,
        onSecondary: HealthColors.textOnPrimary,
        surface: HealthColors.surface,
        onSurface: HealthColors.textPrimary,
        surfaceContainerHighest: HealthColors.surfaceVariant,
        error: HealthColors.error,
      ),
      scaffoldBackgroundColor: HealthColors.background,
      
      // AppBar
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: HealthColors.background,
        foregroundColor: HealthColors.textPrimary,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: HealthColors.textPrimary,
        ),
      ),
      
      // Cards
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HealthRadius.md),
        ),
        color: HealthColors.surface,
      ),
      
      // Elevated buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: HealthSpacing.lg,
            vertical: HealthSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(HealthRadius.sm),
          ),
          textStyle: HealthTypography.labelLarge,
        ),
      ),
      
      // Filled buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: HealthSpacing.lg,
            vertical: HealthSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(HealthRadius.sm),
          ),
          textStyle: HealthTypography.labelLarge,
        ),
      ),
      
      // Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: HealthSpacing.lg,
            vertical: HealthSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(HealthRadius.sm),
          ),
          side: const BorderSide(color: HealthColors.textSecondary),
          textStyle: HealthTypography.labelLarge,
        ),
      ),
      
      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: HealthSpacing.md,
            vertical: HealthSpacing.sm,
          ),
          textStyle: HealthTypography.labelLarge,
        ),
      ),
      
      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HealthColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: HealthSpacing.md,
          vertical: HealthSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HealthRadius.sm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HealthRadius.sm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HealthRadius.sm),
          borderSide: const BorderSide(color: HealthColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HealthRadius.sm),
          borderSide: const BorderSide(color: HealthColors.error),
        ),
        labelStyle: HealthTypography.bodyMedium.copyWith(
          color: HealthColors.textSecondary,
        ),
        hintStyle: HealthTypography.bodyMedium.copyWith(
          color: HealthColors.textTertiary,
        ),
      ),
      
      // Navigation bar
      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        elevation: 0,
        backgroundColor: HealthColors.surface,
        indicatorColor: HealthColors.primary.withOpacity(0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return HealthTypography.labelSmall.copyWith(
              color: HealthColors.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return HealthTypography.labelSmall.copyWith(
            color: HealthColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: HealthColors.primary,
              size: 24,
            );
          }
          return const IconThemeData(
            color: HealthColors.textSecondary,
            size: 24,
          );
        }),
      ),
      
      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: HealthColors.primary,
        inactiveTrackColor: HealthColors.primary.withOpacity(0.24),
        thumbColor: HealthColors.primary,
        overlayColor: HealthColors.primary.withOpacity(0.12),
        trackHeight: 4,
      ),
      
      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: HealthColors.surfaceVariant,
        selectedColor: HealthColors.primary.withOpacity(0.12),
        labelStyle: HealthTypography.labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: HealthSpacing.sm,
          vertical: HealthSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HealthRadius.full),
        ),
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: HealthColors.surfaceVariant,
        thickness: 1,
        space: HealthSpacing.md,
      ),
      
      // Bottom sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: HealthColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(HealthRadius.lg),
          ),
        ),
      ),
      
      // Dialog
      dialogTheme: DialogTheme(
        backgroundColor: HealthColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HealthRadius.lg),
        ),
      ),
      
      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: HealthColors.textPrimaryDark,
        contentTextStyle: HealthTypography.bodyMedium.copyWith(
          color: HealthColors.textPrimaryDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HealthRadius.sm),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: HealthColors.primary,
        brightness: Brightness.dark,
        primary: HealthColors.primaryLight,
        onPrimary: HealthColors.backgroundDark,
        secondary: HealthColors.secondaryLight,
        onSecondary: HealthColors.backgroundDark,
        surface: HealthColors.surfaceDark,
        onSurface: HealthColors.textPrimaryDark,
        surfaceContainerHighest: HealthColors.surfaceVariantDark,
        error: HealthColors.error,
      ),
      scaffoldBackgroundColor: HealthColors.backgroundDark,
      
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: HealthColors.backgroundDark,
        foregroundColor: HealthColors.textPrimaryDark,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: HealthColors.textPrimaryDark,
        ),
      ),
      
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HealthRadius.md),
        ),
        color: HealthColors.surfaceDark,
      ),
      
      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        elevation: 0,
        backgroundColor: HealthColors.surfaceDark,
        indicatorColor: HealthColors.primaryLight.withOpacity(0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return HealthTypography.labelSmall.copyWith(
              color: HealthColors.primaryLight,
              fontWeight: FontWeight.w600,
            );
          }
          return HealthTypography.labelSmall.copyWith(
            color: HealthColors.textSecondaryDark,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: HealthColors.primaryLight,
              size: 24,
            );
          }
          return const IconThemeData(
            color: HealthColors.textSecondaryDark,
            size: 24,
          );
        }),
      ),
      
      // Similar dark theme adaptations for other components...
    );
  }
}

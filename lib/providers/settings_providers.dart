// Settings providers - manages user settings, theme preferences, and onboarding.
// Part of the provider modularization effort (Issue #21)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

// User settings provider
class UserSettings {
  final bool useMetric;
  final double barbellWeight;
  final int defaultRestSeconds;
  final int warmupRestSeconds;
  final bool vibrateOnTimerEnd;
  final bool autoStartRestTimer;

  const UserSettings({
    this.useMetric = true,
    this.barbellWeight = 20.0,
    this.defaultRestSeconds = 90,
    this.warmupRestSeconds = 45,
    this.vibrateOnTimerEnd = true,
    this.autoStartRestTimer = true,
  });

  UserSettings copyWith({
    bool? useMetric,
    double? barbellWeight,
    int? defaultRestSeconds,
    int? warmupRestSeconds,
    bool? vibrateOnTimerEnd,
    bool? autoStartRestTimer,
  }) {
    return UserSettings(
      useMetric: useMetric ?? this.useMetric,
      barbellWeight: barbellWeight ?? this.barbellWeight,
      defaultRestSeconds: defaultRestSeconds ?? this.defaultRestSeconds,
      warmupRestSeconds: warmupRestSeconds ?? this.warmupRestSeconds,
      vibrateOnTimerEnd: vibrateOnTimerEnd ?? this.vibrateOnTimerEnd,
      autoStartRestTimer: autoStartRestTimer ?? this.autoStartRestTimer,
    );
  }
}

final userSettingsProvider = StateNotifierProvider<UserSettingsNotifier, UserSettings>((ref) {
  return UserSettingsNotifier();
});

class UserSettingsNotifier extends StateNotifier<UserSettings> {
  UserSettingsNotifier() : super(const UserSettings()) {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = UserSettings(
      useMetric: prefs.getBool('useMetric') ?? true,
      barbellWeight: prefs.getDouble('barbellWeight') ?? 20.0,
      defaultRestSeconds: prefs.getInt('defaultRestSeconds') ?? 90,
      warmupRestSeconds: prefs.getInt('warmupRestSeconds') ?? 45,
      vibrateOnTimerEnd: prefs.getBool('vibrateOnTimerEnd') ?? true,
      autoStartRestTimer: prefs.getBool('autoStartRestTimer') ?? true,
    );
  }
  
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useMetric', state.useMetric);
    await prefs.setDouble('barbellWeight', state.barbellWeight);
    await prefs.setInt('defaultRestSeconds', state.defaultRestSeconds);
    await prefs.setInt('warmupRestSeconds', state.warmupRestSeconds);
    await prefs.setBool('vibrateOnTimerEnd', state.vibrateOnTimerEnd);
    await prefs.setBool('autoStartRestTimer', state.autoStartRestTimer);
  }
  
  void setUseMetric(bool value) {
    state = state.copyWith(useMetric: value);
    _saveSettings();
  }
  
  void setBarbellWeight(double weight) {
    state = state.copyWith(barbellWeight: weight);
    _saveSettings();
  }
  
  void setDefaultRestSeconds(int seconds) {
    state = state.copyWith(defaultRestSeconds: seconds);
    _saveSettings();
  }
  
  void setWarmupRestSeconds(int seconds) {
    state = state.copyWith(warmupRestSeconds: seconds);
    _saveSettings();
  }
  
  void setVibrateOnTimerEnd(bool value) {
    state = state.copyWith(vibrateOnTimerEnd: value);
    _saveSettings();
  }
  
  void setAutoStartRestTimer(bool value) {
    state = state.copyWith(autoStartRestTimer: value);
    _saveSettings();
  }
}

// Onboarding status provider
final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboardingCompleted') ?? false;
});

final completeOnboardingProvider = FutureProvider<void>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('onboardingCompleted', true);
});

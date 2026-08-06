// Provider tests for RPG Workout App
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rpg_workout_app/providers/providers.dart';
import 'package:rpg_workout_app/providers/core_providers.dart';
import 'package:rpg_workout_app/providers/exercise_providers.dart';

void main() {
  group('CoreProviders', () {
    test('databaseProvider creates AppDatabase instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      
      final db = container.read(databaseProvider);
      expect(db, isNotNull);
    });

    test('uuidProvider creates Uuid instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      
      final uuid = container.read(uuidProvider);
      expect(uuid, isNotNull);
    });

    test('appErrorProvider initializes as null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      
      final error = container.read(appErrorProvider);
      expect(error, isNull);
    });

    test('isLoadingProvider initializes as false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      
      final isLoading = container.read(isLoadingProvider);
      expect(isLoading, isFalse);
    });
  });

  group('ExerciseProviders', () {
    test('exerciseSearchProvider initializes as empty string', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      
      final search = container.read(exerciseSearchProvider);
      expect(search, equals(''));
    });

    test('exerciseSearchProvider can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      
      container.read(exerciseSearchProvider.notifier).state = 'bench press';
      final search = container.read(exerciseSearchProvider);
      expect(search, equals('bench press'));
    });
  });

  group('UserSettings', () {
    test('default settings have expected values', () {
      final settings = UserSettings();
      expect(settings.useMetric, isTrue);
      expect(settings.barbellWeight, equals(20.0));
      expect(settings.defaultRestSeconds, equals(90));
      expect(settings.warmupRestSeconds, equals(45));
      expect(settings.vibrateOnTimerEnd, isTrue);
      expect(settings.autoStartRestTimer, isTrue);
    });

    test('copyWith creates modified copy', () {
      final settings = UserSettings();
      final modified = settings.copyWith(useMetric: false);
      
      expect(modified.useMetric, isFalse);
      expect(modified.barbellWeight, equals(20.0)); // unchanged
    });
  });

  group('DailyQuestsNotifier', () {
    test('generates default quests', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      
      // Initialize provider
      container.read(dailyQuestsProvider);
      
      final quests = container.read(dailyQuestsProvider);
      expect(quests.length, equals(5));
      expect(quests[0].title, equals('First Steps'));
    });
  });

  group('WorkoutPlansNotifier', () {
    test('provides default workout plans', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      
      final plans = container.read(workoutPlansProvider);
      expect(plans.isNotEmpty, isTrue);
      
      // Check beginner plans exist
      final beginnerPlans = plans.where((p) => p.difficulty == 'BEGINNER');
      expect(beginnerPlans.isNotEmpty, isTrue);
    });
  });
}

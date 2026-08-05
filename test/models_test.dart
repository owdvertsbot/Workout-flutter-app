import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_workout_app/models/models.dart';

void main() {
  group('SetEntryModel', () {
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
      // XP = (15 + 100*10*0.002) * 1.0 = 17
      expect(set.calculateXp(), equals(17));
    });

    test('calculates XP correctly for warmup set', () {
      final set = SetEntryModel(
        id: 'test-2',
        sessionId: 'session-1',
        exerciseId: 'ex-1',
        weightKg: 50.0,
        reps: 10,
        setType: SetType.warmup,
        isCompleted: true,
      );
      // XP = (15 + 50*10*0.002) * 0.5 = 8
      expect(set.calculateXp(), equals(8));
    });

    test('calculates XP correctly for failure set', () {
      final set = SetEntryModel(
        id: 'test-3',
        sessionId: 'session-1',
        exerciseId: 'ex-1',
        weightKg: 120.0,
        reps: 8,
        setType: SetType.failure,
        isCompleted: true,
      );
      // XP = (15 + 120*8*0.002) * 1.3 = 16.92 * 1.3 = 22 -> 22
      expect(set.calculateXp(), equals(22));
    });

    test('calculates XP for incomplete set returns 0', () {
      final set = SetEntryModel(
        id: 'test-4',
        sessionId: 'session-1',
        exerciseId: 'ex-1',
        weightKg: 100.0,
        reps: 10,
        isCompleted: false,
      );
      expect(set.calculateXp(), equals(0));
    });

    test('calculates volume correctly', () {
      final set = SetEntryModel(
        id: 'test-5',
        sessionId: 'session-1',
        exerciseId: 'ex-1',
        weightKg: 100.0,
        reps: 10,
        isCompleted: true,
      );
      expect(set.volume, equals(1000.0)); // 100 * 10
    });

    test('volume is 0 when weight or reps is null', () {
      final set = SetEntryModel(
        id: 'test-6',
        sessionId: 'session-1',
        exerciseId: 'ex-1',
        weightKg: null,
        reps: null,
        isCompleted: true,
      );
      expect(set.volume, equals(0.0));
    });

    test('calculates RPE percentage correctly', () {
      final set = SetEntryModel(
        id: 'test-7',
        sessionId: 'session-1',
        exerciseId: 'ex-1',
        weightKg: 90.0,
        reps: 10,
        rpe: 8,
        isCompleted: true,
      );
      // RPE 8 out of 10 = 80%
      expect(set.rpePercentage, closeTo(80.0, 0.1));
    });

    test('fromJson creates valid instance', () {
      final json = {
        'id': 'json-test',
        'session_id': 'session-1',
        'exercise_id': 'ex-1',
        'weight_kg': 80.0,
        'reps': 12,
        'rpe': 7,
        'set_type': 'WORKING',
        'is_completed': true,
      };
      final set = SetEntryModel.fromJson(json);
      expect(set.id, equals('json-test'));
      expect(set.weightKg, equals(80.0));
      expect(set.reps, equals(12));
      expect(set.setType, equals(SetType.working));
    });
  });

  group('PlayerProfileModel', () {
    test('characterTitle returns correct title for level 1', () {
      final profile = PlayerProfileModel(id: 'test', level: 1);
      expect(profile.characterTitle, equals('Novice Trainee'));
    });

    test('characterTitle returns correct title for level 5', () {
      final profile = PlayerProfileModel(id: 'test', level: 5);
      expect(profile.characterTitle, equals('Apprentice'));
    });

    test('characterTitle returns correct title for level 10', () {
      final profile = PlayerProfileModel(id: 'test', level: 10);
      expect(profile.characterTitle, equals('Skilled Warrior'));
    });

    test('characterTitle returns correct title for level 20', () {
      final profile = PlayerProfileModel(id: 'test', level: 20);
      expect(profile.characterTitle, equals('Veteran Adventurer'));
    });

    test('characterTitle returns correct title for level 30', () {
      final profile = PlayerProfileModel(id: 'test', level: 30);
      expect(profile.characterTitle, equals('Elite Fighter'));
    });

    test('characterTitle returns correct title for level 40', () {
      final profile = PlayerProfileModel(id: 'test', level: 40);
      expect(profile.characterTitle, equals('Master Warrior'));
    });

    test('characterTitle returns correct title for level 50+', () {
      final profile = PlayerProfileModel(id: 'test', level: 100);
      expect(profile.characterTitle, equals('Legendary Champion'));
    });

    test('levelProgress calculates correctly', () {
      final profile = PlayerProfileModel(
        id: 'test',
        currentXp: 250,
        xpToNextLevel: 1000,
      );
      expect(profile.levelProgress, equals(0.25));
    });

    test('copyWith preserves unmodified fields', () {
      final original = PlayerProfileModel(
        id: 'test-1',
        level: 5,
        currentXp: 100,
        totalVolumeKg: 5000.0,
        streakDays: 3,
      );
      final copied = original.copyWith(currentXp: 200);
      expect(copied.id, equals('test-1'));
      expect(copied.level, equals(5));
      expect(copied.currentXp, equals(200));
      expect(copied.totalVolumeKg, equals(5000.0));
      expect(copied.streakDays, equals(3));
    });
  });

  group('PlayerStats', () {
    test('fromJson creates instance with correct values', () {
      final json = {
        'strength': 10,
        'dexterity': 5,
        'vitality': 8,
        'endurance': 12,
      };
      final stats = PlayerStats.fromJson(json);
      expect(stats.strength, equals(10));
      expect(stats.dexterity, equals(5));
      expect(stats.vitality, equals(8));
      expect(stats.endurance, equals(12));
    });

    test('fromJson returns default values for null', () {
      final stats = PlayerStats.fromJson(null);
      expect(stats.strength, equals(0));
      expect(stats.dexterity, equals(0));
      expect(stats.vitality, equals(0));
      expect(stats.endurance, equals(0));
    });

    test('copyWith works correctly', () {
      const original = PlayerStats(strength: 5, dexterity: 10);
      final copied = original.copyWith(strength: 15);
      expect(copied.strength, equals(15));
      expect(copied.dexterity, equals(10));
    });
  });

  group('WorkoutSessionModel', () {
    test('totalVolume calculates sum of all set volumes', () {
      final session = WorkoutSessionModel(
        id: 'test-session',
        startTime: DateTime.now(),
        sets: [
          SetEntryModel(
            id: 's1',
            sessionId: 'test-session',
            exerciseId: 'ex-1',
            weightKg: 100,
            reps: 10,
            isCompleted: true,
          ),
          SetEntryModel(
            id: 's2',
            sessionId: 'test-session',
            exerciseId: 'ex-1',
            weightKg: 80,
            reps: 12,
            isCompleted: true,
          ),
        ],
      );
      expect(session.totalVolume, equals(1960.0)); // (100*10) + (80*12)
    });

    test('completedSets counts only completed sets', () {
      final session = WorkoutSessionModel(
        id: 'test-session',
        startTime: DateTime.now(),
        sets: [
          SetEntryModel(
            id: 's1',
            sessionId: 'test-session',
            exerciseId: 'ex-1',
            isCompleted: true,
          ),
          SetEntryModel(
            id: 's2',
            sessionId: 'test-session',
            exerciseId: 'ex-1',
            isCompleted: false,
          ),
          SetEntryModel(
            id: 's3',
            sessionId: 'test-session',
            exerciseId: 'ex-1',
            isCompleted: true,
          ),
        ],
      );
      expect(session.completedSets, equals(2));
    });

    test('totalXp sums XP from all sets', () {
      final session = WorkoutSessionModel(
        id: 'test-session',
        startTime: DateTime.now(),
        sets: [
          SetEntryModel(
            id: 's1',
            sessionId: 'test-session',
            exerciseId: 'ex-1',
            weightKg: 100,
            reps: 10,
            setType: SetType.working,
            isCompleted: true,
          ),
          SetEntryModel(
            id: 's2',
            sessionId: 'test-session',
            exerciseId: 'ex-1',
            weightKg: 80,
            reps: 12,
            setType: SetType.dropSet,
            isCompleted: true,
          ),
        ],
      );
      expect(session.totalXp, greaterThan(0));
    });
  });

  group('WorkoutPlanModel', () {
    test('totalSets calculates sum of all exercise target sets', () {
      final plan = WorkoutPlanModel(
        id: 'test-plan',
        title: 'Test Plan',
        description: 'A test plan',
        difficulty: 'BEGINNER',
        category: 'STRENGTH',
        estimatedMinutes: 30,
        xpReward: 100,
        exercises: [
          const WorkoutPlanExercise(exerciseId: 'ex-1', targetSets: 3, targetReps: 10),
          const WorkoutPlanExercise(exerciseId: 'ex-2', targetSets: 4, targetReps: 8),
        ],
        muscleGroups: ['Chest', 'Back'],
      );
      expect(plan.totalSets, equals(7));
    });

    test('fromJson parses correctly', () {
      final json = {
        'id': 'plan-1',
        'title': 'Push Day',
        'description': 'Chest and triceps',
        'difficulty': 'INTERMEDIATE',
        'category': 'STRENGTH',
        'estimatedMinutes': 45,
        'xpReward': 150,
        'goldReward': 60,
        'exercises': [
          {'exerciseId': 'ex-1', 'targetSets': 4, 'targetReps': 10, 'restSeconds': 90},
        ],
        'muscleGroups': ['Chest', 'Triceps'],
      };
      final plan = WorkoutPlanModel.fromJson(json);
      expect(plan.id, equals('plan-1'));
      expect(plan.title, equals('Push Day'));
      expect(plan.difficulty, equals('INTERMEDIATE'));
      expect(plan.exercises.length, equals(1));
      expect(plan.muscleGroups.length, equals(2));
    });

    test('toJson serializes correctly', () {
      const plan = WorkoutPlanModel(
        id: 'plan-1',
        title: 'Pull Day',
        description: 'Back and biceps',
        difficulty: 'ADVANCED',
        category: 'STRENGTH',
        estimatedMinutes: 60,
        xpReward: 200,
        exercises: [],
        muscleGroups: ['Back', 'Biceps'],
      );
      final json = plan.toJson();
      expect(json['id'], equals('plan-1'));
      expect(json['title'], equals('Pull Day'));
      expect(json['difficulty'], equals('ADVANCED'));
    });
  });

  group('WorkoutPlanExercise', () {
    test('fromJson parses correctly', () {
      final json = {
        'exerciseId': 'ex-1',
        'targetSets': 3,
        'targetReps': 12,
        'restSeconds': 60,
        'isWarmup': false,
      };
      final exercise = WorkoutPlanExercise.fromJson(json);
      expect(exercise.exerciseId, equals('ex-1'));
      expect(exercise.targetSets, equals(3));
      expect(exercise.targetReps, equals(12));
      expect(exercise.restSeconds, equals(60));
      expect(exercise.isWarmup, isFalse);
    });

    test('fromJson uses defaults for missing fields', () {
      final json = {'exerciseId': 'ex-1'};
      final exercise = WorkoutPlanExercise.fromJson(json);
      expect(exercise.targetSets, equals(3));
      expect(exercise.targetReps, equals(10));
      expect(exercise.restSeconds, equals(90));
      expect(exercise.isWarmup, isFalse);
    });
  });

  group('PlanProgressModel', () {
    test('copyWith works correctly', () {
      const original = PlanProgressModel(
        planId: 'plan-1',
        status: PlanStatus.available,
        currentSetIndex: 0,
        xpEarned: 0,
      );
      final started = original.copyWith(
        status: PlanStatus.inProgress,
        startedAt: DateTime(2024, 1, 1),
      );
      expect(started.planId, equals('plan-1'));
      expect(started.status, equals(PlanStatus.inProgress));
      expect(started.startedAt, equals(DateTime(2024, 1, 1)));
      expect(started.currentSetIndex, equals(0));
    });
  });

  group('SetType enum', () {
    test('fromString returns correct type', () {
      expect(SetType.fromString('WORKING'), equals(SetType.working));
      expect(SetType.fromString('WARMUP'), equals(SetType.warmup));
      expect(SetType.fromString('DROP_SET'), equals(SetType.dropSet));
      expect(SetType.fromString('FAILURE'), equals(SetType.failure));
    });

    test('fromString returns working for unknown value', () {
      expect(SetType.fromString('UNKNOWN'), equals(SetType.working));
    });

    test('enum values have correct xp multipliers', () {
      expect(SetType.warmup.xpMultiplier, equals(0));
      expect(SetType.working.xpMultiplier, equals(10));
      expect(SetType.dropSet.xpMultiplier, equals(15));
      expect(SetType.failure.xpMultiplier, equals(20));
    });
  });

  group('WorkoutStatus enum', () {
    test('fromString returns correct status', () {
      expect(WorkoutStatus.fromString('IN_PROGRESS'), equals(WorkoutStatus.inProgress));
      expect(WorkoutStatus.fromString('COMPLETED'), equals(WorkoutStatus.completed));
      expect(WorkoutStatus.fromString('ABANDONED'), equals(WorkoutStatus.abandoned));
    });

    test('fromString returns inProgress for unknown value', () {
      expect(WorkoutStatus.fromString('UNKNOWN'), equals(WorkoutStatus.inProgress));
    });
  });

  group('PRType enum', () {
    test('fromString returns correct type', () {
      expect(PRType.fromString('ALL_TIME_WEIGHT'), equals(PRType.allTimeWeight));
      expect(PRType.fromString('ROLLING_2MONTH_WEIGHT'), equals(PRType.rolling2Month));
      expect(PRType.fromString('VOLUME_PR'), equals(PRType.volumePR));
    });

    test('xpBonus values are correct', () {
      expect(PRType.allTimeWeight.xpBonus, equals(500));
      expect(PRType.rolling2Month.xpBonus, equals(100));
      expect(PRType.volumePR.xpBonus, equals(50));
    });
  });

  group('PlanStatus enum', () {
    test('enum values have correct labels', () {
      expect(PlanStatus.available.label, equals('Available'));
      expect(PlanStatus.inProgress.label, equals('In Progress'));
      expect(PlanStatus.completed.label, equals('Completed'));
    });
  });

  group('QuestType enum', () {
    test('enum values have correct labels', () {
      expect(QuestType.completeWorkout.label, equals('Complete a workout'));
      expect(QuestType.logSets.label, equals('Log sets'));
      expect(QuestType.hitPR.label, equals('Hit a personal record'));
    });
  });

  group('ExerciseModel', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'ex-1',
        'name': 'Bench Press',
        'category': 'Strength',
        'body_part': 'Chest',
        'equipment': 'Barbell',
        'muscle_group': 'Chest',
        'secondary_muscles': ['Triceps', 'Shoulders'],
      };
      final exercise = ExerciseModel.fromJson(json);
      expect(exercise.id, equals('ex-1'));
      expect(exercise.name, equals('Bench Press'));
      expect(exercise.muscleGroup, equals('Chest'));
      expect(exercise.secondaryMuscles, equals(['Triceps', 'Shoulders']));
    });

    test('fromJson handles null values', () {
      final json = {
        'id': null,
        'name': null,
        'category': null,
        'body_part': null,
        'equipment': null,
      };
      final exercise = ExerciseModel.fromJson(json);
      expect(exercise.id, equals(''));
      expect(exercise.name, equals(''));
      expect(exercise.muscleGroup, isNull);
      expect(exercise.secondaryMuscles, isEmpty);
    });

    test('toJson serializes correctly', () {
      final exercise = ExerciseModel(
        id: 'ex-1',
        name: 'Squat',
        category: 'Strength',
        bodyPart: 'Legs',
        equipment: 'Barbell',
        muscleGroup: 'Quads',
        secondaryMuscles: const ['Glutes', 'Hamstrings'],
      );
      final json = exercise.toJson();
      expect(json['id'], equals('ex-1'));
      expect(json['name'], equals('Squat'));
      expect(json['muscle_group'], equals('Quads'));
    });
  });
}

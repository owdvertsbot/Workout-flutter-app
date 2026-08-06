// This file is the main barrel export for all providers.
// For modular organization, providers have been split into:
// - core_providers.dart: Database, UUID, error, loading state
// - exercise_providers.dart: Exercise-related providers (loaded from exercise_providers.dart)
// - workout_providers.dart: Workout session providers (TODO)
// - player_providers.dart: Player profile providers (TODO)
// - quest_providers.dart: Quest and workout plan providers (TODO)
// - settings_providers.dart: Theme and user settings (TODO)
//
// The exercise providers are now defined in exercise_providers.dart and re-exported here.
// This was previously causing duplication with hardcoded categories/equipment values.
//
// TODO: Complete the migration to modular provider files (Issue #3)

export 'core_providers.dart';
export 'exercise_providers.dart';

import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../core/errors.dart';
import '../database/database.dart';
import '../models/models.dart';
import 'core_providers.dart';
import 'exercise_providers.dart';

// Active workout provider
final activeWorkoutProvider = StateNotifierProvider<ActiveWorkoutNotifier, WorkoutSessionModel?>((ref) {
  return ActiveWorkoutNotifier(ref);
});

class ActiveWorkoutNotifier extends StateNotifier<WorkoutSessionModel?> {
  final Ref ref;
  
  ActiveWorkoutNotifier(this.ref) : super(null) {
    _loadActiveWorkout();
  }
  
  Future<void> _loadActiveWorkout() async {
    try {
      final db = ref.read(databaseProvider);
      final sessions = await db.getAllWorkouts();
      final active = sessions.where((s) => s.status == 'IN_PROGRESS').toList();
      
      if (active.isNotEmpty) {
        final session = active.first;
        final sets = await db.getSetsForSession(session.id);
        
        state = WorkoutSessionModel(
          id: session.id,
          title: session.title,
          startTime: session.startTime,
          endTime: session.endTime,
          status: WorkoutStatus.fromString(session.status),
          templateId: session.templateId,
          sets: sets.map((s) => SetEntryModel(
            id: s.id,
            sessionId: s.sessionId,
            exerciseId: s.exerciseId,
            weightKg: s.weightKg,
            reps: s.reps,
            rpe: s.rpe,
            setType: SetType.fromString(s.setType),
            notes: s.notes,
            isCompleted: s.isCompleted,
            completedAt: s.completedAt,
          )).toList(),
          exerciseIds: sets.map((s) => s.exerciseId).toSet().toList(),
        );
      }
    } on DatabaseException catch (e) {
      ref.read(appErrorProvider.notifier).state = e;
    } catch (e) {
      ref.read(appErrorProvider.notifier).state = DatabaseException(
        message: 'Failed to load active workout: $e',
        originalError: e,
      );
    }
  }
  
  Future<void> startWorkout({String? title}) async {
    try {
      ref.read(isLoadingProvider.notifier).state = true;
      final db = ref.read(databaseProvider);
      final uuid = ref.read(uuidProvider);
      
      final session = WorkoutSessionsCompanion(
        id: Value(uuid.v4()),
        title: Value(title ?? 'Workout ${DateTime.now().toString().substring(0, 10)}'),
        startTime: Value(DateTime.now()),
        status: const Value('IN_PROGRESS'),
      );
      
      await db.insertWorkoutSession(session);
      await _loadActiveWorkout();
    } catch (e) {
      ref.read(appErrorProvider.notifier).state = DatabaseException(
        message: 'Failed to start workout: $e',
        originalError: e,
      );
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }
  
  Future<void> addExercise(String exerciseId) async {
    if (state == null) return;
    
    try {
      ref.read(isLoadingProvider.notifier).state = true;
      final db = ref.read(databaseProvider);
      final uuid = ref.read(uuidProvider);
      
      // Add first set entry for this exercise
      final setEntry = SetEntriesCompanion(
        id: Value(uuid.v4()),
        sessionId: Value(state!.id),
        exerciseId: Value(exerciseId),
        setType: const Value('WORKING'),
        isCompleted: const Value(false),
      );
      
      await db.insertSetEntry(setEntry);
      await _loadActiveWorkout();
    } catch (e) {
      ref.read(appErrorProvider.notifier).state = DatabaseException(
        message: 'Failed to add exercise: $e',
        originalError: e,
      );
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }
  
  Future<void> updateSet(SetEntryModel set) async {
    if (state == null) return;
    
    try {
      final db = ref.read(databaseProvider);
      
      await db.updateSetEntry(SetEntriesCompanion(
        id: Value(set.id),
        sessionId: Value(set.sessionId),
        exerciseId: Value(set.exerciseId),
        weightKg: Value(set.weightKg),
        reps: Value(set.reps),
        rpe: Value(set.rpe),
        setType: Value(set.setType.value),
        notes: Value(set.notes),
        isCompleted: Value(set.isCompleted),
        completedAt: Value(set.completedAt),
      ));
      
      await _loadActiveWorkout();
    } catch (e) {
      ref.read(appErrorProvider.notifier).state = DatabaseException(
        message: 'Failed to update set: $e',
        originalError: e,
      );
    }
  }
  
  Future<void> completeSet(String setId) async {
    if (state == null) return;
    
    try {
      final set = state!.sets.firstWhere((s) => s.id == setId);
      final updatedSet = set.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );
      
      await updateSet(updatedSet);
      
      // Get player streak for XP calculation
      final profile = ref.read(playerProfileProvider);
      
      // Update player XP with streak multiplier
      await ref.read(playerProfileProvider.notifier).addXp(
        set.calculateXp(streakDays: profile.streakDays)
      );
      
      // Update quest progress
      ref.read(dailyQuestsProvider.notifier).updateQuestProgress(QuestType.logSets, 1);
      
      // Check for PRs
      await _checkForPRs(set);
    } catch (e) {
      ref.read(appErrorProvider.notifier).state = DatabaseException(
        message: 'Failed to complete set: $e',
        originalError: e,
      );
    }
  }
  
  Future<void> _checkForPRs(SetEntryModel set) async {
    if (set.weightKg == null || set.reps == null) return;
    
    try {
      final db = ref.read(databaseProvider);
      final currentPRs = await db.getPRsForExercise(set.exerciseId);
      final volume = set.volume;
      bool prDetected = false;
      
      // Check all-time weight PR (+250 XP per FDS)
      final allTimePR = currentPRs.where((r) => r.recordType == 'ALL_TIME_WEIGHT').toList();
      if (allTimePR.isEmpty || (allTimePR.first.value < set.weightKg!)) {
        await db.upsertPersonalRecord(PersonalRecordsCompanion(
          id: Value(ref.read(uuidProvider).v4()),
          exerciseId: Value(set.exerciseId),
          recordType: const Value('ALL_TIME_WEIGHT'),
          value: Value(set.weightKg!),
          achievedAt: Value(DateTime.now()),
        ));
        prDetected = true;
        // Award PR bonus XP
        await ref.read(playerProfileProvider.notifier).addXp(250);
      }
      
      // Check rolling 2-month best PR (+100 XP per FDS)
      final rollingPR = currentPRs.where((r) => r.recordType == 'ROLLING_2MO').toList();
      // For rolling PR, we check if this is higher than any weight in the last 2 months
      // If no rolling PR exists or current weight beats it, award XP
      if (rollingPR.isEmpty || (rollingPR.first.value < set.weightKg!)) {
        await db.upsertPersonalRecord(PersonalRecordsCompanion(
          id: Value(ref.read(uuidProvider).v4()),
          exerciseId: Value(set.exerciseId),
          recordType: const Value('ROLLING_2MO'),
          value: Value(set.weightKg!),
          achievedAt: Value(DateTime.now()),
        ));
        prDetected = true;
        await ref.read(playerProfileProvider.notifier).addXp(100);
      }
      
      // Check volume PR (+150 XP per FDS)
      final volumePR = currentPRs.where((r) => r.recordType == 'VOLUME_PR').toList();
      if (volumePR.isEmpty || (volumePR.first.value < volume)) {
        await db.upsertPersonalRecord(PersonalRecordsCompanion(
          id: Value(ref.read(uuidProvider).v4()),
          exerciseId: Value(set.exerciseId),
          recordType: const Value('VOLUME_PR'),
          value: Value(volume),
          achievedAt: Value(DateTime.now()),
        ));
        prDetected = true;
        await ref.read(playerProfileProvider.notifier).addXp(150);
      }
      
      // Update PR quest if detected
      if (prDetected) {
        ref.read(dailyQuestsProvider.notifier).updateQuestProgress(QuestType.hitPR, 1);
      }
    } catch (e) {
      // PR checks are non-critical - don't show error to user
      debugPrint('PR check failed: $e');
    }
  }
  
  Future<void> addSetToExercise(String exerciseId) async {
    if (state == null) return;
    
    try {
      final db = ref.read(databaseProvider);
      final uuid = ref.read(uuidProvider);
      
      // Get previous set for prefill
      final previousSets = await db.getPreviousSetsForExercise(exerciseId, limit: 1);
      final previous = previousSets.isNotEmpty ? previousSets.first : null;
      
      final setEntry = SetEntriesCompanion(
        id: Value(uuid.v4()),
        sessionId: Value(state!.id),
        exerciseId: Value(exerciseId),
        weightKg: Value(previous?.weightKg),
        reps: Value(previous?.reps),
        setType: const Value('WORKING'),
        isCompleted: const Value(false),
      );
      
      await db.insertSetEntry(setEntry);
      await _loadActiveWorkout();
    } catch (e) {
      ref.read(appErrorProvider.notifier).state = DatabaseException(
        message: 'Failed to add set: $e',
        originalError: e,
      );
    }
  }
  
  Future<WorkoutCompletionResult?> finishWorkout() async {
    if (state == null) return null;
    
    try {
      final db = ref.read(databaseProvider);
      final workoutToComplete = state!;
      final levelBefore = ref.read(playerProfileProvider).level;
      
      await db.updateWorkoutSession(WorkoutSessionsCompanion(
        id: Value(workoutToComplete.id),
        title: Value(workoutToComplete.title),
        startTime: Value(workoutToComplete.startTime),
        endTime: Value(DateTime.now()),
        status: const Value('COMPLETED'),
        templateId: Value(workoutToComplete.templateId),
      ));
      
      // Update player stats - this calculates XP internally
      await ref.read(playerProfileProvider.notifier).onWorkoutComplete(workoutToComplete.totalVolume);
      
      // Get updated profile state
      final updatedProfile = ref.read(playerProfileProvider);
      
      // Calculate XP earned (matching the formula in onWorkoutComplete)
      // XP = (volume / 100).round() + streakDays * 5
      final xpEarned = (workoutToComplete.totalVolume / 100).round() + 
                        updatedProfile.streakDays * 5;
      
      state = null;
      
      return WorkoutCompletionResult(
        workout: workoutToComplete,
        xpEarned: xpEarned,
        levelBefore: levelBefore,
        levelAfter: updatedProfile.level,
        streakDays: updatedProfile.streakDays,
      );
    } catch (e) {
      ref.read(appErrorProvider.notifier).state = DatabaseException(
        message: 'Failed to finish workout: $e',
        originalError: e,
      );
      return null;
    }
  }
  
  Future<void> abandonWorkout() async {
    if (state == null) return;
    
    try {
      final db = ref.read(databaseProvider);
      
      await db.updateWorkoutSession(WorkoutSessionsCompanion(
        id: Value(state!.id),
        title: Value(state!.title),
        startTime: Value(state!.startTime),
        endTime: Value(DateTime.now()),
        status: const Value('ABANDONED'),
        templateId: Value(state!.templateId),
      ));
      
      state = null;
    } catch (e) {
      ref.read(appErrorProvider.notifier).state = DatabaseException(
        message: 'Failed to abandon workout: $e',
        originalError: e,
      );
    }
  }
}

// Player profile provider
final playerProfileProvider = StateNotifierProvider<PlayerProfileNotifier, PlayerProfileModel>((ref) {
  return PlayerProfileNotifier(ref);
});

class PlayerProfileNotifier extends StateNotifier<PlayerProfileModel> {
  final Ref ref;
  
  PlayerProfileNotifier(this.ref) : super(PlayerProfileModel(id: 'default')) {
    _loadProfile();
  }
  
  Future<void> _loadProfile() async {
    final db = ref.read(databaseProvider);
    final profile = await db.getPlayerProfile();
    
    if (profile != null) {
      PlayerStats stats = const PlayerStats();
      if (profile.allocatedStats != null) {
        try {
          final decoded = jsonDecode(profile.allocatedStats!) as Map<String, dynamic>;
          stats = PlayerStats.fromJson(decoded);
        } catch (_) {}
      }
      
      state = PlayerProfileModel.fromDb(
        id: profile.id,
        level: profile.currentLevel,
        currentXp: profile.currentXp,
        totalVolumeKg: profile.totalVolumeKg,
        streakDays: profile.streakDays,
        lastWorkoutDate: profile.lastWorkoutDate,
        stats: stats,
      );
    } else {
      // Create default profile
      final uuid = ref.read(uuidProvider);
      final id = uuid.v4();
      
      await db.upsertPlayerProfile(PlayerProfilesCompanion(
        id: Value(id),
        currentLevel: const Value(1),
        currentXp: const Value(0),
        totalVolumeKg: const Value(0),
        streakDays: const Value(0),
      ));
      
      state = PlayerProfileModel(id: id);
    }
  }
  
  Future<void> addXp(int xp) async {
    final db = ref.read(databaseProvider);
    int newXp = state.currentXp + xp;
    int newLevel = state.level;
    
    // Check for level up
    while (newXp >= PlayerProfileModel.xpForLevel(newLevel)) {
      newXp -= PlayerProfileModel.xpForLevel(newLevel);
      newLevel++;
    }
    
    state = state.copyWith(
      level: newLevel,
      currentXp: newXp,
    );
    
    await db.upsertPlayerProfile(PlayerProfilesCompanion(
      id: Value(state.id),
      currentLevel: Value(newLevel),
      currentXp: Value(newXp),
      totalVolumeKg: Value(state.totalVolumeKg),
      streakDays: Value(state.streakDays),
      lastWorkoutDate: Value(state.lastWorkoutDate),
      allocatedStats: Value(jsonEncode(state.stats.toJson())),
    ));
  }
  
  Future<void> onWorkoutComplete(double volume) async {
    final db = ref.read(databaseProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    int newStreak = state.streakDays;
    if (state.lastWorkoutDate != null) {
      final lastDate = DateTime(
        state.lastWorkoutDate!.year,
        state.lastWorkoutDate!.month,
        state.lastWorkoutDate!.day,
      );
      final diff = today.difference(lastDate).inDays;
      if (diff == 1) {
        newStreak++;
      } else if (diff > 1) {
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }
    
    // Calculate XP from workout
    int xpEarned = (volume / 100).round() + state.streakDays * 5;
    await addXp(xpEarned);
    
    state = state.copyWith(
      totalVolumeKg: state.totalVolumeKg + volume,
      streakDays: newStreak,
      lastWorkoutDate: now,
    );
    
    await db.upsertPlayerProfile(PlayerProfilesCompanion(
      id: Value(state.id),
      currentLevel: Value(state.level),
      currentXp: Value(state.currentXp),
      totalVolumeKg: Value(state.totalVolumeKg + volume),
      streakDays: Value(newStreak),
      lastWorkoutDate: Value(now),
      allocatedStats: Value(jsonEncode(state.stats.toJson())),
    ));
  }
}

// Workout history provider
final workoutHistoryProvider = FutureProvider<List<WorkoutSessionModel>>((ref) async {
  final db = ref.watch(databaseProvider);
  final sessions = await db.getAllWorkouts();
  
  return sessions.map((s) => WorkoutSessionModel(
    id: s.id,
    title: s.title,
    startTime: s.startTime,
    endTime: s.endTime,
    status: WorkoutStatus.fromString(s.status),
    templateId: s.templateId,
  )).toList();
});

// Daily quests provider
final dailyQuestsProvider = StateNotifierProvider<DailyQuestsNotifier, List<QuestModel>>((ref) {
  return DailyQuestsNotifier(ref);
});

class DailyQuestsNotifier extends StateNotifier<List<QuestModel>> {
  final Ref ref;
  
  DailyQuestsNotifier(this.ref) : super(_generateDefaultQuests()) {
    _loadQuests();
  }
  
  static List<QuestModel> _generateDefaultQuests() {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return [
      QuestModel(
        id: 'quest_1',
        title: 'First Steps',
        description: 'Complete your first workout',
        type: QuestType.completeWorkout,
        targetValue: 1,
        xpReward: 100,
        expiresAt: endOfDay,
      ),
      QuestModel(
        id: 'quest_2',
        title: 'Volume Crusher',
        description: 'Log 50 total sets',
        type: QuestType.logSets,
        targetValue: 50,
        xpReward: 150,
        expiresAt: endOfDay,
      ),
      QuestModel(
        id: 'quest_3',
        title: 'Iron Warrior',
        description: 'Lift 5000kg total volume',
        type: QuestType.reachVolume,
        targetValue: 5000,
        xpReward: 200,
        expiresAt: endOfDay,
      ),
      QuestModel(
        id: 'quest_4',
        title: 'PR Hunter',
        description: 'Hit a new personal record',
        type: QuestType.hitPR,
        targetValue: 1,
        xpReward: 250,
        expiresAt: endOfDay,
      ),
      QuestModel(
        id: 'quest_5',
        title: 'Streak Keeper',
        description: 'Work out 3 days in a row',
        type: QuestType.maintainStreak,
        targetValue: 3,
        xpReward: 175,
        expiresAt: endOfDay,
      ),
    ];
  }
  
  void _loadQuests() {
    // In a full implementation, load from shared_preferences or database
    // For now, use defaults
  }
  
  void updateQuestProgress(QuestType type, int increment) {
    state = state.map((quest) {
      if (quest.type == type && !quest.isCompleted) {
        return quest.copyWith(
          currentValue: quest.currentValue + increment,
          isCompleted: quest.currentValue + increment >= quest.targetValue,
        );
      }
      return quest;
    }).toList();
  }
  
  void claimQuest(String questId) async {
    final quest = state.firstWhere((q) => q.id == questId);
    if (quest.canClaim && !quest.isCompleted) {
      // Add XP reward
      await ref.read(playerProfileProvider.notifier).addXp(quest.xpReward);
      
      // Mark as completed
      state = state.map((q) {
        if (q.id == questId) {
          return q.copyWith(isCompleted: true);
        }
        return q;
      }).toList();
    }
  }
}

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

// Quest type for workout plans
enum PlanQuestType {
  completePlan('COMPLETE_PLAN', 'Complete a workout plan');

  final String value;
  final String label;
  const PlanQuestType(this.value, this.label);
}

// Workout Plans Provider - manages pre-built workout plans
final workoutPlansProvider = StateNotifierProvider<WorkoutPlansNotifier, List<WorkoutPlanModel>>((ref) {
  return WorkoutPlansNotifier();
});

class WorkoutPlansNotifier extends StateNotifier<List<WorkoutPlanModel>> {
  WorkoutPlansNotifier() : super(_defaultPlans);
  
  static final List<WorkoutPlanModel> _defaultPlans = [
    // BEGINNER PLANS
    const WorkoutPlanModel(
      id: 'plan_beginner_full_body',
      title: 'Novice Warrior',
      description: 'Start your journey with a full-body workout perfect for beginners. Master the basics and build your foundation.',
      difficulty: 'BEGINNER',
      category: 'STRENGTH',
      estimatedMinutes: 30,
      xpReward: 150,
      goldReward: 50,
      exercises: [
        WorkoutPlanExercise(exerciseId: 'air_squat', targetSets: 3, targetReps: 12, restSeconds: 60),
        WorkoutPlanExercise(exerciseId: 'push_up', targetSets: 3, targetReps: 8, restSeconds: 60),
        WorkoutPlanExercise(exerciseId: 'plank', targetSets: 3, targetReps: 30, restSeconds: 45, isWarmup: true),
        WorkoutPlanExercise(exerciseId: 'lunges', targetSets: 3, targetReps: 10, restSeconds: 60),
      ],
      muscleGroups: ['legs', 'chest', 'abs', 'shoulders'],
      imageIcon: '🗡️',
    ),
    const WorkoutPlanModel(
      id: 'plan_beginner_upper',
      title: 'Armory Basics',
      description: 'Build upper body strength with this beginner-friendly routine focusing on chest, arms, and shoulders.',
      difficulty: 'BEGINNER',
      category: 'STRENGTH',
      estimatedMinutes: 25,
      xpReward: 125,
      goldReward: 40,
      exercises: [
        WorkoutPlanExercise(exerciseId: 'push_up', targetSets: 3, targetReps: 10, restSeconds: 60),
        WorkoutPlanExercise(exerciseId: 'dumbbell_row', targetSets: 3, targetReps: 10, restSeconds: 60),
        WorkoutPlanExercise(exerciseId: 'shoulder_press', targetSets: 3, targetReps: 10, restSeconds: 60),
        WorkoutPlanExercise(exerciseId: 'bicep_curl', targetSets: 3, targetReps: 12, restSeconds: 45),
      ],
      muscleGroups: ['chest', 'back', 'shoulders', 'upper arms'],
      imageIcon: '💪',
    ),
    const WorkoutPlanModel(
      id: 'plan_beginner_lower',
      title: 'Foundation Builder',
      description: 'Strengthen your legs and glutes with this beginner lower body workout. Perfect for building a strong base.',
      difficulty: 'BEGINNER',
      category: 'STRENGTH',
      estimatedMinutes: 25,
      xpReward: 125,
      goldReward: 40,
      exercises: [
        WorkoutPlanExercise(exerciseId: 'air_squat', targetSets: 3, targetReps: 15, restSeconds: 60),
        WorkoutPlanExercise(exerciseId: 'lunges', targetSets: 3, targetReps: 12, restSeconds: 60),
        WorkoutPlanExercise(exerciseId: 'glute_bridge', targetSets: 3, targetReps: 15, restSeconds: 45),
        WorkoutPlanExercise(exerciseId: 'calf_raise', targetSets: 3, targetReps: 20, restSeconds: 30),
      ],
      muscleGroups: ['legs', 'glutes'],
      imageIcon: '🦵',
    ),

    // INTERMEDIATE PLANS
    const WorkoutPlanModel(
      id: 'plan_intermediate_push',
      title: 'Push Power',
      description: 'An intermediate pushing workout targeting chest, shoulders, and triceps with progressive overload.',
      difficulty: 'INTERMEDIATE',
      category: 'STRENGTH',
      estimatedMinutes: 40,
      xpReward: 200,
      goldReward: 75,
      exercises: [
        WorkoutPlanExercise(exerciseId: 'bench_press', targetSets: 4, targetReps: 10, restSeconds: 90),
        WorkoutPlanExercise(exerciseId: 'overhead_press', targetSets: 4, targetReps: 8, restSeconds: 90),
        WorkoutPlanExercise(exerciseId: 'incline_dumbbell_press', targetSets: 3, targetReps: 12, restSeconds: 60),
        WorkoutPlanExercise(exerciseId: 'tricep_pushdown', targetSets: 3, targetReps: 12, restSeconds: 60),
        WorkoutPlanExercise(exerciseId: 'lateral_raise', targetSets: 3, targetReps: 15, restSeconds: 45),
      ],
      muscleGroups: ['chest', 'shoulders', 'upper arms'],
      imageIcon: '🏋️',
    ),
    const WorkoutPlanModel(
      id: 'plan_intermediate_pull',
      title: 'Pull Champion',
      description: 'Master the pull workout with deadlifts, rows, and pull-ups to build a powerful back.',
      difficulty: 'INTERMEDIATE',
      category: 'STRENGTH',
      estimatedMinutes: 45,
      xpReward: 225,
      goldReward: 80,
      exercises: [
        WorkoutPlanExercise(exerciseId: 'deadlift', targetSets: 4, targetReps: 6, restSeconds: 120),
        WorkoutPlanExercise(exerciseId: 'barbell_row', targetSets: 4, targetReps: 8, restSeconds: 90),
        WorkoutPlanExercise(exerciseId: 'pull_up', targetSets: 3, targetReps: 8, restSeconds: 90),
        WorkoutPlanExercise(exerciseId: 'face_pull', targetSets: 3, targetReps: 15, restSeconds: 60),
        WorkoutPlanExercise(exerciseId: 'hammer_curl', targetSets: 3, targetReps: 12, restSeconds: 60),
      ],
      muscleGroups: ['back', 'biceps', 'shoulders'],
      imageIcon: '🦾',
    ),
    const WorkoutPlanModel(
      id: 'plan_intermediate_legs',
      title: 'Leg Day Legend',
      description: 'Intense leg workout with squats, leg press, and isolation exercises for powerful legs.',
      difficulty: 'INTERMEDIATE',
      category: 'STRENGTH',
      estimatedMinutes: 45,
      xpReward: 225,
      goldReward: 80,
      exercises: [
        WorkoutPlanExercise(exerciseId: 'squat', targetSets: 4, targetReps: 8, restSeconds: 120),
        WorkoutPlanExercise(exerciseId: 'romanian_deadlift', targetSets: 4, targetReps: 10, restSeconds: 90),
        WorkoutPlanExercise(exerciseId: 'leg_press', targetSets: 3, targetReps: 12, restSeconds: 90),
        WorkoutPlanExercise(exerciseId: 'leg_curl', targetSets: 3, targetReps: 12, restSeconds: 60),
        WorkoutPlanExercise(exerciseId: 'leg_extension', targetSets: 3, targetReps: 12, restSeconds: 60),
      ],
      muscleGroups: ['legs', 'glutes'],
      imageIcon: '🦿',
    ),

    // ADVANCED PLANS
    const WorkoutPlanModel(
      id: 'plan_advanced_full_body',
      title: 'Titan Transformation',
      description: 'The ultimate full-body challenge for advanced athletes. Expect high volume and maximum gains.',
      difficulty: 'ADVANCED',
      category: 'HYBRID',
      estimatedMinutes: 60,
      xpReward: 350,
      goldReward: 120,
      exercises: [
        WorkoutPlanExercise(exerciseId: 'squat', targetSets: 5, targetReps: 5, restSeconds: 180),
        WorkoutPlanExercise(exerciseId: 'bench_press', targetSets: 5, targetReps: 5, restSeconds: 180),
        WorkoutPlanExercise(exerciseId: 'barbell_row', targetSets: 5, targetReps: 5, restSeconds: 120),
        WorkoutPlanExercise(exerciseId: 'overhead_press', targetSets: 4, targetReps: 6, restSeconds: 120),
        WorkoutPlanExercise(exerciseId: 'pull_up', targetSets: 4, targetReps: 10, restSeconds: 90),
        WorkoutPlanExercise(exerciseId: 'deadlift', targetSets: 3, targetReps: 5, restSeconds: 180),
      ],
      muscleGroups: ['legs', 'chest', 'back', 'shoulders', 'abs'],
      imageIcon: '⚔️',
    ),
    const WorkoutPlanModel(
      id: 'plan_advanced_hypertrophy',
      title: 'Muscle Maximizer',
      description: 'High-volume hypertrophy workout designed to maximize muscle growth through metabolic stress.',
      difficulty: 'ADVANCED',
      category: 'STRENGTH',
      estimatedMinutes: 55,
      xpReward: 300,
      goldReward: 100,
      exercises: [
        WorkoutPlanExercise(exerciseId: 'bench_press', targetSets: 4, targetReps: 12, restSeconds: 90),
        WorkoutPlanExercise(exerciseId: 'incline_dumbbell_press', targetSets: 4, targetReps: 12, restSeconds: 60),
        WorkoutPlanExercise(exerciseId: 'cable_fly', targetSets: 4, targetReps: 15, restSeconds: 60),
        WorkoutPlanExercise(exerciseId: 'tricep_pushdown', targetSets: 4, targetReps: 12, restSeconds: 45),
        WorkoutPlanExercise(exerciseId: 'overhead_tricep_extension', targetSets: 3, targetReps: 15, restSeconds: 45),
        WorkoutPlanExercise(exerciseId: 'lateral_raise', targetSets: 4, targetReps: 20, restSeconds: 45),
      ],
      muscleGroups: ['chest', 'upper arms', 'shoulders'],
      imageIcon: '💎',
    ),

    // CARDIO PLANS
    const WorkoutPlanModel(
      id: 'plan_cardio_fat_burn',
      title: 'Inferno Blaster',
      description: 'High-intensity cardio workout to torch calories and improve cardiovascular endurance.',
      difficulty: 'INTERMEDIATE',
      category: 'CARDIO',
      estimatedMinutes: 30,
      xpReward: 175,
      goldReward: 60,
      exercises: [
        WorkoutPlanExercise(exerciseId: 'burpee', targetSets: 4, targetReps: 10, restSeconds: 30),
        WorkoutPlanExercise(exerciseId: 'jump_squat', targetSets: 4, targetReps: 15, restSeconds: 30),
        WorkoutPlanExercise(exerciseId: 'mountain_climber', targetSets: 4, targetReps: 30, restSeconds: 30),
        WorkoutPlanExercise(exerciseId: 'high_knees', targetSets: 4, targetReps: 30, restSeconds: 30),
        WorkoutPlanExercise(exerciseId: 'jumping_jacks', targetSets: 3, targetReps: 50, restSeconds: 30),
      ],
      muscleGroups: ['cardio', 'full body'],
      imageIcon: '🔥',
    ),

    // FLEXIBILITY PLANS
    const WorkoutPlanModel(
      id: 'plan_flexibility_recovery',
      title: 'Zen Master',
      description: 'Recovery-focused flexibility workout to improve mobility and prevent injuries.',
      difficulty: 'BEGINNER',
      category: 'FLEXIBILITY',
      estimatedMinutes: 20,
      xpReward: 100,
      goldReward: 35,
      exercises: [
        WorkoutPlanExercise(exerciseId: 'stretch_chest', targetSets: 2, targetReps: 30, restSeconds: 15),
        WorkoutPlanExercise(exerciseId: 'stretch_back', targetSets: 2, targetReps: 30, restSeconds: 15),
        WorkoutPlanExercise(exerciseId: 'stretch_hamstring', targetSets: 2, targetReps: 30, restSeconds: 15),
        WorkoutPlanExercise(exerciseId: 'stretch_quad', targetSets: 2, targetReps: 30, restSeconds: 15),
        WorkoutPlanExercise(exerciseId: 'stretch_hip', targetSets: 2, targetReps: 30, restSeconds: 15),
      ],
      muscleGroups: ['full body'],
      imageIcon: '🧘',
    ),
  ];
}

// Plan Progress Provider - tracks user progress on workout plans
final planProgressProvider = StateNotifierProvider<PlanProgressNotifier, Map<String, PlanProgressModel>>((ref) {
  return PlanProgressNotifier(ref);
});

class PlanProgressNotifier extends StateNotifier<Map<String, PlanProgressModel>> {
  final Ref ref;
  
  PlanProgressNotifier(this.ref) : super({}) {
    _loadProgress();
  }
  
  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final String? progressJson = prefs.getString('plan_progress');
    
    if (progressJson != null) {
      try {
        final Map<String, dynamic> decoded = Map<String, dynamic>.from(
          Uri.splitQueryString(progressJson).map((k, v) => MapEntry(k, v))
        );
        
        // Parse from simple format - we'll use a different approach
        final Map<String, PlanProgressModel> progress = {};
        for (final entry in decoded.entries) {
          if (entry.key.endsWith('_status')) {
            final planId = entry.key.replaceAll('_status', '');
            progress[planId] = PlanProgressModel(
              planId: planId,
              status: PlanStatus.values.firstWhere(
                (s) => s.value == entry.value,
                orElse: () => PlanStatus.available,
              ),
              startedAt: decoded['${planId}_started'] != null 
                ? DateTime.tryParse(decoded['${planId}_started']!) 
                : null,
              completedAt: decoded['${planId}_completed'] != null 
                ? DateTime.tryParse(decoded['${planId}_completed']!) 
                : null,
              timesCompleted: int.tryParse(decoded['${planId}_completed'] ?? '0') ?? 0,
            );
          }
        }
        state = progress;
      } catch (e) {
        // If parsing fails, start fresh
        state = {};
      }
    }
  }
  
  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, String> data = {};
    
    for (final entry in state.entries) {
      data['${entry.key}_status'] = entry.value.status.value;
      if (entry.value.startedAt != null) {
        data['${entry.key}_started'] = entry.value.startedAt!.toIso8601String();
      }
      if (entry.value.completedAt != null) {
        data['${entry.key}_completed'] = entry.value.completedAt!.toIso8601String();
      }
      data['${entry.key}_times'] = entry.value.timesCompleted.toString();
    }
    
    await prefs.setString('plan_progress', Uri(queryParameters: data).query);
  }
  
  PlanStatus getStatus(String planId) {
    return state[planId]?.status ?? PlanStatus.available;
  }
  
  bool isCompleted(String planId) {
    return state[planId]?.status == PlanStatus.completed;
  }
  
  int getTimesCompleted(String planId) {
    return state[planId]?.timesCompleted ?? 0;
  }
  
  Future<void> startPlan(String planId) async {
    final now = DateTime.now();
    final current = state[planId];
    
    // If already in progress or completed, don't restart
    if (current?.status == PlanStatus.inProgress) return;
    if (current?.status == PlanStatus.completed) return;
    
    state = {
      ...state,
      planId: PlanProgressModel(
        planId: planId,
        status: PlanStatus.inProgress,
        startedAt: now,
        timesCompleted: current?.timesCompleted ?? 0,
      ),
    };
    
    await _saveProgress();
  }
  
  Future<int> completePlan(String planId, int xpReward, int goldReward) async {
    final now = DateTime.now();
    final current = state[planId];
    final timesCompleted = (current?.timesCompleted ?? 0) + 1;
    
    state = {
      ...state,
      planId: PlanProgressModel(
        planId: planId,
        status: PlanStatus.completed,
        startedAt: current?.startedAt ?? now,
        completedAt: now,
        timesCompleted: timesCompleted,
      ),
    };
    
    await _saveProgress();
    
    // Award XP and update quest progress
    await ref.read(playerProfileProvider.notifier).addXp(xpReward);
    ref.read(dailyQuestsProvider.notifier).updateQuestProgress(QuestType.completeWorkout, 1);
    
    // Reset to available after completion (for repeatable quests)
    Future.delayed(const Duration(seconds: 1), () async {
      state = {
        ...state,
        planId: PlanProgressModel(
          planId: planId,
          status: PlanStatus.available,
          timesCompleted: timesCompleted,
        ),
      };
      await _saveProgress();
    });
    
    return xpReward;
  }
}

// Available workout plans (filtered by difficulty)
final availablePlansProvider = Provider.family<List<WorkoutPlanModel>, String>((ref, difficulty) {
  final plans = ref.watch(workoutPlansProvider);
  if (difficulty.isEmpty || difficulty == 'ALL') return plans;
  return plans.where((p) => p.difficulty == difficulty).toList();
});

// Featured/recommended plans
final featuredPlansProvider = Provider<List<WorkoutPlanModel>>((ref) {
  final plans = ref.watch(workoutPlansProvider);
  // Return plans that are not yet completed
  final progress = ref.watch(planProgressProvider);
  return plans.where((p) {
    final pStatus = progress[p.id]?.status;
    return pStatus != PlanStatus.completed;
  }).take(5).toList();
});

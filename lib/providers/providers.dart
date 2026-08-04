import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import '../models/models.dart';

// Database provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// UUID generator
final uuidProvider = Provider<Uuid>((ref) => const Uuid());

// Exercises provider
final exercisesProvider = FutureProvider<List<ExerciseModel>>((ref) async {
  final db = ref.watch(databaseProvider);
  final exercises = await db.getAllExercises();
  
  if (exercises.isEmpty) {
    // Load exercises from JSON if database is empty
    await ref.read(exerciseLoaderProvider.future);
    return db.getAllExercises().then((list) => list.map((e) => ExerciseModel(
      id: e.id,
      name: e.name,
      category: e.category,
      bodyPart: e.bodyPart,
      equipment: e.equipment,
      muscleGroup: e.muscleGroup,
      target: e.target,
    )).toList());
  }
  
  return exercises.map((e) => ExerciseModel(
    id: e.id,
    name: e.name,
    category: e.category,
    bodyPart: e.bodyPart,
    equipment: e.equipment,
    muscleGroup: e.muscleGroup,
    target: e.target,
  )).toList();
});

// Load exercises from JSON file
final exerciseLoaderProvider = FutureProvider<void>((ref) async {
  final db = ref.read(databaseProvider);
  
  // Load exercises from assets
  final String jsonString = await rootBundle.loadString('assets/exercises.json');
  final List<dynamic> jsonList = json.decode(jsonString);
  
  // Convert to database companions and insert
  final exercises = jsonList.map((e) => ExercisesCompanion(
    id: Value(e['id']?.toString() ?? ''),
    name: Value(e['name']?.toString() ?? ''),
    category: Value(e['category']?.toString() ?? ''),
    bodyPart: Value(e['bodyPart']?.toString() ?? ''),
    equipment: Value(e['equipment']?.toString() ?? ''),
    muscleGroup: Value(e['muscleGroup']?.toString()),
    secondaryMuscles: Value(e['secondaryMuscles'] != null ? json.encode(e['secondaryMuscles']) : null),
    target: Value(e['target']?.toString()),
    instructions: Value(e['instructions'] != null ? json.encode(e['instructions']) : null),
  )).toList();
  
  await db.insertExercises(exercises);
});

// Exercise search provider
final exerciseSearchProvider = StateProvider<String>((ref) => '');

final filteredExercisesProvider = Provider<AsyncValue<List<ExerciseModel>>>((ref) {
  final exercisesAsync = ref.watch(exercisesProvider);
  final searchQuery = ref.watch(exerciseSearchProvider).toLowerCase();
  
  return exercisesAsync.whenData((exercises) {
    if (searchQuery.isEmpty) return exercises;
    return exercises.where((e) =>
      e.name.toLowerCase().contains(searchQuery) ||
      e.category.toLowerCase().contains(searchQuery) ||
      e.bodyPart.toLowerCase().contains(searchQuery)
    ).toList();
  });
});

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
  }
  
  Future<void> startWorkout({String? title}) async {
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
  }
  
  Future<void> addExercise(String exerciseId) async {
    if (state == null) return;
    
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
  }
  
  Future<void> updateSet(SetEntryModel set) async {
    if (state == null) return;
    
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
  }
  
  Future<void> completeSet(String setId) async {
    if (state == null) return;
    
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
  }
  
  Future<void> _checkForPRs(SetEntryModel set) async {
    if (set.weightKg == null || set.reps == null) return;
    
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
  }
  
  Future<void> addSetToExercise(String exerciseId) async {
    if (state == null) return;
    
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
  }
  
  Future<void> finishWorkout() async {
    if (state == null) return;
    
    final db = ref.read(databaseProvider);
    
    await db.updateWorkoutSession(WorkoutSessionsCompanion(
      id: Value(state!.id),
      title: Value(state!.title),
      startTime: Value(state!.startTime),
      endTime: Value(DateTime.now()),
      status: const Value('COMPLETED'),
      templateId: Value(state!.templateId),
    ));
    
    // Update player stats
    await ref.read(playerProfileProvider.notifier).onWorkoutComplete(state!.totalVolume);
    
    state = null;
  }
  
  Future<void> abandonWorkout() async {
    if (state == null) return;
    
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

// Exercise categories provider
final exerciseCategoriesProvider = Provider<List<String>>((ref) {
  return ['abs', 'back', 'cardio', 'chest', 'legs', 'shoulders', 'waist', 'lower arms', 'upper arms'];
});

// Equipment types provider
final equipmentTypesProvider = Provider<List<String>>((ref) {
  return ['body weight', 'barbell', 'dumbbell', 'cable', 'machine', 'kettlebell', 'band', 'other'];
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

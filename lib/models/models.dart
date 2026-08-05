import 'dart:math' as math;

// Exercise model for UI
class ExerciseModel {
  final String id;
  final String name;
  final String category;
  final String bodyPart;
  final String equipment;
  final String? muscleGroup;
  final List<String> secondaryMuscles;
  final String? target;
  final Map<String, String>? instructions;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.category,
    required this.bodyPart,
    required this.equipment,
    this.muscleGroup,
    this.secondaryMuscles = const [],
    this.target,
    this.instructions,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic value) {
      if (value == null) return [];
      if (value is List) return value.map((e) => e.toString()).toList();
      if (value is String) {
        try {
          final decoded = Uri.decodeComponent(value);
          if (decoded.startsWith('[')) {
            // Simple JSON array parse
            return decoded
                .replaceAll('[', '')
                .replaceAll(']', '')
                .replaceAll('"', '')
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
          }
        } catch (_) {}
        return [];
      }
      return [];
    }

    Map<String, String> parseInstructions(dynamic value) {
      if (value == null) return {};
      if (value is Map) {
        return value.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
      return {};
    }

    return ExerciseModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      bodyPart: json['body_part']?.toString() ?? '',
      equipment: json['equipment']?.toString() ?? '',
      muscleGroup: json['muscle_group']?.toString(),
      secondaryMuscles: parseList(json['secondary_muscles']),
      target: json['target']?.toString(),
      instructions: parseInstructions(json['instructions']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'body_part': bodyPart,
    'equipment': equipment,
    'muscle_group': muscleGroup,
    'secondary_muscles': secondaryMuscles,
    'target': target,
    'instructions': instructions,
  };
}

// Set type enum
enum SetType {
  warmup('WARMUP', 'Warmup', 0),
  working('WORKING', 'Working', 10),
  dropSet('DROP_SET', 'Drop Set', 15),
  failure('FAILURE', 'Failure', 20);

  final String value;
  final String label;
  final int xpMultiplier;

  const SetType(this.value, this.label, this.xpMultiplier);

  static SetType fromString(String value) {
    return SetType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SetType.working,
    );
  }
}

// Workout status enum
enum WorkoutStatus {
  inProgress('IN_PROGRESS', 'In Progress'),
  completed('COMPLETED', 'Completed'),
  abandoned('ABANDONED', 'Abandoned');

  final String value;
  final String label;

  const WorkoutStatus(this.value, this.label);

  static WorkoutStatus fromString(String value) {
    return WorkoutStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => WorkoutStatus.inProgress,
    );
  }
}

// PR type enum
enum PRType {
  allTimeWeight('ALL_TIME_WEIGHT', 'All-Time PR', 500),
  rolling2Month('ROLLING_2MONTH_WEIGHT', '2-Month PR', 100),
  volumePR('VOLUME_PR', 'Volume PR', 50);

  final String value;
  final String label;
  final int xpBonus;

  const PRType(this.value, this.label, this.xpBonus);

  static PRType fromString(String value) {
    return PRType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PRType.volumePR,
    );
  }
}

// Player stats model
class PlayerStats {
  final int strength;
  final int dexterity;
  final int vitality;
  final int endurance;

  const PlayerStats({
    this.strength = 0,
    this.dexterity = 0,
    this.vitality = 0,
    this.endurance = 0,
  });

  factory PlayerStats.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PlayerStats();
    return PlayerStats(
      strength: json['strength'] ?? 0,
      dexterity: json['dexterity'] ?? 0,
      vitality: json['vitality'] ?? 0,
      endurance: json['endurance'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'strength': strength,
    'dexterity': dexterity,
    'vitality': vitality,
    'endurance': endurance,
  };

  PlayerStats copyWith({
    int? strength,
    int? dexterity,
    int? vitality,
    int? endurance,
  }) {
    return PlayerStats(
      strength: strength ?? this.strength,
      dexterity: dexterity ?? this.dexterity,
      vitality: vitality ?? this.vitality,
      endurance: endurance ?? this.endurance,
    );
  }
}

// Player profile model
class PlayerProfileModel {
  final String id;
  final int level;
  final int currentXp;
  final int xpToNextLevel;
  final double totalVolumeKg;
  final int streakDays;
  final DateTime? lastWorkoutDate;
  final PlayerStats stats;

  PlayerProfileModel({
    required this.id,
    this.level = 1,
    this.currentXp = 0,
    this.xpToNextLevel = 750,
    this.totalVolumeKg = 0,
    this.streakDays = 0,
    this.lastWorkoutDate,
    this.stats = const PlayerStats(),
  });

  // FDS Level Progression Formula:
  // XP Required(L) = 250 × L^1.5 + 500
  static int xpForLevel(int level) {
    if (level < 1) level = 1;
    return (250 * _pow(level, 1.5) + 500).round();
  }
  
  static double _pow(int base, double exponent) {
    return math.pow(base, exponent);
  }
  
  // Get XP required for next level
  static int xpRequiredForLevel(int level) => xpForLevel(level + 1);
  
  factory PlayerProfileModel.fromDb({
    required String id,
    required int level,
    required int currentXp,
    required double totalVolumeKg,
    required int streakDays,
    DateTime? lastWorkoutDate,
    PlayerStats? stats,
  }) {
    final xpToNext = xpRequiredForLevel(level);
    return PlayerProfileModel(
      id: id,
      level: level,
      currentXp: currentXp,
      xpToNextLevel: xpToNext,
      totalVolumeKg: totalVolumeKg,
      streakDays: streakDays,
      lastWorkoutDate: lastWorkoutDate,
      stats: stats ?? const PlayerStats(),
    );
  }

  double get levelProgress => currentXp / xpToNextLevel;
  
  // Get character title based on level
  String get characterTitle {
    if (level >= 50) return 'Legendary Champion';
    if (level >= 40) return 'Master Warrior';
    if (level >= 30) return 'Elite Fighter';
    if (level >= 20) return 'Veteran Adventurer';
    if (level >= 10) return 'Skilled Warrior';
    if (level >= 5) return 'Apprentice';
    return 'Novice Trainee';
  }

  PlayerProfileModel copyWith({
    String? id,
    int? level,
    int? currentXp,
    int? xpToNextLevel,
    double? totalVolumeKg,
    int? streakDays,
    DateTime? lastWorkoutDate,
    PlayerStats? stats,
  }) {
    return PlayerProfileModel(
      id: id ?? this.id,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      totalVolumeKg: totalVolumeKg ?? this.totalVolumeKg,
      streakDays: streakDays ?? this.streakDays,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      stats: stats ?? this.stats,
    );
  }
}

// Set entry model for UI
class SetEntryModel {
  final String id;
  final String sessionId;
  final String exerciseId;
  final double? weightKg;
  final int? reps;
  final int? rpe;
  final SetType setType;
  final String? notes;
  final bool isCompleted;
  final DateTime? completedAt;

  SetEntryModel({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    this.weightKg,
    this.reps,
    this.rpe,
    this.setType = SetType.working,
    this.notes,
    this.isCompleted = false,
    this.completedAt,
  });

  double get volume => (weightKg ?? 0) * (reps ?? 0);
  
  // RPE as a percentage (RPE 1-10 maps to 0-100%)
  double get rpePercentage => rpe != null ? (rpe! / 10.0) * 100.0 : 0.0;
  
  factory SetEntryModel.fromJson(Map<String, dynamic> json) {
    return SetEntryModel(
      id: json['id']?.toString() ?? '',
      sessionId: json['session_id']?.toString() ?? json['sessionId']?.toString() ?? '',
      exerciseId: json['exercise_id']?.toString() ?? json['exerciseId']?.toString() ?? '',
      weightKg: (json['weight_kg'] ?? json['weightKg'])?.toDouble(),
      reps: json['reps']?.toInt(),
      rpe: json['rpe']?.toInt(),
      setType: SetType.fromString(json['set_type']?.toString() ?? json['setType']?.toString() ?? 'WORKING'),
      notes: json['notes']?.toString(),
      isCompleted: json['is_completed'] ?? json['isCompleted'] ?? false,
      completedAt: json['completed_at'] != null 
          ? DateTime.tryParse(json['completed_at'].toString())
          : (json['completedAt'] != null ? DateTime.tryParse(json['completedAt'].toString()) : null),
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'sessionId': sessionId,
    'exerciseId': exerciseId,
    'weightKg': weightKg,
    'reps': reps,
    'rpe': rpe,
    'setType': setType.value,
    'notes': notes,
    'isCompleted': isCompleted,
    'completedAt': completedAt?.toIso8601String(),
  };
  
  // FDS XP Formula:
  // Set XP = (Base XP + (Weight × Reps × α)) × μType × μStreak × μRPE
  // Base XP = 15, α = 0.002
  // μType: Warmup=0.5, Working=1.0, Drop=1.2, Failure=1.3
  // μRPE: ≤6=1.0, 7-8=1.1, 9-10=1.25
  int calculateXp({int streakDays = 0}) {
    // Incomplete sets don't earn XP
    if (!isCompleted) return 0;
    
    const double baseXp = 15.0;
    const double alpha = 0.002;
    
    // Volume contribution
    final double volumeContribution = (weightKg ?? 0) * (reps ?? 0) * alpha;
    
    // Set type multiplier
    final double typeMultiplier = switch (setType) {
      SetType.warmup => 0.5,
      SetType.working => 1.0,
      SetType.dropSet => 1.2,
      SetType.failure => 1.3,
    };
    
    // Streak multiplier: 1.0 to 1.5 over 30 days
    final double streakMultiplier = 1.0 + (streakDays.clamp(0, 30) / 30) * 0.5;
    
    // RPE multiplier
    final double rpeMultiplier = switch (rpe) {
      null => 1.0,
      <= 6 => 1.0,
      <= 8 => 1.1,
      _ => 1.25,
    };
    
    final double totalXp = (baseXp + volumeContribution) * typeMultiplier * streakMultiplier * rpeMultiplier;
    return totalXp.round().clamp(5, 500);
  }

  SetEntryModel copyWith({
    String? id,
    String? sessionId,
    String? exerciseId,
    double? weightKg,
    int? reps,
    int? rpe,
    SetType? setType,
    String? notes,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return SetEntryModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      rpe: rpe ?? this.rpe,
      setType: setType ?? this.setType,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

// Quest/Mission model for daily quests
class QuestModel {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final int targetValue;
  final int currentValue;
  final int xpReward;
  final bool isCompleted;
  final DateTime? expiresAt;

  const QuestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    this.currentValue = 0,
    required this.xpReward,
    this.isCompleted = false,
    this.expiresAt,
  });

  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);
  
  bool get canClaim => isCompleted || currentValue >= targetValue;
  
  QuestModel copyWith({
    String? id,
    String? title,
    String? description,
    QuestType? type,
    int? targetValue,
    int? currentValue,
    int? xpReward,
    bool? isCompleted,
    DateTime? expiresAt,
  }) {
    return QuestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      xpReward: xpReward ?? this.xpReward,
      isCompleted: isCompleted ?? this.isCompleted,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

enum QuestType {
  completeWorkout('COMPLETE_WORKOUT', 'Complete a workout'),
  logSets('LOG_SETS', 'Log sets'),
  reachVolume('REACH_VOLUME', 'Reach total volume'),
  maintainStreak('MAINTAIN_STREAK', 'Maintain streak'),
  hitPR('HIT_PR', 'Hit a personal record'),
  useApp('USE_APP', 'Use the app');

  final String value;
  final String label;
  const QuestType(this.value, this.label);
}

// Workout session model
class WorkoutSessionModel {
  final String id;
  final String? title;
  final DateTime startTime;
  final DateTime? endTime;
  final WorkoutStatus status;
  final String? templateId;
  final List<SetEntryModel> sets;
  final List<String> exerciseIds;

  WorkoutSessionModel({
    required this.id,
    this.title,
    required this.startTime,
    this.endTime,
    this.status = WorkoutStatus.inProgress,
    this.templateId,
    this.sets = const [],
    this.exerciseIds = const [],
  });

  double get totalVolume => sets.fold(0, (sum, set) => sum + set.volume);
  
  int get totalXp => sets.fold(0, (sum, set) => sum + set.calculateXp());
  
  int get completedSets => sets.where((s) => s.isCompleted).length;
  
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  WorkoutSessionModel copyWith({
    String? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    WorkoutStatus? status,
    String? templateId,
    List<SetEntryModel>? sets,
    List<String>? exerciseIds,
  }) {
    return WorkoutSessionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      templateId: templateId ?? this.templateId,
      sets: sets ?? this.sets,
      exerciseIds: exerciseIds ?? this.exerciseIds,
    );
  }
}

// Workout completion result returned by the notifier
class WorkoutCompletionResult {
  final WorkoutSessionModel workout;
  final int xpEarned;
  final int levelBefore;
  final int levelAfter;
  final int streakDays;

  WorkoutCompletionResult({
    required this.workout,
    required this.xpEarned,
    required this.levelBefore,
    required this.levelAfter,
    required this.streakDays,
  });

  bool get leveledUp => levelAfter > levelBefore;
}

// Workout Plan Exercise - represents an exercise within a workout plan
class WorkoutPlanExercise {
  final String exerciseId;
  final int targetSets;
  final int targetReps;
  final int restSeconds;
  final bool isWarmup;

  const WorkoutPlanExercise({
    required this.exerciseId,
    required this.targetSets,
    required this.targetReps,
    this.restSeconds = 90,
    this.isWarmup = false,
  });

  factory WorkoutPlanExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutPlanExercise(
      exerciseId: json['exerciseId']?.toString() ?? '',
      targetSets: json['targetSets'] ?? 3,
      targetReps: json['targetReps'] ?? 10,
      restSeconds: json['restSeconds'] ?? 90,
      isWarmup: json['isWarmup'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'targetSets': targetSets,
    'targetReps': targetReps,
    'restSeconds': restSeconds,
    'isWarmup': isWarmup,
  };
}

// Workout Plan - a structured workout that can be completed as a quest
class WorkoutPlanModel {
  final String id;
  final String title;
  final String description;
  final String difficulty; // BEGINNER, INTERMEDIATE, ADVANCED
  final String category; // STRENGTH, CARDIO, FLEXIBILITY, HYBRID
  final int estimatedMinutes;
  final int xpReward;
  final int goldReward;
  final List<WorkoutPlanExercise> exercises;
  final List<String> muscleGroups;
  final String? imageIcon;

  const WorkoutPlanModel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.category,
    required this.estimatedMinutes,
    required this.xpReward,
    this.goldReward = 50,
    required this.exercises,
    required this.muscleGroups,
    this.imageIcon,
  });

  int get totalSets => exercises.fold(0, (sum, e) => sum + e.targetSets);

  factory WorkoutPlanModel.fromJson(Map<String, dynamic> json) {
    return WorkoutPlanModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      difficulty: json['difficulty']?.toString() ?? 'INTERMEDIATE',
      category: json['category']?.toString() ?? 'HYBRID',
      estimatedMinutes: json['estimatedMinutes'] ?? 30,
      xpReward: json['xpReward'] ?? 100,
      goldReward: json['goldReward'] ?? 50,
      exercises: (json['exercises'] as List<dynamic>?)
          ?.map((e) => WorkoutPlanExercise.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      muscleGroups: (json['muscleGroups'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      imageIcon: json['imageIcon']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'difficulty': difficulty,
    'category': category,
    'estimatedMinutes': estimatedMinutes,
    'xpReward': xpReward,
    'goldReward': goldReward,
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'muscleGroups': muscleGroups,
    'imageIcon': imageIcon,
  };

  WorkoutPlanModel copyWith({
    String? id,
    String? title,
    String? description,
    String? difficulty,
    String? category,
    int? estimatedMinutes,
    int? xpReward,
    int? goldReward,
    List<WorkoutPlanExercise>? exercises,
    List<String>? muscleGroups,
    String? imageIcon,
  }) {
    return WorkoutPlanModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      xpReward: xpReward ?? this.xpReward,
      goldReward: goldReward ?? this.goldReward,
      exercises: exercises ?? this.exercises,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      imageIcon: imageIcon ?? this.imageIcon,
    );
  }
}

// Plan completion status
enum PlanStatus {
  available('AVAILABLE', 'Available'),
  inProgress('IN_PROGRESS', 'In Progress'),
  completed('COMPLETED', 'Completed');

  final String value;
  final String label;
  const PlanStatus(this.value, this.label);
}

// User's progress on a workout plan
class PlanProgressModel {
  final String planId;
  final PlanStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int currentSetIndex;
  final int xpEarned;
  final int timesCompleted;

  const PlanProgressModel({
    required this.planId,
    this.status = PlanStatus.available,
    this.startedAt,
    this.completedAt,
    this.currentSetIndex = 0,
    this.xpEarned = 0,
    this.timesCompleted = 0,
  });

  PlanProgressModel copyWith({
    String? planId,
    PlanStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    int? currentSetIndex,
    int? xpEarned,
    int? timesCompleted,
  }) {
    return PlanProgressModel(
      planId: planId ?? this.planId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      currentSetIndex: currentSetIndex ?? this.currentSetIndex,
      xpEarned: xpEarned ?? this.xpEarned,
      timesCompleted: timesCompleted ?? this.timesCompleted,
    );
  }
}

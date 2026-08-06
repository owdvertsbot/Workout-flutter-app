// Adaptive Health - Adaptation Models
// Models for tracking user performance and app adaptation

import 'user_profile.dart';

/// Adaptation profile that tracks user progress and app learning
class AdaptationProfile {
  final String id;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final PerformanceMetrics performance;
  final RecoveryMetrics recovery;
  final FeedbackHistory feedback;
  final AdaptationFlags flags;
  final List<WeeklySummary> weeklySummaries;

  const AdaptationProfile({
    required this.id,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.performance,
    required this.recovery,
    required this.feedback,
    required this.flags,
    this.weeklySummaries = const [],
  });
}

/// Performance metrics over time
class PerformanceMetrics {
  final List<PerformanceSnapshot> snapshots;
  final double averageRPE; // Rate of Perceived Exertion
  final double volumeTrend; // Increasing, stable, or decreasing
  final double strengthTrend;
  final int sessionsCompleted;
  final int sessionsMissed;
  final double completionRate;

  const PerformanceMetrics({
    this.snapshots = const [],
    this.averageRPE = 6.0,
    this.volumeTrend = 0,
    this.strengthTrend = 0,
    this.sessionsCompleted = 0,
    this.sessionsMissed = 0,
    this.completionRate = 0.0,
  });
}

/// Individual performance snapshot
class PerformanceSnapshot {
  final DateTime date;
  final double rpe;
  final int volumeKg;
  final int exerciseCount;
  final int durationMinutes;
  final double heartRateAvg;
  final List<String> exercisesCompleted;
  final List<String> exercisesSkipped;

  const PerformanceSnapshot({
    required this.date,
    required this.rpe,
    required this.volumeKg,
    required this.exerciseCount,
    required this.durationMinutes,
    this.heartRateAvg = 0,
    this.exercisesCompleted = const [],
    this.exercisesSkipped = const [],
  });
}

/// Recovery metrics
class RecoveryMetrics {
  final List<RecoverySnapshot> snapshots;
  final double averageSleepHours;
  final double averageSleepQuality; // 0-10
  final int restDaysTaken;
  final int restDaysNeeded;
  final double readinessScore; // 0-100, overall readiness to train

  const RecoveryMetrics({
    this.snapshots = const [],
    this.averageSleepHours = 7.5,
    this.averageSleepQuality = 7.0,
    this.restDaysTaken = 0,
    this.restDaysNeeded = 0,
    this.readinessScore = 70,
  });
}

/// Individual recovery snapshot
class RecoverySnapshot {
  final DateTime date;
  final double sleepHours;
  final double sleepQuality; // 0-10
  final int restingHeartRate;
  final int hrvScore; // Heart Rate Variability
  final int perceivedFatigue; // 1-10
  final int sorenessLevel; // 1-10
  final List<String> stressors;

  const RecoverySnapshot({
    required this.date,
    required this.sleepHours,
    required this.sleepQuality,
    this.restingHeartRate = 60,
    this.hrvScore = 50,
    this.perceivedFatigue = 5,
    this.sorenessLevel = 5,
    this.stressors = const [],
  });
}

/// Feedback history from post-workout surveys
class FeedbackHistory {
  final List<WorkoutFeedback> entries;
  final double averageEnjoyment; // 1-10
  final List<String> commonLikes;
  final List<String> commonDislikes;
  final List<String> commonDifficulties;

  const FeedbackHistory({
    this.entries = const [],
    this.averageEnjoyment = 7.0,
    this.commonLikes = const [],
    this.commonDislikes = const [],
    this.commonDifficulties = const [],
  });
}

/// Post-workout feedback
class WorkoutFeedback {
  final DateTime date;
  final String prescriptionId;
  final double enjoyment; // 1-10
  final double difficulty; // 1-10
  final double perceivedEffort; // 1-10
  final bool completed;
  final String? notCompletedReason;
  final List<String> skippedExercises;
  final List<String> modifiedExercises;
  final String? additionalComments;
  final List<String> tags; // 'too_hard', 'too_easy', 'boring', 'enjoyed', etc.

  const WorkoutFeedback({
    required this.date,
    required this.prescriptionId,
    required this.enjoyment,
    required this.difficulty,
    required this.perceivedEffort,
    required this.completed,
    this.notCompletedReason,
    this.skippedExercises = const [],
    this.modifiedExercises = const [],
    this.additionalComments,
    this.tags = const [],
  });
}

/// Adaptation flags that influence prescription decisions
class AdaptationFlags {
  final bool needsEasierWorkouts;
  final bool needsHarderWorkouts;
  final bool needsMoreRest;
  final bool needsDifferentExercises;
  final bool needsShorterWorkouts;
  final bool needsLongerWorkouts;
  final bool strugglingWithConsistency;
  final bool overtraining;
  final List<String> exerciseSubstitutions; // Exercise IDs that should be replaced
  final List<String> exercisePreferences; // Exercises the user enjoys
  final List<String> equipmentAdjustments;

  const AdaptationFlags({
    this.needsEasierWorkouts = false,
    this.needsHarderWorkouts = false,
    this.needsMoreRest = false,
    this.needsDifferentExercises = false,
    this.needsShorterWorkouts = false,
    this.needsLongerWorkouts = false,
    this.strugglingWithConsistency = false,
    this.overtraining = false,
    this.exerciseSubstitutions = const [],
    this.exercisePreferences = const [],
    this.equipmentAdjustments = const [],
  });
}

/// Weekly summary
class WeeklySummary {
  final DateTime weekStart;
  final DateTime weekEnd;
  final int workoutsCompleted;
  final int workoutsPlanned;
  final double totalVolume;
  final double totalDurationMinutes;
  final double averageEnjoyment;
  final List<String> highlights;
  final List<String> challenges;
  final double progressScore; // 0-100

  const WeeklySummary({
    required this.weekStart,
    required this.weekEnd,
    required this.workoutsCompleted,
    required this.workoutsPlanned,
    this.totalVolume = 0,
    this.totalDurationMinutes = 0,
    this.averageEnjoyment = 0,
    this.highlights = const [],
    this.challenges = const [],
    this.progressScore = 0,
  });
}

/// Achievement model for milestones
class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementCategory category;
  final String iconName;
  final DateTime? unlockedAt;
  final bool isUnlocked;
  final double progress; // 0.0 to 1.0
  final String? badge;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.iconName,
    this.unlockedAt,
    this.isUnlocked = false,
    this.progress = 0,
    this.badge,
  });
}

/// Achievement categories
enum AchievementCategory {
  consistency('Consistency', 'Built lasting habits'),
  strength('Strength', 'Achieved strength milestones'),
  movement('Movement', 'Mastered new movements'),
  nutrition('Nutrition', 'Improved eating habits'),
  recovery('Recovery', 'Prioritized rest and recovery'),
  education('Education', 'Learned about health'),
  milestones('Milestones', 'Reached significant milestones');

  final String label;
  final String description;

  const AchievementCategory(this.label, this.description);
}

/// Progress/Rank model (adapted from RPG system)
class ProgressProfile {
  final String id;
  final int xp;
  final int level;
  final int xpToNextLevel;
  final Rank rank;
  final List<Achievement> achievements;
  final int totalWorkouts;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastWorkoutDate;

  const ProgressProfile({
    required this.id,
    this.xp = 0,
    this.level = 1,
    this.xpToNextLevel = 500,
    this.rank = Rank.novice,
    this.achievements = const [],
    this.totalWorkouts = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastWorkoutDate,
  });

  double get levelProgress => xp / xpToNextLevel;
}

/// Training maturity ranks
enum Rank {
  novice('Novice', 'Starting the journey', 1),
  beginner('Beginner', 'Building foundations', 5),
  intermediate('Intermediate', 'Making progress', 10),
  advanced('Advanced', 'Seeing results', 20),
  expert('Expert', 'Mastering fundamentals', 50);

  final String label;
  final String description;
  final int requiredLevel;

  const Rank(this.label, this.description, this.requiredLevel);
}

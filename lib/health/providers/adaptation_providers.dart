// Adaptive Health - Adaptation Providers
// Providers for tracking performance and adapting prescriptions

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

/// Adaptation profile provider
final adaptationProfileProvider = StateNotifierProvider<AdaptationProfileNotifier, AdaptationProfile>((ref) {
  return AdaptationProfileNotifier();
});

class AdaptationProfileNotifier extends StateNotifier<AdaptationProfile> {
  AdaptationProfileNotifier() : super(AdaptationProfile(
    id: 'default',
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    performance: const PerformanceMetrics(),
    recovery: const RecoveryMetrics(),
    feedback: const FeedbackHistory(),
    flags: const AdaptationFlags(),
  ));

  void recordPerformance(PerformanceSnapshot snapshot) {
    List<PerformanceSnapshot> snapshots = [...state.performance.snapshots, snapshot];
    
    // Calculate updated averages
    double avgRPE = snapshots.map((s) => s.rpe).reduce((a, b) => a + b) / snapshots.length;
    
    // Calculate trends
    double volumeTrend = _calculateTrend(snapshots.map((s) => s.volumeKg.toDouble()).toList());
    double strengthTrend = _calculateTrend(snapshots.map((s) => s.rpe).toList());
    
    // Count sessions
    int completed = snapshots.length;
    int missed = _calculateMissedSessions(snapshots);
    double completionRate = completed / (completed + missed);
    
    state = state.copyWith(
      lastUpdatedAt: DateTime.now(),
      performance: PerformanceMetrics(
        snapshots: snapshots,
        averageRPE: avgRPE,
        volumeTrend: volumeTrend,
        strengthTrend: strengthTrend,
        sessionsCompleted: completed,
        sessionsMissed: missed,
        completionRate: completionRate,
      ),
    );
    
    _updateFlags();
  }

  void recordRecovery(RecoverySnapshot snapshot) {
    List<RecoverySnapshot> snapshots = [...state.recovery.snapshots, snapshot];
    
    double avgSleepHours = snapshots.map((s) => s.sleepHours).reduce((a, b) => a + b) / snapshots.length;
    double avgSleepQuality = snapshots.map((s) => s.sleepQuality).reduce((a, b) => a + b) / snapshots.length;
    
    // Calculate readiness
    double readiness = _calculateReadiness(snapshot);
    
    state = state.copyWith(
      lastUpdatedAt: DateTime.now(),
      recovery: RecoveryMetrics(
        snapshots: snapshots,
        averageSleepHours: avgSleepHours,
        averageSleepQuality: avgSleepQuality,
        readinessScore: readiness,
      ),
    );
    
    _updateFlags();
  }

  void recordFeedback(WorkoutFeedback feedback) {
    List<WorkoutFeedback> entries = [...state.feedback.entries, feedback];
    
    double avgEnjoyment = entries.map((e) => e.enjoyment).reduce((a, b) => a + b) / entries.length;
    
    // Analyze patterns
    List<String> likes = _analyzeLikes(entries);
    List<String> dislikes = _analyzeDislikes(entries);
    List<String> difficulties = _analyzeDifficulties(entries);
    
    state = state.copyWith(
      lastUpdatedAt: DateTime.now(),
      feedback: FeedbackHistory(
        entries: entries,
        averageEnjoyment: avgEnjoyment,
        commonLikes: likes,
        commonDislikes: dislikes,
        commonDifficulties: difficulties,
      ),
    );
    
    _updateFlags();
  }

  void _updateFlags() {
    AdaptationFlags flags = const AdaptationFlags();
    
    // Analyze performance for flags
    if (state.performance.averageRPE > 8.5) {
      flags = AdaptationFlags(
        needsEasierWorkouts: true,
      );
    } else if (state.performance.averageRPE < 5) {
      flags = AdaptationFlags(
        needsHarderWorkouts: true,
      );
    }
    
    // Analyze recovery
    if (state.recovery.readinessScore < 40) {
      flags = AdaptationFlags(
        needsMoreRest: true,
      );
    }
    
    // Analyze feedback patterns
    if (state.feedback.commonDislikes.length > 3) {
      flags = AdaptationFlags(
        needsDifferentExercises: true,
      );
    }
    
    state = state.copyWith(flags: flags);
  }

  double _calculateTrend(List<double> values) {
    if (values.length < 2) return 0;
    
    // Simple linear regression slope
    int n = values.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    
    for (int i = 0; i < n; i++) {
      sumX += i;
      sumY += values[i];
      sumXY += i * values[i];
      sumX2 += i * i;
    }
    
    double slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    
    // Normalize to -1, 0, 1
    if (slope > 0.1) return 1;
    if (slope < -0.1) return -1;
    return 0;
  }

  int _calculateMissedSessions(List<PerformanceSnapshot> snapshots) {
    if (snapshots.isEmpty) return 0;
    
    // Assume max 7 days between sessions
    int missed = 0;
    DateTime? lastSession;
    
    for (var snapshot in snapshots.reversed) {
      if (lastSession == null) {
        lastSession = snapshot.date;
        continue;
      }
      
      int daysDiff = snapshot.date.difference(lastSession).inDays;
      if (daysDiff > 7) {
        missed += daysDiff - 7;
      }
      lastSession = snapshot.date;
    }
    
    return missed;
  }

  double _calculateReadiness(RecoverySnapshot snapshot) {
    double score = 100;
    
    // Deduct for poor sleep
    if (snapshot.sleepHours < 6) score -= 30;
    else if (snapshot.sleepHours < 7) score -= 15;
    else if (snapshot.sleepHours < 8) score -= 5;
    
    // Deduct for low sleep quality
    if (snapshot.sleepQuality < 5) score -= 20;
    else if (snapshot.sleepQuality < 7) score -= 10;
    
    // Deduct for high fatigue
    if (snapshot.perceivedFatigue > 7) score -= 20;
    else if (snapshot.perceivedFatigue > 5) score -= 10;
    
    // Deduct for high soreness
    if (snapshot.sorenessLevel > 7) score -= 15;
    else if (snapshot.sorenessLevel > 5) score -= 8;
    
    return score.clamp(0, 100);
  }

  List<String> _analyzeLikes(List<WorkoutFeedback> entries) {
    List<String> likes = [];
    for (var entry in entries) {
      if (entry.tags.contains('enjoyed')) {
        likes.addAll(entry.tags);
      }
    }
    return likes.toSet().toList();
  }

  List<String> _analyzeDislikes(List<WorkoutFeedback> entries) {
    List<String> dislikes = [];
    for (var entry in entries) {
      if (entry.tags.contains('boring') || entry.tags.contains('too_hard')) {
        dislikes.addAll(entry.tags);
      }
    }
    return dislikes.toSet().toList();
  }

  List<String> _analyzeDifficulties(List<WorkoutFeedback> entries) {
    List<String> difficulties = [];
    for (var entry in entries) {
      if (entry.perceivedEffort > 8) {
        difficulties.addAll(entry.skippedExercises);
      }
    }
    return difficulties.toSet().toList();
  }

  void addWeeklySummary(WeeklySummary summary) {
    state = state.copyWith(
      weeklySummaries: [...state.weeklySummaries, summary],
    );
  }
}

/// Progress/Rank provider (adapted from RPG system)
final progressProfileProvider = StateNotifierProvider<ProgressProfileNotifier, ProgressProfile>((ref) {
  return ProgressProfileNotifier();
});

class ProgressProfileNotifier extends StateNotifier<ProgressProfile> {
  ProgressProfileNotifier() : super(const ProgressProfile(id: 'default'));

  void addXp(int amount) {
    int newXp = state.xp + amount;
    int newLevel = state.level;
    int xpToNext = state.xpToNextLevel;
    Rank newRank = state.rank;
    
    // Check for level up
    while (newXp >= xpToNext) {
      newXp -= xpToNext;
      newLevel++;
      xpToNext = _calculateXpForLevel(newLevel);
      
      // Check for rank promotion
      for (var rank in Rank.values) {
        if (newLevel >= rank.requiredLevel && rank.requiredLevel > state.rank.requiredLevel) {
          newRank = rank;
        }
      }
    }
    
    state = state.copyWith(
      xp: newXp,
      level: newLevel,
      xpToNextLevel: xpToNext,
      rank: newRank,
    );
  }

  void recordWorkout() {
    state = state.copyWith(
      totalWorkouts: state.totalWorkouts + 1,
      lastWorkoutDate: DateTime.now(),
    );
    
    // Update streak
    _updateStreak();
    
    // Award XP for completing workout
    addXp(100);
  }

  void _updateStreak() {
    DateTime? lastWorkout = state.lastWorkoutDate;
    DateTime now = DateTime.now();
    int currentStreak = state.currentStreak;
    
    if (lastWorkout == null) {
      currentStreak = 1;
    } else {
      int daysSinceLast = now.difference(lastWorkout).inDays;
      if (daysSinceLast <= 1) {
        currentStreak++;
      } else {
        currentStreak = 1;
      }
    }
    
    int longestStreak = state.longestStreak;
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }
    
    state = state.copyWith(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
    );
  }

  void unlockAchievement(String achievementId) {
    List<Achievement> achievements = [...state.achievements];
    int index = achievements.indexWhere((a) => a.id == achievementId);
    
    if (index != -1) {
      achievements[index] = Achievement(
        id: achievementId,
        title: achievements[index].title,
        description: achievements[index].description,
        category: achievements[index].category,
        iconName: achievements[index].iconName,
        isUnlocked: true,
        unlockedAt: DateTime.now(),
        badge: achievements[index].badge,
      );
      
      state = state.copyWith(achievements: achievements);
      
      // Award XP for achievement
      addXp(50);
    }
  }

  int _calculateXpForLevel(int level) {
    // XP formula: 250 * level^1.5 + 500
    return (250 * (level * 1.5).round() + 500);
  }
}

/// Feedback form provider for post-workout surveys
final feedbackFormProvider = StateNotifierProvider<FeedbackFormNotifier, WorkoutFeedback?>((ref) {
  return FeedbackFormNotifier();
});

class FeedbackFormNotifier extends StateNotifier<WorkoutFeedback?> {
  FeedbackFormNotifier() : super(null);

  void startFeedback(String prescriptionId) {
    state = WorkoutFeedback(
      date: DateTime.now(),
      prescriptionId: prescriptionId,
      enjoyment: 5,
      difficulty: 5,
      perceivedEffort: 5,
      completed: false,
    );
  }

  void updateEnjoyment(double value) {
    if (state != null) {
      state = WorkoutFeedback(
        date: state!.date,
        prescriptionId: state!.prescriptionId,
        enjoyment: value,
        difficulty: state!.difficulty,
        perceivedEffort: state!.perceivedEffort,
        completed: state!.completed,
        notCompletedReason: state!.notCompletedReason,
        skippedExercises: state!.skippedExercises,
        modifiedExercises: state!.modifiedExercises,
        additionalComments: state!.additionalComments,
        tags: state!.tags,
      );
    }
  }

  void updateDifficulty(double value) {
    if (state != null) {
      state = WorkoutFeedback(
        date: state!.date,
        prescriptionId: state!.prescriptionId,
        enjoyment: state!.enjoyment,
        difficulty: value,
        perceivedEffort: state!.perceivedEffort,
        completed: state!.completed,
        notCompletedReason: state!.notCompletedReason,
        skippedExercises: state!.skippedExercises,
        modifiedExercises: state!.modifiedExercises,
        additionalComments: state!.additionalComments,
        tags: state!.tags,
      );
    }
  }

  void updateEffort(double value) {
    if (state != null) {
      state = WorkoutFeedback(
        date: state!.date,
        prescriptionId: state!.prescriptionId,
        enjoyment: state!.enjoyment,
        difficulty: state!.difficulty,
        perceivedEffort: value,
        completed: state!.completed,
        notCompletedReason: state!.notCompletedReason,
        skippedExercises: state!.skippedExercises,
        modifiedExercises: state!.modifiedExercises,
        additionalComments: state!.additionalComments,
        tags: state!.tags,
      );
    }
  }

  void setCompleted(bool completed, {String? reason}) {
    if (state != null) {
      state = WorkoutFeedback(
        date: state!.date,
        prescriptionId: state!.prescriptionId,
        enjoyment: state!.enjoyment,
        difficulty: state!.difficulty,
        perceivedEffort: state!.perceivedEffort,
        completed: completed,
        notCompletedReason: reason,
        skippedExercises: state!.skippedExercises,
        modifiedExercises: state!.modifiedExercises,
        additionalComments: state!.additionalComments,
        tags: state!.tags,
      );
    }
  }

  void addTag(String tag) {
    if (state != null) {
      state = WorkoutFeedback(
        date: state!.date,
        prescriptionId: state!.prescriptionId,
        enjoyment: state!.enjoyment,
        difficulty: state!.difficulty,
        perceivedEffort: state!.perceivedEffort,
        completed: state!.completed,
        notCompletedReason: state!.notCompletedReason,
        skippedExercises: state!.skippedExercises,
        modifiedExercises: state!.modifiedExercises,
        additionalComments: state!.additionalComments,
        tags: [...state!.tags, tag],
      );
    }
  }

  void submit() {
    // This would typically save to database
    state = null;
  }
}

// Extension to copy AdaptationProfile with new values
extension AdaptationProfileCopy on AdaptationProfile {
  AdaptationProfile copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    PerformanceMetrics? performance,
    RecoveryMetrics? recovery,
    FeedbackHistory? feedback,
    AdaptationFlags? flags,
    List<WeeklySummary>? weeklySummaries,
  }) {
    return AdaptationProfile(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      performance: performance ?? this.performance,
      recovery: recovery ?? this.recovery,
      feedback: feedback ?? this.feedback,
      flags: flags ?? this.flags,
      weeklySummaries: weeklySummaries ?? this.weeklySummaries,
    );
  }
}

// Extension to copy PerformanceMetrics with new values
extension PerformanceMetricsCopy on PerformanceMetrics {
  PerformanceMetrics copyWith({
    List<PerformanceSnapshot>? snapshots,
    double? averageRPE,
    double? volumeTrend,
    double? strengthTrend,
    int? sessionsCompleted,
    int? sessionsMissed,
    double? completionRate,
  }) {
    return PerformanceMetrics(
      snapshots: snapshots ?? this.snapshots,
      averageRPE: averageRPE ?? this.averageRPE,
      volumeTrend: volumeTrend ?? this.volumeTrend,
      strengthTrend: strengthTrend ?? this.strengthTrend,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      sessionsMissed: sessionsMissed ?? this.sessionsMissed,
      completionRate: completionRate ?? this.completionRate,
    );
  }
}

// Extension to copy RecoveryMetrics with new values
extension RecoveryMetricsCopy on RecoveryMetrics {
  RecoveryMetrics copyWith({
    List<RecoverySnapshot>? snapshots,
    double? averageSleepHours,
    double? averageSleepQuality,
    int? restDaysTaken,
    int? restDaysNeeded,
    double? readinessScore,
  }) {
    return RecoveryMetrics(
      snapshots: snapshots ?? this.snapshots,
      averageSleepHours: averageSleepHours ?? this.averageSleepHours,
      averageSleepQuality: averageSleepQuality ?? this.averageSleepQuality,
      restDaysTaken: restDaysTaken ?? this.restDaysTaken,
      restDaysNeeded: restDaysNeeded ?? this.restDaysNeeded,
      readinessScore: readinessScore ?? this.readinessScore,
    );
  }
}

// Extension to copy FeedbackHistory with new values
extension FeedbackHistoryCopy on FeedbackHistory {
  FeedbackHistory copyWith({
    List<WorkoutFeedback>? entries,
    double? averageEnjoyment,
    List<String>? commonLikes,
    List<String>? commonDislikes,
    List<String>? commonDifficulties,
  }) {
    return FeedbackHistory(
      entries: entries ?? this.entries,
      averageEnjoyment: averageEnjoyment ?? this.averageEnjoyment,
      commonLikes: commonLikes ?? this.commonLikes,
      commonDislikes: commonDislikes ?? this.commonDislikes,
      commonDifficulties: commonDifficulties ?? this.commonDifficulties,
    );
  }
}

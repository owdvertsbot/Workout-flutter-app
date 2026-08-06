// Adaptive Health - Prescription Models
// Models for personalized exercise and nutrition prescriptions

import 'user_profile.dart';

/// A complete daily prescription containing movement, nutrition, and recovery recommendations
class DailyPrescription {
  final String id;
  final DateTime date;
  final MovementPrescription movement;
  final NutritionPrescription nutrition;
  final RecoveryPrescription recovery;
  final List<EducationalContent> education;
  final DateTime generatedAt;
  final DateTime? adaptedAt;

  const DailyPrescription({
    required this.id,
    required this.date,
    required this.movement,
    required this.nutrition,
    required this.recovery,
    this.education = const [],
    required this.generatedAt,
    this.adaptedAt,
  });
}

/// Movement prescription for a single day
class MovementPrescription {
  final String id;
  final DateTime date;
  final int targetDurationMinutes;
  final int targetExercises;
  final List<ExercisePrescription> exercises;
  final MovementType primaryFocus;
  final IntensityLevel intensity;
  final String overallGuidance;
  final List<EvidenceSource> evidenceSources;

  const MovementPrescription({
    required this.id,
    required this.date,
    required this.targetDurationMinutes,
    required this.targetExercises,
    required this.exercises,
    required this.primaryFocus,
    required this.intensity,
    required this.overallGuidance,
    this.evidenceSources = const [],
  });
}

/// Individual exercise prescription
class ExercisePrescription {
  final String exerciseId;
  final String exerciseName;
  final String? videoUrl;
  final List<String> imageUrls;
  final ExercisePrescriptionType type;
  final int targetSets;
  final int targetReps;
  final int targetRepMax; // For rep ranges (e.g., 8-12)
  final int restSeconds;
  final double? targetWeight; // null = bodyweight or user choice
  final TempoPattern? tempo;
  final String instructions;
  final List<AccessibilityModification> accessibilityMods;
  final List<String> muscleGroups;
  final List<EvidenceSource> whyThisExercise; // Evidence for why this exercise is prescribed
  final List<EvidenceSource> whyThisDose; // Evidence for sets/reps/duration

  const ExercisePrescription({
    required this.exerciseId,
    required this.exerciseName,
    this.videoUrl,
    this.imageUrls = const [],
    required this.type,
    this.targetSets = 3,
    this.targetReps = 10,
    this.targetRepMax,
    this.restSeconds = 60,
    this.targetWeight,
    this.tempo,
    required this.instructions,
    this.accessibilityMods = const [],
    this.muscleGroups = const [],
    this.whyThisExercise = const [],
    this.whyThisDose = const [],
  });

  String get repRangeDisplay {
    if (targetRepMax != null && targetRepMax != targetReps) {
      return '$targetReps-$targetRepMax';
    }
    return targetReps.toString();
  }
}

/// Exercise prescription types
enum ExercisePrescriptionType {
  warmup('Warm-up', 'Prepares body for main workout'),
  strength('Strength', 'Builds muscular strength'),
  hypertrophy('Hypertrophy', 'Builds muscle size'),
  cardio('Cardio', 'Improves cardiovascular health'),
  flexibility('Flexibility', 'Improves range of motion'),
  balance('Balance', 'Improves balance and stability'),
  functional('Functional', 'Improves everyday movement'),
  mobility('Mobility', 'Improves joint mobility'),
  cooldown('Cool-down', 'Helps body recover post-workout');

  final String label;
  final String description;

  const ExercisePrescriptionType(this.label, this.description);
}

/// Tempo pattern for exercises (eccentric, pause, concentric)
class TempoPattern {
  final int eccentricSeconds; // Lowering phase
  final int pauseBottomSeconds; // Pause at bottom
  final int concentricSeconds; // Lifting phase
  final int pauseTopSeconds; // Pause at top

  const TempoPattern({
    this.eccentricSeconds = 2,
    this.pauseBottomSeconds = 0,
    this.concentricSeconds = 2,
    this.pauseTopSeconds = 0,
  });

  String get display => '$eccentricSeconds-$pauseBottomSeconds-$concentricSeconds-$pauseTopSeconds';
}

/// Intensity levels
enum IntensityLevel {
  veryLight('Very Light', 'RPE 1-3', 0.5),
  light('Light', 'RPE 4-5', 0.6),
  moderate('Moderate', 'RPE 6-7', 0.7),
  hard('Hard', 'RPE 8', 0.85),
  veryHard('Very Hard', 'RPE 9-10', 0.95);

  final String label;
  final String rpeDescription;
  final double effortPercentage;

  const IntensityLevel(this.label, this.rpeDescription, this.effortPercentage);
}

/// Movement type focus areas
enum MovementType {
  upperBodyPush('Upper Body Push', 'Chest, shoulders, triceps'),
  upperBodyPull('Upper Body Pull', 'Back, biceps'),
  lowerBody('Lower Body', 'Quads, hamstrings, glutes, calves'),
  core('Core', 'Abs, obliques, lower back'),
  fullBody('Full Body', 'Multiple muscle groups'),
  cardio('Cardiovascular', 'Heart and lung health'),
  flexibility('Flexibility', 'Stretching and mobility'),
  balance('Balance', 'Stability and coordination');

  final String label;
  final String description;

  const MovementType(this.label, this.description);
}

/// Accessibility modifications for exercises
class AccessibilityModification {
  final String id;
  final String type; // 'substitution', 'adaptation', 'modification'
  final String description;
  final String reason;
  final String originalExerciseId;
  final String modifiedExerciseId;
  final List<EvidenceSource> evidenceSources;

  const AccessibilityModification({
    required this.id,
    required this.type,
    required this.description,
    required this.reason,
    required this.originalExerciseId,
    required this.modifiedExerciseId,
    this.evidenceSources = const [],
  });
}

/// Nutrition prescription for a single day
class NutritionPrescription {
  final String id;
  final DateTime date;
  final double targetCalories;
  final double targetProteinGrams;
  final double targetCarbsGrams;
  final double targetFatGrams;
  final MealPlan? mealPlan;
  final List<NutritionGuidance> guidance;
  final HydrationTarget hydration;
  final List<EvidenceSource> evidenceSources;

  const NutritionPrescription({
    required this.id,
    required this.date,
    required this.targetCalories,
    required this.targetProteinGrams,
    required this.targetCarbsGrams,
    required this.targetFatGrams,
    this.mealPlan,
    this.guidance = const [],
    required this.hydration,
    this.evidenceSources = const [],
  });
}

/// Meal plan for the day
class MealPlan {
  final List<Meal> meals;
  final List<Snack> snacks;

  const MealPlan({
    this.meals = const [],
    this.snacks = const [],
  });

  int get mealCount => meals.length;
}

/// Individual meal
class Meal {
  final String id;
  final MealType type;
  final String name;
  final int targetCalories;
  final double targetProteinGrams;
  final double targetCarbsGrams;
  final double targetFatGrams;
  final List<FoodItem> foods;
  final String? recipeUrl;
  final int prepMinutes;
  final int cookMinutes;
  final double estimatedCost;
  final List<String> tags; // 'quick', 'budget', 'high-protein', etc.

  const Meal({
    required this.id,
    required this.type,
    required this.name,
    required this.targetCalories,
    this.targetProteinGrams = 0,
    this.targetCarbsGrams = 0,
    this.targetFatGrams = 0,
    this.foods = const [],
    this.recipeUrl,
    this.prepMinutes = 0,
    this.cookMinutes = 0,
    this.estimatedCost = 0,
    this.tags = const [],
  });
}

/// Meal types
enum MealType {
  breakfast('Breakfast'),
  lunch('Lunch'),
  dinner('Dinner'),
  snack('Snack');

  final String label;
  const MealType(this.label);
}

/// Individual food item
class FoodItem {
  final String id;
  final String name;
  final double grams;
  final double calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final List<String> tags; // 'source:protein', 'source:carbs', 'source:fat', etc.
  final List<String> allergens;

  const FoodItem({
    required this.id,
    required this.name,
    required this.grams,
    required this.calories,
    this.proteinGrams = 0,
    this.carbsGrams = 0,
    this.fatGrams = 0,
    this.tags = const [],
    this.allergens = const [],
  });
}

/// Snack between meals
class Snack {
  final String id;
  final String name;
  final int targetCalories;
  final List<FoodItem> foods;
  final String? whyNow; // Explanation of why this snack is recommended at this time

  const Snack({
    required this.id,
    required this.name,
    required this.targetCalories,
    this.foods = const [],
    this.whyNow,
  });
}

/// Nutrition guidance/recommendations
class NutritionGuidance {
  final String id;
  final String title;
  final String content;
  final GuidanceType type;
  final List<EvidenceSource> evidenceSources;

  const NutritionGuidance({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    this.evidenceSources = const [],
  });

  enum GuidanceType {
    general('General'),
    timing('Timing'),
    supplementation('Supplementation'),
    foodChoice('Food Choice'),
    preparation('Preparation');

    final String label;
    const GuidanceType(this.label);
  }
}

/// Hydration target
class HydrationTarget {
  final double targetLiters;
  final List<HydrationReminder> reminders;

  const HydrationTarget({
    this.targetLiters = 2.5,
    this.reminders = const [],
  });
}

/// Hydration reminder
class HydrationReminder {
  final int hour;
  final int minute;
  final String message;

  const HydrationReminder({
    required this.hour,
    required this.minute,
    required this.message,
  });
}

/// Recovery prescription
class RecoveryPrescription {
  final String id;
  final DateTime date;
  final SleepTarget sleep;
  final List<RecoveryActivity> activities;
  final List<RecoveryGuidance> guidance;
  final int restDayScore; // 0-100, how much rest is recommended

  const RecoveryPrescription({
    required this.id,
    required this.date,
    required this.sleep,
    this.activities = const [],
    this.guidance = const [],
    this.restDayScore = 50,
  });
}

/// Sleep target
class SleepTarget {
  final int targetHours;
  final int targetMinutes;
  final int bedTimeHour;
  final int bedTimeMinute;
  final int wakeTimeHour;
  final int wakeTimeMinute;
  final List<SleepGuidance> guidance;

  const SleepTarget({
    this.targetHours = 8,
    this.targetMinutes = 0,
    this.bedTimeHour = 22,
    this.bedTimeMinute = 0,
    this.wakeTimeHour = 6,
    this.wakeTimeMinute = 0,
    this.guidance = const [],
  });
}

/// Sleep guidance
class SleepGuidance({
  required this.id,
  required this.title,
  required this.content,
  final List<EvidenceSource> evidenceSources,
});

/// Recovery activity
class RecoveryActivity {
  final String id;
  final RecoveryActivityType type;
  final String title;
  final String description;
  final int durationMinutes;
  final List<EvidenceSource> whyThisActivity;

  const RecoveryActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.durationMinutes = 15,
    this.whyThisActivity = const [],
  });

  RecoveryActivityType get activityType => type;
}

enum RecoveryActivityType {
  stretching('Stretching'),
  foamRolling('Foam Rolling'),
  meditation('Meditation'),
  breathing('Breathing Exercises'),
  walk('Light Walk'),
  yoga('Yoga'),
  swim('Swimming'),
  massage('Self-Massage');

  final String label;
  const RecoveryActivityType(this.label);
}

/// Recovery guidance
class RecoveryGuidance {
  final String id;
  final String title;
  final String content;
  final GuidanceType type;
  final List<EvidenceSource> evidenceSources;

  const RecoveryGuidance({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    this.evidenceSources = const [],
  });

  enum GuidanceType {
    general('General'),
    sleep('Sleep'),
    stress('Stress Management'),
    nutrition('Nutrition'),
    hydration('Hydration');

    final String label;
    const GuidanceType(this.label);
  }
}

/// Educational content
class EducationalContent {
  final String id;
  final EducationTopic topic;
  final String title;
  final String summary;
  final String content;
  final String? imageUrl;
  final String? videoUrl;
  final int readMinutes;
  final List<EvidenceSource> sources;

  const EducationalContent({
    required this.id,
    required this.topic,
    required this.title,
    required this.summary,
    required this.content,
    this.imageUrl,
    this.videoUrl,
    this.readMinutes = 3,
    this.sources = const [],
  });
}

/// Education topics
enum EducationTopic {
  exerciseScience('Exercise Science'),
  nutrition('Nutrition'),
  recovery('Recovery'),
  sleep('Sleep'),
  goalSetting('Goal Setting'),
  habitFormation('Habit Formation'),
  injuryPrevention('Injury Prevention'),
  mentalHealth('Mental Health');

  final String label;
  const EducationTopic(this.label);
}

/// Evidence source for recommendations
class EvidenceSource {
  final String id;
  final String title;
  final String authors;
  final String journal;
  final int? year;
  final String url;
  final EvidenceLevel level;
  final String relevance; // How this source supports the recommendation

  const EvidenceSource({
    required this.id,
    required this.title,
    required this.authors,
    required this.journal,
    this.year,
    required this.url,
    required this.level,
    required this.relevance,
  });
}

/// Evidence quality levels
enum EvidenceLevel {
  systematicReview('Systematic Review / Meta-Analysis'),
  rct('Randomized Controlled Trial'),
  cohort('Cohort Study'),
  caseControl('Case-Control Study'),
  caseReport('Case Report / Expert Opinion'),
  animalStudy('Animal Study');

  final String label;
  const EvidenceLevel(this.label);
}

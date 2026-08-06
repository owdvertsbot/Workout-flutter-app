// Adaptive Health - Prescription Providers
// Providers for generating and managing personalized prescriptions

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

/// Current user profile provider
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier();
});

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(
    UserProfile(
      id: 'default',
      birthDate: DateTime(1990, 1, 1),
    ),
  );

  void updateProfile(UserProfile profile) {
    state = profile;
  }

  void updateBasicInfo({
    String? name,
    DateTime? birthDate,
    String? gender,
  }) {
    state = state.copyWith(
      name: name,
      birthDate: birthDate,
      gender: gender,
    );
  }

  void updatePhysicalMetrics({
    double? heightCm,
    double? weightKg,
    String? measurementUnit,
  }) {
    state = state.copyWith(
      heightCm: heightCm,
      weightKg: weightKg,
      measurementUnit: measurementUnit,
    );
  }

  void updateGoals({
    ActivityLevel? activityLevel,
    HealthGoal? primaryGoal,
    HealthGoal? secondaryGoal,
    int? weeklyWorkoutDays,
    int? availableWorkoutMinutes,
  }) {
    state = state.copyWith(
      activityLevel: activityLevel,
      primaryGoal: primaryGoal,
      secondaryGoal: secondaryGoal,
      weeklyWorkoutDays: weeklyWorkoutDays,
      availableWorkoutMinutes: availableWorkoutMinutes,
    );
  }

  void updateEquipment(List<EquipmentType> equipment) {
    state = state.copyWith(availableEquipment: equipment);
  }

  void updateHealthConsiderations({
    List<InjuryType>? injuries,
    List<DisabilityType>? disabilities,
    List<MobilityLimitation>? mobilityLimitations,
  }) {
    state = state.copyWith(
      injuries: injuries,
      disabilities: disabilities,
      mobilityLimitations: mobilityLimitations,
    );
  }

  void updateDietaryInfo({
    List<String>? foodAllergies,
    List<String>? dietaryRestrictions,
    DietaryPreference? dietaryPreference,
    CookingSkillLevel? cookingSkill,
    double? monthlyBudget,
  }) {
    state = state.copyWith(
      foodAllergies: foodAllergies,
      dietaryRestrictions: dietaryRestrictions,
      dietaryPreference: dietaryPreference,
      cookingSkill: cookingSkill,
      monthlyBudget: monthlyBudget,
    );
  }

  void completeOnboarding() {
    state = state.copyWith(
      onboardingCompleted: true,
      createdAt: DateTime.now(),
    );
  }
}

/// Today's prescription provider
final todayPrescriptionProvider = FutureProvider<DailyPrescription>((ref) async {
  final profile = ref.watch(userProfileProvider);
  final adaptation = ref.watch(adaptationProfileProvider);
  
  // Generate prescription based on profile and adaptation data
  return PrescriptionGenerator.generateDailyPrescription(
    profile: profile,
    adaptation: adaptation,
  );
});

/// Prescription history provider
final prescriptionHistoryProvider = StateNotifierProvider<PrescriptionHistoryNotifier, List<DailyPrescription>>((ref) {
  return PrescriptionHistoryNotifier();
});

class PrescriptionHistoryNotifier extends StateNotifier<List<DailyPrescription>> {
  PrescriptionHistoryNotifier() : super([]);

  void addPrescription(DailyPrescription prescription) {
    state = [prescription, ...state];
  }

  void updatePrescription(DailyPrescription prescription) {
    state = state.map((p) => p.id == prescription.id ? prescription : p).toList();
  }
}

/// Prescription generator service
class PrescriptionGenerator {
  static DailyPrescription generateDailyPrescription({
    required UserProfile profile,
    required AdaptationProfile adaptation,
  }) {
    final now = DateTime.now();
    final id = 'rx_${now.millisecondsSinceEpoch}';
    
    // Generate movement prescription
    final movement = _generateMovementPrescription(profile, adaptation, now);
    
    // Generate nutrition prescription
    final nutrition = _generateNutritionPrescription(profile, now);
    
    // Generate recovery prescription
    final recovery = _generateRecoveryPrescription(profile, adaptation, now);
    
    // Generate educational content
    final education = _generateEducation(profile, now);
    
    return DailyPrescription(
      id: id,
      date: now,
      movement: movement,
      nutrition: nutrition,
      recovery: recovery,
      education: education,
      generatedAt: now,
    );
  }
  
  static MovementPrescription _generateMovementPrescription(
    UserProfile profile,
    AdaptationProfile adaptation,
    DateTime date,
  ) {
    // Calculate target duration based on available time and activity level
    int targetMinutes = profile.availableWorkoutMinutes.clamp(15, 60);
    
    // Adjust based on recovery status
    if (adaptation.recovery.readinessScore < 50) {
      targetMinutes = (targetMinutes * 0.7).round();
    }
    
    // Determine primary focus based on goal and recent history
    MovementType focus = _determineFocus(profile, adaptation);
    
    // Determine intensity
    IntensityLevel intensity = _determineIntensity(profile, adaptation);
    
    // Generate exercises
    List<ExercisePrescription> exercises = _generateExercises(
      profile: profile,
      adaptation: adaptation,
      focus: focus,
      intensity: intensity,
    );
    
    return MovementPrescription(
      id: 'mov_${date.millisecondsSinceEpoch}',
      date: date,
      targetDurationMinutes: targetMinutes,
      targetExercises: exercises.length,
      exercises: exercises,
      primaryFocus: focus,
      intensity: intensity,
      overallGuidance: _generateMovementGuidance(profile, focus, intensity),
      evidenceSources: _getMovementEvidenceSources(focus),
    );
  }
  
  static NutritionPrescription _generateNutritionPrescription(
    UserProfile profile,
    DateTime date,
  ) {
    double targetCalories = profile.targetCalories;
    
    // Calculate macros based on goal
    double proteinPct = 0.30; // 30% of calories from protein
    double fatPct = 0.35; // 35% from fat
    double carbPct = 0.35; // 35% from carbs
    
    if (profile.primaryGoal == HealthGoal.muscleGain) {
      proteinPct = 0.35;
      carbPct = 0.40;
      fatPct = 0.25;
    } else if (profile.primaryGoal == HealthGoal.fatLoss) {
      proteinPct = 0.40;
      carbPct = 0.30;
      fatPct = 0.30;
    }
    
    double proteinGrams = (targetCalories * proteinPct) / 4; // 4 cal per gram protein
    double carbGrams = (targetCalories * carbPct) / 4; // 4 cal per gram carbs
    double fatGrams = (targetCalories * fatPct) / 9; // 9 cal per gram fat
    
    return NutritionPrescription(
      id: 'nut_${date.millisecondsSinceEpoch}',
      date: date,
      targetCalories: targetCalories,
      targetProteinGrams: proteinGrams,
      targetCarbsGrams: carbGrams,
      targetFatGrams: fatGrams,
      hydration: HydrationTarget(
        targetLiters: profile.weightKg * 0.033, // ~33ml per kg
      ),
      evidenceSources: _getNutritionEvidenceSources(profile.primaryGoal),
    );
  }
  
  static RecoveryPrescription _generateRecoveryPrescription(
    UserProfile profile,
    AdaptationProfile adaptation,
    DateTime date,
  ) {
    return RecoveryPrescription(
      id: 'rec_${date.millisecondsSinceEpoch}',
      date: date,
      sleep: SleepTarget(
        targetHours: 8,
        guidance: _getSleepGuidance(profile),
      ),
      activities: _getRecoveryActivities(adaptation.recovery),
      restDayScore: adaptation.recovery.readinessScore < 60 ? 80 : 30,
    );
  }
  
  static List<EducationalContent> _generateEducation(
    UserProfile profile,
    DateTime date,
  ) {
    // Return relevant educational content based on user profile
    return [
      EducationalContent(
        id: 'edu_${date.millisecondsSinceEpoch}',
        topic: EducationTopic.exerciseScience,
        title: 'Why Progressive Overload Matters',
        summary: 'Learn how gradual increases in exercise difficulty drive adaptation.',
        content: 'Progressive overload is the gradual increase of stress placed on the body during exercise...',
        readMinutes: 3,
        sources: _getMovementEvidenceSources(MovementType.strength as MovementType),
      ),
    ];
  }
  
  static MovementType _determineFocus(UserProfile profile, AdaptationProfile adaptation) {
    // Logic to rotate focus based on training history
    return MovementType.fullBody;
  }
  
  static IntensityLevel _determineIntensity(UserProfile profile, AdaptationProfile adaptation) {
    // Adjust based on recent performance
    if (adaptation.performance.averageRPE > 8) {
      return IntensityLevel.moderate;
    } else if (adaptation.performance.averageRPE < 5) {
      return IntensityLevel.hard;
    }
    return IntensityLevel.moderate;
  }
  
  static List<ExercisePrescription> _generateExercises({
    required UserProfile profile,
    required AdaptationProfile adaptation,
    required MovementType focus,
    required IntensityLevel intensity,
  }) {
    // Generate accessible exercises based on user profile
    List<ExercisePrescription> exercises = [];
    
    // Add warmup
    exercises.add(ExercisePrescription(
      exerciseId: 'warmup_general',
      exerciseName: 'Light Movement Warm-up',
      type: ExercisePrescriptionType.warmup,
      targetSets: 1,
      targetReps: 1,
      restSeconds: 0,
      instructions: '5 minutes of light cardio to prepare your body.',
      whyThisExercise: [
        EvidenceSource(
          id: 'ev_warmup',
          title: 'The Importance of Warming Up',
          authors: 'Fradkin et al.',
          journal: 'Journal of Strength and Conditioning Research',
          year: 2010,
          url: 'https://pubmed.ncbi.nlm.nih.gov/19901583/',
          level: EvidenceLevel.systematicReview,
          relevance: 'Warm-ups reduce injury risk by increasing muscle temperature and blood flow.',
        ),
      ],
    ));
    
    // Add main exercises based on focus
    exercises.add(ExercisePrescription(
      exerciseId: 'bodyweight_squat',
      exerciseName: 'Bodyweight Squat',
      type: ExercisePrescriptionType.strength,
      targetSets: 3,
      targetReps: 10,
      targetRepMax: 15,
      restSeconds: 60,
      instructions: 'Stand with feet shoulder-width apart. Lower your hips back and down.',
      accessibilityMods: _getAccessibilityMods(profile, 'bodyweight_squat'),
      whyThisExercise: [
        EvidenceSource(
          id: 'ev_squat',
          title: 'Effects of Squat Training on Muscular Adaptations',
          authors: 'Schoenfeld et al.',
          journal: 'Sports Medicine',
          year: 2016,
          url: 'https://pubmed.ncbi.nlm.nih.gov/27001161/',
          level: EvidenceLevel.systematicReview,
          relevance: 'Squats are a compound movement targeting multiple muscle groups including quads, glutes, and hamstrings.',
        ),
      ],
    ));
    
    return exercises;
  }
  
  static List<AccessibilityModification> _getAccessibilityMods(UserProfile profile, String exerciseId) {
    List<AccessibilityModification> mods = [];
    
    // Check for injuries and provide substitutions
    for (var injury in profile.injuries) {
      if (exerciseId.contains('squat') && 
          (injury == InjuryType.kneeLeft || injury == InjuryType.kneeRight)) {
        mods.add(AccessibilityModification(
          id: 'mod_${exerciseId}_knee',
          type: 'substitution',
          description: 'Seated leg press or池壁练习代替深蹲',
          reason: '保护受伤膝盖',
          originalExerciseId: exerciseId,
          modifiedExerciseId: 'seated_leg_press',
        ));
      }
    }
    
    return mods;
  }
  
  static String _generateMovementGuidance(UserProfile profile, MovementType focus, IntensityLevel intensity) {
    return '今天专注于${focus.label}训练。保持${intensity.rpeDescription}的用力感觉，如有不适请立即停止。';
  }
  
  static List<EvidenceSource> _getMovementEvidenceSources(MovementType focus) {
    return [
      EvidenceSource(
        id: 'ev_movement_general',
        title: 'Physical Activity Guidelines for Americans',
        authors: 'U.S. Department of Health and Human Services',
        journal: 'Official Guidelines',
        year: 2018,
        url: 'https://health.gov/paguidelines/',
        level: EvidenceLevel.systematicReview,
        relevance: 'Evidence-based guidelines recommending 150-300 minutes of moderate aerobic activity per week.',
      ),
    ];
  }
  
  static List<EvidenceSource> _getNutritionEvidenceSources(HealthGoal goal) {
    return [
      EvidenceSource(
        id: 'ev_nutrition_general',
        title: 'Dietary Reference Intakes for Macronutrients',
        authors: 'Institute of Medicine',
        journal: 'National Academies Press',
        year: 2005,
        url: 'https://nap.nationalacademies.org/catalog/10490/dietary-reference-intakes-for-energy-carbohydrate-fiber-fat-fatty-acids-cholesterol-protein-and-amino-acids',
        level: EvidenceLevel.systematicReview,
        relevance: 'Established recommended ranges for macronutrient intake based on caloric needs.',
      ),
    ];
  }
  
  static List<SleepGuidance> _getSleepGuidance(UserProfile profile) {
    return [];
  }
  
  static List<RecoveryActivity> _getRecoveryActivities(RecoveryMetrics recovery) {
    List<RecoveryActivity> activities = [];
    
    // Suggest stretching if soreness is high
    if (recovery.averageSleepQuality < 7) {
      activities.add(RecoveryActivity(
        id: 'rec_stretch',
        type: RecoveryActivityType.stretching,
        title: 'Gentle Stretching',
        description: '10-15 minutes of full-body stretching to reduce tension.',
        durationMinutes: 15,
      ));
    }
    
    return activities;
  }
}

// Re-export for convenience
export '../models/models.dart';

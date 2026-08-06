// Adaptive Health - User Profile Model
// Central model for storing all user information needed for personalization

import 'dart:math' as math;

class UserProfile {
  // Basic Information
  final String id;
  final String name;
  final DateTime birthDate;
  final String gender;
  
  // Physical Metrics
  final double heightCm;
  final double weightKg;
  final String measurementUnit; // 'metric' or 'imperial'
  
  // Activity & Goals
  final ActivityLevel activityLevel;
  final HealthGoal primaryGoal;
  final HealthGoal? secondaryGoal;
  final int weeklyWorkoutDays;
  final int availableWorkoutMinutes;
  
  // Equipment & Resources
  final List<EquipmentType> availableEquipment;
  final String? gymAccess;
  final double monthlyBudget;
  final CookingSkillLevel cookingSkill;
  
  // Health Considerations
  final List<InjuryType> injuries;
  final List<DisabilityType> disabilities;
  final List<MobilityLimitation> mobilityLimitations;
  final List<String> foodAllergies;
  final List<String> dietaryRestrictions;
  final DietaryPreference dietaryPreference;
  
  // Local Context
  final String? location;
  final List<String> availableFoods; // Common local foods
  
  // Onboarding
  final bool onboardingCompleted;
  final DateTime? createdAt;
  final DateTime? lastActiveAt;

  const UserProfile({
    required this.id,
    this.name = '',
    required this.birthDate,
    this.gender = 'not_specified',
    this.heightCm = 170,
    this.weightKg = 70,
    this.measurementUnit = 'metric',
    this.activityLevel = ActivityLevel.sedentary,
    this.primaryGoal = HealthGoal.generalHealth,
    this.secondaryGoal,
    this.weeklyWorkoutDays = 3,
    this.availableWorkoutMinutes = 30,
    this.availableEquipment = const [],
    this.gymAccess,
    this.monthlyBudget = 0,
    this.cookingSkill = CookingSkillLevel.beginner,
    this.injuries = const [],
    this.disabilities = const [],
    this.mobilityLimitations = const [],
    this.foodAllergies = const [],
    this.dietaryRestrictions = const [],
    this.dietaryPreference = DietaryPreference.none,
    this.location,
    this.availableFoods = const [],
    this.onboardingCompleted = false,
    this.createdAt,
    this.lastActiveAt,
  });

  // Calculate age from birth date
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Calculate BMI
  double get bmi {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  // Get BMI category
  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  // Calculate BMI
  double calculateBMI(double heightCm, double weightKg) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  // BMR using Mifflin-St Jeor Equation
  double get bmr {
    // Mifflin-St Jeor Equation
    // Men: BMR = 10*weight + 6.25*height - 5*age + 5
    // Women: BMR = 10*weight + 6.25*height - 5*age - 161
    double bmr;
    if (gender == 'male') {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }
    return bmr;
  }

  // TDEE (Total Daily Energy Expenditure)
  double get tdee {
    return bmr * activityLevel.multiplier;
  }

  // Target calories based on goal
  double get targetCalories {
    switch (primaryGoal) {
      case HealthGoal.fatLoss:
        return tdee * 0.8; // 20% deficit
      case HealthGoal.muscleGain:
        return tdee * 1.1; // 10% surplus
      case HealthGoal.strength:
        return tdee * 1.05; // 5% surplus
      case HealthGoal.generalHealth:
      case HealthGoal.endurance:
        return tdee;
    }
  }

  // Target protein based on goal (grams per kg body weight)
  double get targetProteinGramsPerKg {
    switch (primaryGoal) {
      case HealthGoal.muscleGain:
        return 2.0; // 2g/kg for muscle building
      case HealthGoal.strength:
        return 1.8; // 1.8g/kg for strength
      case HealthGoal.fatLoss:
        return 2.2; // Higher protein during deficit to preserve muscle
      case HealthGoal.generalHealth:
      case HealthGoal.endurance:
        return 1.6; // 1.6g/kg for general health
    }
  }

  // Target protein in grams
  double get targetProteinGrams => weightKg * targetProteinGramsPerKg;

  UserProfile copyWith({
    String? id,
    String? name,
    DateTime? birthDate,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? measurementUnit,
    ActivityLevel? activityLevel,
    HealthGoal? primaryGoal,
    HealthGoal? secondaryGoal,
    int? weeklyWorkoutDays,
    int? availableWorkoutMinutes,
    List<EquipmentType>? availableEquipment,
    String? gymAccess,
    double? monthlyBudget,
    CookingSkillLevel? cookingSkill,
    List<InjuryType>? injuries,
    List<DisabilityType>? disabilities,
    List<MobilityLimitation>? mobilityLimitations,
    List<String>? foodAllergies,
    List<String>? dietaryRestrictions,
    DietaryPreference? dietaryPreference,
    String? location,
    List<String>? availableFoods,
    bool? onboardingCompleted,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      measurementUnit: measurementUnit ?? this.measurementUnit,
      activityLevel: activityLevel ?? this.activityLevel,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      secondaryGoal: secondaryGoal ?? this.secondaryGoal,
      weeklyWorkoutDays: weeklyWorkoutDays ?? this.weeklyWorkoutDays,
      availableWorkoutMinutes: availableWorkoutMinutes ?? this.availableWorkoutMinutes,
      availableEquipment: availableEquipment ?? this.availableEquipment,
      gymAccess: gymAccess ?? this.gymAccess,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      cookingSkill: cookingSkill ?? this.cookingSkill,
      injuries: injuries ?? this.injuries,
      disabilities: disabilities ?? this.disabilities,
      mobilityLimitations: mobilityLimitations ?? this.mobilityLimitations,
      foodAllergies: foodAllergies ?? this.foodAllergies,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      location: location ?? this.location,
      availableFoods: availableFoods ?? this.availableFoods,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}

// Activity Levels with multipliers for TDEE calculation
enum ActivityLevel {
  sedentary('Sedentary', 'Little or no exercise', 1.2),
  lightlyActive('Lightly Active', 'Light exercise 1-3 days/week', 1.375),
  moderatelyActive('Moderately Active', 'Moderate exercise 3-5 days/week', 1.55),
  veryActive('Very Active', 'Hard exercise 6-7 days/week', 1.725),
  extraActive('Extra Active', 'Very hard exercise & physical job', 1.9);

  final String label;
  final String description;
  final double multiplier;

  const ActivityLevel(this.label, this.description, this.multiplier);
}

// Health Goals
enum HealthGoal {
  fatLoss('Fat Loss', 'Reduce body fat percentage'),
  muscleGain('Muscle Gain', 'Build lean muscle mass'),
  strength('Strength', 'Increase strength and power'),
  generalHealth('General Health', 'Improve overall health and fitness'),
  endurance('Endurance', 'Build cardiovascular endurance');

  final String label;
  final String description;

  const HealthGoal(this.label, this.description);
}

// Equipment Types
enum EquipmentType {
  none('No Equipment', 'Bodyweight only'),
  resistanceBands('Resistance Bands', 'Elastic resistance bands'),
  dumbbells('Dumbbells', 'Adjustable or fixed dumbbells'),
  barbell('Barbell', 'Olympic or standard barbell'),
  kettlebell('Kettlebell', 'Kettlebells'),
  pullUpBar('Pull-up Bar', 'Doorway or wall-mounted'),
  bench('Weight Bench', 'Flat or adjustable bench'),
  cableMachine('Cable Machine', 'Gym cable machine'),
  treadmill('Treadmill', 'Cardio machine'),
  bike('Stationary Bike', 'Indoor cycling bike'),
  rowingMachine('Rowing Machine', 'Indoor rowing'),
  other('Other', 'Other equipment');

  final String label;
  final String description;

  const EquipmentType(this.label, this.description);
}

// Cooking Skill Levels
enum CookingSkillLevel {
  beginner('Beginner', 'Can follow simple recipes'),
  intermediate('Intermediate', 'Comfortable cooking basic meals'),
  advanced('Advanced', 'Can cook complex meals'),
  expert('Expert', 'Professional or near-professional skill');

  final String label;
  final String description;

  const CookingSkillLevel(this.label, this.description);
}

// Injury Types
enum InjuryType {
  backLower('Lower Back', 'Lower back pain or injury'),
  backUpper('Upper Back', 'Upper back pain or injury'),
  shoulderLeft('Left Shoulder', 'Left shoulder injury'),
  shoulderRight('Right Shoulder', 'Right shoulder injury'),
  kneeLeft('Left Knee', 'Left knee injury'),
  kneeRight('Right Knee', 'Right knee injury'),
  hipLeft('Left Hip', 'Left hip injury'),
  hipRight('Right Hip', 'Right hip injury'),
  ankleLeft('Left Ankle', 'Left ankle injury'),
  ankleRight('Right Ankle', 'Right ankle injury'),
  wristLeft('Left Wrist', 'Left wrist injury'),
  wristRight('Right Wrist', 'Right wrist injury'),
  neck('Neck', 'Neck pain or injury'),
  elbowLeft('Left Elbow', 'Left elbow injury'),
  elbowRight('Right Elbow', 'Right elbow injury');

  final String label;
  final String description;

  const InjuryType(this.label, this.description);
}

// Disability Types
enum DisabilityType {
  wheelchair('Wheelchair User', 'Uses wheelchair for mobility'),
  prosthetic('Prosthetic Limb', 'Uses prosthetic limb(s)'),
  visualImpairment('Visual Impairment', 'Vision impairment affecting exercise'),
  hearingImpairment('Hearing Impairment', 'Hearing impairment'),
  amputation('Amputation', 'Limb amputation'),
  spinalCordInjury('Spinal Cord Injury', 'Spinal cord injury affecting mobility'),
  cerebralPalsy('Cerebral Palsy', 'Cerebral palsy affecting movement'),
  other('Other Disability', 'Other disability affecting exercise');

  final String label;
  final String description;

  const DisabilityType(this.label, this.description);
}

// Mobility Limitations
enum MobilityLimitation {
  limitedFlexibility('Limited Flexibility', 'Reduced range of motion'),
  balanceIssues('Balance Issues', 'Difficulty with balance'),
  jointStiffness('Joint Stiffness', 'Stiffness in joints'),
  chronicPain('Chronic Pain', 'Chronic pain affecting exercise'),
  breathingDifficulty('Breathing Difficulty', 'Respiratory conditions'),
  heartCondition('Heart Condition', 'Cardiovascular conditions requiring caution');

  final String label;
  final String description;

  const MobilityLimitation(this.label, this.description);
}

// Dietary Preferences
enum DietaryPreference {
  none('No Preference', 'No specific dietary preference'),
  vegetarian('Vegetarian', 'No meat'),
  vegan('Vegan', 'No animal products'),
  pescatarian('Pescatarian', 'Fish but no other meat'),
  keto('Ketogenic', 'Low carb, high fat'),
  paleo('Paleo', 'Whole foods, no processed'),
  glutenFree('Gluten-Free', 'Celiac or gluten sensitivity'),
  dairyFree('Dairy-Free', 'Lactose intolerance or preference'),
  halal('Halal', 'Islamic dietary laws'),
  kosher('Kosher', 'Jewish dietary laws');

  final String label;
  final String description;

  const DietaryPreference(this.label, this.description);
}

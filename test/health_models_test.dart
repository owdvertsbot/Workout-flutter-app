import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_health/health/models/models.dart';

void main() {
  group('UserProfile', () {
    test('calculates age correctly', () {
      final now = DateTime.now();
      final birthDate = DateTime(now.year - 30, 1, 1);
      final profile = UserProfile(
        id: 'test',
        birthDate: birthDate,
      );
      expect(profile.age, equals(30));
    });

    test('calculates BMI correctly', () {
      final profile = UserProfile(
        id: 'test',
        birthDate: DateTime(1990, 1, 1),
        heightCm: 180,
        weightKg: 80,
      );
      // BMI = 80 / (1.8 * 1.8) = 24.69
      expect(profile.bmi, closeTo(24.69, 0.1));
    });

    test('returns correct BMI category', () {
      final underweight = UserProfile(
        id: 'test',
        birthDate: DateTime(1990, 1, 1),
        heightCm: 180,
        weightKg: 55,
      );
      expect(underweight.bmiCategory, equals('Underweight'));

      final normal = UserProfile(
        id: 'test',
        birthDate: DateTime(1990, 1, 1),
        heightCm: 180,
        weightKg: 75,
      );
      expect(normal.bmiCategory, equals('Normal'));

      final overweight = UserProfile(
        id: 'test',
        birthDate: DateTime(1990, 1, 1),
        heightCm: 180,
        weightKg: 90,
      );
      expect(overweight.bmiCategory, equals('Overweight'));

      final obese = UserProfile(
        id: 'test',
        birthDate: DateTime(1990, 1, 1),
        heightCm: 180,
        weightKg: 110,
      );
      expect(obese.bmiCategory, equals('Obese'));
    });

    test('calculates BMR for male correctly', () {
      final profile = UserProfile(
        id: 'test',
        birthDate: DateTime(1990, 1, 1), // 35 years old
        gender: 'male',
        heightCm: 180,
        weightKg: 80,
      );
      // BMR = 10*80 + 6.25*180 - 5*35 + 5 = 800 + 1125 - 175 + 5 = 1755
      expect(profile.bmr, closeTo(1755, 1));
    });

    test('calculates BMR for female correctly', () {
      final profile = UserProfile(
        id: 'test',
        birthDate: DateTime(1990, 1, 1), // 35 years old
        gender: 'female',
        heightCm: 165,
        weightKg: 60,
      );
      // BMR = 10*60 + 6.25*165 - 5*35 - 161 = 600 + 1031.25 - 175 - 161 = 1295.25
      expect(profile.bmr, closeTo(1295, 1));
    });

    test('calculates TDEE correctly', () {
      final profile = UserProfile(
        id: 'test',
        birthDate: DateTime(1990, 1, 1),
        heightCm: 180,
        weightKg: 80,
        activityLevel: ActivityLevel.moderatelyActive,
      );
      // TDEE = BMR * 1.55
      expect(profile.tdee, equals(profile.bmr * 1.55));
    });

    test('calculates target calories for fat loss', () {
      final profile = UserProfile(
        id: 'test',
        birthDate: DateTime(1990, 1, 1),
        heightCm: 180,
        weightKg: 80,
        activityLevel: ActivityLevel.sedentary,
        primaryGoal: HealthGoal.fatLoss,
      );
      // Fat loss: TDEE * 0.8
      expect(profile.targetCalories, equals(profile.tdee * 0.8));
    });

    test('calculates target calories for muscle gain', () {
      final profile = UserProfile(
        id: 'test',
        birthDate: DateTime(1990, 1, 1),
        heightCm: 180,
        weightKg: 80,
        activityLevel: ActivityLevel.sedentary,
        primaryGoal: HealthGoal.muscleGain,
      );
      // Muscle gain: TDEE * 1.1
      expect(profile.targetCalories, equals(profile.tdee * 1.1));
    });

    test('calculates target protein for muscle gain', () {
      final profile = UserProfile(
        id: 'test',
        birthDate: DateTime(1990, 1, 1),
        weightKg: 80,
        primaryGoal: HealthGoal.muscleGain,
      );
      // Muscle gain: 2.0g per kg
      expect(profile.targetProteinGramsPerKg, equals(2.0));
      expect(profile.targetProteinGrams, equals(160)); // 80 * 2.0
    });

    test('calculates target protein for fat loss', () {
      final profile = UserProfile(
        id: 'test',
        birthDate: DateTime(1990, 1, 1),
        weightKg: 80,
        primaryGoal: HealthGoal.fatLoss,
      );
      // Fat loss: 2.2g per kg
      expect(profile.targetProteinGramsPerKg, equals(2.2));
      expect(profile.targetProteinGrams, equals(176)); // 80 * 2.2
    });

    test('copyWith preserves unmodified fields', () {
      final original = UserProfile(
        id: 'test-1',
        name: 'Test User',
        birthDate: DateTime(1990, 1, 1),
        heightCm: 180,
        weightKg: 80,
      );
      final copied = original.copyWith(weightKg: 85);
      expect(copied.id, equals('test-1'));
      expect(copied.name, equals('Test User'));
      expect(copied.heightCm, equals(180));
      expect(copied.weightKg, equals(85));
    });
  });

  group('ActivityLevel', () {
    test('has correct multiplier values', () {
      expect(ActivityLevel.sedentary.multiplier, equals(1.2));
      expect(ActivityLevel.lightlyActive.multiplier, equals(1.375));
      expect(ActivityLevel.moderatelyActive.multiplier, equals(1.55));
      expect(ActivityLevel.veryActive.multiplier, equals(1.725));
      expect(ActivityLevel.extraActive.multiplier, equals(1.9));
    });
  });

  group('ExercisePrescription', () {
    test('repRangeDisplay returns correct format', () {
      final exercise = ExercisePrescription(
        exerciseId: 'ex-1',
        exerciseName: 'Test Exercise',
        type: ExercisePrescriptionType.strength,
        targetSets: 3,
        targetReps: 10,
        targetRepMax: 12,
        instructions: 'Test instructions',
      );
      expect(exercise.repRangeDisplay, equals('10-12'));
    });

    test('repRangeDisplay returns single value when no max', () {
      final exercise = ExercisePrescription(
        exerciseId: 'ex-1',
        exerciseName: 'Test Exercise',
        type: ExercisePrescriptionType.strength,
        targetSets: 3,
        targetReps: 10,
        instructions: 'Test instructions',
      );
      expect(exercise.repRangeDisplay, equals('10'));
    });
  });

  group('TempoPattern', () {
    test('display returns correct format', () {
      const tempo = TempoPattern(
        eccentricSeconds: 3,
        pauseBottomSeconds: 1,
        concentricSeconds: 2,
        pauseTopSeconds: 0,
      );
      expect(tempo.display, equals('3-1-2-0'));
    });
  });

  group('Rank', () {
    test('has correct labels and required levels', () {
      expect(Rank.novice.label, equals('Novice'));
      expect(Rank.novice.requiredLevel, equals(1));
      
      expect(Rank.beginner.label, equals('Beginner'));
      expect(Rank.beginner.requiredLevel, equals(5));
      
      expect(Rank.intermediate.label, equals('Intermediate'));
      expect(Rank.intermediate.requiredLevel, equals(10));
      
      expect(Rank.advanced.label, equals('Advanced'));
      expect(Rank.advanced.requiredLevel, equals(20));
      
      expect(Rank.expert.label, equals('Expert'));
      expect(Rank.expert.requiredLevel, equals(50));
    });
  });

  group('EquipmentType', () {
    test('has correct labels', () {
      expect(EquipmentType.none.label, equals('No Equipment'));
      expect(EquipmentType.dumbbells.label, equals('Dumbbells'));
      expect(EquipmentType.barbell.label, equals('Barbell'));
    });
  });

  group('InjuryType', () {
    test('has correct labels', () {
      expect(InjuryType.backLower.label, equals('Lower Back'));
      expect(InjuryType.kneeLeft.label, equals('Left Knee'));
    });
  });

  group('DietaryPreference', () {
    test('has correct labels', () {
      expect(DietaryPreference.none.label, equals('No Preference'));
      expect(DietaryPreference.vegetarian.label, equals('Vegetarian'));
      expect(DietaryPreference.vegan.label, equals('Vegan'));
      expect(DietaryPreference.keto.label, equals('Ketogenic'));
    });
  });

  group('EvidenceLevel', () {
    test('has correct labels', () {
      expect(EvidenceLevel.systematicReview.label, contains('Systematic Review'));
      expect(EvidenceLevel.rct.label, contains('Randomized Controlled'));
      expect(EvidenceLevel.cohort.label, contains('Cohort'));
    });
  });
}

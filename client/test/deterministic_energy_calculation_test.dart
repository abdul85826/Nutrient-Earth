import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/domain/nutrition/energy_calculation_service.dart';
import 'package:nutrient_earth_client/core/domain/nutrition/nutrition_models.dart';

void main() {
  group('DeterministicEnergyCalculationService — Mifflin-St Jeor BMR', () {
    const service = DeterministicEnergyCalculationService();

    test('calculates correct BMR for male: 70kg, 175cm, 30y', () {
      // Formula: 10 * 70 + 6.25 * 175 - 5 * 30 + 5 = 700 + 1093.75 - 150 + 5 = 1648.75 -> 1648.8
      const inputs = PhysiologicalInputs(
        weightKg: 70.0,
        heightCm: 175.0,
        ageYears: 30,
        biologicalSex: BiologicalSex.male,
      );

      final result = service.calculateBmr(inputs);
      expect(result.isSuccess, isTrue);
      expect(result.bmrKcal, equals(1648.8));
    });

    test('calculates correct BMR for female: 60kg, 165cm, 28y', () {
      // Formula: 10 * 60 + 6.25 * 165 - 5 * 28 - 161 = 600 + 1031.25 - 140 - 161 = 1330.25 -> 1330.3
      const inputs = PhysiologicalInputs(
        weightKg: 60.0,
        heightCm: 165.0,
        ageYears: 28,
        biologicalSex: BiologicalSex.female,
      );

      final result = service.calculateBmr(inputs);
      expect(result.isSuccess, isTrue);
      expect(result.bmrKcal, equals(1330.3));
    });

    test('strictly rejects missing inputs without guessing zero', () {
      const inputs = PhysiologicalInputs(
        weightKg: null,
        heightCm: 175.0,
        ageYears: null,
        biologicalSex: BiologicalSex.male,
      );

      final result = service.calculateBmr(inputs);
      expect(result.isSuccess, isFalse);
      expect(result.status, equals(CalculationStatus.missingInputs));
      expect(result.missingFields, containsAll(['weightKg', 'ageYears']));
      expect(result.bmrKcal, isNull);
    });

    test('rejects physiologically implausible values', () {
      const inputs = PhysiologicalInputs(
        weightKg: 400.0, // Exceeds 350kg
        heightCm: 175.0,
        ageYears: 30,
        biologicalSex: BiologicalSex.male,
      );

      final result = service.calculateBmr(inputs);
      expect(result.isSuccess, isFalse);
      expect(result.status, equals(CalculationStatus.invalidInputs));
    });
  });

  group('DeterministicEnergyCalculationService — TDEE & Wearable Integration', () {
    const service = DeterministicEnergyCalculationService();

    test('calculates TDEE using FAO/WHO PAL factors when no wearable data is present', () {
      const inputs = PhysiologicalInputs(
        weightKg: 70.0,
        heightCm: 175.0,
        ageYears: 30,
        biologicalSex: BiologicalSex.male,
        activityLevel: PhysicalActivityLevel.moderatelyActive, // 1.55
      );

      final result = service.calculateTdee(inputs);
      expect(result.isSuccess, isTrue);
      expect(result.usedWearableActiveCalories, isFalse);
      // 1648.75 * 1.55 = 2555.56 -> 2555.6
      expect(result.tdeeKcal, equals(2555.6));
    });

    test('integrates verified active calories from Health Connect onto sedentary baseline', () {
      const inputs = PhysiologicalInputs(
        weightKg: 70.0,
        heightCm: 175.0,
        ageYears: 30,
        biologicalSex: BiologicalSex.male,
        verifiedActiveCaloriesKcal: 450.0, // Measured from physical hardware
      );

      final result = service.calculateTdee(inputs);
      expect(result.isSuccess, isTrue);
      expect(result.usedWearableActiveCalories, isTrue);
      // (1648.75 * 1.15) + 450 = 1896.06 + 450 = 2346.1
      expect(result.tdeeKcal, equals(2346.1));
    });
  });

  group('DeterministicEnergyCalculationService — Macronutrient Targets', () {
    const service = DeterministicEnergyCalculationService();

    test('calculates endurance recovery targets with 1.6g/kg protein', () {
      final targets = service.calculateMacronutrientTargets(
        tdeeKcal: 2500.0,
        weightKg: 70.0,
        primaryGoal: 'Endurance Recovery',
      );

      expect(targets.proteinGrams, equals(112.0)); // 70 * 1.6
      expect(targets.proteinKcal, equals(448.0)); // 112 * 4
      expect(targets.fatKcal, equals(625.0)); // 25% of 2500
      expect(targets.carbsKcal, equals(1427.0)); // 2500 - 448 - 625
      expect(targets.strategyDescription, contains('Endurance Recovery'));
    });

    test('calculates hypertrophy targets with 2.0g/kg protein and caloric surplus', () {
      final targets = service.calculateMacronutrientTargets(
        tdeeKcal: 2500.0,
        weightKg: 80.0,
        primaryGoal: 'Muscle Hypertrophy & Strength',
      );

      expect(targets.targetCaloriesKcal, equals(2750.0)); // 2500 + 250
      expect(targets.proteinGrams, equals(160.0)); // 80 * 2.0
      expect(targets.strategyDescription, contains('Hypertrophy / Strength'));
    });
  });

  group('DeterministicEnergyCalculationService — Hydration Guidance', () {
    const service = DeterministicEnergyCalculationService();

    test('calculates baseline plus exercise and thermal offsets', () {
      const inputs = PhysiologicalInputs(
        weightKg: 70.0,
        verifiedActiveCaloriesKcal: 500.0,
        ambientTemperatureCelsius: 28.0, // Warm day -> +300mL
      );

      final guidance = service.calculateDailyHydration(inputs);
      expect(guidance.isSuccess, isTrue);
      expect(guidance.baselineMilliliters, equals(2450.0)); // 70 * 35
      expect(guidance.exerciseAdjustmentMilliliters, equals(600.0)); // (500 / 10) * 12
      expect(guidance.thermalAdjustmentMilliliters, equals(300.0)); // >= 25°C
      expect(guidance.totalRecommendedMilliliters, equals(3350.0));
    });
  });

  group('DeterministicEnergyCalculationService — Micronutrient RDAs', () {
    const service = DeterministicEnergyCalculationService();

    test('evaluates micronutrients highlighting deficiency and adequacy', () {
      final recorded = [
        const MicronutrientMeasurement(
          nutrientName: 'Vitamin C',
          amount: 30.0, // RDA for male is 90mg -> deficient (33.3%)
          unit: NutrientUnit.milligram,
        ),
        const MicronutrientMeasurement(
          nutrientName: 'Zinc',
          amount: 12.0, // RDA for male is 11mg -> adequate (109.1%)
          unit: NutrientUnit.milligram,
        ),
      ];

      final results = service.evaluateMicronutrients(
        recordedMicros: recorded,
        sex: BiologicalSex.male,
        age: 30,
      );

      expect(results.length, equals(2));
      final vitC = results.firstWhere((r) => r.nutrientName == 'Vitamin C');
      expect(vitC.isDeficient, isTrue);
      expect(vitC.percentageMet, closeTo(33.3, 0.5));

      final zinc = results.firstWhere((r) => r.nutrientName == 'Zinc');
      expect(zinc.isDeficient, isFalse);
      expect(zinc.percentageMet, closeTo(109.1, 0.5));
    });
  });
}


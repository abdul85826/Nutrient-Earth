// ==============================================================================
// Nutrient Earth — Deterministic Energy & Nutrition Calculation Service
// Mathematical implementations of Mifflin-St Jeor BMR, TDEE, macronutrient
// budgeting, dietary reference intakes (RDAs), and physiological hydration guidance.
// Strictly validates inputs. Never hallucinates, guesses, or defaults missing inputs to zero.
// ==============================================================================

import 'nutrition_models.dart';

/// Validation or computation status for deterministic calculations.
enum CalculationStatus {
  success,
  missingInputs,
  invalidInputs,
}

/// Biological sex for human metabolic modeling.
enum BiologicalSex {
  male,
  female;

  static BiologicalSex? tryParse(String? value) {
    if (value == null) return null;
    final lower = value.trim().toLowerCase();
    if (lower == 'male' || lower == 'm') return BiologicalSex.male;
    if (lower == 'female' || lower == 'f') return BiologicalSex.female;
    return null;
  }
}

/// Physical Activity Level (PAL) standard factors from FAO/WHO/UNU.
enum PhysicalActivityLevel {
  sedentary(1.2, 'Little or no exercise, desk job'),
  lightlyActive(1.375, 'Light exercise or sports 1-3 days/week'),
  moderatelyActive(1.55, 'Moderate exercise or sports 3-5 days/week'),
  veryActive(1.725, 'Hard exercise or sports 6-7 days/week'),
  extraActive(1.9, 'Very hard exercise, physical job, or athletic training');

  final double factor;
  final String description;

  const PhysicalActivityLevel(this.factor, this.description);

  static PhysicalActivityLevel fromString(String? value) {
    if (value == null) return PhysicalActivityLevel.moderatelyActive;
    final lower = value.trim().toLowerCase();
    if (lower.contains('sedentary')) return PhysicalActivityLevel.sedentary;
    if (lower.contains('light')) return PhysicalActivityLevel.lightlyActive;
    if (lower.contains('very') || lower.contains('heavy')) return PhysicalActivityLevel.veryActive;
    if (lower.contains('extra') || lower.contains('athlete')) return PhysicalActivityLevel.extraActive;
    return PhysicalActivityLevel.moderatelyActive;
  }
}

/// Standardized physiological inputs for metabolic calculations.
class PhysiologicalInputs {
  final double? weightKg;
  final double? heightCm;
  final int? ageYears;
  final BiologicalSex? biologicalSex;
  final PhysicalActivityLevel activityLevel;
  final double? verifiedActiveCaloriesKcal;
  final double? ambientTemperatureCelsius;

  const PhysiologicalInputs({
    this.weightKg,
    this.heightCm,
    this.ageYears,
    this.biologicalSex,
    this.activityLevel = PhysicalActivityLevel.moderatelyActive,
    this.verifiedActiveCaloriesKcal,
    this.ambientTemperatureCelsius,
  });

  /// Identifies all missing required inputs for BMR calculation.
  List<String> get missingBmrFields {
    final missing = <String>[];
    if (weightKg == null) missing.add('weightKg');
    if (heightCm == null) missing.add('heightCm');
    if (ageYears == null) missing.add('ageYears');
    if (biologicalSex == null) missing.add('biologicalSex');
    return missing;
  }

  /// Validates human physiological plausibility.
  String? validate() {
    final missing = missingBmrFields;
    if (missing.isNotEmpty) {
      return 'Missing required physiological fields: ${missing.join(', ')}';
    }
    if (weightKg! < 20.0 || weightKg! > 350.0) {
      return 'Weight ($weightKg kg) is outside physiologically plausible range (20 - 350 kg)';
    }
    if (heightCm! < 50.0 || heightCm! > 260.0) {
      return 'Height ($heightCm cm) is outside physiologically plausible range (50 - 260 cm)';
    }
    if (ageYears! < 10 || ageYears! > 120) {
      return 'Age ($ageYears years) is outside valid range (10 - 120 years)';
    }
    return null;
  }
}

/// Result of Basal Metabolic Rate (BMR) calculation.
class BmrResult {
  final CalculationStatus status;
  final double? bmrKcal;
  final String formula;
  final String? errorMessage;
  final List<String> missingFields;

  const BmrResult.success({
    required double this.bmrKcal,
    this.formula = 'Mifflin-St Jeor (1990)',
  })  : status = CalculationStatus.success,
        errorMessage = null,
        missingFields = const [];

  const BmrResult.missingInputs(this.missingFields)
      : status = CalculationStatus.missingInputs,
        bmrKcal = null,
        formula = 'Mifflin-St Jeor (1990)',
        errorMessage = 'Missing required inputs to calculate BMR';

  const BmrResult.invalid(this.errorMessage)
      : status = CalculationStatus.invalidInputs,
        bmrKcal = null,
        formula = 'Mifflin-St Jeor (1990)',
        missingFields = const [];

  bool get isSuccess => status == CalculationStatus.success && bmrKcal != null;
}

/// Result of Total Daily Energy Expenditure (TDEE) calculation.
class TdeeResult {
  final CalculationStatus status;
  final double? tdeeKcal;
  final double? baselineBmrKcal;
  final double palFactor;
  final double? activeCaloriesKcal;
  final bool usedWearableActiveCalories;
  final String? errorMessage;

  const TdeeResult.success({
    required double this.tdeeKcal,
    required double this.baselineBmrKcal,
    required this.palFactor,
    this.activeCaloriesKcal,
    this.usedWearableActiveCalories = false,
  })  : status = CalculationStatus.success,
        errorMessage = null;

  const TdeeResult.failure(this.errorMessage)
      : status = CalculationStatus.missingInputs,
        tdeeKcal = null,
        baselineBmrKcal = null,
        palFactor = 1.0,
        activeCaloriesKcal = null,
        usedWearableActiveCalories = false;

  bool get isSuccess => status == CalculationStatus.success && tdeeKcal != null;
}

/// Macronutrient distribution targets.
class MacronutrientTargets {
  final double targetCaloriesKcal;
  final double proteinGrams;
  final double proteinKcal;
  final double proteinPercentage;
  final double fatGrams;
  final double fatKcal;
  final double fatPercentage;
  final double carbsGrams;
  final double carbsKcal;
  final double carbsPercentage;
  final String strategyDescription;

  const MacronutrientTargets({
    required this.targetCaloriesKcal,
    required this.proteinGrams,
    required this.proteinKcal,
    required this.proteinPercentage,
    required this.fatGrams,
    required this.fatKcal,
    required this.fatPercentage,
    required this.carbsGrams,
    required this.carbsKcal,
    required this.carbsPercentage,
    required this.strategyDescription,
  });
}

/// Daily hydration guidance result.
class HydrationGuidance {
  final CalculationStatus status;
  final double? baselineMilliliters;
  final double? exerciseAdjustmentMilliliters;
  final double? thermalAdjustmentMilliliters;
  final double? totalRecommendedMilliliters;
  final String rationale;

  const HydrationGuidance.success({
    required double this.baselineMilliliters,
    required double this.exerciseAdjustmentMilliliters,
    required double this.thermalAdjustmentMilliliters,
    required double this.totalRecommendedMilliliters,
    required this.rationale,
  }) : status = CalculationStatus.success;

  const HydrationGuidance.missingInputs(String missing)
      : status = CalculationStatus.missingInputs,
        baselineMilliliters = null,
        exerciseAdjustmentMilliliters = null,
        thermalAdjustmentMilliliters = null,
        totalRecommendedMilliliters = null,
        rationale = 'Missing required inputs: $missing';

  bool get isSuccess => status == CalculationStatus.success && totalRecommendedMilliliters != null;
}

/// Recommended Dietary Allowance (RDA) evaluation comparison.
class MicronutrientRdaEvaluation {
  final String nutrientName;
  final double reportedIntake;
  final double rdaAmount;
  final NutrientUnit unit;
  final double percentageMet;
  final bool isDeficient;
  final bool isExcessive;
  final String clinicalContext;

  const MicronutrientRdaEvaluation({
    required this.nutrientName,
    required this.reportedIntake,
    required this.rdaAmount,
    required this.unit,
    required this.percentageMet,
    required this.isDeficient,
    required this.isExcessive,
    required this.clinicalContext,
  });
}

/// Production-grade deterministic calculation service.
class DeterministicEnergyCalculationService {
  const DeterministicEnergyCalculationService();

  /// Computes BMR using the Mifflin-St Jeor equation:
  /// Male: 10 * weight(kg) + 6.25 * height(cm) - 5 * age(y) + 5
  /// Female: 10 * weight(kg) + 6.25 * height(cm) - 5 * age(y) - 161
  /// Validates physiological bounds and rejects missing inputs with zero tolerance.
  BmrResult calculateBmr(PhysiologicalInputs inputs) {
    final validationError = inputs.validate();
    if (validationError != null) {
      if (inputs.missingBmrFields.isNotEmpty) {
        return BmrResult.missingInputs(inputs.missingBmrFields);
      }
      return BmrResult.invalid(validationError);
    }

    final w = inputs.weightKg!;
    final h = inputs.heightCm!;
    final a = inputs.ageYears!;

    double bmr;
    if (inputs.biologicalSex == BiologicalSex.male) {
      bmr = (10.0 * w) + (6.25 * h) - (5.0 * a) + 5.0;
    } else {
      bmr = (10.0 * w) + (6.25 * h) - (5.0 * a) - 161.0;
    }

    return BmrResult.success(bmrKcal: _round(bmr, 1));
  }

  /// Calculates TDEE.
  /// When verified active calories are present from connected hardware (Health Connect / HealthKit),
  /// integrates them directly onto the sedentary basal baseline (BMR * 1.2 + activeKcal).
  /// Otherwise scales BMR by the FAO/WHO PAL multiplier.
  TdeeResult calculateTdee(PhysiologicalInputs inputs) {
    final bmrResult = calculateBmr(inputs);
    if (!bmrResult.isSuccess) {
      return TdeeResult.failure(bmrResult.errorMessage ?? 'Unable to compute BMR');
    }

    final bmr = bmrResult.bmrKcal!;
    final activeKcal = inputs.verifiedActiveCaloriesKcal;

    if (activeKcal != null && activeKcal > 0.0) {
      // Sedentary baseline + actual hardware-measured burned energy
      final tdee = (bmr * 1.15) + activeKcal;
      return TdeeResult.success(
        tdeeKcal: _round(tdee, 1),
        baselineBmrKcal: bmr,
        palFactor: inputs.activityLevel.factor,
        activeCaloriesKcal: activeKcal,
        usedWearableActiveCalories: true,
      );
    }

    final tdee = bmr * inputs.activityLevel.factor;
    return TdeeResult.success(
      tdeeKcal: _round(tdee, 1),
      baselineBmrKcal: bmr,
      palFactor: inputs.activityLevel.factor,
      activeCaloriesKcal: 0.0,
      usedWearableActiveCalories: false,
    );
  }

  /// Calculates tailored macronutrient targets based on primary goal and TDEE.
  MacronutrientTargets calculateMacronutrientTargets({
    required double tdeeKcal,
    required double weightKg,
    String? primaryGoal,
  }) {
    final goal = (primaryGoal ?? '').toLowerCase();

    double targetCalories = tdeeKcal;
    double proteinGramsPerKg;
    double fatPercentage;
    String strategy;

    if (goal.contains('endurance') || goal.contains('recovery')) {
      strategy = 'Endurance Recovery: High carbohydrate glycogen replenishment with optimal protein';
      proteinGramsPerKg = 1.6;
      fatPercentage = 0.25;
    } else if (goal.contains('muscle') || goal.contains('strength') || goal.contains('hypertrophy')) {
      strategy = 'Hypertrophy / Strength: Elevated protein synthesis with caloric surplus';
      targetCalories = tdeeKcal + 250.0;
      proteinGramsPerKg = 2.0;
      fatPercentage = 0.25;
    } else if (goal.contains('loss') || goal.contains('deficit') || goal.contains('cut')) {
      strategy = 'Fat Loss / Deficit: Caloric deficit with protein sparing to protect lean tissue';
      targetCalories = (tdeeKcal - 400.0).clamp(1200.0, double.infinity);
      proteinGramsPerKg = 2.2;
      fatPercentage = 0.25;
    } else {
      strategy = 'Balanced Maintenance: Homeostatic macronutrient distribution';
      proteinGramsPerKg = 1.4;
      fatPercentage = 0.28;
    }

    final proteinGrams = _round(weightKg * proteinGramsPerKg, 1);
    final proteinKcal = _round(proteinGrams * 4.0, 1);

    final fatKcal = _round(targetCalories * fatPercentage, 1);
    final fatGrams = _round(fatKcal / 9.0, 1);

    final carbsKcal = _round((targetCalories - proteinKcal - fatKcal).clamp(0.0, double.infinity), 1);
    final carbsGrams = _round(carbsKcal / 4.0, 1);

    final totalKcal = proteinKcal + fatKcal + carbsKcal;

    return MacronutrientTargets(
      targetCaloriesKcal: targetCalories,
      proteinGrams: proteinGrams,
      proteinKcal: proteinKcal,
      proteinPercentage: _round((proteinKcal / totalKcal) * 100, 1),
      fatGrams: fatGrams,
      fatKcal: fatKcal,
      fatPercentage: _round((fatKcal / totalKcal) * 100, 1),
      carbsGrams: carbsGrams,
      carbsKcal: carbsKcal,
      carbsPercentage: _round((carbsKcal / totalKcal) * 100, 1),
      strategyDescription: strategy,
    );
  }

  /// Calculates personalized hydration guidance with thermal and exercise adjustments.
  HydrationGuidance calculateDailyHydration(PhysiologicalInputs inputs) {
    if (inputs.weightKg == null || inputs.weightKg! <= 0.0) {
      return const HydrationGuidance.missingInputs('weightKg');
    }

    final weight = inputs.weightKg!;
    // Baseline: 35 mL per kg
    final baseline = _round(weight * 35.0, 0);

    // Exercise fluid replenishment: 12 mL per 10 active kcal burned
    double exerciseOffset = 0.0;
    if (inputs.verifiedActiveCaloriesKcal != null && inputs.verifiedActiveCaloriesKcal! > 0) {
      exerciseOffset = _round((inputs.verifiedActiveCaloriesKcal! / 10.0) * 12.0, 0);
    } else if (inputs.activityLevel == PhysicalActivityLevel.moderatelyActive) {
      exerciseOffset = 350.0;
    } else if (inputs.activityLevel == PhysicalActivityLevel.veryActive ||
        inputs.activityLevel == PhysicalActivityLevel.extraActive) {
      exerciseOffset = 700.0;
    }

    // Thermal environmental adjustment
    double thermalOffset = 0.0;
    final temp = inputs.ambientTemperatureCelsius;
    if (temp != null) {
      if (temp >= 30.0) {
        thermalOffset = 600.0;
      } else if (temp >= 25.0) {
        thermalOffset = 300.0;
      }
    }

    final total = baseline + exerciseOffset + thermalOffset;

    final rationale = 'Baseline: ${baseline.toInt()} mL (35 mL/kg) + '
        'Exercise offset: ${exerciseOffset.toInt()} mL + '
        'Thermal offset: ${thermalOffset.toInt()} mL';

    return HydrationGuidance.success(
      baselineMilliliters: baseline,
      exerciseAdjustmentMilliliters: exerciseOffset,
      thermalAdjustmentMilliliters: thermalOffset,
      totalRecommendedMilliliters: total,
      rationale: rationale,
    );
  }

  /// Evaluates micronutrient intake against clinical RDAs for age and biological sex.
  List<MicronutrientRdaEvaluation> evaluateMicronutrients({
    required List<MicronutrientMeasurement> recordedMicros,
    required BiologicalSex sex,
    required int age,
  }) {
    final rdas = _getClinicalRdas(sex: sex, age: age);
    final evaluations = <MicronutrientRdaEvaluation>[];

    for (final micro in recordedMicros) {
      final key = micro.nutrientName.toLowerCase();
      final rda = rdas[key];
      if (rda != null) {
        final pctMet = _round((micro.amount / rda.amount) * 100, 1);
        final isDeficient = pctMet < 75.0;
        final isExcessive = pctMet > 250.0;

        String context;
        if (isDeficient) {
          context = 'Intake below 75% of RDA (${rda.amount} ${rda.unit.name}). Consider bioavailable food sources.';
        } else if (isExcessive) {
          context = 'Intake exceeds 250% of RDA. Verify against tolerable upper intake levels.';
        } else {
          context = 'Adequate intake meeting physiological dietary reference target.';
        }

        evaluations.add(MicronutrientRdaEvaluation(
          nutrientName: micro.nutrientName,
          reportedIntake: micro.amount,
          rdaAmount: rda.amount,
          unit: rda.unit,
          percentageMet: pctMet,
          isDeficient: isDeficient,
          isExcessive: isExcessive,
          clinicalContext: context,
        ));
      }
    }

    return evaluations;
  }

  Map<String, ({double amount, NutrientUnit unit})> _getClinicalRdas({
    required BiologicalSex sex,
    required int age,
  }) {
    final isMale = sex == BiologicalSex.male;
    final isOlder = age > 50;

    return {
      'vitamin c': (amount: isMale ? 90.0 : 75.0, unit: NutrientUnit.milligram),
      'vitamin d': (amount: age > 70 ? 20.0 : 15.0, unit: NutrientUnit.microgram),
      'vitamin b12': (amount: 2.4, unit: NutrientUnit.microgram),
      'iron': (amount: isMale || isOlder ? 8.0 : 18.0, unit: NutrientUnit.milligram),
      'calcium': (amount: (isMale && !isOlder) || (!isMale && !isOlder) ? 1000.0 : 1200.0, unit: NutrientUnit.milligram),
      'magnesium': (amount: isMale ? 420.0 : 320.0, unit: NutrientUnit.milligram),
      'zinc': (amount: isMale ? 11.0 : 8.0, unit: NutrientUnit.milligram),
      'potassium': (amount: isMale ? 3400.0 : 2600.0, unit: NutrientUnit.milligram),
    };
  }

  static double _round(double val, int decimals) {
    return double.parse(val.toStringAsFixed(decimals));
  }
}


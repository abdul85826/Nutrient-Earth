/// Domain Value Objects for Nutrient Earth BIOS.
///
/// Purpose: Encapsulate validated, immutable biological measurements as typed
/// value objects, preventing invalid states from entering the domain layer.
///
/// Responsibilities:
/// - Validate measurement values at construction time
/// - Provide unit conversion utilities
/// - Enforce clinical data constraints
/// - Support serialization for persistence
///
/// Future expansion:
/// - FHIR Observation resource mapping
/// - Clinical unit validation per ICD guidelines
library;

import '../../core/types/biological_types.dart';

// ─── Weight ───────────────────────────────────────────────────────────────────

class Weight {
  final double _kg;

  Weight.fromKg(double kg) : _kg = _validatePositive(kg, 'Weight');
  Weight.fromLbs(double lbs) : _kg = _validatePositive(lbs * 0.453592, 'Weight');

  double get inKg => _kg;
  double get inLbs => _kg / 0.453592;

  double get bmiNumerator => _kg;

  String formatted(WeightUnit unit) =>
      unit == WeightUnit.kg ? '${_kg.toStringAsFixed(1)} kg' : '${inLbs.toStringAsFixed(1)} lbs';

  static double _validatePositive(double value, String name) {
    if (value <= 0 || value > 500) throw ArgumentError('$name must be between 0-500: $value');
    return value;
  }
}

// ─── Height ───────────────────────────────────────────────────────────────────

class Height {
  final double _cm;

  Height.fromCm(double cm) : _cm = _validatePositive(cm, 'Height');
  Height.fromFeet(double feet, {double inches = 0})
      : _cm = _validatePositive((feet * 30.48) + (inches * 2.54), 'Height');

  double get inCm => _cm;
  double get inFeet => _cm / 30.48;

  String formatted(HeightUnit unit) =>
      unit == HeightUnit.cm ? '${_cm.toStringAsFixed(0)} cm' : '${inFeet.toStringAsFixed(1)} ft';

  static double _validatePositive(double value, String name) {
    if (value <= 0 || value > 300) throw ArgumentError('$name must be between 0-300cm: $value');
    return value;
  }
}

// ─── BMI ─────────────────────────────────────────────────────────────────────

class BMI {
  final double value;

  BMI._({required this.value});

  factory BMI.compute({required Weight weight, required Height height}) {
    final heightM = height.inCm / 100.0;
    final bmi = weight.inKg / (heightM * heightM);
    return BMI._(value: bmi);
  }

  String get classification {
    if (value < 18.5) return 'Underweight';
    if (value < 25.0) return 'Normal';
    if (value < 30.0) return 'Overweight';
    if (value < 35.0) return 'Obese Class I';
    if (value < 40.0) return 'Obese Class II';
    return 'Obese Class III';
  }

  String get formatted => value.toStringAsFixed(1);
}

// ─── Age ─────────────────────────────────────────────────────────────────────

class BiologicalAge {
  final int years;

  BiologicalAge(this.years) {
    if (years < 13 || years > 120) throw ArgumentError('Age must be between 13-120: $years');
  }

  factory BiologicalAge.fromBirthDate(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return BiologicalAge(age);
  }

  bool get isSenior => years >= 65;
  bool get isAdolescent => years < 18;
  String get ageGroup {
    if (years < 18) return 'Adolescent';
    if (years < 30) return 'Young Adult';
    if (years < 45) return 'Adult';
    if (years < 65) return 'Middle-Aged';
    return 'Senior';
  }
}

// ─── Hydration Target ─────────────────────────────────────────────────────────

class HydrationTarget {
  final double dailyLiters;

  HydrationTarget._(this.dailyLiters);

  factory HydrationTarget.compute({
    required Weight weight,
    required ActivityLevel activityLevel,
    required double temperatureC,
  }) {
    // Base: 35ml per kg
    double base = weight.inKg * 0.035;

    // Activity modifier
    final activityModifier = switch (activityLevel) {
      ActivityLevel.sedentary => 0.0,
      ActivityLevel.lightlyActive => 0.3,
      ActivityLevel.moderatelyActive => 0.5,
      ActivityLevel.veryActive => 0.8,
      ActivityLevel.athleteLevel => 1.2,
    };

    // Heat modifier: +250ml per degree above 25°C
    final heatModifier = temperatureC > 25 ? (temperatureC - 25) * 0.25 : 0.0;

    return HydrationTarget._((base + activityModifier + heatModifier).clamp(1.5, 5.0));
  }

  String get formatted => '${dailyLiters.toStringAsFixed(1)}L/day';
}

// ─── Sleep Target ──────────────────────────────────────────────────────────────

class SleepTarget {
  final double targetHours;
  final double minimumHours;

  SleepTarget._({required this.targetHours, required this.minimumHours});

  factory SleepTarget.compute({required BiologicalAge age, required ActivityLevel activityLevel}) {
    double target;
    if (age.years < 18) {
      target = 9.0;
    } else if (age.years < 65) {
      target = 8.0;
    } else {
      target = 7.5;
    }

    // High-performance athletes need more
    if (activityLevel == ActivityLevel.athleteLevel) target += 0.5;

    return SleepTarget._(targetHours: target, minimumHours: target - 1.0);
  }

  String get formatted => '${targetHours.toStringAsFixed(1)}h/night';
}

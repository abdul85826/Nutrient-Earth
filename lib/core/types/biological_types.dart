/// Biological Type System for Nutrient Earth BIOS.
///
/// Purpose: Central canonical type definitions and enumerations for all
/// biological, clinical, and wellness data modeled across the platform.
///
/// Responsibilities:
/// - Define biological measurement units and scales
/// - Define clinical state classifications
/// - Provide serialization helpers for persistence
///
/// Future expansion:
/// - ICD-10 code mapping
/// - SNOMED CT terminology binding
/// - FHIR resource compatibility
library;

// ─── Biological State Classifications ───────────────────────────────────────

enum RecoveryState {
  optimal,         // >85% recovery score
  adequate,        // 65-85%
  subOptimal,      // 45-65%
  stressed,        // 25-45%
  critical,        // <25%
}

enum FatigueLevel {
  none,
  mild,
  moderate,
  severe,
  extreme,
}

enum InflammationState {
  baseline,
  mildlyElevated,
  elevated,
  highlyElevated,
  critical,
}

enum HydrationStatus {
  overHydrated,
  optimal,
  mildlyDehydrated,
  dehydrated,
  severelyDehydrated,
}

enum MetabolicLoadState {
  rest,
  lowLoad,
  moderateLoad,
  highLoad,
  peakLoad,
}

enum NervousSystemState {
  highParasympathetic,  // Deep recovery
  balanced,
  mildlySympathetic,    // Light stress
  sympatheticDominant,  // High stress
  burnout,              // Chronic sympathetic overload
}

// ─── Wellness Domain Enumerations ────────────────────────────────────────────

enum BiologicalSex { male, female, intersex, preferNotToSay }

enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  athleteLevel,
}

enum SleepQuality { poor, fair, good, excellent }

enum StressManagementCapacity { low, moderate, high, exceptional }

enum BodyCompositionGoal {
  fatLoss,
  muscleBuild,
  recomposition,
  maintenance,
  performanceOptimization,
}

enum DietaryPattern {
  omnivore,
  vegetarian,
  vegan,
  pescatarian,
  ketogenic,
  paleo,
  mediterranean,
  carnivore,
  lowFodmap,
  custom,
}

enum ChronicConditionCategory {
  metabolic,
  cardiovascular,
  autoimmune,
  neurological,
  hormonal,
  digestive,
  respiratory,
  musculoskeletal,
  mentalHealth,
  none,
}

// ─── Measurement Units ────────────────────────────────────────────────────────

enum WeightUnit { kg, lbs }
enum HeightUnit { cm, feet }
enum TemperatureUnit { celsius, fahrenheit }
enum VolumeUnit { liters, fluidOunces }

// ─── Scoring Scale Definitions ───────────────────────────────────────────────

/// Normalized biological score on a 0.0 to 1.0 scale.
typedef BiologicalScore = double;

/// A tagged biological metric with label and normalized value.
class LabeledBioScore {
  final String label;
  final BiologicalScore value;
  final String unit;

  const LabeledBioScore({
    required this.label,
    required this.value,
    required this.unit,
  });

  /// Classify score into human-readable tier.
  String get tier {
    if (value >= 0.85) return 'Optimal';
    if (value >= 0.65) return 'Good';
    if (value >= 0.45) return 'Fair';
    if (value >= 0.25) return 'Poor';
    return 'Critical';
  }
}

// ─── Environmental Classification ────────────────────────────────────────────

enum AirQualityIndex {
  good,         // 0-50
  moderate,     // 51-100
  unhealthyForSensitive, // 101-150
  unhealthy,    // 151-200
  veryUnhealthy, // 201-300
  hazardous,    // >300
}

enum ClimateStressor { extremeHeat, extremeCold, highHumidity, lowHumidity, highAltitude, polluted }

// ─── Wearable Data Source Registry ───────────────────────────────────────────

enum WearableProvider {
  appleHealth,
  googleFit,
  fitbit,
  garmin,
  whoop,
  oura,
  polar,
  suunto,
  amazfit,
  manual, // User-entered data
}

// ─── Protocol Categories ──────────────────────────────────────────────────────

enum ProtocolCategory {
  hydration,
  nutrition,
  supplementation,
  sleep,
  movement,
  recovery,
  breathwork,
  mindfulness,
  sunlight,
  coldExposure,
  heatTherapy,
}

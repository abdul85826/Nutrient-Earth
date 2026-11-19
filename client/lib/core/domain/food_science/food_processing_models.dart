// ==============================================================================
// Nutrient Earth — Food Processing & Nutrient Transformation Models
// Distinguishes:
// 1. Nutrient retention (%) vs. concentration changes (accounting for water mass changes)
// 2. Leaching into discarded cooking water
// 3. Bioavailability changes & antinutritional factor degradation (phytates, oxalates)
// 4. Resistant Starch Type 3 (RS3) retrogradation upon cooling
// ==============================================================================

enum FoodProcessingOp {
  washing,
  soaking,
  sprouting,
  fermentation,
  boiling,
  steaming,
  pressureCooking,
  roasting,
  panFrying,
  deepFrying,
  microwaving,
  refrigeration,
  reheating;

  String get displayName {
    switch (this) {
      case FoodProcessingOp.washing:
        return 'Washing & Surface Decontamination';
      case FoodProcessingOp.soaking:
        return 'Hydration / Water Soaking';
      case FoodProcessingOp.sprouting:
        return 'Germination / Sprouting';
      case FoodProcessingOp.fermentation:
        return 'Bacterial / Yeast Fermentation';
      case FoodProcessingOp.boiling:
        return 'Water Boiling (Submerged)';
      case FoodProcessingOp.steaming:
        return 'Steam Cooking (Vapor Phase)';
      case FoodProcessingOp.pressureCooking:
        return 'High-Pressure Wet Cooking';
      case FoodProcessingOp.roasting:
        return 'Dry Heat Roasting / Baking';
      case FoodProcessingOp.panFrying:
        return 'Shallow Pan Sautéing';
      case FoodProcessingOp.deepFrying:
        return 'High-Temperature Oil Submersion';
      case FoodProcessingOp.microwaving:
        return 'Dielectric Radiofrequency Heating';
      case FoodProcessingOp.refrigeration:
        return 'Cold Storage Retrogradation (4°C)';
      case FoodProcessingOp.reheating:
        return 'Secondary Thermal Reheating';
    }
  }
}

enum LeachingRisk {
  none,
  low,
  moderate,
  high;

  String get label {
    switch (this) {
      case LeachingRisk.none:
        return 'No Leaching (Dry/Enclosed)';
      case LeachingRisk.low:
        return 'Low Leaching (Minimal Fluid Contact)';
      case LeachingRisk.moderate:
        return 'Moderate Leaching into Medium';
      case LeachingRisk.high:
        return 'High Leaching (Severe Loss if Water Discarded)';
    }
  }
}

enum BioavailabilityImpact {
  increased,
  decreased,
  unchanged;

  String get label {
    switch (this) {
      case BioavailabilityImpact.increased:
        return 'Bioavailability Increased (Enhanced Absorption)';
      case BioavailabilityImpact.decreased:
        return 'Bioavailability Decreased (Degradation / Chelation)';
      case BioavailabilityImpact.unchanged:
        return 'Bioavailability Unchanged';
    }
  }
}

class NutrientTransformationRule {
  final String id;
  final String ingredientSlug; // e.g. 'spinach', 'parboiled_rice', 'chana_dal', 'millet_ragi'
  final FoodProcessingOp operation;
  final String nutrientId; // e.g. 'vitamin_c', 'folate', 'iron', 'calcium', 'resistant_starch'
  final String nutrientName;
  final double retentionMinPercent;
  final double retentionMaxPercent;
  final double concentrationChangeFactor; // Accounts for moisture loss or uptake
  final LeachingRisk leachingRisk;
  final BioavailabilityImpact bioavailabilityImpact;
  final double antinutrientReductionPercent; // e.g. phytate / oxalate breakdown
  final String? resistantStarchEffect; // e.g. 'formed_rs3'
  String? get resistantStarchImpact => resistantStarchEffect;
  final String scientificMechanism;
  final String evidenceCitation;

  const NutrientTransformationRule({
    required this.id,
    required this.ingredientSlug,
    required this.operation,
    required this.nutrientId,
    required this.nutrientName,
    required this.retentionMinPercent,
    required this.retentionMaxPercent,
    this.concentrationChangeFactor = 1.0,
    this.leachingRisk = LeachingRisk.none,
    this.bioavailabilityImpact = BioavailabilityImpact.unchanged,
    this.antinutrientReductionPercent = 0.0,
    String? resistantStarchEffect,
    String? resistantStarchImpact,
    required this.scientificMechanism,
    required this.evidenceCitation,
  }) : resistantStarchEffect = resistantStarchEffect ?? resistantStarchImpact;

  /// Average expected retention percentage
  double get averageRetention => (retentionMinPercent + retentionMaxPercent) / 2.0;
}

class FoodProcessingGuidance {
  final String ingredientName;
  final String recommendedMethod;
  final String scientificRationale;
  final List<String> stepByStepProcess;
  final Map<String, String> keyParameters; // e.g. 'Duration': '10 mins', 'Water Ratio': '1:2'
  final List<NutrientTransformationRule> nutrientTransformations;
  final List<String> safetyPrecautions;
  final String evidenceConfidence;
  final String uncertaintyDisclosure;

  const FoodProcessingGuidance({
    required this.ingredientName,
    required this.recommendedMethod,
    required this.scientificRationale,
    required this.stepByStepProcess,
    required this.keyParameters,
    required this.nutrientTransformations,
    required this.safetyPrecautions,
    required this.evidenceConfidence,
    required this.uncertaintyDisclosure,
  });
}

// ==============================================================================
// Nutrient Earth — Food Safety Hazards & Cancer Evidence Models
// Evaluates foodborne chemical, microbiological, and processing contaminants:
// - IARC Carcinogen Classifications (Group 1, 2A, 2B, 3)
// - FSSAI & Codex Alimentarius Maximum Permissible Residue Limits
// - Processing Contaminants: Acrylamide, Heterocyclic Amines (HCA), PAHs
// - Heavy Metals & Agricultural Residues: Arsenic, Lead, Pesticides
// - Exposure Assessment: Distinguishes hazard classification from actual human dose & absolute risk
// ==============================================================================

enum IarcGroup {
  group1,
  group2A,
  group2B,
  group3;

  String get label {
    switch (this) {
      case IarcGroup.group1:
        return 'IARC Group 1: Carcinogenic to Humans (Sufficient Human Evidence)';
      case IarcGroup.group2A:
        return 'IARC Group 2A: Probably Carcinogenic to Humans (Strong Mechanistic/Animal Evidence)';
      case IarcGroup.group2B:
        return 'IARC Group 2B: Possibly Carcinogenic to Humans (Limited Evidence)';
      case IarcGroup.group3:
        return 'IARC Group 3: Not Classifiable as to Carcinogenicity';
    }
  }
}

enum HazardCategory {
  mycotoxin,
  heavyMetal,
  pesticideResidue,
  processingContaminant,
  bacterialPathogen,
  chemicalMigration;

  String get displayName {
    switch (this) {
      case HazardCategory.mycotoxin:
        return 'Fungal Toxin (Mycotoxin)';
      case HazardCategory.heavyMetal:
        return 'Environmental Heavy Metal';
      case HazardCategory.pesticideResidue:
        return 'Agricultural Pesticide Residue';
      case HazardCategory.processingContaminant:
        return 'Thermal Processing Byproduct';
      case HazardCategory.bacterialPathogen:
        return 'Foodborne Pathogen';
      case HazardCategory.chemicalMigration:
        return 'Packaging / Contact Material Migration';
    }
  }
}

class FoodSafetyHazardRecord {
  final String id;
  final String hazardName;
  final HazardCategory category;
  final IarcGroup? iarcClassification;
  final String fssaiLimit;
  final String codexLimit;
  final List<String> highRiskFoodMatrices;
  final String formationOrContaminationMechanism;
  final String humanEpidemiologySummary;
  final String absoluteVsRelativeRiskExplanation;
  final List<String> practicalMitigationProtocols;

  const FoodSafetyHazardRecord({
    required this.id,
    required this.hazardName,
    required this.category,
    this.iarcClassification,
    required this.fssaiLimit,
    required this.codexLimit,
    required this.highRiskFoodMatrices,
    required this.formationOrContaminationMechanism,
    required this.humanEpidemiologySummary,
    required this.absoluteVsRelativeRiskExplanation,
    required this.practicalMitigationProtocols,
  });
}

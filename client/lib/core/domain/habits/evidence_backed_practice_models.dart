// ==============================================================================
// Nutrient Earth — Evidence-Backed Everyday Practices & Life Hacks Models
// Separates genuinely proven habits from internet wellness fads.
// Captures effect sizes, contraindications, required effort, and protocols.
// ==============================================================================

enum PracticeCategory {
  foodPreparation,
  circadianSleep,
  physicalMovement,
  metabolicHealth,
  environmentalSafety,
  recoveryStress;

  String get displayName {
    switch (this) {
      case PracticeCategory.foodPreparation:
        return 'Food Preparation & Bioavailability';
      case PracticeCategory.circadianSleep:
        return 'Circadian Rhythm & Restorative Sleep';
      case PracticeCategory.physicalMovement:
        return 'Functional Physical Movement';
      case PracticeCategory.metabolicHealth:
        return 'Metabolic Flexibility & Blood Sugar';
      case PracticeCategory.environmentalSafety:
        return 'Environmental Detox & Cookware Safety';
      case PracticeCategory.recoveryStress:
        return 'Autonomic Nervous System Recovery';
    }
  }
}

enum PracticeEvidenceGrade {
  strongMetaAnalysis,
  moderateRct,
  preliminaryCohort,
  traditionalVerified,
  unsupportedOrAnecdotal;

  String get label {
    switch (this) {
      case PracticeEvidenceGrade.strongMetaAnalysis:
        return 'Tier 1: Strongly Supported by Meta-Analyses / Cochrane';
      case PracticeEvidenceGrade.moderateRct:
        return 'Tier 2: Moderately Supported by Controlled Clinical Trials';
      case PracticeEvidenceGrade.preliminaryCohort:
        return 'Tier 3: Preliminary Observational / Cohort Evidence';
      case PracticeEvidenceGrade.traditionalVerified:
        return 'Traditional Knowledge with Corroborating Empirical Evidence';
      case PracticeEvidenceGrade.unsupportedOrAnecdotal:
        return 'Unsupported by Controlled Science / Anecdotal Only';
    }
  }
}

class EvidenceBackedPractice {
  final String id;
  final String title;
  final PracticeCategory category;
  final String targetBenefit;
  final String targetPopulation;
  final String? contraindications; // Who should avoid or modify this
  final PracticeEvidenceGrade evidenceGrade;
  final String effectSizeSummary;
  final List<String> practicalSteps;
  final String effortLevel; // 'Minimal (<5m)', 'Moderate (15-30m)', 'High'
  final String costLevel; // 'Free', 'Low Cost (<$10)', 'Investment'
  final List<String> supportingCitations;

  const EvidenceBackedPractice({
    required this.id,
    required this.title,
    required this.category,
    required this.targetBenefit,
    required this.targetPopulation,
    this.contraindications,
    required this.evidenceGrade,
    required this.effectSizeSummary,
    required this.practicalSteps,
    required this.effortLevel,
    required this.costLevel,
    required this.supportingCitations,
  });
}

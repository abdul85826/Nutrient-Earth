// ==============================================================================
// Nutrient Earth — Multidimensional Product Rating Framework Models
// Enforces 10 separate, transparent dimensions with defined scoring criteria.
// Never calculates an opaque single score that conceals low evidence or safety issues.
// ==============================================================================

class DimensionScore {
  final String dimensionKey;
  final String dimensionDisplayName;
  final double score; // 0.0 to 1.0
  final double confidence; // 0.0 to 1.0
  final String evidenceRequirement;
  final String explanation;
  final List<String> sourceReferences;
  final bool hasMissingData;

  const DimensionScore({
    required this.dimensionKey,
    required this.dimensionDisplayName,
    required this.score,
    this.confidence = 1.0,
    required this.evidenceRequirement,
    required this.explanation,
    this.sourceReferences = const [],
    this.hasMissingData = false,
  });

  Map<String, dynamic> toJson() => {
        'dimension_key': dimensionKey,
        'dimension_display_name': dimensionDisplayName,
        'score': score,
        'confidence': confidence,
        'evidence_requirement': evidenceRequirement,
        'explanation': explanation,
        'source_references': sourceReferences,
        'has_missing_data': hasMissingData,
      };
}

class MultidimensionalAssessmentProfile {
  final String id;
  final String variantId;
  final String formulationId;
  final String scoringAlgorithmVersion;
  final DimensionScore identityConfidence;
  final DimensionScore labelCompleteness;
  final DimensionScore ingredientTransparency;
  final DimensionScore nutritionalComposition;
  final DimensionScore evidenceQuality;
  final DimensionScore claimSubstantiation;
  final DimensionScore safetyScore;
  final DimensionScore manufacturingQuality;
  final DimensionScore personalSuitability;
  final DimensionScore freshnessScore;
  final List<String> unknownsAndLimitations;
  final DateTime createdAt;

  const MultidimensionalAssessmentProfile({
    required this.id,
    required this.variantId,
    required this.formulationId,
    this.scoringAlgorithmVersion = 'v1.0.0',
    required this.identityConfidence,
    required this.labelCompleteness,
    required this.ingredientTransparency,
    required this.nutritionalComposition,
    required this.evidenceQuality,
    required this.claimSubstantiation,
    required this.safetyScore,
    required this.manufacturingQuality,
    required this.personalSuitability,
    required this.freshnessScore,
    this.unknownsAndLimitations = const [],
    required this.createdAt,
  });

  List<DimensionScore> get allDimensions => [
        identityConfidence,
        labelCompleteness,
        ingredientTransparency,
        nutritionalComposition,
        evidenceQuality,
        claimSubstantiation,
        safetyScore,
        manufacturingQuality,
        personalSuitability,
        freshnessScore,
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'variant_id': variantId,
        'formulation_id': formulationId,
        'scoring_algorithm_version': scoringAlgorithmVersion,
        'dimensions': allDimensions.map((d) => d.toJson()).toList(),
        'unknowns_and_limitations': unknownsAndLimitations,
        'created_at': createdAt.toIso8601String(),
      };
}

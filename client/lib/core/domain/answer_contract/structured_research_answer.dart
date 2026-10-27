// ==============================================================================
// Nutrient Earth — Versioned Structured Answer Contract (v2026.1)
// Clean Architecture representation of goal-aware, evidence-grounded research answers.
// Backward-compatible with existing Flutter presentation modals and services.
// ==============================================================================

import '../evidence/scientific_evidence_contract.dart';
import '../nutrition/nutrition_models.dart';
import '../personalization/goal_alignment_evaluator.dart';

enum EffectivenessAssessment {
  stronglySupported,
  moderatelySupported,
  preliminaryEvidence,
  inconclusive,
  contradictedByEvidence,
}

class HealthBenefit {
  final String benefitSummary;
  final String physiologicalMechanism;
  final String evidenceStrength; // e.g. 'Consistent Clinical Trials', 'Observational'

  const HealthBenefit({
    required this.benefitSummary,
    required this.physiologicalMechanism,
    required this.evidenceStrength,
  });

  factory HealthBenefit.fromJson(Map<String, dynamic> json) {
    return HealthBenefit(
      benefitSummary: json['benefitSummary'] as String? ?? '',
      physiologicalMechanism: json['physiologicalMechanism'] as String? ?? '',
      evidenceStrength: json['evidenceStrength'] as String? ?? 'Clinical Evidence',
    );
  }

  Map<String, dynamic> toJson() => {
        'benefitSummary': benefitSummary,
        'physiologicalMechanism': physiologicalMechanism,
        'evidenceStrength': evidenceStrength,
      };
}

class SafetyInformation {
  final String? tolerableUpperIntakeLevel;
  final List<String> drugInteractions;
  final List<String> populationContraindications;
  final String generalMedicalDisclaimer;

  const SafetyInformation({
    this.tolerableUpperIntakeLevel,
    this.drugInteractions = const [],
    this.populationContraindications = const [],
    required this.generalMedicalDisclaimer,
  });

  factory SafetyInformation.fromJson(Map<String, dynamic> json) {
    return SafetyInformation(
      tolerableUpperIntakeLevel: json['tolerableUpperIntakeLevel'] as String?,
      drugInteractions: (json['drugInteractions'] as List<dynamic>?)
              ?.map((d) => d.toString())
              .toList() ??
          const [],
      populationContraindications: (json['populationContraindications'] as List<dynamic>?)
              ?.map((p) => p.toString())
              .toList() ??
          const [],
      generalMedicalDisclaimer: json['generalMedicalDisclaimer'] as String? ??
          'Nutrient Earth provides nutritional and biochemical research syntheses for educational guidance; it does not replace individualized clinical care.',
    );
  }

  Map<String, dynamic> toJson() => {
        'tolerableUpperIntakeLevel': tolerableUpperIntakeLevel,
        'drugInteractions': drugInteractions,
        'populationContraindications': populationContraindications,
        'generalMedicalDisclaimer': generalMedicalDisclaimer,
      };
}

class StructuredResearchAnswer {
  final String contractVersion;
  final String query;
  final String referenceId;
  final String domainCategory;
  final String quickAnswer;
  final String detailedExplanation;
  final EffectivenessAssessment effectivenessAssessment;
  final String evidenceBadge;
  final List<ScientificSource> sources;
  final List<ScientificClaim> claims;
  final List<HealthBenefit> healthBenefits;
  final List<String> practicalRecommendations;
  final String? studyLimitations;
  final SafetyInformation safetyInformation;
  final GoalAssessmentResult? goalAlignment;
  final NutritionAnalysisProfile? nutritionAnalysis;
  final String? comparisonCallout;
  final double? comparisonIndex;
  final String provider;
  final DateTime generatedAt;

  const StructuredResearchAnswer({
    this.contractVersion = '2026.1',
    required this.query,
    this.referenceId = 'REF-2026-NE01',
    this.domainCategory = 'Nutritional Biochemistry & Health Science',
    required this.quickAnswer,
    required this.detailedExplanation,
    this.effectivenessAssessment = EffectivenessAssessment.moderatelySupported,
    this.evidenceBadge = 'SYSTEMATIC REVIEW • PEER REVIEWED',
    this.sources = const [],
    this.claims = const [],
    this.healthBenefits = const [],
    this.practicalRecommendations = const [],
    this.studyLimitations,
    required this.safetyInformation,
    this.goalAlignment,
    this.nutritionAnalysis,
    this.comparisonCallout,
    this.comparisonIndex,
    this.provider = 'Nutrient Earth Verified Evidence Base',
    required this.generatedAt,
  });

  factory StructuredResearchAnswer.fromJson(Map<String, dynamic> json) {
    return StructuredResearchAnswer(
      contractVersion: json['contractVersion'] as String? ?? '2026.1',
      query: json['query'] as String? ?? '',
      referenceId: json['referenceId'] as String? ?? 'REF-2026-NE01',
      domainCategory: json['domainCategory'] as String? ?? 'Nutritional Biochemistry & Health Science',
      quickAnswer: json['quickAnswer'] as String? ?? json['answerSummary'] as String? ?? '',
      detailedExplanation: json['detailedExplanation'] as String? ?? json['answerSummary'] as String? ?? '',
      effectivenessAssessment: _parseEffectiveness(json['effectivenessAssessment'] as String?),
      evidenceBadge: json['evidenceBadge'] as String? ?? 'SYSTEMATIC REVIEW • PEER REVIEWED',
      sources: (json['sources'] as List<dynamic>? ?? json['citations'] as List<dynamic>?)
              ?.map((s) => ScientificSource.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
      claims: (json['claims'] as List<dynamic>?)
              ?.map((c) => ScientificClaim.fromJson(c as Map<String, dynamic>))
              .toList() ??
          const [],
      healthBenefits: (json['healthBenefits'] as List<dynamic>?)
              ?.map((b) => HealthBenefit.fromJson(b as Map<String, dynamic>))
              .toList() ??
          const [],
      practicalRecommendations: (json['practicalRecommendations'] as List<dynamic>? ??
                  json['practicalSteps'] as List<dynamic>?)
              ?.map((p) => p.toString())
              .toList() ??
          const [],
      studyLimitations: json['studyLimitations'] as String? ?? json['evidenceGap'] as String?,
      safetyInformation: json['safetyInformation'] != null
          ? SafetyInformation.fromJson(json['safetyInformation'] as Map<String, dynamic>)
          : SafetyInformation(
              generalMedicalDisclaimer: json['uncertaintyDisclaimer'] as String? ??
                  'Nutrient Earth provides nutritional research syntheses for educational guidance; it does not replace individualized medical diagnoses.',
            ),
      goalAlignment: json['goalAlignment'] != null
          ? GoalAssessmentResult.fromJson(json['goalAlignment'] as Map<String, dynamic>)
          : null,
      nutritionAnalysis: json['nutritionAnalysis'] != null
          ? NutritionAnalysisProfile.fromJson(json['nutritionAnalysis'] as Map<String, dynamic>)
          : null,
      comparisonCallout: json['comparisonCallout'] as String?,
      comparisonIndex: (json['comparisonIndex'] as num?)?.toDouble(),
      provider: json['provider'] as String? ?? 'Nutrient Earth Verified Evidence Base',
      generatedAt: json['generatedAt'] != null
          ? DateTime.tryParse(json['generatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'contractVersion': contractVersion,
        'query': query,
        'referenceId': referenceId,
        'domainCategory': domainCategory,
        'quickAnswer': quickAnswer,
        'detailedExplanation': detailedExplanation,
        'effectivenessAssessment': effectivenessAssessment.name,
        'evidenceBadge': evidenceBadge,
        'sources': sources.map((s) => s.toJson()).toList(),
        'claims': claims.map((c) => c.toJson()).toList(),
        'healthBenefits': healthBenefits.map((b) => b.toJson()).toList(),
        'practicalRecommendations': practicalRecommendations,
        'studyLimitations': studyLimitations,
        'safetyInformation': safetyInformation.toJson(),
        'goalAlignment': goalAlignment?.toJson(),
        'nutritionAnalysis': nutritionAnalysis?.toJson(),
        'comparisonCallout': comparisonCallout,
        'comparisonIndex': comparisonIndex,
        'provider': provider,
        'generatedAt': generatedAt.toIso8601String(),
        // Legacy compatibility aliases for existing UI components
        'answerSummary': detailedExplanation.isNotEmpty ? detailedExplanation : quickAnswer,
        'citations': sources.map((s) => {
              'title': s.title,
              'authorsOrJournal': s.authorsOrJournal,
              'year': s.year,
              'evidenceGrade': s.evidenceGrade,
              'url': s.url,
              'pmid': s.pmid,
            }).toList(),
        'practicalSteps': practicalRecommendations,
        'uncertaintyDisclaimer': safetyInformation.generalMedicalDisclaimer,
        'evidenceGap': studyLimitations,
      };

  static EffectivenessAssessment _parseEffectiveness(String? raw) {
    if (raw == null) return EffectivenessAssessment.moderatelySupported;
    for (final assessment in EffectivenessAssessment.values) {
      if (assessment.name.toLowerCase() == raw.toLowerCase()) return assessment;
    }
    return EffectivenessAssessment.moderatelySupported;
  }
}

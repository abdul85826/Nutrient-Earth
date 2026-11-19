// ==============================================================================
// Nutrient Earth — Governed Recommendation Engine Models
// Implements the 12-stage governed recommendation decision pipeline across
// Food, Supplements, Medicines, Ayurveda, Exercise, Lifestyle, and Consumer Products.
// ==============================================================================

import 'package:uuid/uuid.dart';

enum RecommendationDomain {
  food,
  supplement,
  medicine,
  ayurveda,
  exercise,
  lifestyle,
  consumerGood;

  String get value => name;

  static RecommendationDomain fromString(String val) {
    return RecommendationDomain.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase().replaceAll('_', ''),
      orElse: () => RecommendationDomain.food,
    );
  }
}

enum RecommendationStage {
  intentRecognition,
  personalContextVerification,
  constraintsValidation,
  candidateDiscovery,
  identityResolution,
  evidenceAssessment,
  safetyEvaluation,
  suitabilityAnalysis,
  alternativesComparison,
  recommendationSynthesis,
  explanationFormulation,
  outcomeRegistration;

  String get value => name;
}

class AlternativeEvaluationItem {
  final String candidateId;
  final String candidateName;
  final double suitabilityScore; // 0.0 to 1.0
  final bool isAccepted;
  final String? rejectionReason;
  final List<String> safetyConcerns;

  const AlternativeEvaluationItem({
    required this.candidateId,
    required this.candidateName,
    required this.suitabilityScore,
    required this.isAccepted,
    this.rejectionReason,
    this.safetyConcerns = const [],
  });

  Map<String, dynamic> toJson() => {
        'candidate_id': candidateId,
        'candidate_name': candidateName,
        'suitability_score': suitabilityScore,
        'is_accepted': isAccepted,
        'rejection_reason': rejectionReason,
        'safety_concerns': safetyConcerns,
      };
}

class GovernedRecommendationResult {
  final String id;
  final String traceId;
  final String userId;
  final RecommendationDomain domain;
  final String userIntent;
  final String recommendedEntityId;
  final String recommendedEntityName;
  final List<AlternativeEvaluationItem> alternatives;
  final String decisionRationale;
  final List<String> scientificCitations;
  final List<String> safetyRulesApplied;
  final List<String> personalConstraintsSatisfied;
  final String uncertaintyDisclosure;
  final String safetyPolicyVersion;
  final String scoringAlgorithmVersion;
  final DateTime createdAt;

  const GovernedRecommendationResult({
    required this.id,
    required this.traceId,
    required this.userId,
    required this.domain,
    required this.userIntent,
    required this.recommendedEntityId,
    required this.recommendedEntityName,
    required this.alternatives,
    required this.decisionRationale,
    this.scientificCitations = const [],
    this.safetyRulesApplied = const [],
    this.personalConstraintsSatisfied = const [],
    required this.uncertaintyDisclosure,
    this.safetyPolicyVersion = 'v3.2.0',
    this.scoringAlgorithmVersion = 'v1.0.0',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'trace_id': traceId,
        'user_id': userId,
        'domain': domain.value,
        'user_intent': userIntent,
        'recommended_entity_id': recommendedEntityId,
        'recommended_entity_name': recommendedEntityName,
        'alternatives': alternatives.map((a) => a.toJson()).toList(),
        'decision_rationale': decisionRationale,
        'scientific_citations': scientificCitations,
        'safety_rules_applied': safetyRulesApplied,
        'personal_constraints_satisfied': personalConstraintsSatisfied,
        'uncertainty_disclosure': uncertaintyDisclosure,
        'safety_policy_version': safetyPolicyVersion,
        'scoring_algorithm_version': scoringAlgorithmVersion,
        'created_at': createdAt.toIso8601String(),
      };
}

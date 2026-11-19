// ==============================================================================
// Nutrient Earth — Structured Decision Traceability Models
// Captures verifiable decision records for every important recommendation:
// - Context snapshots, state versions, safety rules, and preferences applied
// - Alternatives considered with explicit rejection reasons
// - ZERO private chain-of-thought stored; human-auditable explanations only
// ==============================================================================

import 'package:uuid/uuid.dart';

class AlternativeConsidered {
  final String name;
  final String description;
  final String rejectionReason;
  final double confidenceScore;

  const AlternativeConsidered({
    required this.name,
    required this.description,
    required this.rejectionReason,
    this.confidenceScore = 0.5,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'rejection_reason': rejectionReason,
      'confidence_score': confidenceScore,
    };
  }

  factory AlternativeConsidered.fromJson(Map<String, dynamic> json) {
    return AlternativeConsidered(
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      rejectionReason: json['rejection_reason'] as String? ?? '',
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.5,
    );
  }
}

class DecisionRecord {
  final String id;
  final String traceId;
  final String userId;
  final String recommendationId;
  final String userObjective;
  final Map<String, dynamic> contextSnapshotRef;
  final String personalStateVersion;
  final List<String> retrievedEvidenceRefs;
  final List<String> applicableSafetyRules;
  final List<String> dietaryConstraints;
  final List<String> relevantPreferences;
  final Map<String, dynamic> calculationReferences;
  final Map<String, dynamic> selectedRecommendation;
  final List<AlternativeConsidered> alternativesConsidered;
  final double confidenceScore;
  final String uncertaintyDisclosure;
  final String decisionPolicyVersion;
  final String? modelExecutionRef;
  final String finalDeliveredOutput;
  final DateTime createdAt;

  const DecisionRecord({
    required this.id,
    required this.traceId,
    required this.userId,
    required this.recommendationId,
    required this.userObjective,
    this.contextSnapshotRef = const {},
    required this.personalStateVersion,
    this.retrievedEvidenceRefs = const [],
    this.applicableSafetyRules = const [],
    this.dietaryConstraints = const [],
    this.relevantPreferences = const [],
    this.calculationReferences = const {},
    required this.selectedRecommendation,
    this.alternativesConsidered = const [],
    this.confidenceScore = 1.0,
    required this.uncertaintyDisclosure,
    this.decisionPolicyVersion = '2026.11.1',
    this.modelExecutionRef,
    required this.finalDeliveredOutput,
    required this.createdAt,
  });

  factory DecisionRecord.create({
    required String traceId,
    required String userId,
    required String recommendationId,
    required String userObjective,
    Map<String, dynamic> contextSnapshotRef = const {},
    required String personalStateVersion,
    List<String> retrievedEvidenceRefs = const [],
    List<String> applicableSafetyRules = const [],
    List<String> dietaryConstraints = const [],
    List<String> relevantPreferences = const [],
    Map<String, dynamic> calculationReferences = const {},
    required Map<String, dynamic> selectedRecommendation,
    List<AlternativeConsidered> alternativesConsidered = const [],
    double confidenceScore = 1.0,
    required String uncertaintyDisclosure,
    String decisionPolicyVersion = '2026.11.1',
    String? modelExecutionRef,
    required String finalDeliveredOutput,
  }) {
    return DecisionRecord(
      id: const Uuid().v4(),
      traceId: traceId,
      userId: userId,
      recommendationId: recommendationId,
      userObjective: userObjective,
      contextSnapshotRef: contextSnapshotRef,
      personalStateVersion: personalStateVersion,
      retrievedEvidenceRefs: retrievedEvidenceRefs,
      applicableSafetyRules: applicableSafetyRules,
      dietaryConstraints: dietaryConstraints,
      relevantPreferences: relevantPreferences,
      calculationReferences: calculationReferences,
      selectedRecommendation: selectedRecommendation,
      alternativesConsidered: alternativesConsidered,
      confidenceScore: confidenceScore,
      uncertaintyDisclosure: uncertaintyDisclosure,
      decisionPolicyVersion: decisionPolicyVersion,
      modelExecutionRef: modelExecutionRef,
      finalDeliveredOutput: finalDeliveredOutput,
      createdAt: DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trace_id': traceId,
      'user_id': userId,
      'recommendation_id': recommendationId,
      'user_objective': userObjective,
      'context_snapshot_ref': contextSnapshotRef,
      'personal_state_version': personalStateVersion,
      'retrieved_evidence_refs': retrievedEvidenceRefs,
      'applicable_safety_rules': applicableSafetyRules,
      'dietary_constraints': dietaryConstraints,
      'relevant_preferences': relevantPreferences,
      'calculation_references': calculationReferences,
      'selected_recommendation': selectedRecommendation,
      'alternatives_considered': alternativesConsidered.map((a) => a.toJson()).toList(),
      'confidence_score': confidenceScore,
      'uncertainty_disclosure': uncertaintyDisclosure,
      'decision_policy_version': decisionPolicyVersion,
      'model_execution_ref': modelExecutionRef,
      'final_delivered_output': finalDeliveredOutput,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

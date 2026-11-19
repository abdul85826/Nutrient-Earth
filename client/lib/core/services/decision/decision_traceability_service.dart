// ==============================================================================
// Nutrient Earth — Structured Decision Traceability Service
// Records verifiable decision records for every important recommendation:
// - Context snapshots, state versions, safety rules, and preferences applied
// - Alternatives considered with explicit rejection reasons
// - ZERO private chain-of-thought stored; human-auditable explanations only
// ==============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_config.dart';
import '../../domain/decision/decision_record_models.dart';

abstract class DecisionTraceabilityService {
  Future<DecisionRecord> recordDecision({
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
  });

  Future<DecisionRecord?> getDecisionRecord(String decisionId);

  Future<List<DecisionRecord>> getDecisionsForUser(String userId);
}

class DefaultDecisionTraceabilityService implements DecisionTraceabilityService {
  final SupabaseClient? _supabase;

  // In-memory store for fast lookup and tests
  final Map<String, DecisionRecord> _decisionCache = {};

  DefaultDecisionTraceabilityService({SupabaseClient? supabase})
      : _supabase = supabase ?? (SupabaseConfig.isInitialized ? Supabase.instance.client : null);

  @override
  Future<DecisionRecord> recordDecision({
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
  }) async {
    final record = DecisionRecord.create(
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
    );

    _decisionCache[record.id] = record;

    if (_supabase != null) {
      try {
        await _supabase!.from('decision_records').insert(record.toJson());
      } catch (e) {
        debugPrint('[DecisionTraceabilityService] Supabase insert decision record error: $e');
      }
    }

    return record;
  }

  @override
  Future<DecisionRecord?> getDecisionRecord(String decisionId) async {
    if (_decisionCache.containsKey(decisionId)) {
      return _decisionCache[decisionId];
    }

    if (_supabase != null) {
      try {
        final data = await _supabase!
            .from('decision_records')
            .select()
            .eq('id', decisionId)
            .maybeSingle();
        if (data != null) {
          final record = DecisionRecord(
            id: data['id'] as String,
            traceId: data['trace_id'] as String,
            userId: data['user_id'] as String,
            recommendationId: data['recommendation_id'] as String,
            userObjective: data['user_objective'] as String,
            contextSnapshotRef: (data['context_snapshot_ref'] as Map<String, dynamic>?) ?? {},
            personalStateVersion: data['personal_state_version'] as String,
            retrievedEvidenceRefs: List<String>.from(data['retrieved_evidence_refs'] ?? []),
            applicableSafetyRules: List<String>.from(data['applicable_safety_rules'] ?? []),
            dietaryConstraints: List<String>.from(data['dietary_constraints'] ?? []),
            relevantPreferences: List<String>.from(data['relevant_preferences'] ?? []),
            calculationReferences: (data['calculation_references'] as Map<String, dynamic>?) ?? {},
            selectedRecommendation: (data['selected_recommendation'] as Map<String, dynamic>?) ?? {},
            alternativesConsidered: ((data['alternatives_considered'] as List?) ?? [])
                .map((a) => AlternativeConsidered.fromJson(a as Map<String, dynamic>))
                .toList(),
            confidenceScore: (data['confidence_score'] as num?)?.toDouble() ?? 1.0,
            uncertaintyDisclosure: data['uncertainty_disclosure'] as String,
            decisionPolicyVersion: data['decision_policy_version'] as String,
            modelExecutionRef: data['model_execution_ref'] as String?,
            finalDeliveredOutput: data['final_delivered_output'] as String,
            createdAt: DateTime.parse(data['created_at'] as String),
          );
          _decisionCache[record.id] = record;
          return record;
        }
      } catch (e) {
        debugPrint('[DecisionTraceabilityService] Supabase fetch decision record error: $e');
      }
    }

    return null;
  }

  @override
  Future<List<DecisionRecord>> getDecisionsForUser(String userId) async {
    if (_supabase != null) {
      try {
        final data = await _supabase!
            .from('decision_records')
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false);
        return (data as List).map((d) => DecisionRecord(
          id: d['id'] as String,
          traceId: d['trace_id'] as String,
          userId: d['user_id'] as String,
          recommendationId: d['recommendation_id'] as String,
          userObjective: d['user_objective'] as String,
          contextSnapshotRef: (d['context_snapshot_ref'] as Map<String, dynamic>?) ?? {},
          personalStateVersion: d['personal_state_version'] as String,
          retrievedEvidenceRefs: List<String>.from(d['retrieved_evidence_refs'] ?? []),
          applicableSafetyRules: List<String>.from(d['applicable_safety_rules'] ?? []),
          dietaryConstraints: List<String>.from(d['dietary_constraints'] ?? []),
          relevantPreferences: List<String>.from(d['relevant_preferences'] ?? []),
          calculationReferences: (d['calculation_references'] as Map<String, dynamic>?) ?? {},
          selectedRecommendation: (d['selected_recommendation'] as Map<String, dynamic>?) ?? {},
          alternativesConsidered: ((d['alternatives_considered'] as List?) ?? [])
              .map((a) => AlternativeConsidered.fromJson(a as Map<String, dynamic>))
              .toList(),
          confidenceScore: (d['confidence_score'] as num?)?.toDouble() ?? 1.0,
          uncertaintyDisclosure: d['uncertainty_disclosure'] as String,
          decisionPolicyVersion: d['decision_policy_version'] as String,
          modelExecutionRef: d['model_execution_ref'] as String?,
          finalDeliveredOutput: d['final_delivered_output'] as String,
          createdAt: DateTime.parse(d['created_at'] as String),
        )).toList();
      } catch (e) {
        debugPrint('[DecisionTraceabilityService] Supabase fetch decisions list error: $e');
      }
    }

    return _decisionCache.values.where((d) => d.userId == userId).toList();
  }
}

final decisionTraceabilityServiceProvider = Provider<DecisionTraceabilityService>((ref) {
  return DefaultDecisionTraceabilityService();
});

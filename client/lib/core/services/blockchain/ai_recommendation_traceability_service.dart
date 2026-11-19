// ==============================================================================
// Nutrient Earth — AI Recommendation Traceability Service
// Cryptographically binds AI recommendations and decision records to blockchain commitments.
// Strict zero-PII and zero private chain-of-thought (CoT) boundary.
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/blockchain/blockchain_trust_models.dart';
import '../../domain/decision/decision_record_models.dart';
import 'blockchain_trust_service.dart';

abstract class AiRecommendationTraceabilityService {
  Future<CryptographicCommitment> anchorDecisionRecord({
    required DecisionRecord decision,
    String? modelIdentifier,
    String? promptVersion,
  });
}

class DefaultAiRecommendationTraceabilityService implements AiRecommendationTraceabilityService {
  final BlockchainTrustService _trustService;

  DefaultAiRecommendationTraceabilityService({BlockchainTrustService? trustService})
      : _trustService = trustService ?? DefaultBlockchainTrustService();

  @override
  Future<CryptographicCommitment> anchorDecisionRecord({
    required DecisionRecord decision,
    String? modelIdentifier,
    String? promptVersion,
  }) async {
    // Non-sensitive metadata digest only — zero PII, zero private CoT
    final payload = {
      'decision_id': decision.id,
      'trace_id': decision.traceId,
      'objective_category': decision.userObjective,
      'safety_rules_applied': decision.applicableSafetyRules,
      'citations_count': decision.retrievedEvidenceRefs.length,
      'alternatives_evaluated_count': decision.alternativesConsidered.length,
      'model_identifier': modelIdentifier ?? 'nutrient-earth-clinical-core',
      'prompt_version': promptVersion ?? 'v2.4.0',
      'decision_timestamp': decision.createdAt.toIso8601String(),
    };

    return _trustService.createCommitment(
      recordType: 'ai_recommendation',
      recordId: decision.id,
      nonSensitivePayload: payload,
      domainSeparator: 'NUTRIENT_EARTH_RECOMMENDATION_V1',
    );
  }
}

final aiRecommendationTraceabilityServiceProvider = Provider<AiRecommendationTraceabilityService>((ref) {
  final trust = ref.watch(blockchainTrustServiceProvider);
  return DefaultAiRecommendationTraceabilityService(trustService: trust);
});

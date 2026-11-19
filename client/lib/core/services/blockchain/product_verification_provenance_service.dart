// ==============================================================================
// Nutrient Earth — Product Verification Provenance Service
// Anchors finalized multidimensional product quality, safety, and label assessments.
// Preserves historical versions without overwriting when formulations change.
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/blockchain/blockchain_trust_models.dart';
import '../../domain/product_verification/product_verification_models.dart';
import '../../domain/ratings/multidimensional_rating_models.dart';
import 'blockchain_trust_service.dart';

abstract class ProductVerificationProvenanceService {
  Future<CryptographicCommitment> anchorProductAssessment({
    required ProductIdentityCandidate candidate,
    required MultidimensionalAssessmentProfile assessment,
    String? previousVersionId,
  });
}

class DefaultProductVerificationProvenanceService implements ProductVerificationProvenanceService {
  final BlockchainTrustService _trustService;

  DefaultProductVerificationProvenanceService({BlockchainTrustService? trustService})
      : _trustService = trustService ?? DefaultBlockchainTrustService();

  @override
  Future<CryptographicCommitment> anchorProductAssessment({
    required ProductIdentityCandidate candidate,
    required MultidimensionalAssessmentProfile assessment,
    String? previousVersionId,
  }) async {
    // Build non-sensitive canonical payload
    final payload = {
      'product_id': candidate.product.id,
      'canonical_name': candidate.product.canonicalName,
      'brand_name': candidate.product.brandName ?? 'Independent',
      'variant_name': candidate.variant.variantName,
      'formulation_version': candidate.formulation.formulationVersion,
      'packaging_version': candidate.formulation.packagingVersion ?? '',
      'scoring_algorithm_version': assessment.scoringAlgorithmVersion,
      'identity_confidence': assessment.identityConfidence.score,
      'safety_score': assessment.safetyScore.score,
      'evidence_quality_score': assessment.evidenceQuality.score,
      'ingredient_transparency_score': assessment.ingredientTransparency.score,
      'previous_version_id': previousVersionId ?? '',
      'assessment_timestamp': assessment.createdAt.toIso8601String(),
    };

    return _trustService.createCommitment(
      recordType: 'product_verification',
      recordId: '${candidate.product.id}_${candidate.formulation.formulationVersion}',
      nonSensitivePayload: payload,
      recordVersion: candidate.formulation.formulationVersion,
      domainSeparator: 'NUTRIENT_EARTH_PRODUCT_${assessment.scoringAlgorithmVersion}',
    );
  }
}

final productVerificationProvenanceServiceProvider = Provider<ProductVerificationProvenanceService>((ref) {
  final trust = ref.watch(blockchainTrustServiceProvider);
  return DefaultProductVerificationProvenanceService(trustService: trust);
});

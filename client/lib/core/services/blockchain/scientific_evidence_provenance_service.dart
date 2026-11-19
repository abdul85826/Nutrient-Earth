// ==============================================================================
// Nutrient Earth — Scientific Evidence Provenance Service
// Anchors finalized clinical research studies, meta-analyses, and claims.
// Supports versioning, retractions, and independent cryptographic verification.
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/blockchain/blockchain_trust_models.dart';
import 'blockchain_trust_service.dart';

abstract class ScientificEvidenceProvenanceService {
  Future<CryptographicCommitment> anchorEvidenceDossier({
    required String studyId,
    required String paperTitle,
    String? doi,
    String? pmid,
    required String studyDesign,
    required String primaryOutcome,
    String? effectSize,
    String extractionVersion = 'v1.0.0',
    bool isRetracted = false,
  });
}

class DefaultScientificEvidenceProvenanceService implements ScientificEvidenceProvenanceService {
  final BlockchainTrustService _trustService;

  DefaultScientificEvidenceProvenanceService({BlockchainTrustService? trustService})
      : _trustService = trustService ?? DefaultBlockchainTrustService();

  @override
  Future<CryptographicCommitment> anchorEvidenceDossier({
    required String studyId,
    required String paperTitle,
    String? doi,
    String? pmid,
    required String studyDesign,
    required String primaryOutcome,
    String? effectSize,
    String extractionVersion = 'v1.0.0',
    bool isRetracted = false,
  }) async {
    // Non-sensitive payload with canonical field names
    final payload = {
      'study_id': studyId,
      'paper_title': paperTitle,
      'doi': doi ?? '',
      'pmid': pmid ?? '',
      'study_design': studyDesign,
      'primary_outcome': primaryOutcome,
      'effect_size': effectSize ?? '',
      'extraction_version': extractionVersion,
      'is_retracted': isRetracted,
    };

    return _trustService.createCommitment(
      recordType: 'scientific_evidence',
      recordId: studyId,
      nonSensitivePayload: payload,
      recordVersion: extractionVersion,
      domainSeparator: 'NUTRIENT_EARTH_EVIDENCE_$extractionVersion',
    );
  }
}

final scientificEvidenceProvenanceServiceProvider = Provider<ScientificEvidenceProvenanceService>((ref) {
  final trust = ref.watch(blockchainTrustServiceProvider);
  return DefaultScientificEvidenceProvenanceService(trustService: trust);
});

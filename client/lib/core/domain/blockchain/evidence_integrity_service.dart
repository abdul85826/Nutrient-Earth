// ==============================================================================
// Nutrient Earth — Evidence Integrity & Provenance Service
// Coordinates canonical manifest generation, Merkle tree batching,
// blockchain anchoring, and independent proof verification.
// RESILIENCE RULE: Outages on the blockchain or network NEVER block research answers.
// ==============================================================================

import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

import '../../config/supabase_config.dart';
import '../answer_contract/structured_research_answer.dart';
import 'blockchain_anchor_provider.dart';
import 'merkle_tree.dart';
import 'mock_testnet_anchor_provider.dart';
import 'provenance_manifest.dart';

class ResearchProvenanceDossier {
  final CanonicalProvenanceManifest manifest;
  final String manifestHash;
  final String merkleRoot;
  final MerkleProof merkleProof;
  final AnchorTransactionResult anchorResult;
  final AnchorStatus status;
  final DateTime createdAt;

  const ResearchProvenanceDossier({
    required this.manifest,
    required this.manifestHash,
    required this.merkleRoot,
    required this.merkleProof,
    required this.anchorResult,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'manifest': manifest.toJson(),
        'manifest_hash': manifestHash,
        'merkle_root': merkleRoot,
        'merkle_proof': merkleProof.toJson(),
        'anchor_result': anchorResult.toJson(),
        'status': status.name,
        'created_at': createdAt.toIso8601String(),
      };

  factory ResearchProvenanceDossier.fromJson(Map<String, dynamic> json) {
    return ResearchProvenanceDossier(
      manifest: CanonicalProvenanceManifest.fromJson(json['manifest'] as Map<String, dynamic>),
      manifestHash: json['manifest_hash'] as String? ?? '',
      merkleRoot: json['merkle_root'] as String? ?? '',
      merkleProof: MerkleProof.fromJson(json['merkle_proof'] as Map<String, dynamic>),
      anchorResult: AnchorTransactionResult.fromJson(json['anchor_result'] as Map<String, dynamic>),
      status: AnchorStatus.fromString(json['status'] as String? ?? 'pending'),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    );
  }
}

class EvidenceIntegrityService {
  final BlockchainAnchorProvider anchorProvider;

  EvidenceIntegrityService({
    BlockchainAnchorProvider? anchorProvider,
  }) : anchorProvider = anchorProvider ?? MockTestnetAnchorProvider();

  /// Creates a canonical manifest, computes Merkle proof, and anchors to chain.
  /// Never throws: fails gracefully to pending/failed state if anchoring fails or times out.
  Future<ResearchProvenanceDossier> generateAndAnchorManifest({
    required StructuredResearchAnswer answer,
    bool containsPersonalHealthData = false,
  }) async {
    final now = DateTime.now().toUtc();

    // 1. Extract claim hashes
    final claimHashes = <String>[];
    for (final claim in answer.claims) {
      final claimBytes = utf8.encode(claim.claimText.trim());
      claimHashes.add(sha256.convert(claimBytes).toString());
    }
    if (claimHashes.isEmpty) {
      // Default to quickAnswer hash if claims array was empty
      claimHashes.add(sha256.convert(utf8.encode(answer.quickAnswer.trim())).toString());
    }

    // 2. Extract verified scientific source identifiers (PMID / DOI / SHA-256 Title Hash)
    final sourceIdentifiers = <String>[];
    for (final src in answer.sources) {
      if (src.pmid != null && src.pmid!.isNotEmpty) {
        sourceIdentifiers.add('PMID:${src.pmid!}');
      } else if (src.doi != null && src.doi!.isNotEmpty) {
        sourceIdentifiers.add('DOI:${src.doi!}');
      } else {
        final titleHash = sha256.convert(utf8.encode(src.title.trim())).toString().substring(0, 16);
        sourceIdentifiers.add('TITLE:$titleHash');
      }
    }

    // 3. Map evidence tier
    final evidenceTier = _mapAssessmentToTier(answer.effectivenessAssessment);

    // 4. Construct canonical manifest (STRICTLY NO PII: use domainCategory to eliminate prompt leak risk)
    final manifest = CanonicalProvenanceManifest(
      inquiryReferenceId: answer.referenceId,
      querySanitized: answer.domainCategory,
      domainCategory: answer.domainCategory,
      evidenceTier: evidenceTier,
      claimHashes: claimHashes,
      sourceIdentifiers: sourceIdentifiers,
      generatedAtUtc: now,
    );

    final manifestHash = manifest.computeManifestHash();

    // 5. Construct Merkle tree (single leaf builds valid tree per RFC-6962)
    final tree = MerkleTree.compute([manifestHash]);
    final proof = tree.generateProof(0);
    final merkleRoot = tree.root;

    // 6. Anchor to blockchain with 4-second bounded timeout and graceful exception handling
    AnchorTransactionResult anchorResult;
    AnchorStatus status;

    try {
      anchorResult = await anchorProvider.submitBatchAnchor(
        merkleRoot: merkleRoot,
        manifestHashes: [manifestHash],
        metadata: {
          'inquiry_ref': answer.referenceId,
          'evidence_tier': evidenceTier.name,
          'claim_count': claimHashes.length,
          'source_count': sourceIdentifiers.length,
        },
      ).timeout(const Duration(seconds: 4));
      status = anchorResult.isSuccess ? AnchorStatus.anchored : AnchorStatus.failed;
    } catch (e) {
      anchorResult = AnchorTransactionResult(
        isSuccess: false,
        chainId: anchorProvider.chainId,
        errorMessage: 'Anchor timeout or error: $e',
      );
      status = AnchorStatus.failed;
    }

    return ResearchProvenanceDossier(
      manifest: manifest,
      manifestHash: manifestHash,
      merkleRoot: merkleRoot,
      merkleProof: proof,
      anchorResult: anchorResult,
      status: status,
      createdAt: now,
    );
  }

  /// Persists validated dossier linkage to Supabase once conversation and message exist.
  /// Bypasses persistence if the inquiry contains personal health data.
  Future<void> persistDossierLinkage({
    required ResearchProvenanceDossier dossier,
    required String conversationId,
    String? messageId,
    bool containsPersonalHealthData = false,
  }) async {
    if (containsPersonalHealthData) return;

    final client = SupabaseConfig.client;
    if (client == null) return;

    final user = client.auth.currentUser;
    if (user == null) return;

    try {
      await client.from('research_provenance_manifests').insert({
        'user_id': user.id,
        'conversation_id': conversationId,
        'message_id': messageId,
        'inquiry_reference_id': dossier.manifest.inquiryReferenceId,
        'query_sanitized': dossier.manifest.querySanitized,
        'domain_category': dossier.manifest.domainCategory,
        'evidence_tier': dossier.manifest.evidenceTier.name,
        'manifest_hash': dossier.manifestHash,
        'merkle_root': dossier.merkleRoot,
        'merkle_proof': dossier.merkleProof.toJson(),
        'claim_count': dossier.manifest.claimHashes.length,
        'source_count': dossier.manifest.sourceIdentifiers.length,
        'non_sensitive_manifest': dossier.manifest.toJson(),
        'anchor_status': dossier.status.name,
        'chain_id': dossier.anchorResult.chainId,
        'contract_or_anchor_address': dossier.anchorResult.contractAddress,
        'tx_hash': dossier.anchorResult.txHash,
        'block_number': dossier.anchorResult.blockNumber,
        'anchored_at': dossier.anchorResult.anchoredAt?.toIso8601String(),
      });
    } catch (_) {
      // Offline or network error: never throw to keep research available
    }
  }

  /// Independently verifies a research provenance dossier.
  Future<ProofVerificationResult> verifyDossier(ResearchProvenanceDossier dossier) async {
    return anchorProvider.verifyOnChainProof(
      merkleRoot: dossier.merkleRoot,
      proof: dossier.merkleProof,
      manifestHash: dossier.manifestHash,
      txHash: dossier.anchorResult.txHash,
    );
  }

  EvidenceTier _mapAssessmentToTier(EffectivenessAssessment assessment) {
    switch (assessment) {
      case EffectivenessAssessment.stronglySupported:
        return EvidenceTier.strong;
      case EffectivenessAssessment.moderatelySupported:
        return EvidenceTier.moderate;
      case EffectivenessAssessment.preliminaryEvidence:
        return EvidenceTier.limited;
      case EffectivenessAssessment.inconclusive:
        return EvidenceTier.insufficient;
      case EffectivenessAssessment.contradictedByEvidence:
        return EvidenceTier.conflicting;
    }
  }
}

final evidenceIntegrityServiceProvider = Provider<EvidenceIntegrityService>((ref) {
  return EvidenceIntegrityService();
});

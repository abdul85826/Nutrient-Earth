// ==============================================================================
// Nutrient Earth — Blockchain Evidence Integrity Test Suite
// Verifies RFC-8785 canonical manifest serialization, SHA-256 cryptographic hashing,
// Merkle tree root calculation, Merkle inclusion proof verification, tamper detection,
// testnet blockchain anchoring, and zero-PII compliance.
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/domain/answer_contract/structured_research_answer.dart';
import 'package:nutrient_earth_client/core/domain/blockchain/blockchain_anchor_provider.dart';
import 'package:nutrient_earth_client/core/domain/blockchain/evidence_integrity_service.dart';
import 'package:nutrient_earth_client/core/domain/blockchain/merkle_tree.dart';
import 'package:nutrient_earth_client/core/domain/blockchain/mock_testnet_anchor_provider.dart';
import 'package:nutrient_earth_client/core/domain/blockchain/provenance_manifest.dart';
import 'package:nutrient_earth_client/core/domain/evidence/scientific_evidence_contract.dart';

void main() {
  group('Phase 4: Canonical Research Provenance Manifest & Hashing', () {
    test('Canonical manifest produces deterministic sorted JSON and invariant hash', () {
      final manifest1 = CanonicalProvenanceManifest(
        inquiryReferenceId: 'REF-2026-NE884',
        querySanitized: 'Magnesium bisglycinate bioavailability for sleep',
        domainCategory: 'Biochemical Pharmacology',
        evidenceTier: EvidenceTier.strong,
        claimHashes: const [
          '4a5b6c7d8e9f0123456789abcdef0123456789abcdef0123456789abcdef0123',
          '11223344556677889900aabbccddeeff11223344556677889900aabbccddeeff',
        ],
        sourceIdentifiers: const ['PMID:11794633', 'PMID:23853635'],
        generatedAtUtc: DateTime.utc(2026, 11, 3, 12, 0, 0),
      );

      final manifest2 = CanonicalProvenanceManifest(
        inquiryReferenceId: 'REF-2026-NE884',
        querySanitized: 'Magnesium bisglycinate bioavailability for sleep',
        domainCategory: 'Biochemical Pharmacology',
        evidenceTier: EvidenceTier.strong,
        claimHashes: const [
          // Order swapped in input
          '11223344556677889900aabbccddeeff11223344556677889900aabbccddeeff',
          '4a5b6c7d8e9f0123456789abcdef0123456789abcdef0123456789abcdef0123',
        ],
        sourceIdentifiers: const [
          // Order swapped in input
          'PMID:23853635',
          'PMID:11794633',
        ],
        generatedAtUtc: DateTime.utc(2026, 11, 3, 12, 0, 0),
      );

      // Both must serialize to the exact same canonical JSON string
      expect(manifest1.toCanonicalJson(), equals(manifest2.toCanonicalJson()));

      // Manifest hashes must be strictly identical (SHA-256)
      final hash1 = manifest1.computeManifestHash();
      final hash2 = manifest2.computeManifestHash();
      expect(hash1, equals(hash2));
      expect(hash1.length, equals(64)); // 32-byte hex string
    });

    test('Strict Privacy Check: Canonical manifest contains ZERO PII', () {
      final manifest = CanonicalProvenanceManifest(
        inquiryReferenceId: 'REF-2026-NE884',
        querySanitized: 'Optimal leucine threshold for protein synthesis',
        domainCategory: 'Nutritional Biochemistry',
        evidenceTier: EvidenceTier.strong,
        claimHashes: const ['a1b2c3d4e5f6'],
        sourceIdentifiers: const ['PMID:24299726'],
        generatedAtUtc: DateTime.utc(2026, 11, 3, 12, 0, 0),
      );

      final jsonString = manifest.toCanonicalJson().toLowerCase();

      // Ensure no identity, email, session token, or health records are in manifest
      expect(jsonString.contains('user_id'), isFalse);
      expect(jsonString.contains('email'), isFalse);
      expect(jsonString.contains('bearer'), isFalse);
      expect(jsonString.contains('token'), isFalse);
      expect(jsonString.contains('password'), isFalse);
      expect(jsonString.contains('sarah'), isFalse);
    });
  });

  group('Phase 4: Cryptographic Merkle Tree & Inclusion Proofs', () {
    test('Single leaf Merkle tree correctly computes root equal to leaf', () {
      const leaf = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';
      final tree = MerkleTree.compute([leaf]);

      expect(tree.root, equals(leaf));
      final proof = tree.generateProof(0);
      expect(proof.verify(), isTrue);
    });

    test('Multi-leaf Merkle tree generates verifiable inclusion proofs for all leaves', () {
      final leaves = [
        '1111111111111111111111111111111111111111111111111111111111111111',
        '2222222222222222222222222222222222222222222222222222222222222222',
        '3333333333333333333333333333333333333333333333333333333333333333',
        '4444444444444444444444444444444444444444444444444444444444444444',
      ];

      final tree = MerkleTree.compute(leaves);
      expect(tree.root, isNotEmpty);
      expect(tree.root.length, equals(64));

      // Verify inclusion proof for each of the 4 leaves
      for (int i = 0; i < leaves.length; i++) {
        final proof = tree.generateProof(i);
        expect(proof.leafHash, equals(leaves[i]));
        expect(proof.expectedRoot, equals(tree.root));
        expect(proof.verify(), isTrue, reason: 'Leaf $i failed verification');
      }
    });

    test('Odd-number leaves correctly split per RFC-6962 power-of-two rule', () {
      final leaves = [
        'aaaa1111aaaa1111aaaa1111aaaa1111aaaa1111aaaa1111aaaa1111aaaa1111',
        'bbbb2222bbbb2222bbbb2222bbbb2222bbbb2222bbbb2222bbbb2222bbbb2222',
        'cccc3333cccc3333cccc3333cccc3333cccc3333cccc3333cccc3333cccc3333',
      ];

      final tree = MerkleTree.compute(leaves);
      expect(tree.root, isNotEmpty);

      // Verify all 3 leaves evaluate to root via computeRoot and verify
      for (int i = 0; i < 3; i++) {
        final proof = tree.generateProof(i);
        expect(proof.computeRoot(), equals(tree.root));
        expect(proof.verify(), isTrue);
      }
    });

    test('Tampered leaf or audit path is definitively rejected by MerkleProof.verify()', () {
      final leaves = [
        'leaf1leaf1leaf1leaf1leaf1leaf1leaf1leaf1leaf1leaf1leaf1leaf1leaf1le',
        'leaf2leaf2leaf2leaf2leaf2leaf2leaf2leaf2leaf2leaf2leaf2leaf2leaf2le',
      ];

      final tree = MerkleTree.compute(leaves);
      final validProof = tree.generateProof(0);

      expect(validProof.verify(), isTrue);

      // 1. Tamper leaf hash
      final tamperedLeafProof = MerkleProof(
        leafHash: 'tamperedleaftamperedleaftamperedleaftamperedleaftamperedleaftampe',
        leafIndex: validProof.leafIndex,
        auditPath: validProof.auditPath,
        expectedRoot: validProof.expectedRoot,
      );
      expect(tamperedLeafProof.verify(), isFalse);

      // 2. Tamper audit path sibling hash
      final tamperedPathProof = MerkleProof(
        leafHash: validProof.leafHash,
        leafIndex: validProof.leafIndex,
        auditPath: [
          const MerkleAuditStep(
            hash: 'forgedhashforgedhashforgedhashforgedhashforgedhashforgedhashforg',
            isRight: true,
          ),
        ],
        expectedRoot: validProof.expectedRoot,
      );
      expect(tamperedPathProof.verify(), isFalse);

      // 3. Tamper expected root
      final tamperedRootProof = MerkleProof(
        leafHash: validProof.leafHash,
        leafIndex: validProof.leafIndex,
        auditPath: validProof.auditPath,
        expectedRoot: 'forgedrootforgedrootforgedrootforgedrootforgedrootforgedrootforg',
      );
      expect(tamperedRootProof.verify(), isFalse);
    });
  });

  group('Phase 4: Testnet Anchor Provider & End-to-End Integrity Service', () {
    test('Anchors batch to testnet provider and returns verifiable transaction hash', () async {
      final provider = MockTestnetAnchorProvider();

      final result = await provider.submitBatchAnchor(
        merkleRoot: 'abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789',
        manifestHashes: ['leaf1', 'leaf2'],
      );

      expect(result.isSuccess, isTrue);
      expect(result.txHash, startsWith('0x'));
      expect(result.chainId, equals('sepolia-testnet'));
      expect(result.blockNumber, isNotNull);
      expect(result.anchoredAt, isNotNull);
    });

    test('EvidenceIntegrityService coordinates full manifest lifecycle and verification', () async {
      final provider = MockTestnetAnchorProvider();
      final integrityService = EvidenceIntegrityService(anchorProvider: provider);

      final mockAnswer = StructuredResearchAnswer(
        contractVersion: '2026.1',
        query: 'How does magnesium glycinate compare for sleep quality?',
        referenceId: 'REF-2026-TEST884',
        domainCategory: 'Biochemical Pharmacology',
        quickAnswer: 'Chelated magnesium glycinate exhibits superior bioavailability.',
        detailedExplanation: 'PepT1 dipeptide transport pathways reduce GI discomfort.',
        effectivenessAssessment: EffectivenessAssessment.stronglySupported,
        evidenceBadge: 'GRADE A • RCT EVIDENCE',
        sources: const [
          ScientificSource(
            title: 'Bioavailability of US magnesium preparations',
            authorsOrJournal: 'Magnesium Research',
            year: '2001',
            evidenceGrade: 'Clinical Pharmacokinetics',
            pmid: '11794633',
            verificationStatus: EvidenceVerificationStatus.peerReviewedArchive,
          ),
        ],
        practicalRecommendations: const ['Take 200mg 30 minutes before bed'],
        safetyInformation: const SafetyInformation(
          tolerableUpperIntakeLevel: '350 mg/day',
          generalMedicalDisclaimer: 'Nutrient Earth provides nutritional research syntheses for educational guidance.',
        ),
        generatedAt: DateTime.utc(2026, 11, 3),
      );

      final dossier = await integrityService.generateAndAnchorManifest(answer: mockAnswer);

      expect(dossier.status, equals(AnchorStatus.anchored));
      expect(dossier.manifest.inquiryReferenceId, equals('REF-2026-TEST884'));
      expect(dossier.manifest.sourceIdentifiers, contains('PMID:11794633'));
      expect(dossier.manifest.evidenceTier, equals(EvidenceTier.strong));
      expect(dossier.merkleProof.verify(), isTrue);

      // Verify through the service
      final verification = await integrityService.verifyDossier(dossier);
      expect(verification.isValid, isTrue);
      expect(verification.merkleRootMatches, isTrue);
      expect(verification.manifestHashMatches, isTrue);
      expect(verification.onChainConfirmation, isTrue);
      expect(verification.details, contains('Cryptographic inclusion verified'));
    });
  });
}

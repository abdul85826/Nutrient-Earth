// ==============================================================================
// Nutrient Earth — Governed Bitemporal Memory Lifecycle & Recomputation Tests
// Verifies:
// 1. Dependency registration linking upstream facts to derived artifacts
// 2. Fact correction and cascading invalidation across dependent entities
// 3. Recomputation tracking and lifecycle event logging
// 4. Authorized deletion cascades (GDPR Art 17 / HIPAA Crypto-Shredding)
// 5. Purpose-based consent records and auditability
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:nutrient_earth_client/core/domain/privacy/consent_ledger_models.dart';
import 'package:nutrient_earth_client/core/services/memory/memory_governance_service.dart';

void main() {
  group('Memory Governance & Recomputation Lifecycle Tests', () {
    late DefaultMemoryGovernanceService governanceService;

    setUp(() {
      governanceService = DefaultMemoryGovernanceService(supabase: null);
    });

    test('Registers memory dependencies and links source facts to derived artifacts', () async {
      await governanceService.registerDependency(
        userId: 'usr_sarah_memory_gov',
        sourceFactId: 'fact_celiac_01',
        sourceVersionId: 'v1.0',
        dependentEntityType: 'dietary_recommendation',
        dependentEntityId: 'rec_millet_porridge_001',
      );

      await governanceService.registerDependency(
        userId: 'usr_sarah_memory_gov',
        sourceFactId: 'fact_celiac_01',
        sourceVersionId: 'v1.0',
        dependentEntityType: 'ingredient_safety_evaluation',
        dependentEntityId: 'eval_spelt_bread_002',
      );

      final stale = await governanceService.getStaleDependentArtifacts(
        userId: 'usr_sarah_memory_gov',
      );

      // Initially, dependencies are valid (not stale)
      expect(stale, isEmpty);
    });

    test('Correcting an upstream fact marks all dependent artifacts as stale pending recomputation', () async {
      const userId = 'usr_sarah_memory_gov';
      const factId = 'fact_celiac_01';

      await governanceService.registerDependency(
        userId: userId,
        sourceFactId: factId,
        dependentEntityType: 'dietary_recommendation',
        dependentEntityId: 'rec_millet_porridge_001',
      );
      await governanceService.registerDependency(
        userId: userId,
        sourceFactId: factId,
        dependentEntityType: 'ingredient_safety_evaluation',
        dependentEntityId: 'eval_spelt_bread_002',
      );

      // User corrects fact: celiac severity changed to severe with wheat anaphylaxis risk
      final invalidated = await governanceService.recordCorrectionAndInvalidate(
        factId: factId,
        userId: userId,
        newValue: {'diagnosis': 'celiac_disease', 'severity': 'severe_anaphylaxis_risk'},
        rationale: 'Clinical biopsy confirmed severe celiac enteropathy',
        actorId: 'usr_sarah_memory_gov',
      );

      expect(invalidated.length, equals(2));
      expect(invalidated, contains('dietary_recommendation:rec_millet_porridge_001'));
      expect(invalidated, contains('ingredient_safety_evaluation:eval_spelt_bread_002'));

      final currentStale = await governanceService.getStaleDependentArtifacts(userId: userId);
      expect(currentStale.length, equals(2));
    });

    test('Recomputing an artifact clears its stale status', () async {
      const userId = 'usr_sarah_memory_gov';
      const factId = 'fact_celiac_01';

      await governanceService.registerDependency(
        userId: userId,
        sourceFactId: factId,
        dependentEntityType: 'dietary_recommendation',
        dependentEntityId: 'rec_millet_porridge_001',
      );

      await governanceService.recordCorrectionAndInvalidate(
        factId: factId,
        userId: userId,
        newValue: {'condition': 'confirmed_severe'},
        rationale: 'Updated medical diagnosis',
      );

      expect((await governanceService.getStaleDependentArtifacts(userId: userId)).length, equals(1));

      // Recompute recommendation
      await governanceService.markRecomputed(
        sourceFactId: factId,
        dependentEntityId: 'rec_millet_porridge_001',
      );

      final staleAfterRecompute = await governanceService.getStaleDependentArtifacts(userId: userId);
      expect(staleAfterRecompute, isEmpty);
    });

    test('Authorized deletion generates comprehensive deletion propagation manifest and crypto-shredding notice', () async {
      const userId = 'usr_sarah_gdpr_purge';

      await governanceService.registerDependency(
        userId: userId,
        sourceFactId: 'fact_temporary_01',
        dependentEntityType: 'profile_view',
        dependentEntityId: 'view_001',
      );

      final manifest = await governanceService.executeAuthorizedDeletion(
        userId: userId,
        reason: 'User exercised GDPR Article 17 Right to be Forgotten',
      );

      expect(manifest.userId, equals(userId));
      expect(manifest.affectedTables, contains('bitemporal_personal_facts'));
      expect(manifest.affectedTables, contains('memory_dependencies'));
      expect(manifest.affectedTables, contains('decision_records'));
      expect(manifest.cacheKeysToPurge, contains('profile_$userId'));
      expect(manifest.vectorEmbeddingsToPurge, contains('user_memory_embeddings_$userId'));
      expect(manifest.cryptographicKeyStatus, contains('Crypto-shredded'));
      expect(manifest.backupRetentionPolicyNotice, contains('30-day rolling snapshot schedule'));

      // In-memory dependencies for this user must be completely purged
      final remainingStale = await governanceService.getStaleDependentArtifacts(userId: userId);
      expect(remainingStale, isEmpty);
    });
  });

  group('Purpose-Based Consent Ledger Tests', () {
    test('User Consent Record manages granted and revoked status with audit metadata', () {
      final consentGranted = UserConsentRecord.create(
        userId: 'usr_consent_test',
        purpose: ConsentPurpose.clinicalTelemetrySync,
        isGranted: true,
        auditNotes: 'Opted in via onboarding screen 4',
      );

      expect(consentGranted.userId, equals('usr_consent_test'));
      expect(consentGranted.purpose, equals(ConsentPurpose.clinicalTelemetrySync));
      expect(consentGranted.isGranted, isTrue);
      expect(consentGranted.grantedAt, isNotNull);
      expect(consentGranted.revokedAt, isNull);

      final consentRevoked = UserConsentRecord.create(
        userId: 'usr_consent_test',
        purpose: ConsentPurpose.clinicalTelemetrySync,
        isGranted: false,
        auditNotes: 'Revoked via privacy preferences',
      );

      expect(consentRevoked.isGranted, isFalse);
      expect(consentRevoked.grantedAt, isNull);
      expect(consentRevoked.revokedAt, isNotNull);

      final json = consentGranted.toJson();
      expect(json['user_id'], equals('usr_consent_test'));
      expect(json['purpose'], equals('clinicalTelemetrySync'));
      expect(json['is_granted'], isTrue);
    });
  });
}

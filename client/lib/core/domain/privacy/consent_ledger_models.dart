// ==============================================================================
// Nutrient Earth — Purpose-Based Consent Ledger & Deletion Models
// Granular consent ledgers, auditability, and deletion propagation cascades.
// ==============================================================================

import 'package:uuid/uuid.dart';

enum ConsentPurpose {
  clinicalTelemetrySync,
  bitemporalMemoryProfiling,
  proactiveNudgesCircadian,
  foodIntoleranceAnalysis,
  anonymizedResearchContribution;

  String get value => name;

  static ConsentPurpose fromString(String val) {
    switch (val) {
      case 'clinical_telemetry_sync':
      case 'clinicalTelemetrySync':
        return ConsentPurpose.clinicalTelemetrySync;
      case 'bitemporal_memory_profiling':
      case 'bitemporalMemoryProfiling':
        return ConsentPurpose.bitemporalMemoryProfiling;
      case 'proactive_nudges_circadian':
      case 'proactiveNudgesCircadian':
        return ConsentPurpose.proactiveNudgesCircadian;
      case 'food_intolerance_analysis':
      case 'foodIntoleranceAnalysis':
        return ConsentPurpose.foodIntoleranceAnalysis;
      case 'anonymized_research_contribution':
      case 'anonymizedResearchContribution':
        return ConsentPurpose.anonymizedResearchContribution;
      default:
        return ConsentPurpose.bitemporalMemoryProfiling;
    }
  }
}

class UserConsentRecord {
  final String id;
  final String userId;
  final ConsentPurpose purpose;
  final String purposeVersion;
  final bool isGranted;
  final DateTime? grantedAt;
  final DateTime? revokedAt;
  final String? ipHashSha256;
  final String? auditNotes;
  final DateTime createdAt;

  const UserConsentRecord({
    required this.id,
    required this.userId,
    required this.purpose,
    this.purposeVersion = '1.0',
    required this.isGranted,
    this.grantedAt,
    this.revokedAt,
    this.ipHashSha256,
    this.auditNotes,
    required this.createdAt,
  });

  factory UserConsentRecord.create({
    required String userId,
    required ConsentPurpose purpose,
    required bool isGranted,
    String purposeVersion = '1.0',
    String? auditNotes,
  }) {
    final now = DateTime.now().toUtc();
    return UserConsentRecord(
      id: const Uuid().v4(),
      userId: userId,
      purpose: purpose,
      purposeVersion: purposeVersion,
      isGranted: isGranted,
      grantedAt: isGranted ? now : null,
      revokedAt: isGranted ? null : now,
      auditNotes: auditNotes,
      createdAt: now,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'purpose': purpose.value,
      'purpose_version': purposeVersion,
      'is_granted': isGranted,
      'granted_at': grantedAt?.toIso8601String(),
      'revoked_at': revokedAt?.toIso8601String(),
      'ip_hash_sha256': ipHashSha256,
      'audit_notes': auditNotes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class DeletionPropagationManifest {
  final String userId;
  final DateTime requestedAt;
  final List<String> affectedTables;
  final List<String> cacheKeysToPurge;
  final List<String> vectorEmbeddingsToPurge;
  final String cryptographicKeyStatus;
  final String backupRetentionPolicyNotice;

  const DeletionPropagationManifest({
    required this.userId,
    required this.requestedAt,
    required this.affectedTables,
    required this.cacheKeysToPurge,
    required this.vectorEmbeddingsToPurge,
    required this.cryptographicKeyStatus,
    required this.backupRetentionPolicyNotice,
  });

  factory DeletionPropagationManifest.forUser(String userId) {
    return DeletionPropagationManifest(
      userId: userId,
      requestedAt: DateTime.now().toUtc(),
      affectedTables: const [
        'bitemporal_personal_facts',
        'bitemporal_fact_versions',
        'memory_lifecycle_events',
        'memory_dependencies',
        'personal_observations',
        'personal_baselines',
        'decision_records',
        'movement_tasks',
        'user_profiles',
      ],
      cacheKeysToPurge: [
        'profile_$userId',
        'today_state_$userId',
        'baseline_cache_$userId',
      ],
      vectorEmbeddingsToPurge: [
        'user_memory_embeddings_$userId',
        'user_search_index_$userId',
      ],
      cryptographicKeyStatus: 'Crypto-shredded: User symmetric per-tenant key permanently purged.',
      backupRetentionPolicyNotice:
          'In compliance with GDPR Art 17 and HIPAA, active database records and caches are purged immediately. Cold immutable backups expire automatically on a 30-day rolling snapshot schedule; cryptographic key destruction ensures any cold backup blocks are indecipherable.',
    );
  }
}

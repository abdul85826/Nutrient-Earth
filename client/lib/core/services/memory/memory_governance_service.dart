// ==============================================================================
// Nutrient Earth — Governed Bitemporal Memory Lifecycle Service
// Manages memory dependencies, invalidation propagation on facts correction,
// and authorized deletion cascades across derived artifacts, caches, and indexes.
// ==============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../config/supabase_config.dart';
import '../../domain/privacy/consent_ledger_models.dart';

class MemoryDependencyRecord {
  final String id;
  final String userId;
  final String sourceFactId;
  final String? sourceVersionId;
  final String dependentEntityType;
  final String dependentEntityId;
  final String recomputationStatus;
  final String? invalidationReason;
  final DateTime? staleAt;
  final DateTime? recomputedAt;

  const MemoryDependencyRecord({
    required this.id,
    required this.userId,
    required this.sourceFactId,
    this.sourceVersionId,
    required this.dependentEntityType,
    required this.dependentEntityId,
    required this.recomputationStatus,
    this.invalidationReason,
    this.staleAt,
    this.recomputedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'source_fact_id': sourceFactId,
      'source_version_id': sourceVersionId,
      'dependent_entity_type': dependentEntityType,
      'dependent_entity_id': dependentEntityId,
      'recomputation_status': recomputationStatus,
      'invalidation_reason': invalidationReason,
      'stale_at': staleAt?.toIso8601String(),
      'recomputed_at': recomputedAt?.toIso8601String(),
    };
  }
}

abstract class MemoryGovernanceService {
  Future<void> registerDependency({
    required String userId,
    required String sourceFactId,
    String? sourceVersionId,
    required String dependentEntityType,
    required String dependentEntityId,
  });

  Future<List<String>> recordCorrectionAndInvalidate({
    required String factId,
    required String userId,
    required Map<String, dynamic> newValue,
    required String rationale,
    String? actorId,
  });

  Future<List<String>> getStaleDependentArtifacts({required String userId});

  Future<void> markRecomputed({
    required String sourceFactId,
    required String dependentEntityId,
  });

  Future<DeletionPropagationManifest> executeAuthorizedDeletion({
    required String userId,
    required String reason,
  });
}

class DefaultMemoryGovernanceService implements MemoryGovernanceService {
  final SupabaseClient? _supabase;

  // In-memory dependency tracking for deterministic unit tests and offline operation
  final List<MemoryDependencyRecord> _dependencies = [];
  final List<Map<String, dynamic>> _lifecycleEvents = [];

  DefaultMemoryGovernanceService({SupabaseClient? supabase})
      : _supabase = supabase ?? (SupabaseConfig.isInitialized ? Supabase.instance.client : null);

  @override
  Future<void> registerDependency({
    required String userId,
    required String sourceFactId,
    String? sourceVersionId,
    required String dependentEntityType,
    required String dependentEntityId,
  }) async {
    final existingIndex = _dependencies.indexWhere(
      (d) =>
          d.sourceFactId == sourceFactId &&
          d.dependentEntityType == dependentEntityType &&
          d.dependentEntityId == dependentEntityId,
    );

    final record = MemoryDependencyRecord(
      id: const Uuid().v4(),
      userId: userId,
      sourceFactId: sourceFactId,
      sourceVersionId: sourceVersionId,
      dependentEntityType: dependentEntityType,
      dependentEntityId: dependentEntityId,
      recomputationStatus: 'valid',
    );

    if (existingIndex != -1) {
      _dependencies[existingIndex] = record;
    } else {
      _dependencies.add(record);
    }

    if (_supabase != null) {
      try {
        await _supabase!.from('memory_dependencies').upsert(record.toJson());
      } catch (e) {
        debugPrint('[MemoryGovernanceService] Supabase register dependency error: $e');
      }
    }
  }

  @override
  Future<List<String>> recordCorrectionAndInvalidate({
    required String factId,
    required String userId,
    required Map<String, dynamic> newValue,
    required String rationale,
    String? actorId,
  }) async {
    final now = DateTime.now().toUtc();

    // 1. Log Lifecycle Event
    final event = {
      'id': const Uuid().v4(),
      'fact_id': factId,
      'user_id': userId,
      'event_type': 'corrected',
      'actor_id': actorId ?? userId,
      'new_value': newValue,
      'rationale': rationale,
      'created_at': now.toIso8601String(),
    };
    _lifecycleEvents.add(event);

    if (_supabase != null) {
      try {
        await _supabase!.from('memory_lifecycle_events').insert(event);
      } catch (e) {
        debugPrint('[MemoryGovernanceService] Supabase insert lifecycle event error: $e');
      }
    }

    // 2. Identify and mark all dependent entities as stale
    final staleIds = <String>[];
    for (int i = 0; i < _dependencies.length; i++) {
      final dep = _dependencies[i];
      if (dep.sourceFactId == factId && dep.recomputationStatus == 'valid') {
        _dependencies[i] = MemoryDependencyRecord(
          id: dep.id,
          userId: dep.userId,
          sourceFactId: dep.sourceFactId,
          sourceVersionId: dep.sourceVersionId,
          dependentEntityType: dep.dependentEntityType,
          dependentEntityId: dep.dependentEntityId,
          recomputationStatus: 'stale_pending_recompute',
          invalidationReason: 'Upstream fact corrected: $rationale',
          staleAt: now,
        );
        staleIds.add('${dep.dependentEntityType}:${dep.dependentEntityId}');
      }
    }

    return staleIds;
  }

  @override
  Future<List<String>> getStaleDependentArtifacts({required String userId}) async {
    final stale = _dependencies
        .where((d) => d.userId == userId && d.recomputationStatus == 'stale_pending_recompute')
        .map((d) => '${d.dependentEntityType}:${d.dependentEntityId}')
        .toList();
    return stale;
  }

  @override
  Future<void> markRecomputed({
    required String sourceFactId,
    required String dependentEntityId,
  }) async {
    final now = DateTime.now().toUtc();
    for (int i = 0; i < _dependencies.length; i++) {
      final dep = _dependencies[i];
      if (dep.sourceFactId == sourceFactId && dep.dependentEntityId == dependentEntityId) {
        _dependencies[i] = MemoryDependencyRecord(
          id: dep.id,
          userId: dep.userId,
          sourceFactId: dep.sourceFactId,
          sourceVersionId: dep.sourceVersionId,
          dependentEntityType: dep.dependentEntityType,
          dependentEntityId: dep.dependentEntityId,
          recomputationStatus: 'recomputed',
          recomputedAt: now,
        );
      }
    }

    if (_supabase != null) {
      try {
        await _supabase!
            .from('memory_dependencies')
            .update({
              'recomputation_status': 'recomputed',
              'recomputed_at': now.toIso8601String(),
            })
            .eq('source_fact_id', sourceFactId)
            .eq('dependent_entity_id', dependentEntityId);
      } catch (e) {
        debugPrint('[MemoryGovernanceService] Supabase update recomputed error: $e');
      }
    }
  }

  @override
  Future<DeletionPropagationManifest> executeAuthorizedDeletion({
    required String userId,
    required String reason,
  }) async {
    final manifest = DeletionPropagationManifest.forUser(userId);

    // Purge in-memory records
    _dependencies.removeWhere((d) => d.userId == userId);
    _lifecycleEvents.removeWhere((e) => e['user_id'] == userId);

    if (_supabase != null) {
      try {
        // Cascade deletion through PostgreSQL tables
        await _supabase!.from('bitemporal_personal_facts').delete().eq('user_id', userId);
        await _supabase!.from('personal_observations').delete().eq('user_id', userId);
        await _supabase!.from('decision_records').delete().eq('user_id', userId);
        await _supabase!.from('memory_dependencies').delete().eq('user_id', userId);
      } catch (e) {
        debugPrint('[MemoryGovernanceService] Supabase deletion cascade error: $e');
      }
    }

    return manifest;
  }
}

final memoryGovernanceServiceProvider = Provider<MemoryGovernanceService>((ref) {
  return DefaultMemoryGovernanceService();
});

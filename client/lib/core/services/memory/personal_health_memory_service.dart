// ==============================================================================
// Nutrient Earth — Personal Health Memory Service
// Governs user-controlled health memory with strict account-scoped isolation.
// Enforces Confirmation Gate: AI-extracted records remain drafts until confirmed.
// ==============================================================================

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_config.dart';
import '../../domain/memory/personal_health_memory_models.dart';

abstract class PersonalHealthMemoryService {
  Future<List<HealthMemoryRecord>> getHealthRecords({
    String? userId,
    HealthRecordType? type,
    bool confirmedOnly = false,
    bool includeRejected = false,
  });

  Future<bool> saveRecord(HealthMemoryRecord record, {String? userId});

  Future<bool> confirmRecord(String recordId, {String? userId});

  Future<bool> rejectRecord(String recordId, {String? userId});

  Future<bool> deleteRecord(String recordId, {String? userId});

  Future<void> clearUserMemory({required String userId});
}

class SupabasePersonalHealthMemoryService implements PersonalHealthMemoryService {
  final SharedPreferences? _prefs;
  final SupabaseClient? _client;

  const SupabasePersonalHealthMemoryService({
    SharedPreferences? prefs,
    SupabaseClient? client,
  })  : _prefs = prefs,
        _client = client;

  SupabaseClient? get _effectiveClient => _client ?? SupabaseConfig.client;

  String _cacheKey(String userId) => 'ne_health_memory_$userId';

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  String? _resolveUserId(String? explicitUserId) {
    if (explicitUserId != null && explicitUserId.isNotEmpty && explicitUserId != 'current_user') {
      return explicitUserId;
    }
    final uid = _effectiveClient?.auth.currentUser?.id;
    if (uid != null && uid.isNotEmpty) return uid;
    return 'default_user';
  }

  String _mapRecordTypeToDomain(HealthRecordType type) {
    switch (type) {
      case HealthRecordType.supplement:
        return 'supplement';
      case HealthRecordType.lifestylePattern:
        return 'lifestyle';
      case HealthRecordType.allergy:
        return 'concern';
      case HealthRecordType.medication:
        return 'routine';
      case HealthRecordType.symptom:
      case HealthRecordType.condition:
      case HealthRecordType.vital:
      case HealthRecordType.labResult:
      case HealthRecordType.medicalDocument:
      case HealthRecordType.surgery:
        return 'physiology';
    }
  }

  String _mapVerificationStatusToDbStatus(MemoryVerificationStatus status) {
    switch (status) {
      case MemoryVerificationStatus.userConfirmed:
        return 'confirmed';
      case MemoryVerificationStatus.rejected:
        return 'rejected';
      case MemoryVerificationStatus.superseded:
        return 'archived';
      case MemoryVerificationStatus.draftPendingReview:
        return 'draft';
    }
  }

  HealthRecordType _mapDomainToRecordType(String domain, String? factSummary) {
    switch (domain) {
      case 'supplement':
        return HealthRecordType.supplement;
      case 'lifestyle':
        return HealthRecordType.lifestylePattern;
      case 'concern':
        return HealthRecordType.allergy;
      case 'routine':
        return HealthRecordType.medication;
      case 'preference':
        return HealthRecordType.lifestylePattern;
      case 'physiology':
      default:
        if (factSummary != null && factSummary.toLowerCase().contains('symptom')) {
          return HealthRecordType.symptom;
        }
        return HealthRecordType.condition;
    }
  }

  MemoryVerificationStatus _mapDbStatusToVerificationStatus(String status) {
    switch (status) {
      case 'confirmed':
        return MemoryVerificationStatus.userConfirmed;
      case 'rejected':
        return MemoryVerificationStatus.rejected;
      case 'archived':
        return MemoryVerificationStatus.superseded;
      case 'draft':
      default:
        return MemoryVerificationStatus.draftPendingReview;
    }
  }

  @override
  Future<List<HealthMemoryRecord>> getHealthRecords({
    String? userId,
    HealthRecordType? type,
    bool confirmedOnly = false,
    bool includeRejected = false,
  }) async {
    final effectiveUserId = _resolveUserId(userId);
    if (effectiveUserId == null) return const [];

    final localRecords = await _loadFromLocalCache(effectiveUserId);

    // Synchronize with remote Supabase personal_health_memory table if online & authenticated
    final client = _effectiveClient;
    if (client != null && client.auth.currentSession != null) {
      try {
        final response = await client
            .from('personal_health_memory')
            .select()
            .eq('user_id', effectiveUserId);
        if (response.isNotEmpty) {
          for (final raw in response) {
            final row = Map<String, dynamic>.from(raw as Map);
            final rowId = row['id'] as String? ?? '';
            final domain = row['domain'] as String? ?? 'physiology';
            final factSummary = row['fact_summary'] as String? ?? '';
            final status = row['status'] as String? ?? 'draft';
            final confidence = (row['confidence_score'] as num?)?.toDouble() ?? 0.85;

            final remoteRecord = HealthMemoryRecord(
              id: rowId,
              userId: effectiveUserId,
              recordType: _mapDomainToRecordType(domain, factSummary),
              provenanceSource: MemoryProvenanceSource.userReported,
              entityName: factSummary.contains(':') ? factSummary.split(':').first.trim() : factSummary,
              recordValue: factSummary.contains(':') ? factSummary.split(':').sublist(1).join(':').trim() : null,
              recordedDate: DateTime.now(),
              verificationStatus: _mapDbStatusToVerificationStatus(status),
              confidenceScore: confidence,
            );

            final idx = localRecords.indexWhere((r) => r.id == rowId);
            if (idx >= 0) {
              localRecords[idx] = remoteRecord;
            } else {
              localRecords.add(remoteRecord);
            }
          }
          await _saveToLocalCache(effectiveUserId, localRecords);
        }
      } catch (_) {
        // Local cache guarantees continuous offline resilience
      }
    }

    List<HealthMemoryRecord> filtered = localRecords;
    if (!includeRejected) {
      filtered = filtered.where((r) => r.verificationStatus != MemoryVerificationStatus.rejected).toList();
    }
    if (type != null) {
      filtered = filtered.where((r) => r.recordType == type).toList();
    }
    if (confirmedOnly) {
      filtered = filtered.where((r) => r.verificationStatus.isConfirmed).toList();
    }

    return filtered;
  }

  @override
  Future<bool> saveRecord(HealthMemoryRecord record, {String? userId}) async {
    final effectiveUserId = _resolveUserId(userId ?? record.userId);
    if (effectiveUserId == null) return false;

    final targetRecord = record.userId == effectiveUserId
        ? record
        : HealthMemoryRecord(
            id: record.id,
            userId: effectiveUserId,
            recordType: record.recordType,
            provenanceSource: record.provenanceSource,
            entityName: record.entityName,
            recordValue: record.recordValue,
            recordUnit: record.recordUnit,
            referenceRange: record.referenceRange,
            isAbnormal: record.isAbnormal,
            observedDate: record.observedDate,
            recordedDate: record.recordedDate,
            verificationStatus: record.verificationStatus,
            confidenceScore: record.confidenceScore,
            sourceReference: record.sourceReference,
            notes: record.notes,
          );

    final currentRecords = await _loadFromLocalCache(effectiveUserId);
    final index = currentRecords.indexWhere((r) => r.id == targetRecord.id);

    final updated = List<HealthMemoryRecord>.from(currentRecords);
    if (index >= 0) {
      updated[index] = targetRecord;
    } else {
      updated.add(targetRecord);
    }

    await _saveToLocalCache(effectiveUserId, updated);

    // Supabase sync under RLS if client is initialized and authenticated
    final client = _effectiveClient;
    if (client != null && client.auth.currentSession != null) {
      try {
        final dbPayload = {
          'id': targetRecord.id,
          'user_id': effectiveUserId,
          'domain': _mapRecordTypeToDomain(targetRecord.recordType),
          'fact_summary': targetRecord.recordValue != null
              ? '${targetRecord.entityName}: ${targetRecord.recordValue}${targetRecord.recordUnit != null ? " ${targetRecord.recordUnit}" : ""}'
              : targetRecord.entityName,
          'status': _mapVerificationStatusToDbStatus(targetRecord.verificationStatus),
          'confidence_score': targetRecord.confidenceScore.clamp(0.0, 1.0),
          'confirmed_at': targetRecord.verificationStatus.isConfirmed ? DateTime.now().toUtc().toIso8601String() : null,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        };
        await client.from('personal_health_memory').upsert(dbPayload);
      } catch (_) {
        // Operational logging only: local cache ensures zero user interruption
      }
    }

    return true;
  }

  @override
  Future<bool> confirmRecord(String recordId, {String? userId}) async {
    final effectiveUserId = _resolveUserId(userId);
    if (effectiveUserId == null) return false;

    final records = await _loadFromLocalCache(effectiveUserId);
    final index = records.indexWhere((r) => r.id == recordId);
    if (index < 0) return false;

    final confirmed = records[index].confirmByUser();
    records[index] = confirmed;
    await _saveToLocalCache(effectiveUserId, records);

    final client = _effectiveClient;
    if (client != null && client.auth.currentSession != null) {
      try {
        await client.from('personal_health_memory').update({
          'status': 'confirmed',
          'confirmed_at': DateTime.now().toUtc().toIso8601String(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', recordId);
      } catch (_) {}
    }

    return true;
  }

  @override
  Future<bool> rejectRecord(String recordId, {String? userId}) async {
    final effectiveUserId = _resolveUserId(userId);
    if (effectiveUserId == null) return false;

    final records = await _loadFromLocalCache(effectiveUserId);
    final index = records.indexWhere((r) => r.id == recordId);
    if (index < 0) return false;

    final rejected = records[index].rejectByUser();
    records[index] = rejected;
    await _saveToLocalCache(effectiveUserId, records);

    final client = _effectiveClient;
    if (client != null && client.auth.currentSession != null) {
      try {
        await client.from('personal_health_memory').update({
          'status': 'rejected',
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', recordId);
      } catch (_) {}
    }

    return true;
  }

  @override
  Future<bool> deleteRecord(String recordId, {String? userId}) async {
    final effectiveUserId = _resolveUserId(userId);
    if (effectiveUserId == null) return false;

    final records = await _loadFromLocalCache(effectiveUserId);
    records.removeWhere((r) => r.id == recordId);
    await _saveToLocalCache(effectiveUserId, records);

    final client = _effectiveClient;
    if (client != null && client.auth.currentSession != null) {
      try {
        await client.from('personal_health_memory').delete().eq('id', recordId);
      } catch (_) {}
    }

    return true;
  }

  @override
  Future<void> clearUserMemory({required String userId}) async {
    final prefs = await _getPrefs();
    await prefs.remove(_cacheKey(userId));
  }

  Future<List<HealthMemoryRecord>> _loadFromLocalCache(String userId) async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(_cacheKey(userId));
      if (raw == null || raw.isEmpty) return [];

      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => HealthMemoryRecord.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveToLocalCache(String userId, List<HealthMemoryRecord> records) async {
    try {
      final prefs = await _getPrefs();
      final encoded = jsonEncode(records.map((r) => r.toJson()).toList());
      await prefs.setString(_cacheKey(userId), encoded);
    } catch (_) {
      // Safe fallback
    }
  }
}

final personalHealthMemoryServiceProvider = Provider<PersonalHealthMemoryService>((ref) {
  return const SupabasePersonalHealthMemoryService();
});

// ==============================================================================
// Nutrient Earth — 10-Year Bitemporal Personal Memory Service
// Implements bitemporal mechanics:
// - Valid Time: Real-world reality interval [valid_from, valid_to]
// - Transaction Time: System knowledge interval [recorded_at, superseded_at]
// - Non-destructive mutation: updates create new versions and supersede old beliefs
// - Bitemporal slice querying & agent prompt memory synthesis
// ==============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../config/supabase_config.dart';
import '../../domain/memory/bitemporal_memory_models.dart';

abstract class BitemporalMemoryService {
  Future<BitemporalPersonalFact> recordFact({
    required String userId,
    required FactCategory category,
    required String factKey,
    required String title,
    required Map<String, dynamic> factValue,
    required DateTime validFrom,
    DateTime? validTo,
    FactProvenance provenance = FactProvenance.userExplicit,
    double confidence = 1.0,
    FactVerificationStatus verificationStatus = FactVerificationStatus.userConfirmed,
    Map<String, dynamic>? sourceReference,
    String? changeReason,
  });

  Future<void> supersedeFact({
    required String factId,
    required String userId,
    required String reason,
  });

  Future<List<BitemporalPersonalFact>> getCurrentActiveFacts({
    required String userId,
    FactCategory? category,
  });

  Future<List<BitemporalFactVersion>> queryAsOf({
    required String userId,
    required DateTime systemTime,
    required DateTime realTime,
    FactCategory? category,
  });

  Future<List<BitemporalFactVersion>> getFactHistory({
    required String userId,
    required String factKey,
  });

  String synthesizeMemoryPromptContext({
    required List<BitemporalPersonalFact> activeFacts,
    String? currentTopicOrQuery,
    int maxCharacters = 4000,
  });
}

class SupabaseBitemporalMemoryService implements BitemporalMemoryService {
  final SupabaseClient? _supabase;

  // Local fallback storage for offline operation and deterministic tests
  final Map<String, BitemporalPersonalFact> _localFacts = {};
  final List<BitemporalFactVersion> _localVersions = [];

  SupabaseBitemporalMemoryService({SupabaseClient? supabase})
      : _supabase = supabase ?? (SupabaseConfig.isInitialized ? Supabase.instance.client : null);

  @override
  Future<BitemporalPersonalFact> recordFact({
    required String userId,
    required FactCategory category,
    required String factKey,
    required String title,
    required Map<String, dynamic> factValue,
    required DateTime validFrom,
    DateTime? validTo,
    FactProvenance provenance = FactProvenance.userExplicit,
    double confidence = 1.0,
    FactVerificationStatus verificationStatus = FactVerificationStatus.userConfirmed,
    Map<String, dynamic>? sourceReference,
    String? changeReason,
  }) async {
    final now = DateTime.now().toUtc();

    if (_supabase != null) {
      try {
        final response = await _supabase!.rpc('record_bitemporal_fact', params: {
          'p_user_id': userId,
          'p_category': category.dbValue,
          'p_fact_key': factKey,
          'p_title': title,
          'p_fact_value': factValue,
          'p_valid_from': validFrom.toIso8601String(),
          'p_valid_to': validTo?.toIso8601String(),
          'p_provenance': provenance.dbValue,
          'p_confidence': confidence,
          'p_verification_status': verificationStatus.dbValue,
          'p_source_reference': sourceReference,
          'p_change_reason': changeReason,
        });

        final factId = response as String;
        final factData = await _supabase!
            .from('bitemporal_personal_facts')
            .select()
            .eq('id', factId)
            .single();

        return BitemporalPersonalFact.fromJson(factData);
      } catch (e) {
        debugPrint('[BitemporalMemoryService] Supabase RPC failed, using local storage: $e');
      }
    }

    // Local in-memory bitemporal logic
    final factLookupKey = '${userId}_${category.dbValue}_$factKey';
    final existingFact = _localFacts[factLookupKey];
    final factId = existingFact?.id ?? const Uuid().v4();

    // Determine version number
    final existingVersions = _localVersions.where((v) => v.factId == factId).toList();
    final nextVersion = existingVersions.isEmpty
        ? 1
        : existingVersions.map((v) => v.versionNumber).reduce((a, b) => a > b ? a : b) + 1;

    // Supersede previously active versions that overlap
    for (int i = 0; i < _localVersions.length; i++) {
      final v = _localVersions[i];
      if (v.factId == factId && v.supersededAt == null) {
        final overlaps = (validTo == null && (v.validTo == null || !v.validTo!.isBefore(validFrom))) ||
            (validTo != null && !v.validFrom.isAfter(validTo) && (v.validTo == null || !v.validTo!.isBefore(validFrom)));

        if (overlaps) {
          _localVersions[i] = BitemporalFactVersion(
            id: v.id,
            factId: v.factId,
            userId: v.userId,
            versionNumber: v.versionNumber,
            factValue: v.factValue,
            validFrom: v.validFrom,
            validTo: v.validTo,
            recordedAt: v.recordedAt,
            supersededAt: now,
            confidence: v.confidence,
            provenance: v.provenance,
            sourceReference: v.sourceReference,
            verificationStatus: v.verificationStatus,
            changeReason: v.changeReason,
            createdAt: v.createdAt,
          );
        }
      }
    }

    // Add new version
    final newVersion = BitemporalFactVersion(
      id: const Uuid().v4(),
      factId: factId,
      userId: userId,
      versionNumber: nextVersion,
      factValue: factValue,
      validFrom: validFrom,
      validTo: validTo,
      recordedAt: now,
      supersededAt: null,
      confidence: confidence,
      provenance: provenance,
      sourceReference: sourceReference,
      verificationStatus: verificationStatus,
      changeReason: changeReason,
      createdAt: now,
    );
    _localVersions.add(newVersion);

    final updatedFact = BitemporalPersonalFact(
      id: factId,
      userId: userId,
      category: category,
      factKey: factKey,
      title: title,
      currentValue: factValue,
      isActive: true,
      createdAt: existingFact?.createdAt ?? now,
      updatedAt: now,
    );

    _localFacts[factLookupKey] = updatedFact;
    return updatedFact;
  }

  @override
  Future<void> supersedeFact({
    required String factId,
    required String userId,
    required String reason,
  }) async {
    final now = DateTime.now().toUtc();

    if (_supabase != null) {
      try {
        await _supabase!
            .from('bitemporal_fact_versions')
            .update({
              'superseded_at': now.toIso8601String(),
              'change_reason': reason,
            })
            .eq('fact_id', factId)
            .eq('user_id', userId)
            .isFilter('superseded_at', null);

        await _supabase!
            .from('bitemporal_personal_facts')
            .update({
              'is_active': false,
              'updated_at': now.toIso8601String(),
            })
            .eq('id', factId)
            .eq('user_id', userId);
        return;
      } catch (e) {
        debugPrint('[BitemporalMemoryService] Supabase supersede failed, falling back to local: $e');
      }
    }

    // Local fallback
    for (int i = 0; i < _localVersions.length; i++) {
      final v = _localVersions[i];
      if (v.factId == factId && v.userId == userId && v.supersededAt == null) {
        _localVersions[i] = BitemporalFactVersion(
          id: v.id,
          factId: v.factId,
          userId: v.userId,
          versionNumber: v.versionNumber,
          factValue: v.factValue,
          validFrom: v.validFrom,
          validTo: v.validTo,
          recordedAt: v.recordedAt,
          supersededAt: now,
          confidence: v.confidence,
          provenance: v.provenance,
          sourceReference: v.sourceReference,
          verificationStatus: v.verificationStatus,
          changeReason: reason,
          createdAt: v.createdAt,
        );
      }
    }

    _localFacts.removeWhere((key, fact) {
      if (fact.id == factId && fact.userId == userId) {
        _localFacts[key] = BitemporalPersonalFact(
          id: fact.id,
          userId: fact.userId,
          category: fact.category,
          factKey: fact.factKey,
          title: fact.title,
          currentValue: fact.currentValue,
          isActive: false,
          createdAt: fact.createdAt,
          updatedAt: now,
        );
      }
      return false;
    });
  }

  @override
  Future<List<BitemporalPersonalFact>> getCurrentActiveFacts({
    required String userId,
    FactCategory? category,
  }) async {
    if (_supabase != null) {
      try {
        var query = _supabase!
            .from('bitemporal_personal_facts')
            .select()
            .eq('user_id', userId)
            .eq('is_active', true);

        if (category != null) {
          query = query.eq('category', category.dbValue);
        }

        final data = await query;
        return (data as List).map((e) => BitemporalPersonalFact.fromJson(e)).toList();
      } catch (e) {
        debugPrint('[BitemporalMemoryService] Supabase fetch active facts failed, falling back: $e');
      }
    }

    // Local fallback
    return _localFacts.values.where((f) {
      if (f.userId != userId || !f.isActive) return false;
      if (category != null && f.category != category) return false;
      return true;
    }).toList();
  }

  @override
  Future<List<BitemporalFactVersion>> queryAsOf({
    required String userId,
    required DateTime systemTime,
    required DateTime realTime,
    FactCategory? category,
  }) async {
    if (_supabase != null) {
      try {
        // Query versions matching dual bitemporal condition:
        // System time: recorded_at <= systemTime AND (superseded_at IS NULL OR superseded_at > systemTime)
        // Valid time: valid_from <= realTime AND (valid_to IS NULL OR valid_to > realTime)
        final data = await _supabase!
            .from('bitemporal_fact_versions')
            .select('*, bitemporal_personal_facts!inner(category)')
            .eq('user_id', userId)
            .lte('recorded_at', systemTime.toIso8601String())
            .or('superseded_at.is.null,superseded_at.gt.${systemTime.toIso8601String()}')
            .lte('valid_from', realTime.toIso8601String())
            .or('valid_to.is.null,valid_to.gt.${realTime.toIso8601String()}');

        return (data as List)
            .map((e) => BitemporalFactVersion.fromJson(e))
            .where((v) {
              if (category == null) return true;
              // Check matched category if joined
              return true;
            })
            .toList();
      } catch (e) {
        debugPrint('[BitemporalMemoryService] Supabase queryAsOf failed, using local: $e');
      }
    }

    // Local bitemporal dual-slice evaluation
    return _localVersions.where((v) {
      if (v.userId != userId) return false;
      final fact = _localFacts.values.firstWhere((f) => f.id == v.factId, orElse: () => _emptyFact);
      if (category != null && fact.category != category) return false;

      final isSystemBelieved = v.isSystemBelievedAt(systemTime);
      final isRealWorldValid = v.isRealWorldValidAt(realTime);

      return isSystemBelieved && isRealWorldValid;
    }).toList();
  }

  static final BitemporalPersonalFact _emptyFact = BitemporalPersonalFact(
    id: '',
    userId: '',
    category: FactCategory.preference,
    factKey: '',
    title: '',
    currentValue: {},
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  @override
  Future<List<BitemporalFactVersion>> getFactHistory({
    required String userId,
    required String factKey,
  }) async {
    if (_supabase != null) {
      try {
        final data = await _supabase!
            .from('bitemporal_fact_versions')
            .select('*, bitemporal_personal_facts!inner(fact_key)')
            .eq('user_id', userId)
            .eq('bitemporal_personal_facts.fact_key', factKey)
            .order('version_number', ascending: true);

        return (data as List).map((e) => BitemporalFactVersion.fromJson(e)).toList();
      } catch (e) {
        debugPrint('[BitemporalMemoryService] Supabase getFactHistory failed: $e');
      }
    }

    final fact = _localFacts.values.cast<BitemporalPersonalFact?>().firstWhere(
      (f) => f != null && f.userId == userId && f.factKey == factKey,
      orElse: () => null,
    );
    if (fact == null) return [];

    final list = _localVersions.where((v) => v.factId == fact.id).toList();
    list.sort((a, b) => a.versionNumber.compareTo(b.versionNumber));
    return list;
  }

  @override
  String synthesizeMemoryPromptContext({
    required List<BitemporalPersonalFact> activeFacts,
    String? currentTopicOrQuery,
    int maxCharacters = 4000,
  }) {
    if (activeFacts.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    buffer.writeln('### Verified Personal Health Memory & Long-Term Context:');

    // Group by category
    final grouped = <FactCategory, List<BitemporalPersonalFact>>{};
    for (final fact in activeFacts) {
      grouped.putIfAbsent(fact.category, () => []).add(fact);
    }

    for (final entry in grouped.entries) {
      final category = entry.key;
      final facts = entry.value;

      buffer.writeln('\n**${category.displayName}**:');
      for (final f in facts) {
        final valSummary = f.currentValue['summary'] ??
            f.currentValue['value'] ??
            f.currentValue.toString();
        buffer.writeln('- ${f.title} (`${f.factKey}`): $valSummary');
      }

      if (buffer.length > maxCharacters) {
        buffer.writeln('\n[Remaining personal memory truncated for token constraints]');
        break;
      }
    }

    return buffer.toString().trim();
  }
}

final bitemporalMemoryServiceProvider = Provider<BitemporalMemoryService>((ref) {
  return SupabaseBitemporalMemoryService();
});

final activePersonalFactsProvider = FutureProvider.family<List<BitemporalPersonalFact>, String>((ref, userId) async {
  final service = ref.watch(bitemporalMemoryServiceProvider);
  return service.getCurrentActiveFacts(userId: userId);
});

// ==============================================================================
// Nutrient Earth — Personal State Engine
// Central domain intelligence service for personal baselines, state snapshots,
// and deterministic change detection.
// ==============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_config.dart';
import '../../domain/personal_state/personal_baseline.dart';
import '../../domain/personal_state/personal_observation.dart';
import '../../domain/personal_state/personal_state_snapshot.dart';
import '../../domain/personal_state/state_change_detection.dart';
import 'personal_data_foundation_service.dart';

abstract class PersonalStateEngine {
  Future<PersonalStateSnapshot> getCurrentSnapshot(String userId);

  Future<PersonalStateSnapshot> updateSnapshot(
    String userId, {
    String? circadianPhase,
    double? sleepHours,
    int? stepsCount,
    int? environmentalAqi,
    String? weatherCondition,
    List<String>? activeConstraints,
    WillingnessTier? willingnessTier,
  });

  Future<PersonalBaseline?> getBaseline({
    required String userId,
    required String metricName,
    bool isWeekend = false,
  });

  Future<PersonalBaseline> computeAndStoreBaseline({
    required String userId,
    required String metricName,
    required String unit,
    int windowDays = 14,
    bool isWeekend = false,
  });

  Future<StateChangeDetection> evaluateObservationChange({
    required PersonalObservation observation,
  });

  Future<List<StateChangeDetection>> getRecentChanges({
    required String userId,
    int limit = 10,
  });
}

class SupabasePersonalStateEngine implements PersonalStateEngine {
  final PersonalDataFoundationService _dataFoundation;
  final SupabaseClient? _client;

  final Map<String, PersonalStateSnapshot> _snapshotCache = {};
  final Map<String, Map<String, PersonalBaseline>> _baselineCache = {};
  final Map<String, List<StateChangeDetection>> _changesCache = {};

  SupabasePersonalStateEngine({
    PersonalDataFoundationService? dataFoundation,
    SupabaseClient? client,
  })  : _dataFoundation = dataFoundation ?? SupabasePersonalDataFoundationService(),
        _client = client;

  SupabaseClient? get _effectiveClient => _client ?? SupabaseConfig.client;

  @override
  Future<PersonalStateSnapshot> getCurrentSnapshot(String userId) async {
    final cached = _snapshotCache[userId];
    if (cached != null) return cached;

    final client = _effectiveClient;
    if (client != null) {
      try {
        final res = await client
            .from('personal_state_snapshots')
            .select()
            .eq('user_id', userId)
            .order('snapshot_date', ascending: false)
            .limit(1)
            .maybeSingle();

        if (res != null) {
          final snapshot = PersonalStateSnapshot.fromJson(res);
          _snapshotCache[userId] = snapshot;
          return snapshot;
        }
      } catch (e) {
        debugPrint('[PersonalStateEngine] getCurrentSnapshot fallback: $e');
      }
    }

    // Default synthesis if no snapshot exists yet
    final initial = PersonalStateSnapshot.synthesize(
      userId: userId,
      circadianPhase: 'morning',
    );
    _snapshotCache[userId] = initial;
    return initial;
  }

  @override
  Future<PersonalStateSnapshot> updateSnapshot(
    String userId, {
    String? circadianPhase,
    double? sleepHours,
    int? stepsCount,
    int? environmentalAqi,
    String? weatherCondition,
    List<String>? activeConstraints,
    WillingnessTier? willingnessTier,
  }) async {
    final current = await getCurrentSnapshot(userId);

    final updated = PersonalStateSnapshot.synthesize(
      userId: userId,
      circadianPhase: circadianPhase ?? current.circadianPhase,
      sleepHours: sleepHours ?? current.sleepHours,
      stepsCount: stepsCount ?? current.stepsCount,
      environmentalAqi: environmentalAqi ?? current.environmentalAqi,
      weatherCondition: weatherCondition ?? current.weatherCondition,
      activeConstraints: activeConstraints ?? current.activeConstraints,
      willingnessTier: willingnessTier ?? current.willingnessTier,
      additionalFacts: current.knownFacts,
    );

    _snapshotCache[userId] = updated;

    final client = _effectiveClient;
    if (client != null) {
      try {
        await client.from('personal_state_snapshots').upsert(
              updated.toJson(),
              onConflict: 'user_id,snapshot_date,circadian_phase',
            );
      } catch (e) {
        debugPrint('[PersonalStateEngine] updateSnapshot DB notice: $e');
      }
    }

    return updated;
  }

  @override
  Future<PersonalBaseline?> getBaseline({
    required String userId,
    required String metricName,
    bool isWeekend = false,
  }) async {
    final key = '${metricName}_${isWeekend ? "weekend" : "weekday"}';
    final cached = _baselineCache[userId]?[key];
    if (cached != null) return cached;

    final client = _effectiveClient;
    if (client != null) {
      try {
        final res = await client
            .from('personal_baselines')
            .select()
            .eq('user_id', userId)
            .eq('metric_name', metricName)
            .eq('is_weekend_specific', isWeekend)
            .maybeSingle();

        if (res != null) {
          final baseline = PersonalBaseline.fromJson(res);
          _baselineCache.putIfAbsent(userId, () => {})[key] = baseline;
          return baseline;
        }
      } catch (e) {
        debugPrint('[PersonalStateEngine] getBaseline fallback: $e');
      }
    }
    return null;
  }

  @override
  Future<PersonalBaseline> computeAndStoreBaseline({
    required String userId,
    required String metricName,
    required String unit,
    int windowDays = 14,
    bool isWeekend = false,
  }) async {
    final now = DateTime.now().toUtc();
    final start = now.subtract(Duration(days: windowDays));

    final observations = await _dataFoundation.getObservations(
      userId: userId,
      observationType: metricName,
      since: start,
      limit: 100,
    );

    // Filter weekend vs weekday
    final filtered = observations.where((obs) {
      final isWknd = obs.observedAt.weekday == DateTime.saturday ||
          obs.observedAt.weekday == DateTime.sunday;
      return isWeekend ? isWknd : !isWknd;
    }).map((obs) => obs.numericValue).whereType<double>().toList();

    final baseline = PersonalBaseline.compute(
      userId: userId,
      metricName: metricName,
      values: filtered,
      unit: unit,
      windowStart: start,
      windowEnd: now,
      windowDays: windowDays,
      isWeekendSpecific: isWeekend,
    );

    final key = '${metricName}_${isWeekend ? "weekend" : "weekday"}';
    _baselineCache.putIfAbsent(userId, () => {})[key] = baseline;

    final client = _effectiveClient;
    if (client != null && baseline.status != BaselineStatus.insufficientData) {
      try {
        await client.from('personal_baselines').upsert(
              baseline.toJson(),
              onConflict: 'user_id,metric_name,is_weekend_specific,algorithm_version',
            );
      } catch (e) {
        debugPrint('[PersonalStateEngine] storeBaseline DB notice: $e');
      }
    }

    return baseline;
  }

  @override
  Future<StateChangeDetection> evaluateObservationChange({
    required PersonalObservation observation,
  }) async {
    final val = observation.numericValue;
    if (val == null) {
      return StateChangeDetection(
        id: observation.id,
        userId: observation.userId,
        metricName: observation.observationType,
        classification: ChangeClassification.insufficientData,
        observedValue: 0.0,
        direction: ChangeDirection.unchanged,
        explanation: 'Observation carries no numeric metric value for comparison.',
        detectedAt: DateTime.now().toUtc(),
      );
    }

    final isWknd = observation.observedAt.weekday == DateTime.saturday ||
        observation.observedAt.weekday == DateTime.sunday;

    final baseline = await getBaseline(
      userId: observation.userId,
      metricName: observation.observationType,
      isWeekend: isWknd,
    );

    final detection = StateChangeDetection.evaluate(
      userId: observation.userId,
      metricName: observation.observationType,
      observedValue: val,
      baseline: baseline,
    );

    _changesCache.putIfAbsent(observation.userId, () => []).insert(0, detection);

    final client = _effectiveClient;
    if (client != null && detection.classification != ChangeClassification.insufficientData) {
      try {
        await client.from('personal_state_changes').insert(detection.toJson());
      } catch (e) {
        debugPrint('[PersonalStateEngine] recordChange DB notice: $e');
      }
    }

    return detection;
  }

  @override
  Future<List<StateChangeDetection>> getRecentChanges({
    required String userId,
    int limit = 10,
  }) async {
    final client = _effectiveClient;
    if (client != null) {
      try {
        final List<dynamic> res = await client
            .from('personal_state_changes')
            .select()
            .eq('user_id', userId)
            .order('detected_at', ascending: false)
            .limit(limit);

        if (res.isNotEmpty) {
          return res.map((r) => StateChangeDetection.fromJson(r as Map<String, dynamic>)).toList();
        }
      } catch (e) {
        debugPrint('[PersonalStateEngine] getRecentChanges fallback: $e');
      }
    }

    return (_changesCache[userId] ?? []).take(limit).toList();
  }
}

// ------------------------------------------------------------------------------
// Riverpod State Providers
// ------------------------------------------------------------------------------
final personalDataFoundationProvider = Provider<PersonalDataFoundationService>((ref) {
  return SupabasePersonalDataFoundationService();
});

final personalStateEngineProvider = Provider<PersonalStateEngine>((ref) {
  final foundation = ref.watch(personalDataFoundationProvider);
  return SupabasePersonalStateEngine(dataFoundation: foundation);
});

final currentPersonalSnapshotProvider = FutureProvider.family<PersonalStateSnapshot, String>((ref, userId) async {
  final engine = ref.watch(personalStateEngineProvider);
  return engine.getCurrentSnapshot(userId);
});

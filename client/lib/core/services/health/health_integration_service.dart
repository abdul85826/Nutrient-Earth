import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/health/health_data_types.dart';
import '../../domain/health/health_deduplication_engine.dart';
import '../../domain/health/health_platform_adapter.dart';
import 'android_health_connect_adapter.dart';
import 'apple_healthkit_adapter.dart';
import 'unsupported_platform_adapter.dart';

/// Principal Health Integration Service for Nutrient Earth.
/// Automatically binds to Android Health Connect or Apple HealthKit
/// strictly based on Flutter runtime platform APIs (not user auth).
class HealthIntegrationService {
  final HealthPlatformAdapter _adapter;
  final HealthDeduplicationEngine _deduplicator;
  final SupabaseClient? _supabaseClient;

  HealthIntegrationService({
    HealthPlatformAdapter? adapter,
    HealthDeduplicationEngine? deduplicator,
    SupabaseClient? supabaseClient,
  })  : _adapter = adapter ?? _createPlatformAdapter(),
        _deduplicator = deduplicator ?? const HealthDeduplicationEngine(),
        _supabaseClient = supabaseClient;

  /// Detect platform strictly using Flutter Foundation APIs (defaultTargetPlatform).
  /// Never infers or assumes operating system based on authentication providers.
  static HealthPlatformAdapter _createPlatformAdapter() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidHealthConnectAdapter();
      case TargetPlatform.iOS:
        return AppleHealthKitAdapter();
      default:
        return UnsupportedPlatformAdapter(
          reason: 'TargetPlatform.${defaultTargetPlatform.name} is not a supported mobile health platform.',
        );
    }
  }

  /// The active adapter's platform identifier.
  String get activePlatformName => _adapter.platformName;

  /// Check whether health tracking is supported on the device.
  Future<bool> isSupported() async {
    return _adapter.isPlatformSupported();
  }

  /// Check whether Health Connect or HealthKit store is accessible.
  Future<bool> isHealthStoreAvailable() async {
    return _adapter.isHealthStoreAvailable();
  }

  /// Check whether permissions are currently granted for the core categories.
  Future<bool> checkCorePermissions() async {
    return _adapter.checkPermissions(coreCategories);
  }

  /// Request permissions for core categories.
  Future<bool> requestCorePermissions() async {
    return _adapter.requestPermissions(coreCategories);
  }

  /// Core data categories supported by default in Nutrient Earth:
  /// steps, distance, active calories, heart rate, sleep, workouts.
  static const List<HealthDataType> coreCategories = [
    HealthDataType.steps,
    HealthDataType.distance,
    HealthDataType.activeCalories,
    HealthDataType.heartRate,
    HealthDataType.sleep,
    HealthDataType.workout,
    HealthDataType.restingHeartRate,
    HealthDataType.weight,
    HealthDataType.height,
  ];

  /// Synchronize health biometrics for the authenticated user.
  /// Deduplicates records, normalizes units, enforces clinical provenance,
  /// and persists state to Supabase.
  Future<HealthSyncResult> syncHealthData({
    List<HealthDataType> types = coreCategories,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final now = DateTime.now();
    final start = startTime ?? now.subtract(const Duration(days: 7));
    final end = endTime ?? now;

    // 1. Verify platform support
    if (!await isSupported()) {
      return HealthSyncResult(
        success: false,
        errorMessage: 'Platform "$activePlatformName" does not support native health tracking.',
        syncedAt: now,
      );
    }

    // 2. Verify health store availability
    if (!await isHealthStoreAvailable()) {
      return HealthSyncResult(
        success: false,
        errorMessage: 'Health platform store is not available or requires update on this device.',
        syncedAt: now,
      );
    }

    // 3. Ensure permissions are authorized
    final hasPerm = await _adapter.checkPermissions(types);
    if (!hasPerm) {
      final requested = await _adapter.requestPermissions(types);
      if (!requested) {
        return HealthSyncResult(
          success: false,
          errorMessage: 'User denied required health permissions.',
          syncedAt: now,
        );
      }
    }

    // 4. Read raw records from the native platform
    final rawRecords = await _adapter.readRecords(
      types: types,
      startTime: start,
      endTime: end,
    );

    if (rawRecords.isEmpty) {
      await _updateSyncState(
        status: 'synced',
        totalSynced: 0,
        types: types,
      );
      return HealthSyncResult(
        success: true,
        totalRead: 0,
        totalSynced: 0,
        duplicatesSkipped: 0,
        syncedAt: now,
      );
    }

    // 5. Query existing external record IDs and fingerprints for deduplication
    final existingExternalIds = await _fetchExistingExternalIds();
    final existingFingerprints = await _fetchExistingFingerprints();

    // 6. Deduplicate incoming batch
    final uniqueRecords = _deduplicator.deduplicateBatch(
      incoming: rawRecords,
      existingExternalIds: existingExternalIds,
      existingFingerprints: existingFingerprints,
    );

    final duplicatesCount = rawRecords.length - uniqueRecords.length;

    // 7. Persist to Supabase if client is available
    int persistedCount = 0;
    if (_supabaseClient != null && uniqueRecords.isNotEmpty) {
      persistedCount = await _persistRecordsToSupabase(uniqueRecords);
    } else {
      persistedCount = uniqueRecords.length;
    }

    // 8. Update sync state cursor
    await _updateSyncState(
      status: 'synced',
      totalSynced: persistedCount,
      types: types,
    );

    return HealthSyncResult(
      success: true,
      totalRead: rawRecords.length,
      totalSynced: persistedCount,
      duplicatesSkipped: duplicatesCount,
      syncedAt: now,
    );
  }

  /// Retrieve existing external record IDs to prevent re-inserting duplicates.
  Future<Set<String>> _fetchExistingExternalIds() async {
    if (_supabaseClient == null) return {};
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return {};

      final res = await _supabaseClient
          .from('health_measurements')
          .select('source_platform, external_record_id')
          .eq('user_id', user.id)
          .not('external_record_id', 'is', null);

      final ids = <String>{};
      for (final row in res as List) {
        final platform = row['source_platform'] as String?;
        final extId = row['external_record_id'] as String?;
        if (platform != null && extId != null) {
          ids.add('$platform:$extId');
        }
      }
      return ids;
    } catch (_) {
      return {};
    }
  }

  /// Retrieve existing fingerprints for temporal content deduplication.
  Future<Set<String>> _fetchExistingFingerprints() async {
    if (_supabaseClient == null) return {};
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return {};

      final res = await _supabaseClient
          .from('health_measurements')
          .select('metadata')
          .eq('user_id', user.id);

      final fingerprints = <String>{};
      for (final row in res as List) {
        final meta = row['metadata'] as Map<String, dynamic>?;
        if (meta != null && meta['fingerprint'] != null) {
          fingerprints.add(meta['fingerprint'] as String);
        }
      }
      return fingerprints;
    } catch (_) {
      return {};
    }
  }

  /// Batch persist unique health records into Supabase `health_measurements`.
  Future<int> _persistRecordsToSupabase(List<HealthRecord> records) async {
    if (_supabaseClient == null) return 0;
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return 0;

    final rows = records.map((r) {
      final meta = Map<String, dynamic>.from(r.metadata);
      meta['fingerprint'] = r.deterministicFingerprint;

      return {
        'user_id': user.id,
        'metric_name': r.type.name,
        'category': _mapTypeToCategory(r.type),
        'current_value': r.value,
        'unit': r.unit,
        'target_value': 0.0, // Baseline target
        'data_source': r.source.dbValue,
        'source_platform': r.sourcePlatform,
        'device_model': r.deviceModel,
        'external_record_id': r.externalRecordId,
        'recorded_at': r.recordedAt.toUtc().toIso8601String(),
        'end_recorded_at': r.endRecordedAt?.toUtc().toIso8601String(),
        'metadata': meta,
        'last_updated': DateTime.now().toUtc().toIso8601String(),
      };
    }).toList();

    try {
      // Upsert using the unique constraint (user_id, source_platform, external_record_id)
      await _supabaseClient.from('health_measurements').upsert(
        rows,
        onConflict: 'user_id, source_platform, external_record_id',
      );
      return rows.length;
    } catch (_) {
      // Fallback: insert individually ignoring conflict errors
      int saved = 0;
      for (final row in rows) {
        try {
          await _supabaseClient.from('health_measurements').insert(row);
          saved++;
        } catch (_) {}
      }
      return saved;
    }
  }

  /// Update cursor and sync state in `health_sync_state`.
  Future<void> _updateSyncState({
    required String status,
    required int totalSynced,
    required List<HealthDataType> types,
    String? errorMessage,
  }) async {
    if (_supabaseClient == null) return;
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return;

    try {
      await _supabaseClient.from('health_sync_state').upsert({
        'user_id': user.id,
        'platform': activePlatformName,
        'last_synced_at': DateTime.now().toUtc().toIso8601String(),
        'metrics_synced': types.map((e) => e.name).toList(),
        'status': status,
        'error_message': errorMessage,
      }, onConflict: 'user_id, platform');
    } catch (_) {}
  }

  String _mapTypeToCategory(HealthDataType type) {
    switch (type) {
      case HealthDataType.steps:
      case HealthDataType.distance:
      case HealthDataType.activeCalories:
      case HealthDataType.workout:
        return 'activity';
      case HealthDataType.heartRate:
      case HealthDataType.restingHeartRate:
      case HealthDataType.bloodOxygen:
      case HealthDataType.bodyTemperature:
        return 'vitals';
      case HealthDataType.sleep:
        return 'sleep';
      case HealthDataType.weight:
      case HealthDataType.height:
        return 'body';
      case HealthDataType.water:
        return 'nutrition';
    }
  }
}

/// Wearable Ingestion Pipeline for Nutrient Earth BIOS.
///
/// Purpose: Provide a unified ingestion layer that normalizes biometric
/// data from all wearable providers into a canonical BiometricTelemetry model.
///
/// Responsibilities:
/// - Provider adapter contracts for Apple Health, Garmin, Oura etc.
/// - Raw metric normalization to canonical units
/// - Data quality validation and gap detection
/// - Real-time stream ingestion scheduling
///
/// Future expansion:
/// - HealthKit integration (iOS)
/// - Health Connect integration (Android)
/// - BLE sensor direct ingestion
/// - Edge computing for on-device normalization
library;

import '../../core/types/biological_types.dart';
import '../../core/monitoring/observability.dart';

// ─── Canonical Biometric Reading ──────────────────────────────────────────────

class BiometricReading {
  final String userId;
  final WearableProvider source;
  final String metricType;
  final double value;
  final String unit;
  final DateTime recordedAt;
  final double? confidenceScore;
  final Map<String, dynamic> rawMetadata;

  const BiometricReading({
    required this.userId,
    required this.source,
    required this.metricType,
    required this.value,
    required this.unit,
    required this.recordedAt,
    this.confidenceScore,
    this.rawMetadata = const {},
  });

  Map<String, dynamic> toMap() => {
    'user_id': userId,
    'source': source.name,
    'metric_type': metricType,
    'value': value,
    'unit': unit,
    'recorded_at': recordedAt.toIso8601String(),
    'confidence': confidenceScore,
  };
}

/// Standard wearable metric type constants.
class WearableMetrics {
  static const String heartRate = 'heart_rate';
  static const String hrv = 'hrv_rmssd';
  static const String sleepDuration = 'sleep_duration_hours';
  static const String sleepDeep = 'sleep_deep_hours';
  static const String sleepRem = 'sleep_rem_hours';
  static const String steps = 'steps';
  static const String activeCalories = 'active_calories';
  static const String spO2 = 'spo2_percent';
  static const String respiratoryRate = 'respiratory_rate';
  static const String skinTemp = 'skin_temperature_c';
  static const String stress = 'stress_score';
  static const String recoveryScore = 'recovery_score';
  static const String readinessScore = 'readiness_score';
}

// ─── Provider Adapter Contract ────────────────────────────────────────────────

abstract class WearableAdapter {
  WearableProvider get provider;
  bool get isConnected;

  Future<void> connect(Map<String, String> credentials);
  Future<void> disconnect();
  Future<List<BiometricReading>> fetchReadings({
    required String userId,
    required DateTime from,
    required DateTime to,
  });
  Future<List<String>> availableMetrics();
}

// ─── Manual Data Adapter ──────────────────────────────────────────────────────

/// Adapter for user-manually-entered biometric data (no wearable required).
class ManualDataAdapter implements WearableAdapter {
  final List<BiometricReading> _buffer = [];

  @override WearableProvider get provider => WearableProvider.manual;
  @override bool get isConnected => true;

  @override Future<void> connect(Map<String, String> credentials) async {}
  @override Future<void> disconnect() async {}

  @override
  Future<List<BiometricReading>> fetchReadings({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async {
    return _buffer
        .where((r) => r.userId == userId && r.recordedAt.isAfter(from) && r.recordedAt.isBefore(to))
        .toList();
  }

  @override Future<List<String>> availableMetrics() async => [
    WearableMetrics.heartRate, WearableMetrics.sleepDuration,
    WearableMetrics.steps, WearableMetrics.stress,
  ];

  void addManualReading(BiometricReading reading) => _buffer.add(reading);
}

// ─── Wearable Ingestion Orchestrator ─────────────────────────────────────────

class WearableIngestionOrchestrator {
  final Map<WearableProvider, WearableAdapter> _adapters = {};
  final List<BiometricReading> _ingestedBuffer = [];
  final BIOSLogger _log = BIOSLogger.instance;

  void registerAdapter(WearableAdapter adapter) {
    _adapters[adapter.provider] = adapter;
    _log.info('WearableIngestion', 'Registered adapter: ${adapter.provider.name}');
  }

  Future<List<BiometricReading>> ingestAll({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async {
    final allReadings = <BiometricReading>[];

    for (final adapter in _adapters.values) {
      if (!adapter.isConnected) continue;
      try {
        final readings = await adapter.fetchReadings(userId: userId, from: from, to: to);
        allReadings.addAll(readings);
        _log.info('WearableIngestion', 'Ingested ${readings.length} readings from ${adapter.provider.name}');
      } catch (e) {
        _log.warning('WearableIngestion', 'Adapter ${adapter.provider.name} failed: $e');
      }
    }

    _ingestedBuffer.addAll(allReadings);
    return allReadings;
  }

  /// Get the latest value for a specific metric type across all providers.
  BiometricReading? getLatest(String userId, String metricType) {
    final matches = _ingestedBuffer
        .where((r) => r.userId == userId && r.metricType == metricType)
        .toList();
    if (matches.isEmpty) return null;
    matches.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return matches.first;
  }

  int get totalIngested => _ingestedBuffer.length;
}

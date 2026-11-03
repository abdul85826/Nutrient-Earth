import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Supported health and biometric data categories.
enum HealthDataType {
  steps,
  distance,
  activeCalories,
  heartRate,
  restingHeartRate,
  sleep,
  workout,
  weight,
  height,
  bloodOxygen,
  bodyTemperature,
  water;

  String get displayName {
    switch (this) {
      case HealthDataType.steps:
        return 'Steps';
      case HealthDataType.distance:
        return 'Distance';
      case HealthDataType.activeCalories:
        return 'Active Calories';
      case HealthDataType.heartRate:
        return 'Heart Rate';
      case HealthDataType.restingHeartRate:
        return 'Resting Heart Rate';
      case HealthDataType.sleep:
        return 'Sleep';
      case HealthDataType.workout:
        return 'Workout';
      case HealthDataType.weight:
        return 'Body Weight';
      case HealthDataType.height:
        return 'Height';
      case HealthDataType.bloodOxygen:
        return 'Blood Oxygen (SpO2)';
      case HealthDataType.bodyTemperature:
        return 'Body Temperature';
      case HealthDataType.water:
        return 'Hydration';
    }
  }

  String get standardUnit {
    switch (this) {
      case HealthDataType.steps:
        return 'count';
      case HealthDataType.distance:
        return 'm';
      case HealthDataType.activeCalories:
        return 'kcal';
      case HealthDataType.heartRate:
      case HealthDataType.restingHeartRate:
        return 'bpm';
      case HealthDataType.sleep:
        return 'minutes';
      case HealthDataType.workout:
        return 'minutes';
      case HealthDataType.weight:
        return 'kg';
      case HealthDataType.height:
        return 'cm';
      case HealthDataType.bloodOxygen:
        return '%';
      case HealthDataType.bodyTemperature:
        return 'celsius';
      case HealthDataType.water:
        return 'ml';
    }
  }
}

/// Provenance of the biometric record.
/// Distinguishes clinical hardware recordings from user entry and AI estimation.
enum HealthDataSourceType {
  deviceMeasured, // Direct on-device sensors (e.g. phone accelerometer/pedometer)
  wearable,       // Verified connected wearable (Apple Watch, Pixel Watch, Garmin, Oura, Whoop)
  userEntered,    // Self-reported by user in HealthKit/Health Connect UI or app
  aiEstimated;    // Machine learning calculated estimation (never presented as clinical measurement)

  String get dbValue {
    switch (this) {
      case HealthDataSourceType.deviceMeasured:
        return 'deviceMeasured';
      case HealthDataSourceType.wearable:
        return 'wearable';
      case HealthDataSourceType.userEntered:
        return 'userEntered';
      case HealthDataSourceType.aiEstimated:
        return 'aiEstimated';
    }
  }

  static HealthDataSourceType fromDbValue(String value) {
    switch (value) {
      case 'deviceMeasured':
      case 'measured':
        return HealthDataSourceType.deviceMeasured;
      case 'wearable':
        return HealthDataSourceType.wearable;
      case 'userEntered':
      case 'userReported':
        return HealthDataSourceType.userEntered;
      case 'aiEstimated':
        return HealthDataSourceType.aiEstimated;
      default:
        return HealthDataSourceType.userEntered;
    }
  }
}

/// State of the health sync pipeline.
enum HealthSyncStatus {
  idle,
  checkingPermissions,
  requestingPermissions,
  syncing,
  synced,
  permissionDenied,
  unsupported,
  error;

  String get userMessage {
    switch (this) {
      case HealthSyncStatus.idle:
        return 'Health sync ready';
      case HealthSyncStatus.checkingPermissions:
        return 'Checking health permissions...';
      case HealthSyncStatus.requestingPermissions:
        return 'Requesting health access authorization...';
      case HealthSyncStatus.syncing:
        return 'Syncing biometrics with health provider...';
      case HealthSyncStatus.synced:
        return 'Health data synchronized';
      case HealthSyncStatus.permissionDenied:
        return 'Health permissions were not granted';
      case HealthSyncStatus.unsupported:
        return 'Health platform not available on this device';
      case HealthSyncStatus.error:
        return 'An error occurred during health sync';
    }
  }
}

/// An immutable, normalized health record.
class HealthRecord {
  final String id;
  final HealthDataType type;
  final double value;
  final String unit;
  final DateTime recordedAt;
  final DateTime? endRecordedAt;
  final HealthDataSourceType source;
  final String sourcePlatform; // 'android_health_connect' or 'apple_healthkit'
  final String? deviceModel;
  final String? externalRecordId;
  final Map<String, dynamic> metadata;

  HealthRecord({
    required this.id,
    required this.type,
    required this.value,
    required this.unit,
    required this.recordedAt,
    this.endRecordedAt,
    required this.source,
    required this.sourcePlatform,
    this.deviceModel,
    this.externalRecordId,
    Map<String, dynamic>? metadata,
  }) : metadata = metadata ?? const {};

  /// Compute a deterministic fingerprint for content-based deduplication.
  String get deterministicFingerprint {
    final payload = '${type.name}|${value.toStringAsFixed(3)}|$unit|${recordedAt.toUtc().toIso8601String()}|${source.name}|$sourcePlatform';
    return sha256.convert(utf8.encode(payload)).toString();
  }

  /// Ensure clinical integrity: estimates can never masquerade as measured data.
  bool get isClinicallyMeasured =>
      source == HealthDataSourceType.deviceMeasured || source == HealthDataSourceType.wearable;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'value': value,
    'unit': unit,
    'recorded_at': recordedAt.toUtc().toIso8601String(),
    if (endRecordedAt != null) 'end_recorded_at': endRecordedAt!.toUtc().toIso8601String(),
    'source': source.dbValue,
    'source_platform': sourcePlatform,
    if (deviceModel != null) 'device_model': deviceModel,
    if (externalRecordId != null) 'external_record_id': externalRecordId,
    'metadata': metadata,
  };

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'] as String,
      type: HealthDataType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => HealthDataType.steps,
      ),
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String? ?? 'count',
      recordedAt: DateTime.parse(json['recorded_at'] as String),
      endRecordedAt: json['end_recorded_at'] != null ? DateTime.parse(json['end_recorded_at'] as String) : null,
      source: HealthDataSourceType.fromDbValue(json['source'] as String? ?? 'userEntered'),
      sourcePlatform: json['source_platform'] as String? ?? 'unknown',
      deviceModel: json['device_model'] as String?,
      externalRecordId: json['external_record_id'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
    );
  }

  HealthRecord copyWith({
    String? id,
    HealthDataType? type,
    double? value,
    String? unit,
    DateTime? recordedAt,
    DateTime? endRecordedAt,
    HealthDataSourceType? source,
    String? sourcePlatform,
    String? deviceModel,
    String? externalRecordId,
    Map<String, dynamic>? metadata,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      type: type ?? this.type,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      recordedAt: recordedAt ?? this.recordedAt,
      endRecordedAt: endRecordedAt ?? this.endRecordedAt,
      source: source ?? this.source,
      sourcePlatform: sourcePlatform ?? this.sourcePlatform,
      deviceModel: deviceModel ?? this.deviceModel,
      externalRecordId: externalRecordId ?? this.externalRecordId,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Represents the outcome of an incremental sync operation.
class HealthSyncResult {
  final bool success;
  final int totalRead;
  final int totalSynced;
  final int duplicatesSkipped;
  final String? syncCursor;
  final String? errorMessage;
  final DateTime syncedAt;

  const HealthSyncResult({
    required this.success,
    this.totalRead = 0,
    this.totalSynced = 0,
    this.duplicatesSkipped = 0,
    this.syncCursor,
    this.errorMessage,
    required this.syncedAt,
  });

  factory HealthSyncResult.empty() => HealthSyncResult(
    success: true,
    totalRead: 0,
    totalSynced: 0,
    duplicatesSkipped: 0,
    syncedAt: DateTime.now(),
  );

  factory HealthSyncResult.failure(String message) => HealthSyncResult(
    success: false,
    errorMessage: message,
    syncedAt: DateTime.now(),
  );
}


import 'package:flutter/foundation.dart';
import 'package:health/health.dart' as pkh;
import 'package:uuid/uuid.dart';

import '../../domain/health/health_data_types.dart';
import '../../domain/health/health_platform_adapter.dart';
import '../../domain/health/health_unit_converter.dart';

/// Apple HealthKit infrastructure adapter.
/// Uses Apple HealthKit via package:health.
class AppleHealthKitAdapter implements HealthPlatformAdapter {
  final pkh.Health _health;
  final Uuid _uuid;

  AppleHealthKitAdapter({
    pkh.Health? health,
    Uuid? uuid,
  })  : _health = health ?? pkh.Health(),
        _uuid = uuid ?? const Uuid();

  @override
  String get platformName => 'apple_healthkit';

  @override
  Future<bool> isPlatformSupported() async {
    return defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  Future<bool> isHealthStoreAvailable() async {
    if (!await isPlatformSupported()) return false;
    try {
      await _health.configure();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> checkPermissions(List<HealthDataType> types) async {
    if (!await isPlatformSupported()) return false;
    try {
      await _health.configure();
      final pkhTypes = _mapDomainTypesToPlatform(types);
      if (pkhTypes.isEmpty) return true;
      // Caveat: iOS HealthKit intentionally masks READ permission status for privacy.
      // hasPermissions returns null or boolean.
      final hasPerm = await _health.hasPermissions(pkhTypes);
      return hasPerm ?? true; // On iOS, treat null as potentially permitted to allow query
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> requestPermissions(List<HealthDataType> types) async {
    if (!await isPlatformSupported()) return false;
    try {
      await _health.configure();
      final pkhTypes = _mapDomainTypesToPlatform(types);
      if (pkhTypes.isEmpty) return true;
      final granted = await _health.requestAuthorization(pkhTypes);
      return granted;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<HealthRecord>> readRecords({
    required List<HealthDataType> types,
    required DateTime startTime,
    required DateTime endTime,
    String? syncCursor,
  }) async {
    if (!await isPlatformSupported()) return [];
    try {
      await _health.configure();
      final pkhTypes = _mapDomainTypesToPlatform(types);
      if (pkhTypes.isEmpty) return [];

      final dataPoints = await _health.getHealthDataFromTypes(
        types: pkhTypes,
        startTime: startTime,
        endTime: endTime,
      );

      final records = <HealthRecord>[];
      for (final dp in dataPoints) {
        final domainType = _mapPlatformTypeToDomain(dp.type);
        if (domainType == null) continue;

        final rawValue = _extractValue(dp);
        final rawUnit = dp.unitString;
        final normalizedVal = HealthUnitConverter.normalize(domainType, rawValue, rawUnit);

        // Determine source attribution (Apple Watch vs iPhone vs manual)
        final source = _resolveSourceType(dp);

        records.add(
          HealthRecord(
            id: _uuid.v4(),
            type: domainType,
            value: normalizedVal,
            unit: domainType.standardUnit,
            recordedAt: dp.dateFrom,
            endRecordedAt: dp.dateTo,
            source: source,
            sourcePlatform: platformName,
            deviceModel: dp.deviceModel ?? (dp.sourceName.isNotEmpty ? dp.sourceName : 'Apple Device'),
            externalRecordId: dp.uuid.isNotEmpty ? dp.uuid : null,
            metadata: {
              'raw_unit': rawUnit,
              'raw_value': rawValue,
              'source_id': dp.sourceId,
              'source_name': dp.sourceName,
              'device_model': dp.deviceModel,
              'recording_method': dp.recordingMethod.name,
              if (dp.workoutSummary != null)
                'workout_summary': {
                  'activity_type': dp.workoutSummary!.workoutType,
                  'total_distance': dp.workoutSummary!.totalDistance,
                  'total_energy': dp.workoutSummary!.totalEnergyBurned,
                  'total_steps': dp.workoutSummary!.totalSteps,
                },
            },
          ),
        );
      }

      return records;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> revokePermissions() async {
    // HealthKit does not allow programmatic revocation from third-party apps;
    // Users manage HealthKit permissions via iOS Settings -> Health -> Data Access.
  }

  HealthDataSourceType _resolveSourceType(pkh.HealthDataPoint dp) {
    if (dp.recordingMethod == pkh.RecordingMethod.manual) {
      return HealthDataSourceType.userEntered;
    }

    final devModel = (dp.deviceModel ?? '').toLowerCase();
    final nameLower = dp.sourceName.toLowerCase();

    final isWearable = devModel.contains('watch') ||
        nameLower.contains('watch') ||
        nameLower.contains('garmin') ||
        nameLower.contains('oura') ||
        nameLower.contains('whoop');

    if (isWearable) {
      return HealthDataSourceType.wearable;
    }

    return HealthDataSourceType.deviceMeasured;
  }

  double _extractValue(pkh.HealthDataPoint dp) {
    final v = dp.value;
    if (v is pkh.NumericHealthValue) {
      return v.numericValue.toDouble();
    } else if (v is pkh.WorkoutHealthValue) {
      final duration = dp.dateTo.difference(dp.dateFrom).inMinutes;
      return duration > 0 ? duration.toDouble() : 1.0;
    } else if (dp.type == pkh.HealthDataType.SLEEP_ASLEEP ||
               dp.type == pkh.HealthDataType.SLEEP_IN_BED) {
      final duration = dp.dateTo.difference(dp.dateFrom).inMinutes;
      return duration.toDouble();
    }
    return 0.0;
  }

  List<pkh.HealthDataType> _mapDomainTypesToPlatform(List<HealthDataType> types) {
    final result = <pkh.HealthDataType>[];
    for (final t in types) {
      switch (t) {
        case HealthDataType.steps:
          result.add(pkh.HealthDataType.STEPS);
          break;
        case HealthDataType.distance:
          result.add(pkh.HealthDataType.DISTANCE_WALKING_RUNNING);
          break;
        case HealthDataType.activeCalories:
          result.add(pkh.HealthDataType.ACTIVE_ENERGY_BURNED);
          break;
        case HealthDataType.heartRate:
          result.add(pkh.HealthDataType.HEART_RATE);
          break;
        case HealthDataType.restingHeartRate:
          result.add(pkh.HealthDataType.RESTING_HEART_RATE);
          break;
        case HealthDataType.sleep:
          result.add(pkh.HealthDataType.SLEEP_ASLEEP);
          result.add(pkh.HealthDataType.SLEEP_IN_BED);
          break;
        case HealthDataType.workout:
          result.add(pkh.HealthDataType.WORKOUT);
          break;
        case HealthDataType.weight:
          result.add(pkh.HealthDataType.WEIGHT);
          break;
        case HealthDataType.height:
          result.add(pkh.HealthDataType.HEIGHT);
          break;
        case HealthDataType.bloodOxygen:
          result.add(pkh.HealthDataType.BLOOD_OXYGEN);
          break;
        case HealthDataType.bodyTemperature:
          result.add(pkh.HealthDataType.BODY_TEMPERATURE);
          break;
        case HealthDataType.water:
          result.add(pkh.HealthDataType.WATER);
          break;
      }
    }
    return result;
  }

  HealthDataType? _mapPlatformTypeToDomain(pkh.HealthDataType type) {
    switch (type) {
      case pkh.HealthDataType.STEPS:
        return HealthDataType.steps;
      case pkh.HealthDataType.DISTANCE_WALKING_RUNNING:
      case pkh.HealthDataType.DISTANCE_DELTA:
        return HealthDataType.distance;
      case pkh.HealthDataType.ACTIVE_ENERGY_BURNED:
        return HealthDataType.activeCalories;
      case pkh.HealthDataType.HEART_RATE:
        return HealthDataType.heartRate;
      case pkh.HealthDataType.RESTING_HEART_RATE:
        return HealthDataType.restingHeartRate;
      case pkh.HealthDataType.SLEEP_ASLEEP:
      case pkh.HealthDataType.SLEEP_IN_BED:
      case pkh.HealthDataType.SLEEP_DEEP:
      case pkh.HealthDataType.SLEEP_REM:
      case pkh.HealthDataType.SLEEP_LIGHT:
        return HealthDataType.sleep;
      case pkh.HealthDataType.WORKOUT:
        return HealthDataType.workout;
      case pkh.HealthDataType.WEIGHT:
        return HealthDataType.weight;
      case pkh.HealthDataType.HEIGHT:
        return HealthDataType.height;
      case pkh.HealthDataType.BLOOD_OXYGEN:
        return HealthDataType.bloodOxygen;
      case pkh.HealthDataType.BODY_TEMPERATURE:
        return HealthDataType.bodyTemperature;
      case pkh.HealthDataType.WATER:
        return HealthDataType.water;
      default:
        return null;
    }
  }
}


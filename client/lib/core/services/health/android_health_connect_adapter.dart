import 'package:flutter/foundation.dart';
import 'package:health/health.dart' as pkh;
import 'package:uuid/uuid.dart';

import '../../domain/health/health_data_types.dart';
import '../../domain/health/health_platform_adapter.dart';
import '../../domain/health/health_unit_converter.dart';

/// Android Health Connect infrastructure adapter.
/// Integrates with Google Health Connect via package:health.
class AndroidHealthConnectAdapter implements HealthPlatformAdapter {
  final pkh.Health _health;
  final Uuid _uuid;

  AndroidHealthConnectAdapter({pkh.Health? health, Uuid? uuid})
      : _health = health ?? pkh.Health(),
        _uuid = uuid ?? const Uuid();

  @override
  String get platformName => 'android_health_connect';

  @override
  Future<bool> isPlatformSupported() async {
    return defaultTargetPlatform == TargetPlatform.android;
  }

  @override
  Future<bool> isHealthStoreAvailable() async {
    if (!await isPlatformSupported()) return false;
    try {
      final status = await _health.getHealthConnectSdkStatus();
      return status == pkh.HealthConnectSdkStatus.sdkAvailable;
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
      final hasPerm = await _health.hasPermissions(pkhTypes);
      return hasPerm == true;
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
      return await _health.requestAuthorization(pkhTypes);
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
      debugPrint('[HealthConnect] Starting record retrieval for ${types.length} types. Query range: ${startTime.toIso8601String()} to ${endTime.toIso8601String()}');
      final records = <HealthRecord>[];

      for (final domainType in types) {
        final pkhType = _mapSingleDomainTypeToPlatform(domainType);
        if (pkhType == null) {
          debugPrint('[HealthConnect] Skipping unmapped domain type: ${domainType.name}');
          continue;
        }

        try {
          debugPrint('[HealthConnect] Executing query for: ${domainType.name} (native: ${pkhType.name})');
          final dataPoints = await _health.getHealthDataFromTypes(
            types: [pkhType],
            startTime: startTime,
            endTime: endTime,
          );
          debugPrint('[HealthConnect] Query succeeded for ${domainType.name}. Returned ${dataPoints.length} data points.');

          int typeValidCount = 0;
          for (final dp in dataPoints) {
            final mappedType = _mapPlatformTypeToDomain(dp.type) ?? domainType;
            final rawValue = _extractValue(dp);
            if (rawValue == null) {
              debugPrint('[HealthConnect] Discarded ${mappedType.name} point: raw value is null or invalid');
              continue;
            }

            final rawUnit = dp.unitString;
            final normalizedVal = HealthUnitConverter.normalize(mappedType, rawValue, rawUnit);
            if (normalizedVal == null) {
              debugPrint('[HealthConnect] Discarded ${mappedType.name} point: failed unit conversion ($rawValue $rawUnit)');
              continue;
            }

            final source = _resolveSourceType(dp);
            records.add(
              HealthRecord(
                id: _uuid.v4(),
                type: mappedType,
                value: normalizedVal,
                unit: mappedType.standardUnit,
                recordedAt: dp.dateFrom,
                endRecordedAt: dp.dateTo,
                source: source,
                sourcePlatform: platformName,
                deviceModel: dp.sourceName.isNotEmpty ? dp.sourceName : null,
                externalRecordId: dp.uuid.isNotEmpty ? dp.uuid : null,
                metadata: {
                  'native_type': dp.type.name,
                  'raw_unit': rawUnit,
                  'raw_value': rawValue,
                  'source_id': dp.sourceId,
                  'source_name': dp.sourceName,
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
            typeValidCount++;
          }
          debugPrint('[HealthConnect] ${domainType.name}: $typeValidCount records converted successfully.');
        } catch (catError) {
          debugPrint('[HealthConnect] Query for category ${domainType.name} failed: $catError');
        }
      }

      debugPrint('[HealthConnect] Retrieval complete. Total records gathered: ${records.length}');
      return records;
    } catch (e) {
      debugPrint('[HealthConnect] Top-level readRecords failed: $e');
      if (e is HealthAdapterException) rethrow;
      throw HealthAdapterException('Health Connect read failed', e);
    }
  }

  pkh.HealthDataType? _mapSingleDomainTypeToPlatform(HealthDataType type) {
    final list = _mapDomainTypesToPlatform([type]);
    return list.isNotEmpty ? list.first : null;
  }

  @override
  Future<void> revokePermissions() async {
    if (!await isPlatformSupported()) return;
    try {
      await _health.revokePermissions();
    } catch (_) {}
  }

  HealthDataSourceType _resolveSourceType(pkh.HealthDataPoint dp) {
    if (dp.recordingMethod == pkh.RecordingMethod.manual) {
      return HealthDataSourceType.userEntered;
    }
    final nameLower = dp.sourceName.toLowerCase();
    if (nameLower.contains('watch') ||
        nameLower.contains('band') ||
        nameLower.contains('garmin') ||
        nameLower.contains('fitbit') ||
        nameLower.contains('oura') ||
        nameLower.contains('whoop') ||
        nameLower.contains('polar')) {
      return HealthDataSourceType.wearable;
    }
    return HealthDataSourceType.deviceMeasured;
  }

  double? _extractValue(pkh.HealthDataPoint dp) {
    final v = dp.value;
    if (v is pkh.NumericHealthValue) {
      final num = v.numericValue.toDouble();
      return (num.isNaN || num.isInfinite) ? null : num;
    } else if (v is pkh.WorkoutHealthValue) {
      // Return duration in minutes
      final duration = dp.dateTo.difference(dp.dateFrom).inMinutes;
      return duration > 0 ? duration.toDouble() : 1.0;
    } else if (dp.type == pkh.HealthDataType.SLEEP_SESSION ||
               dp.type == pkh.HealthDataType.SLEEP_ASLEEP) {
      final duration = dp.dateTo.difference(dp.dateFrom).inMinutes;
      return duration >= 0 ? duration.toDouble() : null;
    }
    return null;
  }

  List<pkh.HealthDataType> _mapDomainTypesToPlatform(List<HealthDataType> types) {
    final result = <pkh.HealthDataType>[];
    for (final t in types) {
      switch (t) {
        case HealthDataType.steps:
          result.add(pkh.HealthDataType.STEPS);
          break;
        case HealthDataType.distance:
          result.add(pkh.HealthDataType.DISTANCE_DELTA);
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
          result.add(pkh.HealthDataType.SLEEP_SESSION);
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
      case pkh.HealthDataType.DISTANCE_DELTA:
        return HealthDataType.distance;
      case pkh.HealthDataType.ACTIVE_ENERGY_BURNED:
        return HealthDataType.activeCalories;
      case pkh.HealthDataType.HEART_RATE:
        return HealthDataType.heartRate;
      case pkh.HealthDataType.RESTING_HEART_RATE:
        return HealthDataType.restingHeartRate;
      case pkh.HealthDataType.SLEEP_SESSION:
      case pkh.HealthDataType.SLEEP_ASLEEP:
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

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/domain/health/health_data_types.dart';
import 'package:nutrient_earth_client/core/domain/health/health_deduplication_engine.dart';
import 'package:nutrient_earth_client/core/domain/health/health_platform_adapter.dart';
import 'package:nutrient_earth_client/core/domain/health/health_unit_converter.dart';
import 'package:nutrient_earth_client/core/services/health/android_health_connect_adapter.dart';
import 'package:nutrient_earth_client/core/services/health/apple_healthkit_adapter.dart';
import 'package:nutrient_earth_client/core/services/health/health_integration_service.dart';
import 'package:nutrient_earth_client/core/services/health/unsupported_platform_adapter.dart';

/// Test mock implementation of [HealthPlatformAdapter].
class MockHealthPlatformAdapter implements HealthPlatformAdapter {
  final String _name;
  final bool supported;
  final bool storeAvailable;
  bool permissionsGranted;
  final List<HealthRecord> recordsToReturn;

  MockHealthPlatformAdapter({
    String name = 'mock_health_platform',
    this.supported = true,
    this.storeAvailable = true,
    this.permissionsGranted = true,
    this.recordsToReturn = const [],
  }) : _name = name;

  @override
  String get platformName => _name;

  @override
  Future<bool> isPlatformSupported() async => supported;

  @override
  Future<bool> isHealthStoreAvailable() async => storeAvailable;

  @override
  Future<bool> checkPermissions(List<HealthDataType> types) async => permissionsGranted;

  @override
  Future<bool> requestPermissions(List<HealthDataType> types) async {
    permissionsGranted = true;
    return true;
  }

  @override
  Future<List<HealthRecord>> readRecords({
    required List<HealthDataType> types,
    required DateTime startTime,
    required DateTime endTime,
    String? syncCursor,
  }) async {
    return recordsToReturn;
  }

  @override
  Future<void> revokePermissions() async {
    permissionsGranted = false;
  }
}

void main() {
  group('1. OS Detection & Platform Routing', () {
    test('Unsupported platform resolves cleanly without exceptions', () async {
      final unsupported = UnsupportedPlatformAdapter(reason: 'Desktop test environment');
      expect(unsupported.platformName, 'unsupported_platform');
      expect(await unsupported.isPlatformSupported(), isFalse);
      expect(await unsupported.isHealthStoreAvailable(), isFalse);
      expect(await unsupported.checkPermissions([HealthDataType.steps]), isFalse);
      expect(await unsupported.requestPermissions([HealthDataType.steps]), isFalse);
      final records = await unsupported.readRecords(
        types: [HealthDataType.steps],
        startTime: DateTime.now().subtract(const Duration(days: 1)),
        endTime: DateTime.now(),
      );
      expect(records, isEmpty);
    });

    test('Android Health Connect adapter reports android_health_connect platform name', () {
      final adapter = AndroidHealthConnectAdapter();
      expect(adapter.platformName, 'android_health_connect');
    });

    test('Apple HealthKit adapter reports apple_healthkit platform name', () {
      final adapter = AppleHealthKitAdapter();
      expect(adapter.platformName, 'apple_healthkit');
    });

    test('HealthIntegrationService uses injected adapter or default platform abstraction', () {
      final mockAdapter = MockHealthPlatformAdapter(name: 'test_platform');
      final service = HealthIntegrationService(adapter: mockAdapter);
      expect(service.activePlatformName, 'test_platform');
    });
  });

  group('2. Clinical Data Integrity & Attribution', () {
    final now = DateTime.utc(2026, 11, 3, 12, 0, 0);

    test('Clinical measurement distinction: deviceMeasured vs wearable vs userEntered vs aiEstimated', () {
      final measured = HealthRecord(
        id: 'rec-1',
        type: HealthDataType.steps,
        value: 8432.0,
        unit: 'count',
        recordedAt: now,
        source: HealthDataSourceType.deviceMeasured,
        sourcePlatform: 'android_health_connect',
      );

      final wearable = HealthRecord(
        id: 'rec-2',
        type: HealthDataType.heartRate,
        value: 72.0,
        unit: 'bpm',
        recordedAt: now,
        source: HealthDataSourceType.wearable,
        sourcePlatform: 'apple_healthkit',
        deviceModel: 'Apple Watch Ultra 2',
      );

      final userReported = HealthRecord(
        id: 'rec-3',
        type: HealthDataType.weight,
        value: 74.5,
        unit: 'kg',
        recordedAt: now,
        source: HealthDataSourceType.userEntered,
        sourcePlatform: 'manual',
      );

      final aiEstimated = HealthRecord(
        id: 'rec-4',
        type: HealthDataType.activeCalories,
        value: 450.0,
        unit: 'kcal',
        recordedAt: now,
        source: HealthDataSourceType.aiEstimated,
        sourcePlatform: 'ai_estimation',
      );

      expect(measured.isClinicallyMeasured, isTrue);
      expect(wearable.isClinicallyMeasured, isTrue);
      expect(userReported.isClinicallyMeasured, isFalse);
      expect(aiEstimated.isClinicallyMeasured, isFalse); // Never represent estimates as measured clinical data
    });

    test('HealthRecord serializes and deserializes accurately with source retention', () {
      final record = HealthRecord(
        id: 'rec-json-test',
        type: HealthDataType.bloodOxygen,
        value: 98.5,
        unit: '%',
        recordedAt: now,
        source: HealthDataSourceType.wearable,
        sourcePlatform: 'apple_healthkit',
        deviceModel: 'Apple Watch Series 9',
        externalRecordId: 'hk-spo2-9901',
        metadata: {'sensor': 'optical_photoplethysmography'},
      );

      final json = record.toJson();
      expect(json['source'], 'wearable');
      expect(json['source_platform'], 'apple_healthkit');
      expect(json['external_record_id'], 'hk-spo2-9901');

      final deserialized = HealthRecord.fromJson(json);
      expect(deserialized.id, record.id);
      expect(deserialized.type, HealthDataType.bloodOxygen);
      expect(deserialized.value, 98.5);
      expect(deserialized.source, HealthDataSourceType.wearable);
      expect(deserialized.externalRecordId, 'hk-spo2-9901');
    });
  });

  group('3. Unit Normalization Engine', () {
    test('Steps normalization clamps and rounds to integer counts, rejecting invalid numbers', () {
      expect(HealthUnitConverter.normalizeSteps(10234.7), 10235.0);
      expect(HealthUnitConverter.normalizeSteps(-50.0), isNull);
      expect(HealthUnitConverter.normalizeSteps(double.nan), isNull);
      expect(HealthUnitConverter.normalizeSteps(double.infinity), isNull);
    });

    test('Heart rate and oxygen normalization rejects non-numeric and implausible values', () {
      expect(HealthUnitConverter.normalizeHeartRate(72.4), 72.4);
      expect(HealthUnitConverter.normalizeHeartRate(-10.0), isNull);
      expect(HealthUnitConverter.normalizeHeartRate(350.0), isNull);
      expect(HealthUnitConverter.normalizeHeartRate(double.nan), isNull);

      expect(HealthUnitConverter.normalizeBloodOxygen(0.98), 98.0);
      expect(HealthUnitConverter.normalizeBloodOxygen(-5.0), isNull);
      expect(HealthUnitConverter.normalizeBloodOxygen(150.0), isNull);
      expect(HealthUnitConverter.normalizeBloodOxygen(double.nan), isNull);
    });

    test('Distance normalization accurately converts miles, km, and feet to meters', () {
      expect(HealthUnitConverter.normalizeDistanceToMeters(5.0, 'km'), closeTo(5000.0, 0.1));
      expect(HealthUnitConverter.normalizeDistanceToMeters(1.0, 'mi'), closeTo(1609.344, 0.1));
      expect(HealthUnitConverter.normalizeDistanceToMeters(100.0, 'ft'), closeTo(30.48, 0.1));
      expect(HealthUnitConverter.normalizeDistanceToMeters(1500.0, 'm'), 1500.0);
    });

    test('Calories normalization accurately converts Joules and kJ to kcal', () {
      expect(HealthUnitConverter.normalizeCaloriesToKcal(4184.0, 'joules'), closeTo(1.0, 0.01));
      expect(HealthUnitConverter.normalizeCaloriesToKcal(4.184, 'kj'), closeTo(1.0, 0.01));
      expect(HealthUnitConverter.normalizeCaloriesToKcal(350.0, 'kcal'), 350.0);
    });

    test('Weight and height normalization handles pounds, stone, and inches', () {
      expect(HealthUnitConverter.normalizeWeightToKg(150.0, 'lbs'), closeTo(68.04, 0.1));
      expect(HealthUnitConverter.normalizeWeightToKg(10.0, 'stone'), closeTo(63.50, 0.1));
      expect(HealthUnitConverter.normalizeHeightToCm(70.0, 'inches'), closeTo(177.8, 0.1));
      expect(HealthUnitConverter.normalizeHeightToCm(1.80, 'm'), closeTo(180.0, 0.1));
    });

    test('Temperature and blood oxygen normalization', () {
      expect(HealthUnitConverter.normalizeTemperatureToCelsius(98.6, 'fahrenheit'), closeTo(37.0, 0.1));
      expect(HealthUnitConverter.normalizeBloodOxygen(0.98), 98.0);
      expect(HealthUnitConverter.normalizeBloodOxygen(99.0), 99.0);
    });
  });

  group('4. Deduplication Engine', () {
    const deduplicator = HealthDeduplicationEngine();
    final t1 = DateTime.utc(2026, 11, 3, 10, 0, 0);

    test('Distinct sleep stages with same start time produce unique deterministic fingerprints', () {
      final tStart = DateTime.utc(2026, 11, 3, 23, 0, 0);
      final tEnd1 = DateTime.utc(2026, 11, 3, 23, 30, 0);
      final tEnd2 = DateTime.utc(2026, 11, 4, 0, 15, 0);

      final sleepStage1 = HealthRecord(
        id: 'sleep-1',
        type: HealthDataType.sleep,
        value: 30.0,
        unit: 'minutes',
        recordedAt: tStart,
        endRecordedAt: tEnd1,
        source: HealthDataSourceType.wearable,
        sourcePlatform: 'apple_healthkit',
        metadata: const {'native_type': 'HKCategoryValueSleepAnalysisAsleepREM'},
      );

      final sleepStage2 = HealthRecord(
        id: 'sleep-2',
        type: HealthDataType.sleep,
        value: 75.0,
        unit: 'minutes',
        recordedAt: tStart,
        endRecordedAt: tEnd2,
        source: HealthDataSourceType.wearable,
        sourcePlatform: 'apple_healthkit',
        metadata: const {'native_type': 'HKCategoryValueSleepAnalysisAsleepCore'},
      );

      expect(sleepStage1.deterministicFingerprint, isNot(equals(sleepStage2.deterministicFingerprint)));
    });

    test('Eliminates duplicates by externalRecordId', () {
      final rec1 = HealthRecord(
        id: '1',
        type: HealthDataType.steps,
        value: 1200.0,
        unit: 'count',
        recordedAt: t1,
        source: HealthDataSourceType.deviceMeasured,
        sourcePlatform: 'android_health_connect',
        externalRecordId: 'hc-step-uuid-1234',
      );

      final rec2Duplicate = HealthRecord(
        id: '2',
        type: HealthDataType.steps,
        value: 1200.0,
        unit: 'count',
        recordedAt: t1,
        source: HealthDataSourceType.deviceMeasured,
        sourcePlatform: 'android_health_connect',
        externalRecordId: 'hc-step-uuid-1234',
      );

      final rec3Unique = HealthRecord(
        id: '3',
        type: HealthDataType.steps,
        value: 800.0,
        unit: 'count',
        recordedAt: t1.add(const Duration(hours: 1)),
        source: HealthDataSourceType.deviceMeasured,
        sourcePlatform: 'android_health_connect',
        externalRecordId: 'hc-step-uuid-5678',
      );

      final result = deduplicator.deduplicateBatch(
        incoming: [rec1, rec2Duplicate, rec3Unique],
      );

      expect(result.length, 2);
      expect(result.map((e) => e.externalRecordId), containsAll(['hc-step-uuid-1234', 'hc-step-uuid-5678']));
    });

    test('Eliminates duplicates matching existing persistent database external IDs', () {
      final rec1 = HealthRecord(
        id: '1',
        type: HealthDataType.heartRate,
        value: 68.0,
        unit: 'bpm',
        recordedAt: t1,
        source: HealthDataSourceType.wearable,
        sourcePlatform: 'apple_healthkit',
        externalRecordId: 'existing-hk-record-001',
      );

      final rec2 = HealthRecord(
        id: '2',
        type: HealthDataType.heartRate,
        value: 74.0,
        unit: 'bpm',
        recordedAt: t1.add(const Duration(minutes: 5)),
        source: HealthDataSourceType.wearable,
        sourcePlatform: 'apple_healthkit',
        externalRecordId: 'fresh-hk-record-002',
      );

      final result = deduplicator.deduplicateBatch(
        incoming: [rec1, rec2],
        existingExternalIds: {'apple_healthkit:existing-hk-record-001'},
      );

      expect(result.length, 1);
      expect(result.first.externalRecordId, 'fresh-hk-record-002');
    });

    test('Aggregates incremental step records into daily totals', () {
      final day1 = DateTime.utc(2026, 11, 3, 8, 0, 0);
      final day2 = DateTime.utc(2026, 11, 4, 8, 0, 0);

      final records = [
        HealthRecord(
          id: '1',
          type: HealthDataType.steps,
          value: 3000.0,
          unit: 'count',
          recordedAt: day1,
          source: HealthDataSourceType.deviceMeasured,
          sourcePlatform: 'android_health_connect',
        ),
        HealthRecord(
          id: '2',
          type: HealthDataType.steps,
          value: 4500.0,
          unit: 'count',
          recordedAt: day1.add(const Duration(hours: 4)),
          source: HealthDataSourceType.deviceMeasured,
          sourcePlatform: 'android_health_connect',
        ),
        HealthRecord(
          id: '3',
          type: HealthDataType.steps,
          value: 6200.0,
          unit: 'count',
          recordedAt: day2,
          source: HealthDataSourceType.deviceMeasured,
          sourcePlatform: 'android_health_connect',
        ),
      ];

      final dailyTotals = deduplicator.aggregateDailyTotals(
        records: records,
        targetType: HealthDataType.steps,
      );

      final d1Key = DateTime.utc(2026, 11, 3);
      final d2Key = DateTime.utc(2026, 11, 4);

      expect(dailyTotals[d1Key], 7500.0);
      expect(dailyTotals[d2Key], 6200.0);
    });
  });

  group('5. HealthIntegrationService End-to-End Orchestration', () {
    final now = DateTime.utc(2026, 11, 3, 14, 0, 0);

    test('Successful sync flow returns complete HealthSyncResult', () async {
      final sampleRecords = [
        HealthRecord(
          id: 'r1',
          type: HealthDataType.steps,
          value: 5000.0,
          unit: 'count',
          recordedAt: now,
          source: HealthDataSourceType.deviceMeasured,
          sourcePlatform: 'mock_provider',
          externalRecordId: 'ext-101',
        ),
        HealthRecord(
          id: 'r2',
          type: HealthDataType.heartRate,
          value: 72.0,
          unit: 'bpm',
          recordedAt: now,
          source: HealthDataSourceType.wearable,
          sourcePlatform: 'mock_provider',
          externalRecordId: 'ext-102',
        ),
      ];

      final mockAdapter = MockHealthPlatformAdapter(
        name: 'mock_provider',
        recordsToReturn: sampleRecords,
      );

      final service = HealthIntegrationService(adapter: mockAdapter);
      final result = await service.syncHealthData();

      expect(result.success, isTrue);
      expect(result.totalRead, 2);
      expect(result.totalSynced, 2);
      expect(result.duplicatesSkipped, 0);
      expect(result.categoryMetrics[HealthDataType.steps], 5000.0);
      expect(result.categoryMetrics[HealthDataType.heartRate], 72.0);
      expect(result.categoryCounts[HealthDataType.steps], 1);
      expect(result.categoryCounts[HealthDataType.heartRate], 1);
    });

    test('Sync handles permission rejection gracefully', () async {
      final mockAdapter = MockHealthPlatformAdapter(
        name: 'mock_provider',
        permissionsGranted: false,
      );

      // Force requestPermissions to fail
      final failingAdapter = _FailingPermissionAdapter(mockAdapter);
      final service = HealthIntegrationService(adapter: failingAdapter);
      final result = await service.syncHealthData();

      expect(result.success, isFalse);
      expect(result.errorMessage, contains('denied'));
    });

    test('Sync handles unsupported platform gracefully', () async {
      final unsupported = UnsupportedPlatformAdapter(reason: 'Test platform unsupported');
      final service = HealthIntegrationService(adapter: unsupported);
      final result = await service.syncHealthData();

      expect(result.success, isFalse);
      expect(result.errorMessage, contains('does not support native health tracking'));
    });

    test('Sync handles adapter read exceptions gracefully', () async {
      final mockAdapter = MockHealthPlatformAdapter(
        name: 'mock_provider',
        permissionsGranted: true,
      );
      final throwingAdapter = _ThrowingReadAdapter(mockAdapter);
      final service = HealthIntegrationService(adapter: throwingAdapter);
      final result = await service.syncHealthData();

      expect(result.success, isFalse);
      expect(result.failureReason, equals(HealthSyncFailureReason.adapterReadError));
      expect(result.errorMessage, contains('Health Connect read failed'));
    });
  });
}

class _ThrowingReadAdapter implements HealthPlatformAdapter {
  final HealthPlatformAdapter delegate;
  _ThrowingReadAdapter(this.delegate);

  @override
  String get platformName => delegate.platformName;
  @override
  Future<bool> isPlatformSupported() => delegate.isPlatformSupported();
  @override
  Future<bool> isHealthStoreAvailable() => delegate.isHealthStoreAvailable();
  @override
  Future<bool> checkPermissions(List<HealthDataType> types) async => true;
  @override
  Future<bool> requestPermissions(List<HealthDataType> types) async => true;
  @override
  Future<List<HealthRecord>> readRecords({
    required List<HealthDataType> types,
    required DateTime startTime,
    required DateTime endTime,
    String? syncCursor,
  }) async {
    throw const HealthAdapterException('Health Connect read failed unexpectedly');
  }
  @override
  Future<void> revokePermissions() => delegate.revokePermissions();
}

class _FailingPermissionAdapter implements HealthPlatformAdapter {
  final HealthPlatformAdapter delegate;
  _FailingPermissionAdapter(this.delegate);

  @override
  String get platformName => delegate.platformName;
  @override
  Future<bool> isPlatformSupported() => delegate.isPlatformSupported();
  @override
  Future<bool> isHealthStoreAvailable() => delegate.isHealthStoreAvailable();
  @override
  Future<bool> checkPermissions(List<HealthDataType> types) async => false;
  @override
  Future<bool> requestPermissions(List<HealthDataType> types) async => false;
  @override
  Future<List<HealthRecord>> readRecords({
    required List<HealthDataType> types,
    required DateTime startTime,
    required DateTime endTime,
    String? syncCursor,
  }) => delegate.readRecords(types: types, startTime: startTime, endTime: endTime);
  @override
  Future<void> revokePermissions() => delegate.revokePermissions();
}


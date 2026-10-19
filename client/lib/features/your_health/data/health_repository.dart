import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/supabase_config.dart';
import '../domain/health_profile.dart';
import '../domain/measurement.dart';

final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthRepository();
});

final healthProfileProvider = FutureProvider<HealthProfile>((ref) async {
  final repo = ref.watch(healthRepositoryProvider);
  return repo.getProfile();
});

final healthMeasurementsProvider = FutureProvider<List<HealthMeasurement>>((
  ref,
) async {
  final repo = ref.watch(healthRepositoryProvider);
  return repo.getMeasurements();
});

class HealthRepository {
  // In-memory baseline verified data
  HealthProfile _profile = const HealthProfile(
    userId: 'usr-default-01',
    displayName: 'Alex Mercer',
    age: 34,
    biologicalSex: 'Male',
    primaryGoals: [
      'Cardiorespiratory Endurance',
      'Metabolic Flexibility',
      'Deep Sleep Optimization',
    ],
    activityLevel: 'Moderately Active (4x/week)',
    dietaryPreference: 'Mediterranean / Whole Food',
    budgetConstraint: 'Moderate',
    willingnessToChange: WillingnessToChange.high,
    knownConditions: ['Mild Seasonal Allergies'],
    activeSupplements: [
      'Vitamin D3 2000IU',
      'Omega-3 EPA/DHA',
      'Magnesium Glycinate',
    ],
  );

  List<HealthMeasurement> _measurements = [
    HealthMeasurement(
      id: 'm-01',
      metricName: 'Fasting Blood Glucose',
      category: 'Metabolic',
      currentValue: 88.0,
      unit: 'mg/dL',
      targetValue: 85.0,
      normalRangeMin: 70.0,
      normalRangeMax: 99.0,
      dataSource: DataSourceType.measured,
      lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
      history: [
        HealthDataPoint(
          timestamp: DateTime.now().subtract(const Duration(days: 14)),
          value: 94.0,
        ),
        HealthDataPoint(
          timestamp: DateTime.now().subtract(const Duration(days: 10)),
          value: 91.0,
        ),
        HealthDataPoint(
          timestamp: DateTime.now().subtract(const Duration(days: 6)),
          value: 89.0,
        ),
        HealthDataPoint(
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          value: 88.0,
        ),
      ],
      note: 'Venous blood draw assay at clinical laboratory.',
    ),
    HealthMeasurement(
      id: 'm-02',
      metricName: 'Resting Heart Rate',
      category: 'Cardiovascular',
      currentValue: 52.0,
      unit: 'bpm',
      targetValue: 50.0,
      normalRangeMin: 48.0,
      normalRangeMax: 68.0,
      dataSource: DataSourceType.measured,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 4)),
      history: [
        HealthDataPoint(
          timestamp: DateTime.now().subtract(const Duration(days: 7)),
          value: 56.0,
        ),
        HealthDataPoint(
          timestamp: DateTime.now().subtract(const Duration(days: 5)),
          value: 54.0,
        ),
        HealthDataPoint(
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          value: 53.0,
        ),
        HealthDataPoint(
          timestamp: DateTime.now().subtract(const Duration(hours: 4)),
          value: 52.0,
        ),
      ],
      note: '30-day moving average captured by calibrated optical sensor.',
    ),
    HealthMeasurement(
      id: 'm-03',
      metricName: 'Deep Sleep Duration',
      category: 'Sleep',
      currentValue: 1.7,
      unit: 'hours',
      targetValue: 1.8,
      normalRangeMin: 1.2,
      normalRangeMax: 2.2,
      dataSource: DataSourceType.userReported,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 10)),
      history: [
        HealthDataPoint(
          timestamp: DateTime.now().subtract(const Duration(days: 4)),
          value: 1.4,
        ),
        HealthDataPoint(
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          value: 1.5,
        ),
        HealthDataPoint(
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          value: 1.6,
        ),
        HealthDataPoint(
          timestamp: DateTime.now().subtract(const Duration(hours: 10)),
          value: 1.7,
        ),
      ],
      note: 'Logged from morning self-report and sleep journal.',
    ),
    HealthMeasurement(
      id: 'm-04',
      metricName: 'Estimated VO2 Max',
      category: 'Cardiovascular',
      currentValue: 46.5,
      unit: 'mL/kg/min',
      targetValue: 50.0,
      normalRangeMin: 38.0,
      normalRangeMax: 54.0,
      dataSource: DataSourceType.aiEstimated,
      lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
      history: [
        HealthDataPoint(
          timestamp: DateTime.now().subtract(const Duration(days: 21)),
          value: 44.0,
        ),
        HealthDataPoint(
          timestamp: DateTime.now().subtract(const Duration(days: 14)),
          value: 45.2,
        ),
        HealthDataPoint(
          timestamp: DateTime.now().subtract(const Duration(days: 7)),
          value: 46.0,
        ),
        HealthDataPoint(
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          value: 46.5,
        ),
      ],
      note: 'Modeled via sub-maximal exercise heart rate curve and pace dynamics. Note: correlation does not guarantee clinical VO2 max accuracy.',
    ),
    HealthMeasurement(
      id: 'm-05',
      metricName: 'Serum 25(OH)D',
      category: 'Metabolic',
      currentValue: 47.0,
      unit: 'ng/mL',
      targetValue: 50.0,
      normalRangeMin: 30.0,
      normalRangeMax: 70.0,
      dataSource: DataSourceType.measured,
      lastUpdated: DateTime.now().subtract(const Duration(days: 30)),
      history: [
        HealthDataPoint(
          timestamp: DateTime.now().subtract(const Duration(days: 90)),
          value: 32.0,
        ),
        HealthDataPoint(
          timestamp: DateTime.now().subtract(const Duration(days: 30)),
          value: 47.0,
        ),
      ],
      note: 'Liquid chromatography tandem mass spectrometry assay.',
    ),
  ];

  Future<HealthProfile> getProfile() async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        final res = await client
            .from('profiles')
            .select()
            .eq('user_id', _profile.userId)
            .maybeSingle();
        if (res != null) {
          _profile = HealthProfile.fromJson(res);
        }
      } catch (_) {}
    }
    return _profile;
  }

  Future<void> updateProfile(HealthProfile updated) async {
    _profile = updated;
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        await client.from('profiles').upsert(updated.toJson());
      } catch (_) {}
    }
  }

  Future<List<HealthMeasurement>> getMeasurements() async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        final res = await client.from('health_measurements').select();
        if (res.isNotEmpty) {
          _measurements = (res as List)
              .map((e) => HealthMeasurement.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } catch (_) {}
    }
    return List.unmodifiable(_measurements);
  }

  Future<void> addMeasurement(HealthMeasurement measurement) async {
    _measurements = [
      ..._measurements.where((m) => m.id != measurement.id),
      measurement,
    ];
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        await client.from('health_measurements').upsert(measurement.toJson());
      } catch (_) {}
    }
  }

  /// Generates a structured JSON export of the user's health profile and verified measurements.
  Future<String> exportHealthReportJson() async {
    final exportData = {
      'exported_at': DateTime.now().toIso8601String(),
      'platform': 'Nutrient Earth Continuous Health Intelligence',
      'disclaimer': 'Exported for personal information only. Does not constitute clinical medical diagnosis.',
      'profile': _profile.toJson(),
      'measurements': _measurements.map((m) => m.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(exportData);
  }
}

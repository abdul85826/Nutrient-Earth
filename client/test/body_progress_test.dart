import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/features/your_health/data/health_repository.dart';
import 'package:nutrient_earth_client/features/your_health/domain/measurement.dart';

void main() {
  group('Body & Progress Data Verification Tests', () {
    late HealthRepository repository;

    setUp(() {
      repository = HealthRepository();
    });

    test('Loads baseline measurements and verifies provenance tags', () async {
      final measurements = await repository.getMeasurements();

      expect(measurements.isNotEmpty, true);

      // Verify distinction between measured, user-reported, and AI-estimated
      final measuredList = measurements
          .where((m) => m.dataSource == DataSourceType.measured)
          .toList();
      final reportedList = measurements
          .where((m) => m.dataSource == DataSourceType.userReported)
          .toList();
      final estimatedList = measurements
          .where((m) => m.dataSource == DataSourceType.aiEstimated)
          .toList();

      expect(measuredList.isNotEmpty, true);
      expect(reportedList.isNotEmpty, true);
      expect(estimatedList.isNotEmpty, true);

      // Check glucose is measured
      final glucose = measurements.firstWhere(
        (m) => m.metricName.contains('Glucose'),
      );
      expect(glucose.dataSource, DataSourceType.measured);
      expect(glucose.isInNormalRange, true);

      // Check VO2 Max is AI-estimated
      final vo2 = measurements.firstWhere((m) => m.metricName.contains('VO2'));
      expect(vo2.dataSource, DataSourceType.aiEstimated);
    });

    test(
      'Export health report produces valid JSON containing profile and metrics',
      () async {
        final jsonString = await repository.exportHealthReportJson();
        expect(jsonString.isNotEmpty, true);

        final decoded = json.decode(jsonString) as Map<String, dynamic>;
        expect(decoded.containsKey('profile'), true);
        expect(decoded.containsKey('measurements'), true);
        expect(
          decoded['disclaimer'].toString().contains(
            'Does not constitute clinical medical diagnosis',
          ),
          true,
        );

        final profile = decoded['profile'] as Map<String, dynamic>;
        expect(profile['display_name'], 'Alex Mercer');
        expect(profile['age'], 34);

        final measurements = decoded['measurements'] as List<dynamic>;
        expect(measurements.length >= 5, true);
      },
    );
  });
}

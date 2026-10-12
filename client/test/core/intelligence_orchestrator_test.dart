import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth/core/intelligence/intelligence_contracts.dart';
import 'package:nutrient_earth/core/intelligence/intelligence_orchestrator.dart';
import 'package:nutrient_earth/core/intelligence/product_intelligence_catalog.dart';
import 'package:nutrient_earth/core/network/environmental_service.dart';

void main() {
  group('Intelligence Architecture Tests', () {
    test(
      'ProductIntelligenceCatalog retrieves peer-reviewed clinical citations',
      () {
        final citations = ProductIntelligenceCatalog.findRelevantEvidence(
          'pea protein',
        );
        expect(citations, isNotEmpty);
        expect(citations.any((c) => c.id == 'EV_BABAULT_2015'), isTrue);
      },
    );

    test(
      'IntelligenceOrchestrator synthesizes 5-domain intelligence plan',
      () async {
        final orchestrator = IntelligenceOrchestrator();
        final task = AgentTask(
          id: 'task_001',
          query: 'Pea protein muscle synthesis',
          inputType: QueryInputType.text,
          timestamp: DateTime.now(),
        );

        final env = EnvironmentalMetrics(
          latitude: 37.77,
          longitude: -122.41,
          temperatureC: 21.5,
          relativeHumidity: 55.0,
          apparentTemperatureC: 21.0,
          uvIndex: 4.2,
          weatherCode: 1,
          pm25: 12.0,
          usAqi: 45,
          timestamp: DateTime.now(),
          isReal: true,
        );

        final plan = await orchestrator.orchestrate(
          task,
          environmentalContext: env,
        );

        expect(plan.taskId, equals('task_001'));
        expect(plan.domainFindings.length, equals(5));
        expect(plan.verifiedClaims, isNotEmpty);
        expect(plan.overallConfidence, greaterThan(0.8));
      },
    );
  });
}

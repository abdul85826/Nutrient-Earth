// ==============================================================================
// Nutrient Earth — Operational Observability & Telemetry Tests (Phase 5)
// 1. Distributed trace span lifecycle & duration measurement
// 2. Model inference token and cost tracking
// 3. Health synchronization provenance metrics
// 4. Dead-letter queue (DLQ) ingestion and failure audit
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/services/observability/operational_telemetry_service.dart';

void main() {
  group('Phase 5 — Operational Observability & Telemetry', () {
    setUp(() {
      OperationalTelemetryService.clearForTesting();
    });

    test('Trace spans record execution timing and span attributes', () async {
      final span = OperationalTelemetryService.startSpan(
        'ResearchPipeline.execute',
        attributes: {'query': 'calories in 2 eggs', 'provider': 'USDA_FDC'},
      );

      expect(span.name, equals('ResearchPipeline.execute'));
      expect(span.durationMs, isNull);

      await Future<void>.delayed(const Duration(milliseconds: 20));
      span.finish(status: SpanStatus.ok);

      expect(span.durationMs, isNotNull);
      expect(span.durationMs!, greaterThanOrEqualTo(15));
      expect(span.status, equals(SpanStatus.ok));
    });

    test('Tracks model token consumption and estimated inference costs', () {
      OperationalTelemetryService.recordInference(
        model: 'gemini-1.5-flash',
        provider: 'Google Vertex AI',
        inputTokens: 1200,
        outputTokens: 450,
        latencyMs: 380,
        containsPersonalHealthData: false,
      );

      final metrics = OperationalTelemetryService.inferenceHistory;
      expect(metrics.length, equals(1));

      final item = metrics.first;
      expect(item.model, equals('gemini-1.5-flash'));
      expect(item.inputTokens, equals(1200));
      expect(item.outputTokens, equals(450));
      expect(item.latencyMs, equals(380));
      expect(item.estimatedCostUsd, greaterThan(0.0));
      expect(item.containsPersonalHealthData, isFalse);
    });

    test('Records wearable health sync provenance and duration', () {
      OperationalTelemetryService.recordHealthSync(
        platform: 'health_connect',
        recordsProcessed: 42,
        durationMs: 125,
        isSuccess: true,
      );

      final history = OperationalTelemetryService.healthSyncHistory;
      expect(history.length, equals(1));
      expect(history.first.platform, equals('health_connect'));
      expect(history.first.recordsProcessed, equals(42));
      expect(history.first.isSuccess, isTrue);
    });

    test('Dead-letter queue retains failed jobs with snippets and retry counts', () {
      OperationalTelemetryService.pushToDeadLetterQueue(
        pipeline: 'WebCrawler',
        payloadSnippet: 'https://broken-endpoint.org/data',
        failureReason: 'SocketException: Connection refused',
        retryCount: 5,
      );

      final dlq = OperationalTelemetryService.deadLetterQueue;
      expect(dlq.length, equals(1));
      expect(dlq.first.pipeline, equals('WebCrawler'));
      expect(dlq.first.retryCount, equals(5));
      expect(dlq.first.failureReason, contains('Connection refused'));
    });
  });
}


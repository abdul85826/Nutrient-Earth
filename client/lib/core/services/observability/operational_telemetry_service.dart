// ==============================================================================
// Nutrient Earth — Operational Observability & Telemetry Service
// OpenTelemetry-aligned telemetry tracing:
// 1. Model inference metrics: latency (ms), input/output token counts, and cost.
// 2. Health sync provenance: record count, source provider (Health Connect/HealthKit).
// 3. Dead-letter queue (DLQ) for failed background ingestions and outbox notarizations.
// ==============================================================================

import 'package:uuid/uuid.dart';

enum SpanStatus { ok, error }

class TraceSpan {
  final String traceId;
  final String spanId;
  final String? parentSpanId;
  final String name;
  final DateTime startTime;
  DateTime? endTime;
  int? durationMs;
  final Map<String, dynamic> attributes;
  SpanStatus status;
  String? errorMessage;

  TraceSpan({
    required this.traceId,
    required this.spanId,
    this.parentSpanId,
    required this.name,
    required this.startTime,
    this.attributes = const {},
    this.status = SpanStatus.ok,
  });

  void finish({SpanStatus status = SpanStatus.ok, String? errorMessage}) {
    endTime = DateTime.now();
    durationMs = endTime!.difference(startTime).inMilliseconds;
    this.status = status;
    this.errorMessage = errorMessage;
  }

  Map<String, dynamic> toJson() => {
        'traceId': traceId,
        'spanId': spanId,
        'parentSpanId': parentSpanId,
        'name': name,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'durationMs': durationMs,
        'attributes': attributes,
        'status': status.name,
        'errorMessage': errorMessage,
      };
}

class InferenceMetric {
  final String model;
  final String provider;
  final int inputTokens;
  final int outputTokens;
  final int latencyMs;
  final double estimatedCostUsd;
  final bool containsPersonalHealthData;
  final DateTime recordedAt;

  const InferenceMetric({
    required this.model,
    required this.provider,
    required this.inputTokens,
    required this.outputTokens,
    required this.latencyMs,
    required this.estimatedCostUsd,
    required this.containsPersonalHealthData,
    required this.recordedAt,
  });

  Map<String, dynamic> toJson() => {
        'model': model,
        'provider': provider,
        'inputTokens': inputTokens,
        'outputTokens': outputTokens,
        'totalTokens': inputTokens + outputTokens,
        'latencyMs': latencyMs,
        'estimatedCostUsd': estimatedCostUsd,
        'containsPersonalHealthData': containsPersonalHealthData,
        'recordedAt': recordedAt.toIso8601String(),
      };
}

class HealthSyncMetric {
  final String platform; // 'health_connect' or 'apple_healthkit'
  final int recordsProcessed;
  final int durationMs;
  final bool isSuccess;
  final DateTime syncedAt;

  const HealthSyncMetric({
    required this.platform,
    required this.recordsProcessed,
    required this.durationMs,
    required this.isSuccess,
    required this.syncedAt,
  });
}

class DeadLetterQueueItem {
  final String id;
  final String pipeline;
  final String payloadSnippet;
  final String failureReason;
  final int retryCount;
  final DateTime failedAt;

  const DeadLetterQueueItem({
    required this.id,
    required this.pipeline,
    required this.payloadSnippet,
    required this.failureReason,
    required this.retryCount,
    required this.failedAt,
  });
}

class OperationalTelemetryService {
  OperationalTelemetryService._();

  static const _uuid = Uuid();
  static final List<TraceSpan> _spans = [];
  static final List<InferenceMetric> _inferenceMetrics = [];
  static final List<HealthSyncMetric> _healthSyncMetrics = [];
  static final List<DeadLetterQueueItem> _deadLetterQueue = [];

  static TraceSpan startSpan(String name, {String? traceId, Map<String, dynamic>? attributes}) {
    final span = TraceSpan(
      traceId: traceId ?? _uuid.v4(),
      spanId: _uuid.v4(),
      name: name,
      startTime: DateTime.now(),
      attributes: attributes ?? {},
    );
    _spans.add(span);
    return span;
  }

  static void recordInference({
    required String model,
    required String provider,
    required int inputTokens,
    required int outputTokens,
    required int latencyMs,
    required bool containsPersonalHealthData,
  }) {
    // Standard blended token cost model ($0.15/1M input, $0.60/1M output)
    final inputCost = (inputTokens / 1000000.0) * 0.15;
    final outputCost = (outputTokens / 1000000.0) * 0.60;
    final totalCost = inputCost + outputCost;

    _inferenceMetrics.add(
      InferenceMetric(
        model: model,
        provider: provider,
        inputTokens: inputTokens,
        outputTokens: outputTokens,
        latencyMs: latencyMs,
        estimatedCostUsd: totalCost,
        containsPersonalHealthData: containsPersonalHealthData,
        recordedAt: DateTime.now(),
      ),
    );
  }

  static void recordHealthSync({
    required String platform,
    required int recordsProcessed,
    required int durationMs,
    required bool isSuccess,
  }) {
    _healthSyncMetrics.add(
      HealthSyncMetric(
        platform: platform,
        recordsProcessed: recordsProcessed,
        durationMs: durationMs,
        isSuccess: isSuccess,
        syncedAt: DateTime.now(),
      ),
    );
  }

  static void pushToDeadLetterQueue({
    required String pipeline,
    required String payloadSnippet,
    required String failureReason,
    required int retryCount,
  }) {
    _deadLetterQueue.add(
      DeadLetterQueueItem(
        id: _uuid.v4(),
        pipeline: pipeline,
        payloadSnippet: payloadSnippet,
        failureReason: failureReason,
        retryCount: retryCount,
        failedAt: DateTime.now(),
      ),
    );
  }

  static List<InferenceMetric> get inferenceHistory => List.unmodifiable(_inferenceMetrics);
  static List<HealthSyncMetric> get healthSyncHistory => List.unmodifiable(_healthSyncMetrics);
  static List<DeadLetterQueueItem> get deadLetterQueue => List.unmodifiable(_deadLetterQueue);

  static void clearForTesting() {
    _spans.clear();
    _inferenceMetrics.clear();
    _healthSyncMetrics.clear();
    _deadLetterQueue.clear();
  }
}


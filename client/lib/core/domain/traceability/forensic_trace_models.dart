// ==============================================================================
// Nutrient Earth — End-to-End Forensic Traceability Models
// OpenTelemetry-compatible distributed trace contexts and spans.
// Enforces zero-trust baggage filtering: NO secrets, NO tokens, NO PII.
// ==============================================================================

import 'package:uuid/uuid.dart';

enum TraceSpanStatus {
  ok,
  error,
  cancelled;

  String get value => name;
}

/// Trace baggage sanitizer: strips sensitive data, tokens, and patient PII
class TraceBaggageSanitizer {
  TraceBaggageSanitizer._();

  static final List<RegExp> _sensitivePatterns = [
    RegExp(r'bearer\s+[a-zA-Z0-9_\-\.]+', caseSensitive: false),
    RegExp(r'(key|secret|password|token|auth|credential)\s*[:=]\s*[^\s]+', caseSensitive: false),
    RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,7}\b'), // Emails
    RegExp(r'\b\d{3}-\d{2}-\d{4}\b'), // SSN
    RegExp(r'\b\d{10,12}\b'), // Phone/Aadhaar
  ];

  static Map<String, dynamic> sanitizeAttributes(Map<String, dynamic> raw) {
    final sanitized = <String, dynamic>{};
    for (final entry in raw.entries) {
      final key = entry.key.toLowerCase();
      // Drop keys that inherently carry private credentials or clinical narrative
      if (key.contains('secret') ||
          key.contains('password') ||
          key.contains('authorization') ||
          key.contains('cookie') ||
          key.contains('api_key') ||
          key.contains('token')) {
        continue;
      }

      final val = entry.value;
      if (val is String) {
        String cleanVal = val;
        for (final pattern in _sensitivePatterns) {
          cleanVal = cleanVal.replaceAll(pattern, '[REDACTED_SENSITIVE]');
        }
        sanitized[entry.key] = cleanVal;
      } else if (val is Map<String, dynamic>) {
        sanitized[entry.key] = sanitizeAttributes(val);
      } else {
        sanitized[entry.key] = val;
      }
    }
    return sanitized;
  }
}

/// OpenTelemetry-compatible distributed trace context
class ForensicTraceContext {
  final String traceId;
  final String requestId;
  final String? sessionId;
  final String? actorId;
  final String tenantId;
  final String entryOperationType;
  final String serviceVersion;
  final DateTime startTime;
  final Map<String, dynamic> sanitizedBaggage;

  const ForensicTraceContext({
    required this.traceId,
    required this.requestId,
    this.sessionId,
    this.actorId,
    this.tenantId = 'default',
    required this.entryOperationType,
    this.serviceVersion = '2.0.0',
    required this.startTime,
    this.sanitizedBaggage = const {},
  });

  factory ForensicTraceContext.start({
    required String entryOperationType,
    String? actorId,
    String? sessionId,
    String? existingTraceId,
    String? requestId,
    Map<String, dynamic>? rawBaggage,
  }) {
    final now = DateTime.now().toUtc();
    return ForensicTraceContext(
      traceId: existingTraceId ?? const Uuid().v4(),
      requestId: requestId ?? const Uuid().v4(),
      sessionId: sessionId,
      actorId: actorId,
      entryOperationType: entryOperationType,
      startTime: now,
      sanitizedBaggage: rawBaggage != null ? TraceBaggageSanitizer.sanitizeAttributes(rawBaggage) : const {},
    );
  }

  ForensicTraceContext withActor(String actorId) {
    return ForensicTraceContext(
      traceId: traceId,
      requestId: requestId,
      sessionId: sessionId,
      actorId: actorId,
      tenantId: tenantId,
      entryOperationType: entryOperationType,
      serviceVersion: serviceVersion,
      startTime: startTime,
      sanitizedBaggage: sanitizedBaggage,
    );
  }

  Map<String, dynamic> toCarrier() {
    return {
      'traceparent': '00-$traceId-$requestId-01',
      'x-request-id': requestId,
      'x-tenant-id': tenantId,
      'x-service-version': serviceVersion,
    };
  }
}

/// Individual timed operation span in the forensic trace tree
class TraceSpan {
  final String id;
  final String traceId;
  final String spanId;
  final String? parentSpanId;
  final String operationName;
  final String serviceComponent;
  final TraceSpanStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationMs;
  final Map<String, dynamic> sanitizedAttributes;
  final Map<String, dynamic>? errorDetails;

  const TraceSpan({
    required this.id,
    required this.traceId,
    required this.spanId,
    this.parentSpanId,
    required this.operationName,
    required this.serviceComponent,
    this.status = TraceSpanStatus.ok,
    required this.startTime,
    this.endTime,
    this.durationMs,
    this.sanitizedAttributes = const {},
    this.errorDetails,
  });

  TraceSpan finish({
    TraceSpanStatus status = TraceSpanStatus.ok,
    Map<String, dynamic>? additionalAttributes,
    Map<String, dynamic>? errorDetails,
  }) {
    final finishTime = DateTime.now().toUtc();
    final elapsed = finishTime.difference(startTime).inMilliseconds;
    final merged = Map<String, dynamic>.from(sanitizedAttributes);
    if (additionalAttributes != null) {
      merged.addAll(TraceBaggageSanitizer.sanitizeAttributes(additionalAttributes));
    }

    return TraceSpan(
      id: id,
      traceId: traceId,
      spanId: spanId,
      parentSpanId: parentSpanId,
      operationName: operationName,
      serviceComponent: serviceComponent,
      status: status,
      startTime: startTime,
      endTime: finishTime,
      durationMs: elapsed,
      sanitizedAttributes: merged,
      errorDetails: errorDetails,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trace_id': traceId,
      'span_id': spanId,
      'parent_span_id': parentSpanId,
      'operation_name': operationName,
      'service_component': serviceComponent,
      'status': status.value,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'duration_ms': durationMs,
      'sanitized_attributes': sanitizedAttributes,
      'error_details': errorDetails,
    };
  }
}

// ==============================================================================
// Nutrient Earth — End-to-End Forensic Traceability Service
// Provides OpenTelemetry-compatible tracing across Flutter UI, Central Orchestrator,
// 8 Bounded Specialists, Database RPCs, and Asynchronous Workers.
// Enforces zero-trust baggage filtering: NO secrets, NO tokens, NO PII.
// ==============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../config/supabase_config.dart';
import '../../domain/traceability/forensic_trace_models.dart';

abstract class ForensicTraceService {
  ForensicTraceContext startTrace({
    required String entryOperationType,
    String? actorId,
    String? sessionId,
    String? existingTraceId,
    String? requestId,
    Map<String, dynamic>? rawBaggage,
  });

  TraceSpan startSpan({
    required ForensicTraceContext trace,
    required String operationName,
    required String serviceComponent,
    String? parentSpanId,
    Map<String, dynamic>? attributes,
  });

  Future<void> endSpan(
    TraceSpan span, {
    TraceSpanStatus status = TraceSpanStatus.ok,
    Map<String, dynamic>? additionalAttributes,
    Map<String, dynamic>? errorDetails,
  });

  Future<void> endTrace(
    ForensicTraceContext trace, {
    required String status,
    String? errorSummary,
    Map<String, dynamic>? correlationIdentifiers,
  });

  Future<List<TraceSpan>> getSpansForTrace(String traceId);
}

class DefaultForensicTraceService implements ForensicTraceService {
  final SupabaseClient? _supabase;

  // In-memory trace store for offline operation, unit tests, and fast spans
  final Map<String, ForensicTraceContext> _activeTraces = {};
  final Map<String, List<TraceSpan>> _traceSpans = {};

  DefaultForensicTraceService({SupabaseClient? supabase})
      : _supabase = supabase ?? (SupabaseConfig.isInitialized ? Supabase.instance.client : null);

  @override
  ForensicTraceContext startTrace({
    required String entryOperationType,
    String? actorId,
    String? sessionId,
    String? existingTraceId,
    String? requestId,
    Map<String, dynamic>? rawBaggage,
  }) {
    final context = ForensicTraceContext.start(
      entryOperationType: entryOperationType,
      actorId: actorId,
      sessionId: sessionId,
      existingTraceId: existingTraceId,
      requestId: requestId,
      rawBaggage: rawBaggage,
    );

    _activeTraces[context.traceId] = context;
    _traceSpans[context.traceId] = [];

    if (_supabase != null) {
      _supabase!.from('forensic_traces').insert({
        'trace_id': context.traceId,
        'request_id': context.requestId,
        'session_id': context.sessionId,
        'actor_id': context.actorId,
        'tenant_id': context.tenantId,
        'entry_operation_type': context.entryOperationType,
        'service_version': context.serviceVersion,
        'status': 'started',
        'start_time': context.startTime.toIso8601String(),
        'correlation_identifiers': context.sanitizedBaggage,
      }).then((_) {}).catchError((e) {
        debugPrint('[ForensicTraceService] Supabase insert trace error: $e');
      });
    }

    return context;
  }

  @override
  TraceSpan startSpan({
    required ForensicTraceContext trace,
    required String operationName,
    required String serviceComponent,
    String? parentSpanId,
    Map<String, dynamic>? attributes,
  }) {
    final span = TraceSpan(
      id: const Uuid().v4(),
      traceId: trace.traceId,
      spanId: const Uuid().v4(),
      parentSpanId: parentSpanId,
      operationName: operationName,
      serviceComponent: serviceComponent,
      startTime: DateTime.now().toUtc(),
      sanitizedAttributes: attributes != null ? TraceBaggageSanitizer.sanitizeAttributes(attributes) : const {},
    );

    _traceSpans.putIfAbsent(trace.traceId, () => []).add(span);
    return span;
  }

  @override
  Future<void> endSpan(
    TraceSpan span, {
    TraceSpanStatus status = TraceSpanStatus.ok,
    Map<String, dynamic>? additionalAttributes,
    Map<String, dynamic>? errorDetails,
  }) async {
    final finishedSpan = span.finish(
      status: status,
      additionalAttributes: additionalAttributes,
      errorDetails: errorDetails,
    );

    final list = _traceSpans[span.traceId];
    if (list != null) {
      final index = list.indexWhere((s) => s.spanId == span.spanId);
      if (index != -1) {
        list[index] = finishedSpan;
      } else {
        list.add(finishedSpan);
      }
    }

    if (_supabase != null) {
      try {
        await _supabase!.from('trace_spans').upsert(finishedSpan.toJson());
      } catch (e) {
        debugPrint('[ForensicTraceService] Supabase upsert span error: $e');
      }
    }
  }

  @override
  Future<void> endTrace(
    ForensicTraceContext trace, {
    required String status,
    String? errorSummary,
    Map<String, dynamic>? correlationIdentifiers,
  }) async {
    final endTime = DateTime.now().toUtc();
    final durationMs = endTime.difference(trace.startTime).inMilliseconds;

    if (_supabase != null) {
      try {
        await _supabase!.from('forensic_traces').update({
          'status': status,
          'end_time': endTime.toIso8601String(),
          'duration_ms': durationMs,
          'error_summary': errorSummary,
          if (correlationIdentifiers != null)
            'correlation_identifiers': TraceBaggageSanitizer.sanitizeAttributes(correlationIdentifiers),
        }).eq('trace_id', trace.traceId);
      } catch (e) {
        debugPrint('[ForensicTraceService] Supabase end trace error: $e');
      }
    }
  }

  @override
  Future<List<TraceSpan>> getSpansForTrace(String traceId) async {
    if (_traceSpans.containsKey(traceId)) {
      return _traceSpans[traceId]!;
    }

    if (_supabase != null) {
      try {
        final res = await _supabase!
            .from('trace_spans')
            .select()
            .eq('trace_id', traceId)
            .order('start_time', ascending: true);
        return (res as List).map((e) => TraceSpan(
          id: e['id'] as String,
          traceId: e['trace_id'] as String,
          spanId: e['span_id'] as String,
          parentSpanId: e['parent_span_id'] as String?,
          operationName: e['operation_name'] as String,
          serviceComponent: e['service_component'] as String,
          status: TraceSpanStatus.values.firstWhere((s) => s.value == e['status'], orElse: () => TraceSpanStatus.ok),
          startTime: DateTime.parse(e['start_time'] as String),
          endTime: e['end_time'] != null ? DateTime.parse(e['end_time'] as String) : null,
          durationMs: e['duration_ms'] as int?,
          sanitizedAttributes: (e['sanitized_attributes'] as Map<String, dynamic>?) ?? {},
          errorDetails: e['error_details'] as Map<String, dynamic>?,
        )).toList();
      } catch (e) {
        debugPrint('[ForensicTraceService] Supabase fetch spans error: $e');
      }
    }

    return const [];
  }
}

final forensicTraceServiceProvider = Provider<ForensicTraceService>((ref) {
  return DefaultForensicTraceService();
});

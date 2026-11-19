// ==============================================================================
// Nutrient Earth — Transactional Outbox & Durable Job Service
// Asynchronous event execution with exponential backoff, dead-letter routing,
// and idempotency deduplication.
// ==============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_config.dart';
import '../../domain/outbox/durable_job_models.dart';

abstract class TransactionalOutboxService {
  Future<TransactionalOutboxEvent> publishEvent({
    required String traceId,
    required String aggregateType,
    required String aggregateId,
    required String eventType,
    required Map<String, dynamic> payload,
    int maxRetries = 5,
    String? idempotencyKey,
  });

  Future<List<TransactionalOutboxEvent>> getPendingEvents();

  Future<void> processEvent({
    required String eventId,
    required Future<void> Function(TransactionalOutboxEvent event) handler,
  });

  Future<List<TransactionalOutboxEvent>> getDeadLetterQueue();
}

class DefaultTransactionalOutboxService implements TransactionalOutboxService {
  final SupabaseClient? _supabase;

  // In-memory queue for deterministic unit tests and offline processing
  final List<TransactionalOutboxEvent> _outbox = [];

  DefaultTransactionalOutboxService({SupabaseClient? supabase})
      : _supabase = supabase ?? (SupabaseConfig.isInitialized ? Supabase.instance.client : null);

  @override
  Future<TransactionalOutboxEvent> publishEvent({
    required String traceId,
    required String aggregateType,
    required String aggregateId,
    required String eventType,
    required Map<String, dynamic> payload,
    int maxRetries = 5,
    String? idempotencyKey,
  }) async {
    // Deduplication via idempotency key
    if (idempotencyKey != null) {
      final existing = _outbox.cast<TransactionalOutboxEvent?>().firstWhere(
        (e) => e?.idempotencyKey == idempotencyKey,
        orElse: () => null,
      );
      if (existing != null) {
        return existing;
      }
    }

    final event = TransactionalOutboxEvent.create(
      traceId: traceId,
      aggregateType: aggregateType,
      aggregateId: aggregateId,
      eventType: eventType,
      payload: payload,
      maxRetries: maxRetries,
      idempotencyKey: idempotencyKey,
    );

    _outbox.add(event);

    if (_supabase != null) {
      try {
        await _supabase!.from('transactional_outbox').insert(event.toJson());
      } catch (e) {
        debugPrint('[TransactionalOutboxService] Supabase insert outbox event error: $e');
      }
    }

    return event;
  }

  @override
  Future<List<TransactionalOutboxEvent>> getPendingEvents() async {
    final now = DateTime.now().toUtc();
    return _outbox
        .where((e) =>
            (e.status == OutboxJobStatus.pending || e.status == OutboxJobStatus.failed) &&
            e.nextRetryAt.isBefore(now))
        .toList();
  }

  @override
  Future<void> processEvent({
    required String eventId,
    required Future<void> Function(TransactionalOutboxEvent event) handler,
  }) async {
    final index = _outbox.indexWhere((e) => e.id == eventId);
    if (index == -1) return;

    final event = _outbox[index];

    try {
      await handler(event);
      _outbox[index] = event.markCompleted();

      if (_supabase != null) {
        try {
          await _supabase!.from('transactional_outbox').update({
            'status': 'completed',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          }).eq('id', eventId);
        } catch (e) {
          debugPrint('[TransactionalOutboxService] Supabase update complete error: $e');
        }
      }
    } catch (e) {
      final failed = event.recordFailure(reason: e.toString());
      _outbox[index] = failed;

      if (_supabase != null) {
        try {
          await _supabase!.from('transactional_outbox').update(failed.toJson()).eq('id', eventId);
        } catch (dbErr) {
          debugPrint('[TransactionalOutboxService] Supabase update failure error: $dbErr');
        }
      }
    }
  }

  @override
  Future<List<TransactionalOutboxEvent>> getDeadLetterQueue() async {
    return _outbox.where((e) => e.status == OutboxJobStatus.deadLetter).toList();
  }
}

final transactionalOutboxServiceProvider = Provider<TransactionalOutboxService>((ref) {
  return DefaultTransactionalOutboxService();
});

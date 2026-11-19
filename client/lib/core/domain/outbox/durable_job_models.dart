// ==============================================================================
// Nutrient Earth — Durable Job & Transactional Outbox Models
// Asynchronous event execution with exponential backoff, dead-letter routing,
// and idempotency deduplication.
// ==============================================================================

import 'dart:math';
import 'package:uuid/uuid.dart';

enum OutboxJobStatus {
  pending,
  processing,
  completed,
  failed,
  deadLetter;

  String get value => name;

  static OutboxJobStatus fromString(String val) {
    switch (val) {
      case 'processing':
        return OutboxJobStatus.processing;
      case 'completed':
        return OutboxJobStatus.completed;
      case 'failed':
        return OutboxJobStatus.failed;
      case 'dead_letter':
        return OutboxJobStatus.deadLetter;
      default:
        return OutboxJobStatus.pending;
    }
  }
}

class TransactionalOutboxEvent {
  final String id;
  final String traceId;
  final String aggregateType;
  final String aggregateId;
  final String eventType;
  final Map<String, dynamic> payload;
  final OutboxJobStatus status;
  final int retryCount;
  final int maxRetries;
  final DateTime nextRetryAt;
  final String? deadLetterReason;
  final String? idempotencyKey;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionalOutboxEvent({
    required this.id,
    required this.traceId,
    required this.aggregateType,
    required this.aggregateId,
    required this.eventType,
    required this.payload,
    this.status = OutboxJobStatus.pending,
    this.retryCount = 0,
    this.maxRetries = 5,
    required this.nextRetryAt,
    this.deadLetterReason,
    this.idempotencyKey,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionalOutboxEvent.create({
    required String traceId,
    required String aggregateType,
    required String aggregateId,
    required String eventType,
    required Map<String, dynamic> payload,
    int maxRetries = 5,
    String? idempotencyKey,
  }) {
    final now = DateTime.now().toUtc();
    return TransactionalOutboxEvent(
      id: const Uuid().v4(),
      traceId: traceId,
      aggregateType: aggregateType,
      aggregateId: aggregateId,
      eventType: eventType,
      payload: payload,
      maxRetries: maxRetries,
      nextRetryAt: now,
      idempotencyKey: idempotencyKey,
      createdAt: now,
      updatedAt: now,
    );
  }

  TransactionalOutboxEvent recordFailure({required String reason}) {
    final nextRetry = retryCount + 1;
    final now = DateTime.now().toUtc();

    if (nextRetry >= maxRetries) {
      return TransactionalOutboxEvent(
        id: id,
        traceId: traceId,
        aggregateType: aggregateType,
        aggregateId: aggregateId,
        eventType: eventType,
        payload: payload,
        status: OutboxJobStatus.deadLetter,
        retryCount: nextRetry,
        maxRetries: maxRetries,
        nextRetryAt: now,
        deadLetterReason: 'Exhausted $maxRetries attempts. Final failure: $reason',
        idempotencyKey: idempotencyKey,
        createdAt: createdAt,
        updatedAt: now,
      );
    }

    // Exponential backoff: base 2 seconds with random jitter
    final baseSeconds = pow(2, nextRetry).toInt();
    final jitter = Random().nextInt(500); // 0-500ms
    final delay = Duration(seconds: baseSeconds, milliseconds: jitter);

    return TransactionalOutboxEvent(
      id: id,
      traceId: traceId,
      aggregateType: aggregateType,
      aggregateId: aggregateId,
      eventType: eventType,
      payload: payload,
      status: OutboxJobStatus.failed,
      retryCount: nextRetry,
      maxRetries: maxRetries,
      nextRetryAt: now.add(delay),
      deadLetterReason: reason,
      idempotencyKey: idempotencyKey,
      createdAt: createdAt,
      updatedAt: now,
    );
  }

  TransactionalOutboxEvent markCompleted() {
    return TransactionalOutboxEvent(
      id: id,
      traceId: traceId,
      aggregateType: aggregateType,
      aggregateId: aggregateId,
      eventType: eventType,
      payload: payload,
      status: OutboxJobStatus.completed,
      retryCount: retryCount,
      maxRetries: maxRetries,
      nextRetryAt: nextRetryAt,
      idempotencyKey: idempotencyKey,
      createdAt: createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trace_id': traceId,
      'aggregate_type': aggregateType,
      'aggregate_id': aggregateId,
      'event_type': eventType,
      'payload': payload,
      'status': status.value,
      'retry_count': retryCount,
      'max_retries': maxRetries,
      'next_retry_at': nextRetryAt.toIso8601String(),
      'dead_letter_reason': deadLetterReason,
      'idempotency_key': idempotencyKey,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

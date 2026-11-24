// ==============================================================================
// Nutrient Earth — Reproducible AI Execution, Outbox & Recovery Tests
// Verifies:
// 1. Immutable AI execution records (hashes, model versions, prompt versions)
// 2. Deterministic exact replay vs best-effort live replay
// 3. Transactional Outbox durability, idempotency deduplication, and dead-letter routing
// 4. Disaster recovery targets (RPO 1h, RTO 4h, AES-256-GCM) and restore simulation
// 5. Privacy-preserving operational observability (p95 latency, zero PII alerts)
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:nutrient_earth_client/core/domain/governance/governance_version_models.dart';
import 'package:nutrient_earth_client/core/domain/outbox/durable_job_models.dart';
import 'package:nutrient_earth_client/core/services/governance/reproducible_execution_service.dart';
import 'package:nutrient_earth_client/core/services/observability/operational_observability_service.dart';
import 'package:nutrient_earth_client/core/services/outbox/transactional_outbox_service.dart';
import 'package:nutrient_earth_client/core/services/recovery/disaster_recovery_service.dart';

void main() {
  group('Reproducible AI Execution & Replay Tests', () {
    late DefaultReproducibleExecutionService executionService;

    setUp(() {
      executionService = DefaultReproducibleExecutionService(supabase: null);
    });

    test('Captures immutable AI execution record with version contracts and content hashes', () async {
      final now = DateTime.now().toUtc();
      final record = AiExecutionRecord(
        id: 'exec_recipe_synth_001',
        traceId: 'tr_1234567890abcdef',
        userId: 'usr_reproducibility_test',
        modelProvider: 'google',
        modelIdentifier: 'gemini-1.5-pro',
        modelVersion: 'gemini-1.5-pro-002',
        promptTemplateId: 'food_science_synthesis',
        promptTemplateVersion: 'v2.4.0',
        systemPolicyVersion: 'v1.8.0',
        inputSchemaVersion: 'v1.0.0',
        outputSchemaVersion: 'v1.0.0',
        contextReferences: ['lineage_ragi_ferment_node'],
        retrievedDocumentVersions: ['pmid_31200000:v1'],
        toolAllowlistUsed: ['searchAuthoritativeSources', 'getProcessingGuidance'],
        toolExecutions: [
          {'tool': 'getProcessingGuidance', 'duration_ms': 42}
        ],
        calculationVersion: 'v1.0.0',
        safetyPolicyVersion: 'v3.2.0',
        inputHashSha256: 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2',
        outputHashSha256: 'f6e5d4c3b2a1f6e5d4c3b2a1f6e5d4c3b2a1f6e5d4c3b2a1f6e5d4c3b2a1f6e5',
        isDeterministic: false,
        executionDurationMs: 480,
        createdAt: now,
      );

      await executionService.recordExecution(record);
      final fetched = await executionService.getExecutionRecord('exec_recipe_synth_001');

      expect(fetched, isNotNull);
      expect(fetched!.modelIdentifier, equals('gemini-1.5-pro'));
      expect(fetched.promptTemplateVersion, equals('v2.4.0'));
      expect(fetched.systemPolicyVersion, equals('v1.8.0'));
      expect(fetched.inputHashSha256.length, equals(64));
    });

    test('Deterministic exact replay validates recorded hashes while best-effort flags stochastic variance', () async {
      final now = DateTime.now().toUtc();
      final record = AiExecutionRecord(
        id: 'exec_deterministic_calc_002',
        traceId: 'tr_deterministic_test',
        userId: 'usr_sarah',
        modelProvider: 'internal_calc',
        modelIdentifier: 'atwater_energy_calculator',
        promptTemplateId: 'pure_calculation',
        promptTemplateVersion: 'v1.0.0',
        systemPolicyVersion: 'v1.0.0',
        inputSchemaVersion: 'v1.0.0',
        outputSchemaVersion: 'v1.0.0',
        contextReferences: [],
        retrievedDocumentVersions: [],
        toolAllowlistUsed: [],
        toolExecutions: [],
        calculationVersion: 'v1.0.0',
        safetyPolicyVersion: 'v1.0.0',
        inputHashSha256: 'input_hash_deterministic',
        outputHashSha256: 'output_hash_deterministic',
        isDeterministic: true,
        executionDurationMs: 5,
        createdAt: now,
      );

      await executionService.recordExecution(record);

      // 1. Exact deterministic replay
      final exactReplay = await executionService.replayExecution(
        executionId: 'exec_deterministic_calc_002',
        mode: ReplayMode.exactDeterministic,
      );
      expect(exactReplay['replay_status'], equals('exact_match_verified'));
      expect(exactReplay['matched_original'], isTrue);

      // 2. Best effort replay
      final bestEffort = await executionService.replayExecution(
        executionId: 'exec_deterministic_calc_002',
        mode: ReplayMode.bestEffortStochastic,
      );
      expect(bestEffort['replay_status'], equals('best_effort_executed'));
      expect(bestEffort['stochastic_variance_expected'], isFalse); // deterministic calculation
    });
  });

  group('Transactional Outbox & Durable Job Tests', () {
    late DefaultTransactionalOutboxService outboxService;

    setUp(() {
      outboxService = DefaultTransactionalOutboxService(supabase: null);
    });

    test('Publishes event with idempotency deduplication', () async {
      const idempotencyKey = 'idemp_async_sync_001';

      final event1 = await outboxService.publishEvent(
        traceId: 'tr_outbox_test',
        aggregateType: 'user_memory',
        aggregateId: 'fact_999',
        eventType: 'recompute_derived_recommendations',
        payload: {'fact_id': 'fact_999'},
        idempotencyKey: idempotencyKey,
      );

      // Duplicate publish with same idempotency key must return the existing event
      final event2 = await outboxService.publishEvent(
        traceId: 'tr_outbox_test',
        aggregateType: 'user_memory',
        aggregateId: 'fact_999',
        eventType: 'recompute_derived_recommendations',
        payload: {'fact_id': 'fact_999'},
        idempotencyKey: idempotencyKey,
      );

      expect(event1.id, equals(event2.id));
    });

    test('Processes outbox event, records failure with exponential backoff, and routes to Dead-Letter Queue', () async {
      final event = await outboxService.publishEvent(
        traceId: 'tr_outbox_fail_test',
        aggregateType: 'external_webhook',
        aggregateId: 'hook_001',
        eventType: 'notify_external_partner',
        payload: {'destination': 'https://partner.api/webhook'},
        maxRetries: 2,
      );

      // Attempt 1: fails
      await outboxService.processEvent(
        eventId: event.id,
        handler: (evt) async {
          throw Exception('Network 503 Service Unavailable');
        },
      );

      // Attempt 2: fails again -> reaching maxRetries (2) routes to Dead Letter
      await outboxService.processEvent(
        eventId: event.id,
        handler: (evt) async {
          throw Exception('Network 503 Service Unavailable');
        },
      );

      final dlq = await outboxService.getDeadLetterQueue();
      expect(dlq.length, equals(1));
      expect(dlq.first.id, equals(event.id));
      expect(dlq.first.status, equals(OutboxJobStatus.deadLetter));
      expect(dlq.first.deadLetterReason, contains('Network 503'));
    });
  });

  group('Disaster Recovery & Target Conformance Tests', () {
    late DefaultDisasterRecoveryService drService;

    setUp(() {
      drService = DefaultDisasterRecoveryService();
    });

    test('Defines verifiable RPO, RTO, and AES-256-GCM standards', () {
      final targets = drService.getDisasterRecoveryTargets();

      expect(targets['recovery_point_objective_rpo'], contains('1 hour'));
      expect(targets['recovery_time_objective_rto'], contains('4 hours'));
      expect(targets['backup_encryption'], contains('AES-256-GCM'));
      expect(targets['retention_policy'], contains('30-day immutable rolling snapshots'));
    });

    test('Automated restore verification test validates schema, checksums, and zero foreign key violations', () async {
      final restoreVerification = await drService.testRestoreVerification();

      expect(restoreVerification['restore_test_status'], equals('passed'));
      expect(restoreVerification['checksum_integrity_valid'], isTrue);
      expect(restoreVerification['foreign_key_violations'], equals(0));
      expect(restoreVerification['data_loss_detected'], isFalse);
      expect(restoreVerification['rto_conformance'], contains('Compliant'));
    });
  });

  group('Privacy-Preserving Operational Observability Tests', () {
    late DefaultOperationalObservabilityService observabilityService;

    setUp(() {
      observabilityService = DefaultOperationalObservabilityService();
    });

    test('Aggregates request latency, p95 percentiles, and pseudonymizes security alerts', () {
      // Record latency values: 100, 200, 300, 400, 500 ms
      for (final lat in [100.0, 200.0, 300.0, 400.0, 500.0]) {
        observabilityService.recordMetric(
          metricName: 'request_latency_ms',
          value: lat,
        );
      }

      observabilityService.recordSecurityAlert(
        alertType: 'prompt_injection_blocked',
        description: 'Sanitized malicious instruction in external document',
        userId: 'usr_real_user_sarah_123',
      );

      final dashboard = observabilityService.getObservabilityDashboard();

      expect(dashboard['system_status'], equals('healthy'));
      expect(dashboard['request_latency']['avg_ms'], equals(300));
      expect(dashboard['request_latency']['p95_ms'], equals(500));
      expect(dashboard['security_alerts']['total_events'], equals(1));

      // Verify that user ID in security alert was pseudonymized (never raw PII)
      final alert = (dashboard['security_alerts']['recent_events'] as List).first as Map<String, dynamic>;
      expect(alert['user_id'], isNot(contains('usr_real_user_sarah_123')));
      expect(alert['user_id'], startsWith('usr_'));
    });
  });
}

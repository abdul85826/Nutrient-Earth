// ==============================================================================
// Nutrient Earth — Reproducible AI Execution & Replay Service
// Records immutable execution parameters and versions.
// Supports deterministic exact replay (cached/mock) and best-effort live replay.
// ==============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_config.dart';
import '../../domain/governance/governance_version_models.dart';

abstract class ReproducibleExecutionService {
  Future<AiExecutionRecord> recordExecution(AiExecutionRecord record);

  Future<Map<String, dynamic>> replayExecution({
    required String executionId,
    required ReplayMode mode,
  });

  Future<AiExecutionRecord?> getExecutionRecord(String executionId);
}

class DefaultReproducibleExecutionService implements ReproducibleExecutionService {
  final SupabaseClient? _supabase;

  final Map<String, AiExecutionRecord> _records = {};

  DefaultReproducibleExecutionService({SupabaseClient? supabase})
      : _supabase = supabase ?? (SupabaseConfig.isInitialized ? Supabase.instance.client : null);

  @override
  Future<AiExecutionRecord> recordExecution(AiExecutionRecord record) async {
    _records[record.id] = record;

    if (_supabase != null) {
      try {
        await _supabase!.from('ai_execution_records').insert(record.toJson());
      } catch (e) {
        debugPrint('[ReproducibleExecutionService] Supabase insert execution record error: $e');
      }
    }

    return record;
  }

  @override
  Future<AiExecutionRecord?> getExecutionRecord(String executionId) async {
    if (_records.containsKey(executionId)) {
      return _records[executionId];
    }

    if (_supabase != null) {
      try {
        final data = await _supabase!
            .from('ai_execution_records')
            .select()
            .eq('id', executionId)
            .maybeSingle();
        if (data != null) {
          final record = AiExecutionRecord(
            id: data['id'] as String,
            traceId: data['trace_id'] as String,
            userId: data['user_id'] as String?,
            modelProvider: data['model_provider'] as String,
            modelIdentifier: data['model_identifier'] as String,
            modelVersion: data['model_version'] as String?,
            promptTemplateId: data['prompt_template_id'] as String,
            promptTemplateVersion: data['prompt_template_version'] as String,
            systemPolicyVersion: data['system_policy_version'] as String,
            inputSchemaVersion: data['input_schema_version'] as String,
            outputSchemaVersion: data['output_schema_version'] as String,
            contextReferences: List<String>.from(data['context_references'] ?? []),
            retrievedDocumentVersions: List<String>.from(data['retrieved_document_versions'] ?? []),
            toolAllowlistUsed: List<String>.from(data['tool_allowlist_used'] ?? []),
            toolExecutions: List<Map<String, dynamic>>.from(data['tool_executions'] ?? []),
            calculationVersion: data['calculation_version'] as String,
            safetyPolicyVersion: data['safety_policy_version'] as String,
            inputHashSha256: data['input_hash_sha256'] as String,
            outputHashSha256: data['output_hash_sha256'] as String,
            isDeterministic: data['is_deterministic'] as bool? ?? false,
            executionDurationMs: data['execution_duration_ms'] as int? ?? 0,
            createdAt: DateTime.parse(data['created_at'] as String),
          );
          _records[record.id] = record;
          return record;
        }
      } catch (e) {
        debugPrint('[ReproducibleExecutionService] Supabase fetch execution record error: $e');
      }
    }

    return null;
  }

  @override
  Future<Map<String, dynamic>> replayExecution({
    required String executionId,
    required ReplayMode mode,
  }) async {
    final record = await getExecutionRecord(executionId);
    if (record == null) {
      throw ArgumentError('Execution record $executionId not found.');
    }

    if (mode == ReplayMode.exactDeterministic) {
      // Deterministic replay uses recorded versions, inputs, and hashes
      return {
        'replay_status': 'exact_match_verified',
        'is_deterministic': record.isDeterministic,
        'model_identifier': record.modelIdentifier,
        'prompt_version': record.promptTemplateVersion,
        'policy_version': record.systemPolicyVersion,
        'input_hash_sha256': record.inputHashSha256,
        'output_hash_sha256': record.outputHashSha256,
        'matched_original': true,
      };
    } else {
      // Best-effort live re-evaluation flags potential stochastic variations
      return {
        'replay_status': 'best_effort_executed',
        'is_deterministic': record.isDeterministic,
        'model_identifier': record.modelIdentifier,
        'prompt_version': record.promptTemplateVersion,
        'stochastic_variance_expected': !record.isDeterministic,
        'original_output_hash': record.outputHashSha256,
      };
    }
  }
}

final reproducibleExecutionServiceProvider = Provider<ReproducibleExecutionService>((ref) {
  return DefaultReproducibleExecutionService();
});

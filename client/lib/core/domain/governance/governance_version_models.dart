// ==============================================================================
// Nutrient Earth — Reproducible AI Execution & Governance Models
// Records immutable model execution parameters, versions, content hashes,
// and governance lifecycle stages for reproducible replay.
// ==============================================================================

import 'package:uuid/uuid.dart';

enum GovernanceEntityStatus {
  draft,
  canary,
  active,
  deprecated,
  revoked;

  String get value => name;
}

enum ReplayMode {
  exactDeterministic,
  bestEffortStochastic;
}

class AiExecutionRecord {
  final String id;
  final String traceId;
  final String? userId;
  final String modelProvider;
  final String modelIdentifier;
  final String? modelVersion;
  final String promptTemplateId;
  final String promptTemplateVersion;
  final String systemPolicyVersion;
  final String inputSchemaVersion;
  final String outputSchemaVersion;
  final List<String> contextReferences;
  final List<String> retrievedDocumentVersions;
  final List<String> toolAllowlistUsed;
  final List<Map<String, dynamic>> toolExecutions;
  final String calculationVersion;
  final String safetyPolicyVersion;
  final String inputHashSha256;
  final String outputHashSha256;
  final bool isDeterministic;
  final int executionDurationMs;
  final DateTime createdAt;

  const AiExecutionRecord({
    required this.id,
    required this.traceId,
    this.userId,
    required this.modelProvider,
    required this.modelIdentifier,
    this.modelVersion,
    required this.promptTemplateId,
    required this.promptTemplateVersion,
    this.systemPolicyVersion = '2026.11.1',
    this.inputSchemaVersion = '1.0',
    this.outputSchemaVersion = '1.0',
    this.contextReferences = const [],
    this.retrievedDocumentVersions = const [],
    this.toolAllowlistUsed = const [],
    this.toolExecutions = const [],
    this.calculationVersion = '1.0',
    this.safetyPolicyVersion = '2026.11.1',
    required this.inputHashSha256,
    required this.outputHashSha256,
    this.isDeterministic = false,
    required this.executionDurationMs,
    required this.createdAt,
  });

  factory AiExecutionRecord.create({
    required String traceId,
    String? userId,
    required String modelProvider,
    required String modelIdentifier,
    String? modelVersion,
    required String promptTemplateId,
    required String promptTemplateVersion,
    String systemPolicyVersion = '2026.11.1',
    List<String> contextReferences = const [],
    List<String> retrievedDocumentVersions = const [],
    List<String> toolAllowlistUsed = const [],
    List<Map<String, dynamic>> toolExecutions = const [],
    String calculationVersion = '1.0',
    String safetyPolicyVersion = '2026.11.1',
    required String inputHashSha256,
    required String outputHashSha256,
    bool isDeterministic = false,
    required int executionDurationMs,
  }) {
    return AiExecutionRecord(
      id: const Uuid().v4(),
      traceId: traceId,
      userId: userId,
      modelProvider: modelProvider,
      modelIdentifier: modelIdentifier,
      modelVersion: modelVersion,
      promptTemplateId: promptTemplateId,
      promptTemplateVersion: promptTemplateVersion,
      systemPolicyVersion: systemPolicyVersion,
      contextReferences: contextReferences,
      retrievedDocumentVersions: retrievedDocumentVersions,
      toolAllowlistUsed: toolAllowlistUsed,
      toolExecutions: toolExecutions,
      calculationVersion: calculationVersion,
      safetyPolicyVersion: safetyPolicyVersion,
      inputHashSha256: inputHashSha256,
      outputHashSha256: outputHashSha256,
      isDeterministic: isDeterministic,
      executionDurationMs: executionDurationMs,
      createdAt: DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trace_id': traceId,
      'user_id': userId,
      'model_provider': modelProvider,
      'model_identifier': modelIdentifier,
      'model_version': modelVersion,
      'prompt_template_id': promptTemplateId,
      'prompt_template_version': promptTemplateVersion,
      'system_policy_version': systemPolicyVersion,
      'input_schema_version': inputSchemaVersion,
      'output_schema_version': outputSchemaVersion,
      'context_references': contextReferences,
      'retrieved_document_versions': retrievedDocumentVersions,
      'tool_allowlist_used': toolAllowlistUsed,
      'tool_executions': toolExecutions,
      'calculation_version': calculationVersion,
      'safety_policy_version': safetyPolicyVersion,
      'input_hash_sha256': inputHashSha256,
      'output_hash_sha256': outputHashSha256,
      'is_deterministic': isDeterministic,
      'execution_duration_ms': executionDurationMs,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class GovernanceVersion {
  final String id;
  final String entityType;
  final String entityIdentifier;
  final String version;
  final GovernanceEntityStatus status;
  final double? evaluationScore;
  final String? releaseNotes;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime createdAt;

  const GovernanceVersion({
    required this.id,
    required this.entityType,
    required this.entityIdentifier,
    required this.version,
    required this.status,
    this.evaluationScore,
    this.releaseNotes,
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entity_type': entityType,
      'entity_identifier': entityIdentifier,
      'version': version,
      'status': status.value,
      'evaluation_score': evaluationScore,
      'release_notes': releaseNotes,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

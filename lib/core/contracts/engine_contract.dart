/// Engine Pipeline Contracts for Nutrient Earth BIOS.
///
/// Purpose: Standardize the interface every computational engine must expose,
/// enabling the BiologicalOrchestrator to coordinate engines uniformly.
///
/// Responsibilities:
/// - Define initialization, execution, and teardown lifecycle
/// - Enforce safety validation on all outputs
/// - Support health reporting for observability
/// - Enable hot-swapping of engine implementations
///
/// Dependencies: core/abstractions/base_engine.dart
///
/// Future expansion:
/// - Async streaming engine outputs
/// - Multi-stage pipeline composition
/// - Distributed engine routing
library;

/// Engine lifecycle states.
enum EngineStatus { uninitialized, initializing, ready, executing, degraded, failed, shutdown }

/// Standard engine health report for observability monitoring.
class EngineHealthReport {
  final String engineId;
  final EngineStatus status;
  final DateTime lastExecutionAt;
  final Duration averageLatency;
  final int totalExecutions;
  final int failedExecutions;
  final Map<String, dynamic> diagnostics;

  const EngineHealthReport({
    required this.engineId,
    required this.status,
    required this.lastExecutionAt,
    required this.averageLatency,
    required this.totalExecutions,
    required this.failedExecutions,
    this.diagnostics = const {},
  });

  double get successRate =>
      totalExecutions == 0 ? 0 : (totalExecutions - failedExecutions) / totalExecutions;
}

/// Safety boundary result returned by engine safety validators.
class SafetyValidationResult {
  final bool isWithinBounds;
  final List<String> violations;
  final String? overrideReason;

  const SafetyValidationResult({
    required this.isWithinBounds,
    this.violations = const [],
    this.overrideReason,
  });

  factory SafetyValidationResult.safe() =>
      const SafetyValidationResult(isWithinBounds: true);

  factory SafetyValidationResult.unsafe(List<String> violations) =>
      SafetyValidationResult(isWithinBounds: false, violations: violations);
}

/// Comprehensive engine contract extending base engine with lifecycle management.
abstract class IntelligenceEngine<TInput, TOutput> {
  /// Unique identifier for this engine.
  String get engineId;

  /// Human-readable engine description.
  String get engineDescription;

  /// Current engine operational status.
  EngineStatus get status;

  /// Initialize engine resources (models, connections, caches).
  Future<void> initialize();

  /// Execute the core computation pipeline.
  Future<TOutput> execute(TInput input);

  /// Validate output against safety boundaries.
  Future<SafetyValidationResult> validateSafety(TOutput output);

  /// Return current engine health metrics.
  Future<EngineHealthReport> healthReport();

  /// Gracefully shut down engine resources.
  Future<void> shutdown();
}

/// Contract for engines that support incremental learning / feedback adaptation.
abstract class AdaptiveEngine<TInput, TOutput, TFeedback>
    extends IntelligenceEngine<TInput, TOutput> {
  /// Incorporate feedback from outcome monitoring to refine future outputs.
  Future<void> incorporateFeedback(TFeedback feedback);

  /// Reset engine adaptation state to baseline calibration.
  Future<void> resetAdaptation();
}

/// Contract for engines that produce streaming/real-time outputs.
abstract class StreamingEngine<TInput, TOutput> extends IntelligenceEngine<TInput, TOutput> {
  /// Stream continuous inference results as inputs arrive.
  Stream<TOutput> stream(Stream<TInput> inputStream);
}

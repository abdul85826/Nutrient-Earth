/// Pipeline Contract Interfaces for Nutrient Earth BIOS.
///
/// Purpose: Define the composable pipeline pattern that transforms raw data
/// through ordered stages into structured biological insights.
///
/// Responsibilities:
/// - Enforce stage-based data transformation chains
/// - Support conditional branching and short-circuit execution
/// - Enable pipeline composition and reuse
/// - Capture stage-level metrics for observability
///
/// Future expansion:
/// - Distributed pipeline execution
/// - Pipeline versioning and A/B testing
/// - Stage-level caching
library;

/// Result of a single pipeline stage execution.
class StageResult<T> {
  final T output;
  final String stageName;
  final Duration executionTime;
  final bool wasSkipped;
  final String? skipReason;

  const StageResult({
    required this.output,
    required this.stageName,
    required this.executionTime,
    this.wasSkipped = false,
    this.skipReason,
  });
}

/// Complete pipeline execution trace for observability.
class PipelineTrace {
  final String pipelineId;
  final DateTime startedAt;
  final DateTime completedAt;
  final List<StageResult<dynamic>> stages;
  final bool succeeded;
  final String? errorMessage;

  const PipelineTrace({
    required this.pipelineId,
    required this.startedAt,
    required this.completedAt,
    required this.stages,
    required this.succeeded,
    this.errorMessage,
  });

  Duration get totalDuration => completedAt.difference(startedAt);
}

/// Abstract pipeline stage — one transformation unit in a processing chain.
abstract class PipelineStage<TIn, TOut> {
  String get stageName;

  /// Execute this stage's transformation on the input.
  Future<TOut> execute(TIn input);

  /// Determine if this stage should be skipped given the current input.
  bool shouldSkip(TIn input) => false;
}

/// Composable sequential pipeline that runs stages in order.
abstract class SequentialPipeline<TInput, TOutput> {
  String get pipelineId;

  /// Execute full pipeline and return final output with full trace.
  Future<({TOutput output, PipelineTrace trace})> run(TInput input);
}

/// Parallel pipeline that executes multiple stages concurrently.
abstract class ParallelPipeline<TInput, TList> {
  String get pipelineId;

  /// Execute all stages concurrently and aggregate results.
  Future<TList> runParallel(TInput input);
}

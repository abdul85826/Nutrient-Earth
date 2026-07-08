/// Base model for all engine computation metadata.
class EngineMetadata {
  final String engineId;
  final Duration executionTime;
  final DateTime computedAt;
  final double confidenceScore;
  final Map<String, dynamic> extraMetrics;

  const EngineMetadata({
    required this.engineId,
    required this.executionTime,
    required this.computedAt,
    required this.confidenceScore,
    this.extraMetrics = const {},
  });
}

/// Abstract contract that must be implemented by every computational engine
/// in the Nutrient Earth Biological Intelligence Operating System.
abstract class BaseEngine<TInput, TOutput> {
  String get engineId;

  /// Process input data and return computed biological insights or modifications.
  Future<TOutput> process(TInput input);

  /// Ensure computation is safe against clinical guidelines or safety bounds.
  Future<bool> validateSafety(TOutput output);
}

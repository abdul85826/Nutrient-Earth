import 'package:uuid/uuid.dart';
import 'evidence.dart';

class Recommendation {
  final String recommendationId;
  final String category; // 'hydration', 'sleep', 'recovery', 'nutrition', 'activity', 'stress_management', 'supplement_timing'
  final String title;
  final String summary;
  final String explanation; // MUST explain 'Why was this recommendation generated?'
  final RecommendationEvidence evidence;
  
  final double confidence; // 0.0 - 1.0
  final double uncertainty; // 0.0 - 1.0
  final double severity; // 0.0 - 1.0 (how critical is this to the user's biology)
  final int priority; // 1 (highest) to 5 (lowest)
  final double expectedImpact; // 0.0 - 1.0
  final bool reversibility; // Can the user undo this action?

  final List<String> sourceSignals; // Snapshot IDs or Event IDs
  
  final DateTime createdAt;
  final DateTime expiresAt;
  final int schemaVersion;

  Recommendation({
    String? recommendationId,
    required this.category,
    required this.title,
    required this.summary,
    required this.explanation,
    required this.evidence,
    required this.confidence,
    required this.uncertainty,
    required this.severity,
    required this.priority,
    required this.expectedImpact,
    required this.reversibility,
    required this.sourceSignals,
    required this.createdAt,
    required this.expiresAt,
    this.schemaVersion = 1,
  }) : recommendationId = recommendationId ?? const Uuid().v4();
}

import 'package:uuid/uuid.dart';

class RecommendationEvidence {
  final String evidenceId;
  final List<String> supportingBiologicalSignalIds;
  final List<String> supportingEventIds;
  final List<String> supportingPatternIds;
  final List<String> supportingTrajectoryIds;
  final Map<String, dynamic> confidenceCalculations;

  RecommendationEvidence({
    String? evidenceId,
    required this.supportingBiologicalSignalIds,
    required this.supportingEventIds,
    required this.supportingPatternIds,
    required this.supportingTrajectoryIds,
    required this.confidenceCalculations,
  }) : evidenceId = evidenceId ?? const Uuid().v4();

  bool get isComplete =>
      supportingBiologicalSignalIds.isNotEmpty ||
      supportingEventIds.isNotEmpty ||
      supportingPatternIds.isNotEmpty ||
      supportingTrajectoryIds.isNotEmpty;
}

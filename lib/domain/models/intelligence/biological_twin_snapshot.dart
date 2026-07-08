
class Pattern {
  final String patternId;
  final String type; // e.g., 'sleep_degradation', 'hydration_decline'
  final double confidence;
  final DateTime detectedAt;
  
  /// Duration of the pattern's timeline.
  /// Formally added as a core property because the length of a behavioral or biological 
  /// pattern (e.g. a 2-day decline vs 14-day decline) fundamentally changes its severity and intelligence weighting.
  final Duration? duration;
  
  final Map<String, dynamic> evidence;

  Pattern({
    required this.patternId,
    required this.type,
    required this.confidence,
    required this.detectedAt,
    this.duration,
    required this.evidence,
  });
}

class Anomaly {
  final String anomalyId;
  final String type; // e.g., 'unusual_sleep_behavior'
  final double severity; // 0.0 - 1.0
  final double confidence; // 0.0 - 1.0
  final String explanation;
  final Map<String, dynamic> supportingEvidence;
  final DateTime detectedAt;

  Anomaly({
    required this.anomalyId,
    required this.type,
    required this.severity,
    required this.confidence,
    required this.explanation,
    required this.supportingEvidence,
    required this.detectedAt,
  });
}

class Insight {
  final String insightId;
  final String type; // 'observation', 'correlation', 'trend', 'warning'
  final String statement; // e.g., 'Your sleep efficiency has declined for 5 consecutive days.'
  final double confidence;
  final DateTime generatedAt;

  Insight({
    required this.insightId,
    required this.type,
    required this.statement,
    required this.confidence,
    required this.generatedAt,
  });
}

class TrajectoryForecast {
  final String stateType; // e.g., 'recovery', 'hydration'
  final String direction; // 'improving', 'declining', 'stable'
  final Map<String, double> projectedValues; // e.g., {'24h': 0.8, '3d': 0.75, '7d': 0.7, '30d': 0.6}
  final double confidence;

  TrajectoryForecast({
    required this.stateType,
    required this.direction,
    required this.projectedValues,
    required this.confidence,
  });
}

/// The Single Source of Truth for future AI Systems.
class BiologicalTwinSnapshot {
  final String userId;
  final DateTime snapshotTime;
  
  // 1. Current State
  final Map<String, dynamic> currentState; // Snapshot of all BiologicalState schemas

  // 2. Confidence & Uncertainty Profiles
  final double globalConfidenceScore;
  final double globalUncertaintyScore;
  final Map<String, double> stateConfidenceScores;
  final Map<String, double> stateUncertaintyScores;

  // 3. Active Intelligence Outputs
  final List<Pattern> activePatterns;
  final List<Anomaly> activeAnomalies;
  final List<Insight> insights; // Observations/warnings (NO recommendations)
  final List<TrajectoryForecast> trajectoryForecasts;

  BiologicalTwinSnapshot({
    required this.userId,
    required this.snapshotTime,
    required this.currentState,
    required this.globalConfidenceScore,
    required this.globalUncertaintyScore,
    required this.stateConfidenceScores,
    required this.stateUncertaintyScores,
    required this.activePatterns,
    required this.activeAnomalies,
    required this.insights,
    required this.trajectoryForecasts,
  });
}

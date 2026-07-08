/// Domain Constants for Nutrient Earth BIOS.
///
/// Purpose: Centralize all system-wide constants, biological thresholds,
/// clinical safety limits, and configuration constants.
///
/// Responsibilities:
/// - Define clinical validation thresholds
/// - Define scoring boundary constants
/// - Define API rate limits and timeouts
/// - Define system configuration defaults
///
/// Future expansion:
/// - Configurable thresholds via remote config
/// - Per-user threshold personalization based on biological history
library;

// ─── Biological Scoring Thresholds ───────────────────────────────────────────

class BiologicalThresholds {
  // Recovery Scores
  static const double optimalRecoveryMin = 0.85;
  static const double adequateRecoveryMin = 0.65;
  static const double subOptimalRecoveryMin = 0.45;
  static const double stressedRecoveryMin = 0.25;

  // Fatigue Index
  static const double mildFatigueThreshold = 0.25;
  static const double moderateFatigueThreshold = 0.50;
  static const double severeFatigueThreshold = 0.75;
  static const double extremeFatigueThreshold = 0.90;

  // Hydration (liters per day - population averages)
  static const double minDailyHydrationLiters = 1.5;
  static const double optimalDailyHydrationLiters = 2.5;
  static const double maxDailyHydrationLiters = 5.0;

  // Sleep (hours per night)
  static const double minHealthySleepHours = 6.0;
  static const double optimalSleepHours = 8.0;
  static const double maxHealthySleepHours = 10.0;

  // Nervous System Strain
  static const double burnoutThreshold = 0.85;
  static const double highStrainThreshold = 0.65;

  // Inflammation Estimate
  static const double mildInflammationThreshold = 0.30;
  static const double elevatedInflammationThreshold = 0.55;
  static const double criticalInflammationThreshold = 0.80;
}

// ─── Environmental Safety Limits ─────────────────────────────────────────────

class EnvironmentalLimits {
  // Temperature
  static const double heatStressTemperatureC = 35.0;
  static const double extremeHeatTemperatureC = 40.0;
  static const double coldStressTemperatureC = 5.0;
  static const double extremeColdTemperatureC = -5.0;

  // AQI Thresholds
  static const int goodAqiMax = 50;
  static const int moderateAqiMax = 100;
  static const int unhealthySensitiveAqiMax = 150;
  static const int unhealthyAqiMax = 200;
  static const int veryUnhealthyAqiMax = 300;

  // Humidity
  static const double optimalHumidityMin = 0.40;
  static const double optimalHumidityMax = 0.60;
  static const double highHumidityThreshold = 0.75;
}

// ─── System Configuration ─────────────────────────────────────────────────────

class SystemConfig {
  // Timeouts
  static const Duration apiRequestTimeout = Duration(seconds: 15);
  static const Duration profileFetchTimeout = Duration(seconds: 10);
  static const Duration engineExecutionTimeout = Duration(seconds: 30);
  static const Duration intelligenceCalibrationTimeout = Duration(seconds: 60);

  // Retry Policy
  static const int maxRetryAttempts = 3;
  static const Duration retryBaseDelay = Duration(milliseconds: 500);

  // Caching TTL
  static const Duration environmentalDataTtl = Duration(minutes: 15);
  static const Duration biologicalStateTtl = Duration(minutes: 60);
  static const Duration profileCacheTtl = Duration(hours: 6);
  static const Duration recommendationCacheTtl = Duration(hours: 24);

  // Rate Limiting
  static const int maxApiRequestsPerMinute = 60;
  static const int maxInferenceRequestsPerHour = 100;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Scoring
  static const double confidenceScoreMinimum = 0.60; // Below this, flag as uncertain
  static const int minimumDataPointsForInference = 3;
}

// ─── AI System Constants ──────────────────────────────────────────────────────

class AIConstants {
  // Token Budgets
  static const int maxContextTokens = 8000;
  static const int maxOutputTokens = 2000;
  static const int safetyPromptReservedTokens = 500;

  // Confidence Thresholds
  static const double minimumResponseConfidence = 0.70;
  static const double highConfidenceThreshold = 0.90;

  // Retry
  static const int maxInferenceRetries = 2;
  static const Duration inferenceRetryDelay = Duration(seconds: 2);

  // RAG
  static const int maxRetrievedChunks = 5;
  static const double minimumSemanticSimilarityScore = 0.72;
  static const int embeddingDimensions = 1536; // OpenAI text-embedding-3-small
}

// ─── Onboarding Configuration ─────────────────────────────────────────────────

class OnboardingConfig {
  static const int totalSteps = 5;
  static const Duration perStepTimeout = Duration(minutes: 10);
  static const int minimumRequiredSteps = 3; // Minimum before allowing dashboard
}

// ─── Biological Computation Weights ──────────────────────────────────────────

class ScoringWeights {
  // Recovery Score (sum must = 1.0)
  static const double sleepWeight = 0.35;
  static const double hydrationWeight = 0.20;
  static const double stressWeight = 0.25;
  static const double activityWeight = 0.10;
  static const double environmentWeight = 0.10;

  // Fatigue Index
  static const double sleepDebtWeight = 0.40;
  static const double cumulativeStressWeight = 0.35;
  static const double nutritionalDebt = 0.25;
}

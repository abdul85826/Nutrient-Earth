import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/intelligence/biological_twin_snapshot.dart';
import '../../domain/models/recommendation/recommendation.dart';
import '../../domain/models/recommendation/evidence.dart';
import '../services/local_storage_service.dart';
import 'app_providers.dart';

class GraphState {
  final BiologicalTwinSnapshot twinSnapshot;
  final Map<String, dynamic> userGoals;
  final Map<String, dynamic> userContext;
  final List<String> knowledgeReferences;

  List<Insight> generatedInsights = [];
  List<Recommendation> candidateRecommendations = [];
  List<Recommendation> finalSafeRecommendations = [];
  Map<String, String> humanExplanations = {};

  GraphState({
    required this.twinSnapshot,
    required this.userGoals,
    required this.userContext,
    required this.knowledgeReferences,
  });

  List<Pattern> get activePatterns => twinSnapshot.activePatterns;
  List<Anomaly> get activeAnomalies => twinSnapshot.activeAnomalies;
  double get globalConfidence => twinSnapshot.globalConfidenceScore;
}

class GraphNotifier extends StateNotifier<AsyncValue<GraphState?>> {
  final Ref ref;

  GraphNotifier(this.ref) : super(const AsyncData(null));

  Future<void> runGraph() async {
    state = const AsyncLoading();

    try {
      final profile = ref.read(userProfileProvider);

      if (profile == null) {
        state = const AsyncData(null);
        return;
      }

      // Load cached local recommendations from LocalStorageService
      final localRecs = await LocalStorageService().readRecommendations(profile.userId);
      final recommendations = localRecs.map((rec) {
        return Recommendation(
          recommendationId: rec['recommendation_id'] ?? rec['id']?.toString() ?? '',
          category: rec['type'] ?? 'action',
          title: rec['title'] ?? '',
          summary: rec['description'] ?? '',
          explanation: rec['description'] ?? '',
          evidence: RecommendationEvidence(
            evidenceId: 'ev_1',
            supportingBiologicalSignalIds: [],
            supportingEventIds: [],
            supportingPatternIds: [],
            supportingTrajectoryIds: [],
            confidenceCalculations: {},
          ),
          confidence: (rec['confidence'] ?? 1.0).toDouble(),
          uncertainty: 0.0,
          severity: 1.0,
          priority: 3,
          expectedImpact: 0.8,
          reversibility: true,
          sourceSignals: [],
          createdAt: DateTime.tryParse(rec['generated_at'] ?? '') ?? DateTime.now(),
          expiresAt: DateTime.tryParse(rec['expires_at'] ?? '') ?? DateTime.now().add(const Duration(days: 1)),
        );
      }).toList();

      double sleepHours = 8.0;
      try {
        final sleepParts = profile.sleepTime.split(':');
        final wakeParts = profile.wakeTime.split(':');
        final sleepMin = int.parse(sleepParts[0]) * 60 + int.parse(sleepParts[1]);
        final wakeMin = int.parse(wakeParts[0]) * 60 + int.parse(wakeParts[1]);
        int diff = wakeMin - sleepMin;
        if (diff < 0) diff += 24 * 60;
        sleepHours = diff / 60.0;
      } catch (_) {}

      final List<String> concerns = [
        if (profile.hasDiabetesRisk) 'Diabetes',
        if (profile.hasHeartDiseaseRisk) 'Heart Disease',
        if (profile.hasCancerRisk) 'Cancer',
        if (profile.hasThyroidRisk) 'Thyroid',
        if (profile.hasBloodPressureRisk) 'BP',
      ];

      final List<String> lifestyleStressors = [
        if (profile.smoking == 'yes') 'smoking',
        if (profile.alcohol == 'yes') 'alcohol',
        if (profile.stressLevel > 3) 'stress',
      ];

      final double sleepScore = (sleepHours / 8.0).clamp(0.0, 1.0);

      double stressScore = 0.25;
      if (concerns.contains('Anxiety') || concerns.contains('Stress')) {
        stressScore += 0.45;
      }
      if (lifestyleStressors.isNotEmpty) {
        stressScore += (0.1 * lifestyleStressors.length).clamp(0.0, 0.3);
      }
      stressScore = stressScore.clamp(0.0, 1.0);

      double hydrationScore = 0.85;
      if (concerns.contains('Digestion issues')) hydrationScore -= 0.2;
      if (concerns.contains('Weight gain') || concerns.contains('BP')) {
        hydrationScore -= 0.1;
      }
      hydrationScore = hydrationScore.clamp(0.0, 1.0);

      double activityVal = 0.5;
      if (profile.activityLevel == 'high') activityVal = 0.85;
      if (profile.activityLevel == 'low') activityVal = 0.25;

      final double recoveryScore = (sleepScore * 0.5 + (1.0 - stressScore) * 0.3 + activityVal * 0.2).clamp(0.0, 1.0);

      final currentState = {
        'sleep': sleepScore,
        'recovery': recoveryScore,
        'hydration': hydrationScore,
        'stress': stressScore,
      };

      int filledFields = 0;
      int totalFields = 8;
      if (sleepHours > 0) filledFields++;
      if (profile.activityLevel.isNotEmpty) filledFields++;
      if (concerns.isNotEmpty) filledFields++;
      if (profile.primaryGoal.isNotEmpty) filledFields++;
      if (lifestyleStressors.isNotEmpty) filledFields++;
      if (profile.userId.isNotEmpty) filledFields++;

      final double confidenceScore = (filledFields / totalFields).clamp(0.1, 0.75);
      final double uncertaintyScore = (1.0 - confidenceScore).clamp(0.25, 0.9);

      final List<Anomaly> anomalies = [];
      final List<Insight> insights = [];

      if (sleepScore < 0.65) {
        anomalies.add(Anomaly(
          anomalyId: 'sleep_deprivation',
          type: 'sleep_degrad',
          severity: 0.75,
          confidence: confidenceScore,
          explanation: 'Sleep duration (${sleepHours}h) is below the recommended 8 hours.',
          supportingEvidence: {'sleep_hours': sleepHours},
          detectedAt: DateTime.now(),
        ));
        insights.add(Insight(
          insightId: 'sleep_insight',
          type: 'warning',
          statement: 'Your reported sleep duration suggests a deficit. Aim for 7–9 hours.',
          confidence: confidenceScore,
          generatedAt: DateTime.now(),
        ));
      }

      if (stressScore > 0.6) {
        anomalies.add(Anomaly(
          anomalyId: 'stress_load',
          type: 'high_stress',
          severity: 0.8,
          confidence: confidenceScore,
          explanation: 'Multiple stress indicators detected from your profile.',
          supportingEvidence: {'stressors_count': lifestyleStressors.length},
          detectedAt: DateTime.now(),
        ));
        insights.add(Insight(
          insightId: 'stress_insight',
          type: 'warning',
          statement: 'Your profile indicates elevated chronic stress. Daily check-ins will help track this over time.',
          confidence: confidenceScore,
          generatedAt: DateTime.now(),
        ));
      }

      if (hydrationScore < 0.7) {
        anomalies.add(Anomaly(
          anomalyId: 'hydration_low',
          type: 'hydration_decline',
          severity: 0.7,
          confidence: confidenceScore,
          explanation: 'Digestive or metabolic concerns suggest hydration may be suboptimal.',
          supportingEvidence: {'hydration_estimate': hydrationScore},
          detectedAt: DateTime.now(),
        ));
        insights.add(Insight(
          insightId: 'hydration_insight',
          type: 'warning',
          statement: 'Based on your health profile, hydration consistency is recommended.',
          confidence: confidenceScore,
          generatedAt: DateTime.now(),
        ));
      }

      final List<Pattern> activePatterns = [];
      if (sleepScore < 0.9) {
        activePatterns.add(Pattern(
          patternId: 'sleep_pattern',
          type: 'sleep_degradation',
          confidence: confidenceScore,
          detectedAt: DateTime.now(),
          evidence: {'sleep_score': sleepScore},
        ));
      }
      if (stressScore > 0.4) {
        activePatterns.add(Pattern(
          patternId: 'stress_pattern',
          type: 'stress_accumulation',
          confidence: confidenceScore,
          detectedAt: DateTime.now(),
          evidence: {'stress_score': stressScore},
        ));
      }

      final snapshot = BiologicalTwinSnapshot(
        userId: profile.userId,
        snapshotTime: DateTime.now(),
        currentState: currentState,
        globalConfidenceScore: confidenceScore,
        globalUncertaintyScore: uncertaintyScore,
        stateConfidenceScores: {},
        stateUncertaintyScores: {},
        activePatterns: activePatterns,
        activeAnomalies: anomalies,
        insights: insights,
        trajectoryForecasts: [],
      );

      final resultState = GraphState(
        twinSnapshot: snapshot,
        userGoals: {'primary_focus': profile.primaryGoal},
        userContext: {},
        knowledgeReferences: [],
      );
      resultState.candidateRecommendations = recommendations.where((r) => r.category == 'action').toList();
      resultState.finalSafeRecommendations = recommendations;

      state = AsyncData(resultState);

    } catch (e, st) {
      debugPrint('[GRAPH] runGraph failed: $e');
      state = AsyncError(e, st);
    }
  }
}

final graphStateProvider = StateNotifierProvider<GraphNotifier, AsyncValue<GraphState?>>((ref) {
  return GraphNotifier(ref);
});

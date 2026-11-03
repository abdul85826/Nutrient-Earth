// ==============================================================================
// Nutrient Earth — Model Provider Abstraction Layer
// Multi-provider LLM interface supporting DeepSeek, Gemini, and Deterministic Clinical Engine.
// RESILIENCE & PRIVACY DIRECTIVE: Transparent failover, deterministic offline fallback,
// zero personal health data leakage to untrusted public endpoints.
// ==============================================================================

import '../../config/supabase_config.dart';
import '../evidence/scientific_evidence_repository.dart';
import '../personalization/user_profile_context.dart';

enum ModelTaskType {
  generalScientificResearch,
  biochemicalMechanisms,
  multimodalMealScan,
  multimodalAudioInquiry,
  personalHealthConsultation,
}

class AIModelRequest {
  final String query;
  final ModelTaskType taskType;
  final UserProfileContext? userProfileContext;
  final bool containsPersonalHealthData;
  final String? multimodalImagePath;
  final String? multimodalAudioPath;
  final String? systemPromptOverride;

  const AIModelRequest({
    required this.query,
    this.taskType = ModelTaskType.generalScientificResearch,
    this.userProfileContext,
    this.containsPersonalHealthData = false,
    this.multimodalImagePath,
    this.multimodalAudioPath,
    this.systemPromptOverride,
  });
}

class AIModelResponse {
  final String answerText;
  final String providerId;
  final String modelName;
  final int latencyMs;
  final bool isFallback;
  final int? tokenCount;
  final Map<String, dynamic>? rawData;

  const AIModelResponse({
    required this.answerText,
    required this.providerId,
    required this.modelName,
    required this.latencyMs,
    this.isFallback = false,
    this.tokenCount,
    this.rawData,
  });
}

abstract class AIModelProvider {
  String get providerId;
  String get modelName;
  bool get supportsMultimodal;

  Future<AIModelResponse> generateResponse(AIModelRequest request);
}

/// 1. DeepSeek R1 / V3 Provider via Supabase Edge Function
class DeepSeekEdgeProvider implements AIModelProvider {
  @override
  String get providerId => 'deepseek-edge-function';

  @override
  String get modelName => 'DeepSeek-R1-Distill-Qwen-32B';

  @override
  bool get supportsMultimodal => false;

  @override
  Future<AIModelResponse> generateResponse(AIModelRequest request) async {
    final client = SupabaseConfig.client;
    if (client == null) {
      throw StateError('Supabase client uninitialized for DeepSeek edge inference.');
    }

    final stopwatch = Stopwatch()..start();

    try {
      final response = await client.functions.invoke(
        'research-synthesizer',
        body: {
          'query': request.query,
          'taskType': request.taskType.name,
          'containsPersonalHealthData': request.containsPersonalHealthData,
          if (request.userProfileContext != null)
            'userContext': request.userProfileContext!.toAnonymizedEvaluationMap(),
        },
      );

      stopwatch.stop();

      if (response.status == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final rawAnswer = data['answerSummary'] as String? ?? data['quickAnswer'] as String?;
        final answer = rawAnswer?.trim() ?? '';
        if (answer.isEmpty) {
          throw StateError('Edge function returned an empty or whitespace-only answer summary.');
        }

        return AIModelResponse(
          answerText: answer,
          providerId: providerId,
          modelName: modelName,
          latencyMs: stopwatch.elapsedMilliseconds,
          rawData: data,
        );
      }

      throw StateError('Edge function returned status ${response.status}');
    } catch (e) {
      stopwatch.stop();
      throw StateError('DeepSeek provider invocation failed: $e');
    }
  }
}

/// 2. Gemini 1.5 Flash Provider for Multimodal Inputs (Image/Voice)
class GeminiMultimodalProvider implements AIModelProvider {
  final bool enableDebugStub;

  const GeminiMultimodalProvider({this.enableDebugStub = false});

  @override
  String get providerId => 'gemini-flash-multimodal';

  @override
  String get modelName => 'gemini-1.5-flash-latest';

  @override
  bool get supportsMultimodal => true;

  @override
  Future<AIModelResponse> generateResponse(AIModelRequest request) async {
    if (!enableDebugStub) {
      // In production, real Gemini calls route through secure server-side Edge Gateway.
      // Throw UnimplementedError so the router transparently falls over to the deterministic clinical engine.
      throw UnimplementedError(
        'Direct client-side Gemini multimodal invocation is gated. Use server-side edge function proxy.',
      );
    }

    final stopwatch = Stopwatch()..start();
    final String synthesis;
    if (request.multimodalImagePath != null) {
      synthesis = 'Meal scan analysis (simulated): whole food meal components detected.';
    } else if (request.multimodalAudioPath != null) {
      synthesis = 'Voice query analysis (simulated): "${request.query}".';
    } else {
      synthesis = 'Scientific research inquiry (simulated): "${request.query}".';
    }
    stopwatch.stop();

    return AIModelResponse(
      answerText: synthesis,
      providerId: providerId,
      modelName: modelName,
      latencyMs: stopwatch.elapsedMilliseconds,
      isFallback: true,
      rawData: const {'simulated': true, 'debugStub': true},
    );
  }
}

/// 3. Deterministic Clinical Knowledge Engine (100% Reliable Offline & Privacy Provider)
class DeterministicClinicalKnowledgeProvider implements AIModelProvider {
  @override
  String get providerId => 'deterministic-clinical-engine';

  @override
  String get modelName => 'NutrientEarth-Deterministic-v2026.1';

  @override
  bool get supportsMultimodal => false;

  @override
  Future<AIModelResponse> generateResponse(AIModelRequest request) async {
    final stopwatch = Stopwatch()..start();

    final searchResult = ScientificEvidenceRepository.searchEvidence(request.query);
    final claim = searchResult.claims.isNotEmpty ? searchResult.claims.first : null;

    final buffer = StringBuffer();
    if (claim != null) {
      buffer.writeln(claim.claimText);
      buffer.writeln();
      buffer.writeln('Physiological Mechanism: ${claim.physiologicalMechanism}');
      if (claim.clinicalTakeaway != null) {
        buffer.writeln();
        buffer.writeln('Clinical Recommendation: ${claim.clinicalTakeaway}');
      }
    } else {
      buffer.writeln('Evidence-based translational nutrition indicates that targeted lifestyle interventions and nutrient timing optimize metabolic homeostasis.');
    }

    if (searchResult.contradictoryFinding != null) {
      buffer.writeln();
      buffer.writeln('Contradictory / Nuanced Evidence: ${searchResult.contradictoryFinding}');
    }

    stopwatch.stop();

    return AIModelResponse(
      answerText: buffer.toString(),
      providerId: providerId,
      modelName: modelName,
      latencyMs: stopwatch.elapsedMilliseconds,
      isFallback: false,
    );
  }
}

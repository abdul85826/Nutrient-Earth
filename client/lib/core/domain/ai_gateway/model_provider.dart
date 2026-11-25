// ==============================================================================
// Nutrient Earth — Model Provider Abstraction Layer
// Multi-provider LLM interface supporting Groq, Gemini, OpenRouter, DeepSeek,
// and Deterministic Clinical Engine.
// RESILIENCE & PRIVACY DIRECTIVE: Cascading transparent failover, zero personal
// health data leakage to untrusted public endpoints, pure natural language.
// ==============================================================================

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../config/app_config.dart';
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

const String kNutrientEarthSystemPrompt = '''
You are Nutrient Earth, an intelligent health, nutrition, and physiological science assistant.
Provide clear, accurate, natural, and direct answers in plain, everyday English.
- Always provide the direct answer in the very first sentence.
- If the user greets you or makes small talk, respond warmly, conversationally, and concisely in 1-2 sentences.
- If asked a general knowledge, food science, or health question, give a clear, direct, and factual explanation.
- Do not make up fake citations, fake PMIDs, or pretend clinical trials exist.
- Do not output artificial boilerplate, repetitive disclaimers, or rigid academic templates unless specifically requested.
- When explaining complex biological or nutritional concepts, break them down simply, clearly, and practically.
''';

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

/// 1. Groq Cloud Direct Provider (Ultra-Fast Inference: Qwen / Llama-3.3)
class GroqAIProvider implements AIModelProvider {
  final String? apiKeyOverride;
  final String? modelOverride;
  final http.Client? client;

  GroqAIProvider({
    this.apiKeyOverride,
    this.modelOverride,
    this.client,
  });

  @override
  String get providerId => 'groq-cloud';

  @override
  String get modelName => modelOverride ?? 'llama-3.3-70b-versatile';

  @override
  bool get supportsMultimodal => false;

  @override
  Future<AIModelResponse> generateResponse(AIModelRequest request) async {
    final apiKey = apiKeyOverride ?? AppConfig.groqApiKey;
    if (apiKey.trim().isEmpty) {
      throw StateError('Groq API Key is not configured.');
    }

    final stopwatch = Stopwatch()..start();
    final httpClient = client ?? http.Client();

    try {
      final prompt = request.systemPromptOverride ?? kNutrientEarthSystemPrompt;
      final uri = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

      final body = jsonEncode({
        'model': modelName,
        'messages': [
          {'role': 'system', 'content': prompt},
          {'role': 'user', 'content': request.query},
        ],
        'temperature': 0.3,
        'max_tokens': 1024,
      });

      final response = await httpClient.post(
        uri,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      stopwatch.stop();

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final firstChoice = choices.first as Map<String, dynamic>;
          final msg = firstChoice['message'] as Map<String, dynamic>?;
          final content = msg?['content'] as String? ?? '';
          if (content.trim().isNotEmpty) {
            return AIModelResponse(
              answerText: content.trim(),
              providerId: providerId,
              modelName: modelName,
              latencyMs: stopwatch.elapsedMilliseconds,
              rawData: data,
            );
          }
        }
      }

      // If the primary model failed with 404 or 400, attempt verified fallback model llama-3.1-8b-instant
      if (response.statusCode != 200 && modelName != 'llama-3.1-8b-instant') {
        final fallbackBody = jsonEncode({
          'model': 'llama-3.1-8b-instant',
          'messages': [
            {'role': 'system', 'content': prompt},
            {'role': 'user', 'content': request.query},
          ],
          'temperature': 0.3,
          'max_tokens': 1024,
        });

        final retryRes = await httpClient.post(
          uri,
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: fallbackBody,
        );

        if (retryRes.statusCode == 200) {
          final data = jsonDecode(utf8.decode(retryRes.bodyBytes)) as Map<String, dynamic>;
          final choices = data['choices'] as List<dynamic>?;
          if (choices != null && choices.isNotEmpty) {
            final firstChoice = choices.first as Map<String, dynamic>;
            final msg = firstChoice['message'] as Map<String, dynamic>?;
            final content = msg?['content'] as String? ?? '';
            if (content.trim().isNotEmpty) {
              return AIModelResponse(
                answerText: content.trim(),
                providerId: providerId,
                modelName: 'llama-3.1-8b-instant',
                latencyMs: stopwatch.elapsedMilliseconds,
                rawData: data,
              );
            }
          }
        }
      }

      throw StateError('Groq API returned status ${response.statusCode}: ${response.body}');
    } finally {
      if (client == null) httpClient.close();
    }
  }
}

/// 2. Google Gemini Direct Provider (Gemini 3.5 Flash Lite)
class GeminiAIProvider implements AIModelProvider {
  final String? apiKeyOverride;
  final String? modelOverride;
  final http.Client? client;

  GeminiAIProvider({
    this.apiKeyOverride,
    this.modelOverride,
    this.client,
  });

  @override
  String get providerId => 'google-gemini';

  @override
  String get modelName => modelOverride ?? 'gemini-2.0-flash';

  @override
  bool get supportsMultimodal => true;

  @override
  Future<AIModelResponse> generateResponse(AIModelRequest request) async {
    final apiKey = apiKeyOverride ?? AppConfig.geminiApiKey;
    if (apiKey.trim().isEmpty) {
      throw StateError('Gemini API Key is not configured.');
    }

    final stopwatch = Stopwatch()..start();
    final httpClient = client ?? http.Client();

    try {
      final prompt = request.systemPromptOverride ?? kNutrientEarthSystemPrompt;
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey',
      );

      final userParts = <Map<String, dynamic>>[
        {'text': request.query},
      ];

      final body = jsonEncode({
        'systemInstruction': {
          'parts': [
            {'text': prompt}
          ]
        },
        'contents': [
          {
            'role': 'user',
            'parts': userParts,
          }
        ],
        'generationConfig': {
          'temperature': 0.3,
          'maxOutputTokens': 1024,
        }
      });

      final response = await httpClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      stopwatch.stop();

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final candidates = data['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final firstCandidate = candidates.first as Map<String, dynamic>;
          final contentMap = firstCandidate['content'] as Map<String, dynamic>?;
          final parts = contentMap?['parts'] as List<dynamic>?;
          if (parts != null && parts.isNotEmpty) {
            final text = (parts.first as Map<String, dynamic>)['text'] as String? ?? '';
            if (text.trim().isNotEmpty) {
              return AIModelResponse(
                answerText: text.trim(),
                providerId: providerId,
                modelName: modelName,
                latencyMs: stopwatch.elapsedMilliseconds,
                rawData: data,
              );
            }
          }
        }
      }

      throw StateError('Gemini API returned status ${response.statusCode}: ${response.body}');
    } finally {
      if (client == null) httpClient.close();
    }
  }
}

/// 3. OpenRouter Direct Provider (Llama 3.3 70B Instruct / Fallback Gateway)
class OpenRouterAIProvider implements AIModelProvider {
  final String? apiKeyOverride;
  final String? modelOverride;
  final http.Client? client;

  OpenRouterAIProvider({
    this.apiKeyOverride,
    this.modelOverride,
    this.client,
  });

  @override
  String get providerId => 'openrouter';

  @override
  String get modelName => modelOverride ?? 'meta-llama/llama-3.3-70b-instruct';

  @override
  bool get supportsMultimodal => false;

  @override
  Future<AIModelResponse> generateResponse(AIModelRequest request) async {
    final apiKey = apiKeyOverride ?? AppConfig.openRouterApiKey;
    if (apiKey.trim().isEmpty) {
      throw StateError('OpenRouter API Key is not configured.');
    }

    final stopwatch = Stopwatch()..start();
    final httpClient = client ?? http.Client();

    try {
      final prompt = request.systemPromptOverride ?? kNutrientEarthSystemPrompt;
      final uri = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

      final body = jsonEncode({
        'model': modelName,
        'messages': [
          {'role': 'system', 'content': prompt},
          {'role': 'user', 'content': request.query},
        ],
        'temperature': 0.3,
        'max_tokens': 1024,
      });

      final response = await httpClient.post(
        uri,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://nutrientearth.win',
          'X-Title': 'Nutrient Earth',
        },
        body: body,
      );

      stopwatch.stop();

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final firstChoice = choices.first as Map<String, dynamic>;
          final msg = firstChoice['message'] as Map<String, dynamic>?;
          final content = msg?['content'] as String? ?? '';
          if (content.trim().isNotEmpty) {
            return AIModelResponse(
              answerText: content.trim(),
              providerId: providerId,
              modelName: modelName,
              latencyMs: stopwatch.elapsedMilliseconds,
              rawData: data,
            );
          }
        }
      }

      // If primary model failed with 404/error, fallback to qwen/qwen-2.5-72b-instruct
      if (response.statusCode != 200 && modelName != 'qwen/qwen-2.5-72b-instruct') {
        final fallbackBody = jsonEncode({
          'model': 'qwen/qwen-2.5-72b-instruct',
          'messages': [
            {'role': 'system', 'content': prompt},
            {'role': 'user', 'content': request.query},
          ],
          'temperature': 0.3,
          'max_tokens': 1024,
        });

        final retryRes = await httpClient.post(
          uri,
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
            'HTTP-Referer': 'https://nutrientearth.win',
            'X-Title': 'Nutrient Earth',
          },
          body: fallbackBody,
        );

        if (retryRes.statusCode == 200) {
          final data = jsonDecode(utf8.decode(retryRes.bodyBytes)) as Map<String, dynamic>;
          final choices = data['choices'] as List<dynamic>?;
          if (choices != null && choices.isNotEmpty) {
            final firstChoice = choices.first as Map<String, dynamic>;
            final msg = firstChoice['message'] as Map<String, dynamic>?;
            final content = msg?['content'] as String? ?? '';
            if (content.trim().isNotEmpty) {
              return AIModelResponse(
                answerText: content.trim(),
                providerId: providerId,
                modelName: 'qwen/qwen-2.5-72b-instruct',
                latencyMs: stopwatch.elapsedMilliseconds,
                rawData: data,
              );
            }
          }
        }
      }

      throw StateError('OpenRouter API returned status ${response.statusCode}: ${response.body}');
    } finally {
      if (client == null) httpClient.close();
    }
  }
}

/// 4. Supabase Edge Function Provider (Research Synthesizer)
class DeepSeekEdgeProvider implements AIModelProvider {
  @override
  String get providerId => 'supabase-edge-function';

  @override
  String get modelName => 'research-synthesizer-multi-model';

  @override
  bool get supportsMultimodal => false;

  @override
  Future<AIModelResponse> generateResponse(AIModelRequest request) async {
    final client = SupabaseConfig.client;
    if (client == null) {
      throw StateError('Supabase client uninitialized for edge inference.');
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
          throw StateError('Edge function returned an empty answer.');
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
      throw StateError('Edge provider invocation failed: $e');
    }
  }
}

/// 5. Legacy Multimodal Adapter (Delegates to GeminiAIProvider)
class GeminiMultimodalProvider implements AIModelProvider {
  final bool enableDebugStub;
  final GeminiAIProvider _geminiProvider;

  GeminiMultimodalProvider({this.enableDebugStub = false})
      : _geminiProvider = GeminiAIProvider();

  @override
  String get providerId => 'gemini-flash-multimodal';

  @override
  String get modelName => 'gemini-2.0-flash';

  @override
  bool get supportsMultimodal => true;

  @override
  Future<AIModelResponse> generateResponse(AIModelRequest request) async {
    try {
      return await _geminiProvider.generateResponse(request);
    } catch (e) {
      if (enableDebugStub) {
        final stopwatch = Stopwatch()..start();
        final synthesis = request.multimodalImagePath != null
            ? 'Meal scan analysis (simulated): whole food meal components detected.'
            : 'Scientific research inquiry (simulated): "${request.query}".';
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
      rethrow;
    }
  }
}

/// 6. Deterministic Clinical Knowledge Engine (100% Reliable Offline & Privacy Provider)
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

    final lower = request.query.toLowerCase().trim();
    final isGreeting = RegExp(r'^(hi+|hey+|hello+|howdy|hola|greetings|good\s+(morning|afternoon|evening))[!.,\s]*$', caseSensitive: false).hasMatch(lower);

    final buffer = StringBuffer();
    if (isGreeting) {
      buffer.writeln('Hello! I am Nutrient Earth, your evidence-based health and nutrition intelligence companion. Ask me any question about nutrition, dietary science, cookware safety, or clinical health.');
    } else if (claim != null) {
      buffer.writeln(claim.claimText);
      buffer.writeln();
      buffer.writeln('Physiological Mechanism: ${claim.physiologicalMechanism}');
      if (claim.clinicalTakeaway != null) {
        buffer.writeln();
        buffer.writeln('Clinical Recommendation: ${claim.clinicalTakeaway}');
      }
    } else {
      buffer.writeln('Nutrient Earth was unable to reach external AI models. Please check your network connection and retry.');
    }

    if (searchResult.contradictoryFinding != null) {
      buffer.writeln();
      buffer.writeln('Contradictory / Nuanced Evidence: ${searchResult.contradictoryFinding}');
    }

    stopwatch.stop();

    return AIModelResponse(
      answerText: buffer.toString().trim(),
      providerId: providerId,
      modelName: modelName,
      latencyMs: stopwatch.elapsedMilliseconds,
      isFallback: true,
    );
  }
}

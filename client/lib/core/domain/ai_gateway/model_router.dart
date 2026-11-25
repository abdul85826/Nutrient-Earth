// ==============================================================================
// Nutrient Earth — Central Task-Based AI Model Router
// Routes requests dynamically across Groq, Gemini, OpenRouter, Supabase Edge,
// and Deterministic Clinical Engine.
// Enforces PII isolation, timeouts, cascading failover, and authorization-aware caching.
// ==============================================================================

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_config.dart';
import 'model_provider.dart';

class CachedModelEntry {
  final AIModelResponse response;
  final DateTime cachedAt;

  const CachedModelEntry({
    required this.response,
    required this.cachedAt,
  });

  bool isExpired(Duration ttl) => DateTime.now().difference(cachedAt) > ttl;
}

class AIModelRouter {
  final AIModelProvider groqProvider;
  final AIModelProvider geminiProvider;
  final AIModelProvider openRouterProvider;
  final AIModelProvider deepSeekProvider;
  final AIModelProvider deterministicProvider;
  final Duration requestTimeout;
  final Duration cacheTtl;

  final Map<String, CachedModelEntry> _cache = {};

  AIModelRouter({
    AIModelProvider? groqProvider,
    AIModelProvider? geminiProvider,
    AIModelProvider? openRouterProvider,
    AIModelProvider? deepSeekProvider,
    AIModelProvider? deterministicProvider,
    this.requestTimeout = const Duration(seconds: 10),
    this.cacheTtl = const Duration(minutes: 15),
  })  : groqProvider = groqProvider ?? GroqAIProvider(),
        geminiProvider = geminiProvider ?? GeminiAIProvider(),
        openRouterProvider = openRouterProvider ?? OpenRouterAIProvider(),
        deepSeekProvider = deepSeekProvider ?? DeepSeekEdgeProvider(),
        deterministicProvider = deterministicProvider ?? DeterministicClinicalKnowledgeProvider();

  /// Evaluates whether a request can safely read/write cache entries.
  /// Bypasses cache when personal health data is present, task is health consultation,
  /// user profile context is present, multimodal media is present, or userId is absent.
  bool _isCacheable(AIModelRequest request, String? userId) {
    if (userId == null || userId.trim().isEmpty) return false;
    if (request.containsPersonalHealthData) return false;
    if (request.taskType == ModelTaskType.personalHealthConsultation) return false;
    if (request.userProfileContext != null) return false;
    if (request.multimodalImagePath != null || request.multimodalAudioPath != null) return false;
    return true;
  }

  /// Routes and generates response with multi-layer cascading fallback and caching.
  Future<AIModelResponse> routeAndExecute(AIModelRequest request, {String? userId}) async {
    final cacheable = _isCacheable(request, userId);
    final cacheKey = cacheable ? _computeCacheKey(request, userId!) : null;

    // 1. Authorization-aware caching check
    if (cacheable && cacheKey != null) {
      final cached = _cache[cacheKey];
      if (cached != null && !cached.isExpired(cacheTtl)) {
        return cached.response;
      }
    }

    // 2. Strict Privacy Routing: Personal health signals & consultations NEVER go to public LLMs
    final isProtected = request.containsPersonalHealthData ||
        request.taskType == ModelTaskType.personalHealthConsultation;
    if (isProtected) {
      return await deterministicProvider.generateResponse(request);
    }

    // 3. Multimodal Routing: Images and Voice route to multimodal-capable models
    if (request.multimodalImagePath != null || request.multimodalAudioPath != null) {
      try {
        final response = await geminiProvider
            .generateResponse(request)
            .timeout(requestTimeout);
        return response;
      } catch (e) {
        debugPrint('[AIModelRouter] Multimodal model failed: $e. Falling over to deterministic engine.');
        return await deterministicProvider.generateResponse(request);
      }
    }

    // 4. Cascading Multi-Model Intelligence Stack:
    // Tier 1: Groq Cloud (Ultra-fast Qwen / Llama-3.3)
    // Tier 2: Google Gemini (Gemini 3.5 Flash Lite)
    // Tier 3: OpenRouter (Llama 3.3 70B Instruct)
    // Tier 4: Supabase Edge Synthesizer
    final hasActiveOpenRouter = AppConfig.openRouterApiKey.trim().isNotEmpty;
    final candidates = [
      if (hasActiveOpenRouter) openRouterProvider,
      groqProvider,
      geminiProvider,
      if (!hasActiveOpenRouter) openRouterProvider,
      deepSeekProvider,
    ];

    for (final provider in candidates) {
      try {
        final response = await provider
            .generateResponse(request)
            .timeout(requestTimeout);

        if (response.answerText.trim().isNotEmpty) {
          if (cacheable && cacheKey != null) {
            _cache[cacheKey] = CachedModelEntry(response: response, cachedAt: DateTime.now());
          }
          return response;
        }
      } catch (e) {
        debugPrint('[AIModelRouter] ${provider.providerId} failed: $e. Falling over...');
        continue;
      }
    }

    // 5. Offline Fallback: Deterministic Clinical Knowledge Engine
    final fallbackResponse = await deterministicProvider.generateResponse(request);
    return AIModelResponse(
      answerText: fallbackResponse.answerText,
      providerId: fallbackResponse.providerId,
      modelName: fallbackResponse.modelName,
      latencyMs: fallbackResponse.latencyMs,
      isFallback: true,
    );
  }

  void clearCache() {
    _cache.clear();
  }

  String _computeCacheKey(AIModelRequest request, String userId) {
    final payload = {
      'user_id': userId,
      'task_type': request.taskType.name,
      'query': request.query.trim().toLowerCase(),
      'system_prompt_override': request.systemPromptOverride ?? '',
    };
    final serialized = jsonEncode(payload);
    return sha256.convert(utf8.encode(serialized)).toString();
  }
}

final modelRouterProvider = Provider<AIModelRouter>((ref) {
  return AIModelRouter();
});

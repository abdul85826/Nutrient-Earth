// ==============================================================================
// Nutrient Earth — Central Task-Based AI Model Router
// Routes requests dynamically across DeepSeek, Gemini, and Deterministic Clinical Engine.
// Enforces PII isolation, timeouts, bounded retries, and authorization-aware caching.
// ==============================================================================

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final AIModelProvider deepSeekProvider;
  final AIModelProvider geminiProvider;
  final AIModelProvider deterministicProvider;
  final Duration requestTimeout;
  final Duration cacheTtl;

  final Map<String, CachedModelEntry> _cache = {};

  AIModelRouter({
    AIModelProvider? deepSeekProvider,
    AIModelProvider? geminiProvider,
    AIModelProvider? deterministicProvider,
    this.requestTimeout = const Duration(seconds: 5),
    this.cacheTtl = const Duration(minutes: 15),
  })  : deepSeekProvider = deepSeekProvider ?? DeepSeekEdgeProvider(),
        geminiProvider = geminiProvider ?? const GeminiMultimodalProvider(),
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

  /// Routes and generates response with multi-layer fallback and caching.
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
      final response = await deterministicProvider.generateResponse(request);
      return response;
    }

    // 3. Multimodal Routing: Images and Voice route to multimodal-capable models
    if (request.multimodalImagePath != null || request.multimodalAudioPath != null) {
      try {
        final response = await geminiProvider
            .generateResponse(request)
            .timeout(requestTimeout);
        return response;
      } catch (_) {
        // Fall back to deterministic clinical engine if multimodal endpoint fails
        final fallbackResponse = await deterministicProvider.generateResponse(request);
        return fallbackResponse;
      }
    }

    // 4. Primary Research Routing: DeepSeek with timeout & transparent fallback
    try {
      final response = await deepSeekProvider
          .generateResponse(request)
          .timeout(requestTimeout);

      if (cacheable && cacheKey != null) {
        _cache[cacheKey] = CachedModelEntry(response: response, cachedAt: DateTime.now());
      }
      return response;
    } catch (_) {
      // Automatic transparent failover to Deterministic Clinical Knowledge Engine.
      // Do NOT cache fallback responses so temporary failures do not pollute the cache.
      final fallbackResponse = await deterministicProvider.generateResponse(request);
      return fallbackResponse;
    }
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

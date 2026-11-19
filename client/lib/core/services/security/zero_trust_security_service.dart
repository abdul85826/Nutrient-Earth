// ==============================================================================
// Nutrient Earth — Zero-Trust Security & Agent Boundary Service
// Enforces least-privilege tool allowlists, verified identity derivation,
// tool argument validation, and strict isolation against direct/indirect injection.
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class ZeroTrustSecurityService {
  bool validateVerifiedIdentity({
    required String sessionUserId,
    required String resourceOwnerId,
  });

  bool isToolPermitted({
    required String specialistRole,
    required String toolName,
  });

  bool validateToolArguments({
    required String toolName,
    required Map<String, dynamic> arguments,
  });

  String sanitizeRetrievedContent(String rawContent);

  bool checkRateLimit({
    required String userId,
    required String action,
    int maxPerMinute = 60,
  });
}

class DefaultZeroTrustSecurityService implements ZeroTrustSecurityService {
  // 1. Strict Per-Specialist Tool Allowlists (12 Governed Capabilities)
  static final Map<String, Set<String>> _specialistToolAllowlists = {
    // Phase 10 Governed Capabilities
    'productIdentityResolver': {
      'resolveFromBarcode',
      'resolveFromLabelOcr',
      'validateBarcodeChecksum',
    },
    'productEvidenceResearcher': {
      'searchAuthoritativeSources',
      'critiqueScientificDocument',
    },
    'ingredientIntelligence': {
      'getProcessingGuidance',
      'evaluateFoodAdditives',
    },
    'nutritionAnalyzer': {
      'calculateAtwaterEnergy',
      'searchUsdaFoods',
    },
    'claimVerification': {
      'validateClaim',
      'validateFormulationClaims',
    },
    'urlResearch': {
      'fetchAndExtractUrl',
      'isUrlPermitted',
    },
    'videoUnderstanding': {
      'analyzeVideo',
      'validateVideoContainer',
    },
    'audioUnderstanding': {
      'processMultilingualQuery',
    },
    'multilingualProcessing': {
      'detectLanguage',
      'processMultilingualQuery',
      'extractAndProtectTerminology',
    },
    'scientificEvidenceReviewer': {
      'searchAuthoritativeSources',
      'critiqueScientificDocument',
      'dissectPopularHealthClaim',
    },
    'safetyEvaluator': {
      'evaluateMedicalQuery',
      'checkContraindications',
      'evaluateHazardRisk',
      'evaluateUtensilSafety',
    },
    'personalizedRecommendation': {
      'generateRecommendation',
      'getCurrentActiveFacts',
    },

    // Backward-compatible capability keys
    'research': {
      'searchAuthoritativeSources',
      'fetchAndExtractUrl',
      'critiqueScientificDocument',
      'dissectPopularHealthClaim',
    },
    'foodScience': {
      'getProcessingGuidance',
      'evaluateUtensilSafety',
      'evaluateHazardRisk',
    },
    'medicalSafety': {
      'evaluateMedicalQuery',
      'checkContraindications',
    },
    'traditionalLiving': {
      'getMilletProfiles',
      'getFermentationSuitability',
      'getAyurvedicCrosswalks',
      'evaluateHistoricalLongevityClaims',
    },
    'movementRecovery': {
      'getTasksForDate',
      'adaptTasksForEnvironment',
      'verifyWearableCompletion',
      'adaptTaskForBehavioralAdherence',
    },
    'personalization': {
      'getCurrentActiveFacts',
      'recordFact',
      'getFactsAsOf',
    },
    'nutrition': {
      'calculateAtwaterEnergy',
      'searchUsdaFoods',
    },
    'productLabel': {
      'parseBarcode',
      'evaluateFoodAdditives',
      'resolveFromBarcode',
    },
  };

  // 2. Adversarial Injection Patterns
  static final List<RegExp> _adversarialPatterns = [
    RegExp(r'ignore\s+all\s+(previous|prior)\s+instructions', caseSensitive: false),
    RegExp(r'disregard\s+(previous|system)\s+(instructions|prompt)', caseSensitive: false),
    RegExp(r'you\s+are\s+now\s+(a|an)\s+', caseSensitive: false),
    RegExp(r'<\|im_start\|>', caseSensitive: false),
    RegExp(r'<\|im_end\|>', caseSensitive: false),
    RegExp(r'system\s*:', caseSensitive: false),
    RegExp(r'developer\s+mode', caseSensitive: false),
    RegExp(r'override\s+security\s+guardrails', caseSensitive: false),
    RegExp(r'drop\s+table', caseSensitive: false),
    RegExp(r'select\s+\*\s+from\s+auth\.users', caseSensitive: false),
  ];

  // In-memory rate limiting counters: key -> list of request timestamps
  final Map<String, List<DateTime>> _rateLimits = {};

  @override
  bool validateVerifiedIdentity({
    required String sessionUserId,
    required String resourceOwnerId,
  }) {
    // Client-provided identity is NEVER trusted over authenticated session
    if (sessionUserId.trim().isEmpty || resourceOwnerId.trim().isEmpty) {
      return false;
    }
    return sessionUserId.trim() == resourceOwnerId.trim();
  }

  @override
  bool isToolPermitted({
    required String specialistRole,
    required String toolName,
  }) {
    final allowlist = _specialistToolAllowlists[specialistRole];
    if (allowlist == null) {
      return false; // Unknown specialist has zero tool privileges
    }
    return allowlist.contains(toolName);
  }

  @override
  bool validateToolArguments({
    required String toolName,
    required Map<String, dynamic> arguments,
  }) {
    // 1. SSRF & URL validation
    if (toolName == 'fetchAndExtractUrl') {
      final url = arguments['url']?.toString();
      if (url == null || url.trim().isEmpty) return false;
      final uri = Uri.tryParse(url);
      if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) return false;

      final host = uri.host.toLowerCase();
      if (host == 'localhost' ||
          host == '127.0.0.1' ||
          host == '0.0.0.0' ||
          host.startsWith('10.') ||
          host.startsWith('192.168.') ||
          host.startsWith('169.254.') ||
          host.endsWith('.internal')) {
        return false; // SSRF detected
      }
    }

    // 2. Query length and payload bounds
    if (toolName == 'searchAuthoritativeSources' || toolName == 'evaluateMedicalQuery') {
      final query = arguments['query']?.toString();
      if (query == null || query.trim().isEmpty) return false;
      if (query.length > 2000) return false; // Overflow defense
    }

    // 3. User ID sanity check
    if (arguments.containsKey('userId')) {
      final uid = arguments['userId']?.toString();
      if (uid == null || uid.trim().isEmpty || uid.length > 128) return false;
    }

    return true;
  }

  @override
  String sanitizeRetrievedContent(String rawContent) {
    String sanitized = rawContent;
    for (final pattern in _adversarialPatterns) {
      sanitized = sanitized.replaceAll(pattern, '[REDACTED_SECURITY_RISK]');
    }

    // Wrap external data inside an isolated block
    return '''
<UNTRUSTED_DATA_BOUNDARY>
$sanitized
</UNTRUSTED_DATA_BOUNDARY>''';
  }

  @override
  bool checkRateLimit({
    required String userId,
    required String action,
    int maxPerMinute = 60,
  }) {
    final key = '$userId:$action';
    final now = DateTime.now().toUtc();
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));

    final history = _rateLimits.putIfAbsent(key, () => []);
    history.removeWhere((t) => t.isBefore(oneMinuteAgo));

    if (history.length >= maxPerMinute) {
      return false; // Rate limit exceeded
    }

    history.add(now);
    return true;
  }
}

final zeroTrustSecurityServiceProvider = Provider<ZeroTrustSecurityService>((ref) {
  return DefaultZeroTrustSecurityService();
});

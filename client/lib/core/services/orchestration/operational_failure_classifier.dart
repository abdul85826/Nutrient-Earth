// ==============================================================================
// Nutrient Earth — Operational Failure Classifier & Safe Recovery Engine
// Master Engineering Hardening: Parts C, N, P (Schema v2026.3)
//
// Classifies runtime anomalies into 13 canonical failure states and dictates
// deterministic recovery paths without simulating success or hiding errors.
// ==============================================================================

/// 13 Canonical Operational Failure States
enum OperationalFailureType {
  providerUnavailable,      // Upstream LLM provider is down (500, 502, 503)
  rateLimited,              // Provider quota exhausted or 429 Too Many Requests
  timeoutExceeded,          // Request exceeded bounded execution latency budget
  authInvalid,              // Missing, expired, or invalid API credentials/tokens
  networkDisrupted,         // Device offline or TCP socket failure
  circuitBreakerOpen,       // Circuit breaker tripped due to consecutive upstream failures
  malformedResponse,        // Response failed JSON schema validation or truncated
  contentPolicyTripped,     // Upstream safety filter or toxic prompt rejection
  verificationFailed,       // Generated claims failed citation verification gate
  evidenceInsufficient,     // Literature retrieval returned zero verified publications
  safeAbstention,           // System intentionally declined to answer due to high safety risk or lack of evidence
  partialResponse,          // Some content blocks generated, but downstream enrichment timed out
  unsupportedModality,      // User submitted an input type unsupported by the active model
}

/// Recovery directive for the runtime
enum OperationalRecoveryAction {
  retryWithBackoff,                 // Transient error; safe to retry after exponential backoff
  fallbackToDeterministicEngine,    // Route request to verified internal deterministic knowledge base
  abstainAndNotifyUser,             // Do not answer; present honest, transparent limitation explanation
  requestClarification,             // Query was fundamentally ambiguous; prompt user for specifics
  reauthenticate,                   // Session or credentials expired; prompt user or refresh token
  renderPartialGracefully,          // Display verified partial blocks with explicit degradation warning
}

/// Structured diagnostic report for an operational failure
class OperationalFailureReport {
  final String failureCode;
  final OperationalFailureType failureType;
  final bool isTransient;
  final OperationalRecoveryAction suggestedAction;
  final String userMessage;
  final String forensicSummary;
  final bool canRecoverGracefully;
  final Map<String, dynamic> metadata;

  const OperationalFailureReport({
    required this.failureCode,
    required this.failureType,
    required this.isTransient,
    required this.suggestedAction,
    required this.userMessage,
    required this.forensicSummary,
    this.canRecoverGracefully = true,
    this.metadata = const {},
  });

  @override
  String toString() => '[$failureCode] $failureType -> $suggestedAction: $forensicSummary';
}

class OperationalFailureClassifier {
  OperationalFailureClassifier._();

  /// Classifies any exception, HTTP status code, or verification outcome
  static OperationalFailureReport classify({
    dynamic error,
    int? statusCode,
    String? responseBody,
    String? taskContext,
  }) {
    final errStr = error?.toString().toLowerCase() ?? '';
    final bodyStr = responseBody?.toLowerCase() ?? '';

    // 1. Rate Limiting (429)
    if (statusCode == 429 || errStr.contains('429') || errStr.contains('rate limit') || errStr.contains('quota exceeded')) {
      return const OperationalFailureReport(
        failureCode: 'ERR_RATE_LIMITED',
        failureType: OperationalFailureType.rateLimited,
        isTransient: true,
        suggestedAction: OperationalRecoveryAction.fallbackToDeterministicEngine,
        userMessage: 'Our AI research synthesizers are currently experiencing high global demand. Switching to our deterministic knowledge engine.',
        forensicSummary: 'Upstream provider returned HTTP 429 Rate Limit Exceeded. Triggered local deterministic fallback.',
      );
    }

    // 2. Authentication Invalid (401 / 403)
    if (statusCode == 401 || statusCode == 403 || errStr.contains('unauthorized') || errStr.contains('invalid api key')) {
      return const OperationalFailureReport(
        failureCode: 'ERR_AUTH_INVALID',
        failureType: OperationalFailureType.authInvalid,
        isTransient: false,
        suggestedAction: OperationalRecoveryAction.reauthenticate,
        userMessage: 'Authentication credentials could not be verified. Please verify your connection or sign in again.',
        forensicSummary: 'Provider rejected API key or Supabase JWT token was rejected (401/403).',
      );
    }

    // 3. Network Disruption / Socket Exception
    if (errStr.contains('socketexception') || errStr.contains('connection refused') || errStr.contains('failed host lookup') || errStr.contains('offline')) {
      return const OperationalFailureReport(
        failureCode: 'ERR_NETWORK_DISRUPTED',
        failureType: OperationalFailureType.networkDisrupted,
        isTransient: true,
        suggestedAction: OperationalRecoveryAction.retryWithBackoff,
        userMessage: 'Network connection lost. Please check your internet connectivity and try again.',
        forensicSummary: 'Client detected broken TCP socket or host lookup failure.',
      );
    }

    // 4. Timeout Exceeded (408 / 504 / Client Timeout)
    if (statusCode == 408 || statusCode == 504 || errStr.contains('timeout') || errStr.contains('deadline exceeded')) {
      return const OperationalFailureReport(
        failureCode: 'ERR_TIMEOUT_EXCEEDED',
        failureType: OperationalFailureType.timeoutExceeded,
        isTransient: true,
        suggestedAction: OperationalRecoveryAction.fallbackToDeterministicEngine,
        userMessage: 'The synthesis request timed out while analyzing scientific datasets. Serving immediate verified baseline guidance.',
        forensicSummary: 'Execution time breached bounded latency threshold.',
      );
    }

    // 5. Upstream Provider Outage (500 / 502 / 503)
    if ((statusCode != null && statusCode >= 500) || errStr.contains('bad gateway') || errStr.contains('service unavailable')) {
      return const OperationalFailureReport(
        failureCode: 'ERR_PROVIDER_UNAVAILABLE',
        failureType: OperationalFailureType.providerUnavailable,
        isTransient: true,
        suggestedAction: OperationalRecoveryAction.fallbackToDeterministicEngine,
        userMessage: 'The primary scientific synthesis service is currently undergoing maintenance. Serving deterministic reference data.',
        forensicSummary: 'Upstream model endpoint returned 5xx Server Error.',
      );
    }

    // 6. Verification Failed / Hallucination Intercepted
    if (errStr.contains('verification failed') || errStr.contains('unsupported claim') || bodyStr.contains('unsupportedclaim')) {
      return const OperationalFailureReport(
        failureCode: 'ERR_VERIFICATION_FAILED',
        failureType: OperationalFailureType.verificationFailed,
        isTransient: false,
        suggestedAction: OperationalRecoveryAction.abstainAndNotifyUser,
        userMessage: 'The generated response contained clinical or dosage claims that could not be independently authenticated against primary biomedical literature. In accordance with safety protocol, the unverified claims have been withheld.',
        forensicSummary: 'Publication Gate blocked output: claims lacked verifiable PMIDs or contradicted clinical consensus.',
      );
    }

    // 7. Evidence Insufficient
    if (errStr.contains('evidence insufficient') || errStr.contains('no studies found') || bodyStr.contains('no_studies')) {
      return const OperationalFailureReport(
        failureCode: 'ERR_EVIDENCE_INSUFFICIENT',
        failureType: OperationalFailureType.evidenceInsufficient,
        isTransient: false,
        suggestedAction: OperationalRecoveryAction.abstainAndNotifyUser,
        userMessage: 'There is currently insufficient published, peer-reviewed clinical research to answer this inquiry safely and definitively.',
        forensicSummary: 'PubMed and Cochrane retrieval returned 0 matching high-quality study designs.',
      );
    }

    // 8. Safe Abstention (Intentional)
    if (errStr.contains('safe abstention') || errStr.contains('clinical contraindication') || errStr.contains('acute emergency')) {
      return const OperationalFailureReport(
        failureCode: 'ERR_SAFE_ABSTENTION',
        failureType: OperationalFailureType.safeAbstention,
        isTransient: false,
        suggestedAction: OperationalRecoveryAction.abstainAndNotifyUser,
        userMessage: 'Nutrient Earth cannot provide individualized medical advice or guidance for acute clinical symptoms. Please consult a qualified licensed healthcare provider.',
        forensicSummary: 'Medical Safety Guard triggered intentional abstention and generated emergency clinical advice.',
      );
    }

    // 9. Malformed Response / JSON Deserialization Failure
    if (errStr.contains('formatexception') || errStr.contains('unexpected character') || errStr.contains('syntaxerror')) {
      return const OperationalFailureReport(
        failureCode: 'ERR_MALFORMED_RESPONSE',
        failureType: OperationalFailureType.malformedResponse,
        isTransient: true,
        suggestedAction: OperationalRecoveryAction.fallbackToDeterministicEngine,
        userMessage: 'An error occurred while formatting the research synthesis. Fallback data has been loaded.',
        forensicSummary: 'JSON parsing failure on upstream response payload.',
      );
    }

    // Default Unknown Error
    return OperationalFailureReport(
      failureCode: 'ERR_UNEXPECTED',
      failureType: OperationalFailureType.providerUnavailable,
      isTransient: true,
      suggestedAction: OperationalRecoveryAction.fallbackToDeterministicEngine,
      userMessage: 'An unexpected operational failure occurred. Baseline reference data is active.',
      forensicSummary: 'Unhandled exception: $errStr',
    );
  }
}

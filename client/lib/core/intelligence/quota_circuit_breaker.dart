import 'package:flutter/foundation.dart';

@immutable
class QuotaState {
  final int dailyRequestsMade;
  final int dailyRequestLimit;
  final int totalEstimatedTokens;
  final bool isThrottled;
  final String? warningMessage;

  const QuotaState({
    required this.dailyRequestsMade,
    required this.dailyRequestLimit,
    required this.totalEstimatedTokens,
    required this.isThrottled,
    this.warningMessage,
  });

  bool get isAllowed => !isThrottled;
  int get usedQueries => dailyRequestsMade;
  int get remainingQueries =>
      (dailyRequestLimit - dailyRequestsMade).clamp(0, dailyRequestLimit);

  double get usagePercentage => dailyRequestLimit > 0
      ? (dailyRequestsMade / dailyRequestLimit).clamp(0.0, 1.0)
      : 0.0;
}

class QuotaCircuitBreaker {
  static const int defaultDailyLimit = 50;
  final int dailyLimit;
  int _requestsToday = 0;
  int _estimatedTokens = 0;
  DateTime _lastReset = DateTime.now();

  QuotaCircuitBreaker({int? dailyLimit, int? dailyFreeTierLimit})
    : dailyLimit = dailyLimit ?? dailyFreeTierLimit ?? defaultDailyLimit;

  void _checkReset() {
    final now = DateTime.now();
    if (now.day != _lastReset.day ||
        now.month != _lastReset.month ||
        now.year != _lastReset.year) {
      _requestsToday = 0;
      _lastReset = now;
    }
  }

  QuotaState checkStatus() {
    _checkReset();

    final pct = _requestsToday / dailyLimit;
    String? warning;
    bool throttled = false;

    if (pct >= 1.0) {
      throttled = true;
      warning =
          'Daily research quota limit reached (100%). Free tier rate-limit protection active. Live inference will resume tomorrow.';
    } else if (pct >= 0.90) {
      warning =
          'Research quota at 90% capacity. Please prioritize high-value inquiries.';
    } else if (pct >= 0.75) {
      warning = 'Research quota at 75% capacity.';
    } else if (pct >= 0.50) {
      warning = 'Research quota at 50% capacity.';
    }

    return QuotaState(
      dailyRequestsMade: _requestsToday,
      dailyRequestLimit: dailyLimit,
      totalEstimatedTokens: _estimatedTokens,
      isThrottled: throttled,
      warningMessage: warning,
    );
  }

  QuotaState checkQuota() => checkStatus();

  void recordUsage({int estimatedTokens = 450}) {
    _checkReset();
    _requestsToday++;
    _estimatedTokens += estimatedTokens;
  }

  void recordQuery({int estimatedTokens = 450}) =>
      recordUsage(estimatedTokens: estimatedTokens);

  void resetForTesting() {
    _requestsToday = 0;
    _estimatedTokens = 0;
  }
}

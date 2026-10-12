import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth/core/intelligence/quota_circuit_breaker.dart';

void main() {
  group('QuotaCircuitBreaker Tests', () {
    test('initial state allows requests with 0% usage', () {
      final breaker = QuotaCircuitBreaker(dailyFreeTierLimit: 10);
      final status = breaker.checkQuota();

      expect(status.isAllowed, isTrue);
      expect(status.usedQueries, equals(0));
      expect(status.remainingQueries, equals(10));
      expect(status.usagePercentage, equals(0.0));
    });

    test('increments queries and computes usage thresholds', () {
      final breaker = QuotaCircuitBreaker(dailyFreeTierLimit: 4);

      breaker.recordQuery(); // 1/4 = 25%
      var status = breaker.checkQuota();
      expect(status.isAllowed, isTrue);
      expect(status.usedQueries, equals(1));
      expect(status.remainingQueries, equals(3));
      expect(status.warningMessage, isNull);

      breaker.recordQuery(); // 2/4 = 50%
      status = breaker.checkQuota();
      expect(status.isAllowed, isTrue);
      expect(status.warningMessage, contains('50%'));

      breaker.recordQuery(); // 3/4 = 75%
      status = breaker.checkQuota();
      expect(status.isAllowed, isTrue);
      expect(status.warningMessage, contains('75%'));

      breaker.recordQuery(); // 4/4 = 100%
      status = breaker.checkQuota();
      expect(status.isAllowed, isFalse);
      expect(status.remainingQueries, equals(0));
      expect(status.warningMessage, contains('reached'));
    });

    test('manual reset clears used queries', () {
      final breaker = QuotaCircuitBreaker(dailyFreeTierLimit: 5);
      breaker.recordQuery();
      breaker.recordQuery();
      expect(breaker.checkQuota().usedQueries, equals(2));

      breaker.resetForTesting();
      final status = breaker.checkQuota();
      expect(status.usedQueries, equals(0));
      expect(status.isAllowed, isTrue);
    });
  });
}

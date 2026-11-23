// ==============================================================================
// Nutrient Earth — Streak Engine Verification Tests
// Tests the production-grade, server-authoritative streak engine:
// 1. Qualifying activity taxonomy enforcement (disallowing passive actions).
// 2. Same-day duplicate activity idempotency (at most 1 streak increment per day).
// 3. Consecutive day progression.
// 4. Circadian midnight preservation (yesterday-active streak stays alive today).
// 5. Gap > 1 day reset.
// 6. Full historical reconstruction without client trust.
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/domain/streak/qualifying_activity_models.dart';
import 'package:nutrient_earth_client/core/domain/streak/streak_calculator.dart';
import 'package:nutrient_earth_client/core/services/streak/streak_engine_service.dart';

void main() {
  group('QualifyingActivity Taxonomy Tests', () {
    test('Identifies genuinely qualifying health activities', () {
      expect(QualifyingActivityType.dailyTaskCompleted.isQualifying, isTrue);
      expect(QualifyingActivityType.mealLogged.isQualifying, isTrue);
      expect(QualifyingActivityType.workoutLogged.isQualifying, isTrue);
      expect(QualifyingActivityType.lifestyleActivityCompleted.isQualifying, isTrue);
      expect(QualifyingActivityType.learnCompleted.isQualifying, isTrue);
    });

    test('Parses raw type strings safely with unknown fallback', () {
      expect(QualifyingActivityType.fromRaw('daily_task_completed'), QualifyingActivityType.dailyTaskCompleted);
      expect(QualifyingActivityType.fromRaw('meal_logged'), QualifyingActivityType.mealLogged);
      expect(QualifyingActivityType.fromRaw('workout_logged'), QualifyingActivityType.workoutLogged);
      expect(QualifyingActivityType.fromRaw('unknown_random_action'), QualifyingActivityType.unknown);
      expect(QualifyingActivityType.unknown.isQualifying, isFalse);
    });
  });

  group('StreakCalculator Deterministic Logic Tests', () {
    test('Date formatting and parsing is consistent and timezone-safe', () {
      final date = DateTime.utc(2026, 10, 14);
      final formatted = StreakCalculator.formatLocalDate(date);
      expect(formatted, '2026-10-14');

      final parsed = StreakCalculator.parseLocalDate(formatted);
      expect(parsed.year, 2026);
      expect(parsed.month, 10);
      expect(parsed.day, 14);
    });

    test('Consecutive day detector identifies adjacent dates correctly', () {
      expect(StreakCalculator.areConsecutiveDays('2026-10-13', '2026-10-14'), isTrue);
      expect(StreakCalculator.areConsecutiveDays('2026-10-14', '2026-10-15'), isTrue);
      expect(StreakCalculator.areConsecutiveDays('2026-10-31', '2026-11-01'), isTrue);

      // Non-consecutive
      expect(StreakCalculator.areConsecutiveDays('2026-10-12', '2026-10-14'), isFalse);
      expect(StreakCalculator.areConsecutiveDays('2026-10-14', '2026-10-14'), isFalse);
    });

    test('Circadian Midnight Preservation: Streak remains active if yesterday was qualified', () {
      final todayStr = '2026-10-15';
      final yesterdayStr = '2026-10-14';

      // User was active yesterday and had a 4-day streak, but has not completed today yet
      final evaluation = StreakCalculator.evaluateCurrentStreak(
        todayDateString: todayStr,
        lastQualifyingDateString: yesterdayStr,
        storedCurrentStreak: 4,
      );

      // Streak MUST NOT be reset to 0; it stays alive awaiting today's action!
      expect(evaluation.isStreakAlive, isTrue);
      expect(evaluation.isTodayCompleted, isFalse);
      expect(evaluation.effectiveStreak, 4);
      expect(evaluation.streakLabel, 'Active today · complete a task');
    });

    test('Today Completed: Streak increments if user was active today', () {
      final todayStr = '2026-10-15';

      final evaluation = StreakCalculator.evaluateCurrentStreak(
        todayDateString: todayStr,
        lastQualifyingDateString: todayStr,
        storedCurrentStreak: 5,
      );

      expect(evaluation.isStreakAlive, isTrue);
      expect(evaluation.isTodayCompleted, isTrue);
      expect(evaluation.effectiveStreak, 5);
      expect(evaluation.streakLabel, 'Streak saved for today');
    });

    test('Gap > 1 day: Streak resets to 0 if inactive yesterday and today', () {
      final todayStr = '2026-10-15';
      final olderDateStr = '2026-10-13'; // 2-day gap

      final evaluation = StreakCalculator.evaluateCurrentStreak(
        todayDateString: todayStr,
        lastQualifyingDateString: olderDateStr,
        storedCurrentStreak: 5,
      );

      expect(evaluation.isStreakAlive, isFalse);
      expect(evaluation.isTodayCompleted, isFalse);
      expect(evaluation.effectiveStreak, 0);
      expect(evaluation.streakLabel, 'Start your streak today');
    });

    test('calculateFromHistory reconstructs current and longest streaks accurately', () {
      // 5 consecutive days ending today
      final dates = [
        '2026-10-10',
        '2026-10-11',
        '2026-10-12',
        '2026-10-13',
        '2026-10-14',
      ];

      final summary = StreakCalculator.calculateFromHistory(
        userId: 'test_user',
        qualifyingLocalDates: dates,
        currentLocalDate: '2026-10-14',
      );

      expect(summary.currentStreak, 5);
      expect(summary.longestStreak, 5);
      expect(summary.isTodayQualified, isTrue);
      expect(summary.lastQualifyingDate, '2026-10-14');
    });

    test('calculateFromHistory preserves streak when last activity was yesterday', () {
      final dates = [
        '2026-10-11',
        '2026-10-12',
        '2026-10-13',
      ];

      final summary = StreakCalculator.calculateFromHistory(
        userId: 'test_user',
        qualifyingLocalDates: dates,
        currentLocalDate: '2026-10-14', // Today has no activity yet
      );

      // Streak of 3 from 11th, 12th, 13th is still alive on the 14th!
      expect(summary.currentStreak, 3);
      expect(summary.longestStreak, 3);
      expect(summary.isTodayQualified, isFalse);
      expect(summary.lastQualifyingDate, '2026-10-13');
    });
  });

  group('InMemoryStreakEngineService Acceptance Tests', () {
    late InMemoryStreakEngineService service;

    setUp(() {
      service = InMemoryStreakEngineService();
    });

    test('Initial user state starts with 0 streak and healthy defaults', () async {
      final summary = await service.getStreakSummary(userId: 'test_user_1');
      expect(summary.currentStreak, 0);
      expect(summary.longestStreak, 0);
      expect(summary.isTodayQualified, isFalse);
    });

    test('First qualifying activity initializes streak to 1', () async {
      final summary = await service.recordActivity(
        userId: 'test_user_1',
        activityType: QualifyingActivityType.dailyTaskCompleted,
        sourceRecordReference: 'task-1',
      );

      expect(summary.currentStreak, 1);
      expect(summary.longestStreak, 1);
      expect(summary.isTodayQualified, isTrue);
      expect(summary.streakLabel, 'Day 1 · keep going');
    });

    test('Idempotency: Same-day multiple activities do not duplicate streak', () async {
      // First activity today (daily task)
      await service.recordActivity(
        userId: 'test_user_2',
        activityType: QualifyingActivityType.dailyTaskCompleted,
        sourceRecordReference: 'task-1',
      );

      // Second activity today (logged meal)
      final afterSecond = await service.recordActivity(
        userId: 'test_user_2',
        activityType: QualifyingActivityType.mealLogged,
        sourceRecordReference: 'meal-101',
      );

      // Third activity today (workout)
      final afterThird = await service.recordActivity(
        userId: 'test_user_2',
        activityType: QualifyingActivityType.workoutLogged,
        sourceRecordReference: 'workout-202',
      );

      // Streak must remain 1 for today!
      expect(afterSecond.currentStreak, 1);
      expect(afterThird.currentStreak, 1);
      expect(afterThird.isTodayQualified, isTrue);

      // Total activity ledger holds all 3 events for auditability
      final events = await service.getActivityHistory(userId: 'test_user_2');
      expect(events.length, 3);
    });

    test('Reconciliation recalculates streak cleanly from historical ledger', () async {
      await service.recordActivity(
        userId: 'test_user_3',
        activityType: QualifyingActivityType.dailyTaskCompleted,
        sourceRecordReference: 'task-old-1',
      );
      await service.recordActivity(
        userId: 'test_user_3',
        activityType: QualifyingActivityType.mealLogged,
        sourceRecordReference: 'meal-old-2',
      );
      await service.recordActivity(
        userId: 'test_user_3',
        activityType: QualifyingActivityType.workoutLogged,
        sourceRecordReference: 'workout-today',
      );

      final reconciled = await service.reconcileStreak(userId: 'test_user_3');
      expect(reconciled.currentStreak, 1);
      expect(reconciled.longestStreak, 1);
      expect(reconciled.isTodayQualified, isTrue);
    });
  });
}

// ==============================================================================
// Nutrient Earth — Deterministic Server & Client Streak Calculator
// Pure, deterministic business logic for streak calculation across timezone
// boundaries, midnight transitions, daylight saving, and offline sync.
// ==============================================================================

import 'qualifying_activity_models.dart';

class StreakEvaluation {
  final bool isStreakAlive;
  final bool isTodayCompleted;
  final int effectiveStreak;
  final String streakLabel;

  const StreakEvaluation({
    required this.isStreakAlive,
    required this.isTodayCompleted,
    required this.effectiveStreak,
    required this.streakLabel,
  });
}

class StreakCalculator {
  StreakCalculator._();

  /// Calculates the local date string (YYYY-MM-DD) for a given UTC timestamp
  /// and target timezone offset.
  static String formatLocalDate(DateTime utcDateTime, {Duration? timezoneOffset}) {
    final local = timezoneOffset != null ? utcDateTime.add(timezoneOffset) : utcDateTime.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Parses a YYYY-MM-DD string into a normalized local DateTime (at midnight).
  static DateTime parseLocalDate(String dateString) {
    final parts = dateString.split('-');
    if (parts.length != 3) {
      throw FormatException('Invalid local date format: $dateString (expected YYYY-MM-DD)');
    }
    final y = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final d = int.parse(parts[2]);
    return DateTime.utc(y, m, d);
  }

  /// Checks if two dates are exactly consecutive calendar days (date2 is day after date1).
  static bool areConsecutiveDays(String date1, String date2) {
    final d1 = parseLocalDate(date1);
    final d2 = parseLocalDate(date2);
    final diff = d2.difference(d1).inDays;
    return diff == 1;
  }

  /// Calculates whether the user's current local day is already qualified,
  /// active from yesterday, or lapsed.
  ///
  /// CRITICAL RULE: A streak is NOT reset merely because today's activity has not yet occurred.
  /// If yesterday was qualified, the streak remains active today until local midnight passes.
  static int evaluateCurrentStreak({
    required int recordedStreak,
    required String? lastQualifyingDate,
    required String currentLocalDate,
  }) {
    if (lastQualifyingDate == null || recordedStreak <= 0) {
      return 0;
    }

    if (lastQualifyingDate == currentLocalDate) {
      // Activity occurred today: streak is fully active
      return recordedStreak;
    }

    if (areConsecutiveDays(lastQualifyingDate, currentLocalDate)) {
      // Activity occurred yesterday, today has not occurred yet.
      // Day is still in progress: preserve current streak!
      return recordedStreak;
    }

    // Gap > 1 day: streak has lapsed
    return 0;
  }

  /// Detailed streak status evaluation returning flags and UI labels.
  static StreakEvaluation evaluateStreakStatus({
    required String todayDateString,
    required String? lastQualifyingDateString,
    required int storedCurrentStreak,
  }) {
    final effective = evaluateCurrentStreak(
      recordedStreak: storedCurrentStreak,
      lastQualifyingDate: lastQualifyingDateString,
      currentLocalDate: todayDateString,
    );
    final isToday = lastQualifyingDateString == todayDateString;
    final isAlive = effective > 0;
    String label;
    if (isToday) {
      label = 'Streak saved for today';
    } else if (isAlive) {
      label = 'Active today · complete a task';
    } else {
      label = 'Start your streak today';
    }
    return StreakEvaluation(
      isStreakAlive: isAlive,
      isTodayCompleted: isToday,
      effectiveStreak: effective,
      streakLabel: label,
    );
  }

  /// Reconstructs streak history deterministically from an unordered collection of
  /// qualifying activity dates.
  static UserStreakSummary calculateFromHistory({
    required String userId,
    required List<String> qualifyingLocalDates,
    required String currentLocalDate,
  }) {
    if (qualifyingLocalDates.isEmpty) {
      return UserStreakSummary.initial(userId);
    }

    // Deduplicate and sort dates ascending
    final uniqueSorted = qualifyingLocalDates.toSet().toList()
      ..sort((a, b) => a.compareTo(b));

    int currentStreak = 0;
    int longestStreak = 0;
    String? prevDate;

    for (final date in uniqueSorted) {
      if (prevDate == null) {
        currentStreak = 1;
        longestStreak = 1;
      } else if (areConsecutiveDays(prevDate, date)) {
        currentStreak += 1;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else {
        // Gap detected: reset current streak counter
        currentStreak = 1;
      }
      prevDate = date;
    }

    final lastDate = uniqueSorted.last;
    final effectiveStreak = evaluateCurrentStreak(
      recordedStreak: currentStreak,
      lastQualifyingDate: lastDate,
      currentLocalDate: currentLocalDate,
    );

    return UserStreakSummary(
      userId: userId,
      currentStreak: effectiveStreak,
      longestStreak: longestStreak,
      lastQualifyingDate: lastDate,
      qualifiedActivityDays: uniqueSorted.length,
      isTodayQualified: (lastDate == currentLocalDate),
      lastCalculatedAt: DateTime.now().toUtc(),
    );
  }
}

// ==============================================================================
// Nutrient Earth — Streak Engine Service
// Authoritative server-backed user streak engine with timezone awareness,
// immutable qualifying activity history, and offline fallback resiliency.
// ==============================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/supabase_config.dart';
import '../../domain/streak/qualifying_activity_models.dart';
import '../../domain/streak/streak_calculator.dart';

abstract class StreakEngineService {
  Future<UserStreakSummary> recordActivity({
    required String userId,
    required QualifyingActivityType activityType,
    String? sourceRecordReference,
    Map<String, dynamic>? metadata,
    String? idempotencyKey,
    String? ianaTimezone,
  });

  Future<UserStreakSummary> getStreakSummary({
    required String userId,
    String? ianaTimezone,
  });

  Future<UserStreakSummary> reconcileStreak({
    required String userId,
  });

  Future<List<QualifyingActivityEvent>> getActivityHistory({
    required String userId,
    int limit = 50,
  });
}

class SupabaseStreakEngineService implements StreakEngineService {
  final SharedPreferences? _prefs;

  const SupabaseStreakEngineService([this._prefs]);

  static const String _streakCachePrefix = 'ne_streak_cache_';

  @override
  Future<UserStreakSummary> recordActivity({
    required String userId,
    required QualifyingActivityType activityType,
    String? sourceRecordReference,
    Map<String, dynamic>? metadata,
    String? idempotencyKey,
    String? ianaTimezone,
  }) async {
    final tz = ianaTimezone ?? DateTime.now().timeZoneName;
    final now = DateTime.now().toUtc();
    final localDate = StreakCalculator.formatLocalDate(now);
    final key = idempotencyKey ?? '${userId}_${activityType.wireName}_${localDate}_${now.millisecondsSinceEpoch}';

    final client = SupabaseConfig.client;
    if (client != null && client.auth.currentUser != null) {
      try {
        final payload = <String, dynamic>{
          'p_event_type': activityType.wireName,
          'p_local_date': localDate,
          'p_timezone_id': tz,
          'p_event_data': {
            ...?metadata,
            'source_reference': sourceRecordReference,
          },
          'p_idempotency_key': key,
        };

        final response = await client.rpc('record_qualifying_activity', params: payload);
        if (response != null && response is Map) {
          final summary = UserStreakSummary(
            userId: userId,
            currentStreak: (response['current_streak'] as num?)?.toInt() ?? 1,
            longestStreak: (response['longest_streak'] as num?)?.toInt() ?? 1,
            lastQualifyingDate: response['last_qualifying_date']?.toString() ?? localDate,
            qualifiedActivityDays: (response['qualified_activity_days'] as num?)?.toInt() ?? 1,
            isTodayQualified: true,
            lastCalculatedAt: DateTime.now().toUtc(),
          );
          await _cacheSummary(summary);
          return summary;
        }
      } catch (e) {
        debugPrint('[StreakEngine] Supabase RPC note: $e (Falling back to local calculation)');
      }
    }

    // Fallback offline calculation
    return _recordOffline(
      userId: userId,
      activityType: activityType,
      localDate: localDate,
      tz: tz,
      sourceRef: sourceRecordReference,
    );
  }

  @override
  Future<UserStreakSummary> getStreakSummary({
    required String userId,
    String? ianaTimezone,
  }) async {
    final tz = ianaTimezone ?? DateTime.now().timeZoneName;
    final now = DateTime.now().toUtc();
    final localDate = StreakCalculator.formatLocalDate(now);

    final client = SupabaseConfig.client;
    if (client != null && client.auth.currentUser != null) {
      try {
        final response = await client.rpc(
          'get_user_streak',
          params: {
            'p_local_date': localDate,
            'p_timezone_id': tz,
          },
        );
        if (response != null && response is Map) {
          final summary = UserStreakSummary(
            userId: userId,
            currentStreak: (response['current_streak'] as num?)?.toInt() ?? 0,
            longestStreak: (response['longest_streak'] as num?)?.toInt() ?? 0,
            lastQualifyingDate: response['last_qualifying_date']?.toString(),
            qualifiedActivityDays: (response['qualified_activity_days'] as num?)?.toInt() ?? 0,
            isTodayQualified: response['is_today_qualified'] == true,
            lastCalculatedAt: DateTime.now().toUtc(),
          );
          await _cacheSummary(summary);
          return summary;
        }
      } catch (e) {
        debugPrint('[StreakEngine] Get streak RPC note: $e');
      }
    }

    // Cached or default state
    final cached = await _getCachedSummary(userId);
    if (cached != null) {
      final effectiveStreak = StreakCalculator.evaluateCurrentStreak(
        recordedStreak: cached.currentStreak,
        lastQualifyingDate: cached.lastQualifyingDate,
        currentLocalDate: localDate,
      );
      return cached.copyWith(
        currentStreak: effectiveStreak,
        isTodayQualified: (cached.lastQualifyingDate == localDate),
      );
    }

    return UserStreakSummary.initial(userId);
  }

  @override
  Future<UserStreakSummary> reconcileStreak({
    required String userId,
  }) async {
    final client = SupabaseConfig.client;
    if (client != null && client.auth.currentUser != null) {
      try {
        final response = await client.rpc('recalculate_user_streak', params: {
          'p_target_user_id': userId,
        });
        if (response != null && response is Map) {
          final now = DateTime.now().toUtc();
          final localDate = StreakCalculator.formatLocalDate(now);
          final summary = UserStreakSummary(
            userId: userId,
            currentStreak: (response['current_streak'] as num?)?.toInt() ?? 0,
            longestStreak: (response['longest_streak'] as num?)?.toInt() ?? 0,
            lastQualifyingDate: response['last_qualifying_date']?.toString(),
            qualifiedActivityDays: (response['qualified_activity_days'] as num?)?.toInt() ?? 0,
            isTodayQualified: (response['last_qualifying_date']?.toString() == localDate),
            lastCalculatedAt: DateTime.now().toUtc(),
          );
          await _cacheSummary(summary);
          return summary;
        }
      } catch (e) {
        debugPrint('[StreakEngine] Reconcile RPC note: $e');
      }
    }

    return getStreakSummary(userId: userId);
  }

  @override
  Future<List<QualifyingActivityEvent>> getActivityHistory({
    required String userId,
    int limit = 50,
  }) async {
    final client = SupabaseConfig.client;
    if (client == null) return const [];

    try {
      final data = await client
          .from('user_activity_events')
          .select()
          .eq('user_id', userId)
          .eq('qualification_result', true)
          .order('user_local_date', ascending: false)
          .limit(limit);

      final list = (data as List<dynamic>?) ?? [];
      return list.map((item) => QualifyingActivityEvent.fromJson(Map<String, dynamic>.from(item as Map))).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<UserStreakSummary> _recordOffline({
    required String userId,
    required QualifyingActivityType activityType,
    required String localDate,
    required String tz,
    String? sourceRef,
  }) async {
    if (!activityType.isEligibleForStreak) {
      return getStreakSummary(userId: userId, ianaTimezone: tz);
    }

    final cached = await _getCachedSummary(userId) ?? UserStreakSummary.initial(userId);
    int newCurrent;
    int newLongest;
    int newTotalDays = cached.qualifiedActivityDays;

    if (cached.lastQualifyingDate == localDate) {
      newCurrent = cached.currentStreak;
      newLongest = cached.longestStreak;
    } else if (cached.lastQualifyingDate != null &&
        StreakCalculator.areConsecutiveDays(cached.lastQualifyingDate!, localDate)) {
      newCurrent = cached.currentStreak + 1;
      newLongest = newCurrent > cached.longestStreak ? newCurrent : cached.longestStreak;
      newTotalDays += 1;
    } else {
      newCurrent = 1;
      newLongest = cached.longestStreak > 0 ? cached.longestStreak : 1;
      newTotalDays += 1;
    }

    final updated = UserStreakSummary(
      userId: userId,
      currentStreak: newCurrent,
      longestStreak: newLongest,
      lastQualifyingDate: localDate,
      qualifiedActivityDays: newTotalDays,
      isTodayQualified: true,
      lastCalculatedAt: DateTime.now().toUtc(),
    );

    await _cacheSummary(updated);
    return updated;
  }

  Future<void> _cacheSummary(UserStreakSummary summary) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setString('$_streakCachePrefix${summary.userId}', jsonEncode(summary.toJson()));
    } catch (_) {}
  }

  Future<UserStreakSummary?> _getCachedSummary(String userId) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final str = prefs.getString('$_streakCachePrefix$userId');
      if (str != null) {
        return UserStreakSummary.fromJson(jsonDecode(str) as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }
}

/// In-memory implementation for isolated, hermetic unit tests.
class InMemoryStreakEngineService implements StreakEngineService {
  final Map<String, List<QualifyingActivityEvent>> _events = {};
  final Map<String, UserStreakSummary> _streaks = {};

  @override
  Future<UserStreakSummary> recordActivity({
    required String userId,
    required QualifyingActivityType activityType,
    String? sourceRecordReference,
    Map<String, dynamic>? metadata,
    String? idempotencyKey,
    String? ianaTimezone,
  }) async {
    final tz = ianaTimezone ?? 'UTC';
    final now = DateTime.now().toUtc();
    final localDate = StreakCalculator.formatLocalDate(now);

    // Idempotency check
    if (idempotencyKey != null) {
      final userEvents = _events[userId] ?? [];
      if (userEvents.any((e) => e.idempotencyKey == idempotencyKey)) {
        return _streaks[userId] ?? UserStreakSummary.initial(userId);
      }
    }

    final isEligible = activityType.isEligibleForStreak;

    final event = QualifyingActivityEvent(
      id: 'event-${DateTime.now().millisecondsSinceEpoch}-${_events[userId]?.length ?? 0}',
      userId: userId,
      activityType: activityType,
      eventTimestampUtc: now,
      userLocalDate: localDate,
      ianaTimezone: tz,
      qualificationResult: isEligible,
      sourceRecordReference: sourceRecordReference,
      createdAt: now,
      idempotencyKey: idempotencyKey,
    );

    _events.putIfAbsent(userId, () => []).add(event);

    if (!isEligible) {
      return _streaks[userId] ?? UserStreakSummary.initial(userId);
    }

    final current = _streaks[userId] ?? UserStreakSummary.initial(userId);
    int newCurrent;
    int newLongest;
    int newTotal = current.qualifiedActivityDays;

    if (current.lastQualifyingDate == localDate) {
      newCurrent = current.currentStreak;
      newLongest = current.longestStreak;
    } else if (current.lastQualifyingDate != null &&
        StreakCalculator.areConsecutiveDays(current.lastQualifyingDate!, localDate)) {
      newCurrent = current.currentStreak + 1;
      newLongest = newCurrent > current.longestStreak ? newCurrent : current.longestStreak;
      newTotal += 1;
    } else {
      newCurrent = 1;
      newLongest = current.longestStreak > 0 ? current.longestStreak : 1;
      newTotal += 1;
    }

    final updated = UserStreakSummary(
      userId: userId,
      currentStreak: newCurrent,
      longestStreak: newLongest,
      lastQualifyingDate: localDate,
      qualifiedActivityDays: newTotal,
      isTodayQualified: true,
      lastCalculatedAt: now,
    );

    _streaks[userId] = updated;
    return updated;
  }

  @override
  Future<UserStreakSummary> getStreakSummary({
    required String userId,
    String? ianaTimezone,
  }) async {
    final now = DateTime.now().toUtc();
    final localDate = StreakCalculator.formatLocalDate(now);
    final summary = _streaks[userId] ?? UserStreakSummary.initial(userId);

    final effectiveStreak = StreakCalculator.evaluateCurrentStreak(
      recordedStreak: summary.currentStreak,
      lastQualifyingDate: summary.lastQualifyingDate,
      currentLocalDate: localDate,
    );

    return summary.copyWith(
      currentStreak: effectiveStreak,
      isTodayQualified: (summary.lastQualifyingDate == localDate),
    );
  }

  @override
  Future<UserStreakSummary> reconcileStreak({
    required String userId,
  }) async {
    final events = _events[userId] ?? [];
    final qualifyingDates = events
        .where((e) => e.qualificationResult)
        .map((e) => e.userLocalDate)
        .toList();

    final now = DateTime.now().toUtc();
    final localDate = StreakCalculator.formatLocalDate(now);

    final rebuilt = StreakCalculator.calculateFromHistory(
      userId: userId,
      qualifyingLocalDates: qualifyingDates,
      currentLocalDate: localDate,
    );

    _streaks[userId] = rebuilt;
    return rebuilt;
  }

  @override
  Future<List<QualifyingActivityEvent>> getActivityHistory({
    required String userId,
    int limit = 50,
  }) async {
    final list = _events[userId] ?? [];
    return list.reversed.take(limit).toList();
  }
}

final streakEngineServiceProvider = Provider<StreakEngineService>((ref) {
  return const SupabaseStreakEngineService();
});

// ==============================================================================
// Nutrient Earth — Qualifying Activity & Streak Domain Models
// Explicit, versioned qualifying activity taxonomy with timezone awareness
// and server-authoritative auditability.
// ==============================================================================

enum QualifyingActivityType {
  dailyTaskCompleted('daily_task_completed', 'Completed eligible daily plan task'),
  mealLogged('meal_logged', 'Logged nutritious meal or food intake'),
  workoutLogged('workout_logged', 'Logged workout or physical movement session'),
  lifestyleActivityCompleted('lifestyle_activity_completed', 'Completed restorative lifestyle activity'),
  learnCompleted('learn_completed', 'Completed verified scientific learning article or video'),
  nonQualifying('non_qualifying', 'General app interaction (ineligible for streak)');

  final String wireName;
  final String description;
  const QualifyingActivityType(this.wireName, this.description);

  bool get isEligibleForStreak => this != QualifyingActivityType.nonQualifying;
  bool get isQualifying => isEligibleForStreak;

  static const QualifyingActivityType unknown = nonQualifying;
  static QualifyingActivityType fromRaw(String? name) => fromString(name);

  static QualifyingActivityType fromString(String? name) {
    if (name == null) return QualifyingActivityType.nonQualifying;
    final lower = name.toLowerCase().trim();
    for (final val in QualifyingActivityType.values) {
      if (val.wireName == lower || val.name.toLowerCase() == lower) {
        return val;
      }
    }
    if (lower.contains('task')) return QualifyingActivityType.dailyTaskCompleted;
    if (lower.contains('meal') || lower.contains('food')) return QualifyingActivityType.mealLogged;
    if (lower.contains('workout') || lower.contains('movement') || lower.contains('run')) {
      return QualifyingActivityType.workoutLogged;
    }
    if (lower.contains('lifestyle') || lower.contains('hydration') || lower.contains('sleep')) {
      return QualifyingActivityType.lifestyleActivityCompleted;
    }
    if (lower.contains('learn') || lower.contains('article') || lower.contains('video')) {
      return QualifyingActivityType.learnCompleted;
    }
    return QualifyingActivityType.nonQualifying;
  }
}

class QualifyingActivityEvent {
  final String id;
  final String userId;
  final QualifyingActivityType activityType;
  final DateTime eventTimestampUtc;
  final String userLocalDate; // YYYY-MM-DD in user's IANA timezone
  final String ianaTimezone;
  final bool qualificationResult;
  final String qualificationRuleVersion;
  final String? sourceRecordReference;
  final DateTime createdAt;
  final String? idempotencyKey;

  const QualifyingActivityEvent({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.eventTimestampUtc,
    required this.userLocalDate,
    this.ianaTimezone = 'UTC',
    this.qualificationResult = true,
    this.qualificationRuleVersion = 'v1.0.0',
    this.sourceRecordReference,
    required this.createdAt,
    this.idempotencyKey,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'activity_type': activityType.wireName,
        'event_timestamp': eventTimestampUtc.toIso8601String(),
        'user_local_date': userLocalDate,
        'iana_timezone': ianaTimezone,
        'qualification_result': qualificationResult,
        'qualification_rule_version': qualificationRuleVersion,
        'source_record_reference': sourceRecordReference,
        'created_at': createdAt.toIso8601String(),
        'idempotency_key': idempotencyKey,
      };

  factory QualifyingActivityEvent.fromJson(Map<String, dynamic> json) {
    return QualifyingActivityEvent(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      activityType: QualifyingActivityType.fromString(
        json['activity_type']?.toString() ?? json['event_type']?.toString(),
      ),
      eventTimestampUtc: json['event_timestamp'] != null
          ? DateTime.tryParse(json['event_timestamp'].toString()) ?? DateTime.now().toUtc()
          : (json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now().toUtc()
              : DateTime.now().toUtc()),
      userLocalDate: json['user_local_date']?.toString() ??
          json['local_date']?.toString() ??
          DateTime.now().toIso8601String().substring(0, 10),
      ianaTimezone: json['iana_timezone']?.toString() ?? json['timezone_id']?.toString() ?? 'UTC',
      qualificationResult: json['qualification_result'] != false,
      qualificationRuleVersion: json['qualification_rule_version']?.toString() ?? 'v1.0.0',
      sourceRecordReference: json['source_record_reference']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now().toUtc()
          : DateTime.now().toUtc(),
      idempotencyKey: json['idempotency_key']?.toString(),
    );
  }
}

class UserStreakSummary {
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final String? lastQualifyingDate; // YYYY-MM-DD
  final int qualifiedActivityDays;
  final bool isTodayQualified;
  final DateTime lastCalculatedAt;

  const UserStreakSummary({
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    this.lastQualifyingDate,
    required this.qualifiedActivityDays,
    this.isTodayQualified = false,
    required this.lastCalculatedAt,
  });

  factory UserStreakSummary.initial(String userId) {
    return UserStreakSummary(
      userId: userId,
      currentStreak: 0,
      longestStreak: 0,
      lastQualifyingDate: null,
      qualifiedActivityDays: 0,
      isTodayQualified: false,
      lastCalculatedAt: DateTime.now().toUtc(),
    );
  }

  String get streakLabel {
    if (currentStreak == 0) return 'Fresh start';
    if (currentStreak == 1) return 'Day 1 completed';
    if (currentStreak < 7) return 'Keep going';
    if (currentStreak < 30) return 'Habit forming';
    return 'Consistent flow';
  }

  String get formattedDisplay {
    if (currentStreak == 0) return '0 days';
    if (currentStreak == 1) return '1 day';
    return '$currentStreak days';
  }

  UserStreakSummary copyWith({
    int? currentStreak,
    int? longestStreak,
    String? lastQualifyingDate,
    int? qualifiedActivityDays,
    bool? isTodayQualified,
    DateTime? lastCalculatedAt,
  }) {
    return UserStreakSummary(
      userId: userId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastQualifyingDate: lastQualifyingDate ?? this.lastQualifyingDate,
      qualifiedActivityDays: qualifiedActivityDays ?? this.qualifiedActivityDays,
      isTodayQualified: isTodayQualified ?? this.isTodayQualified,
      lastCalculatedAt: lastCalculatedAt ?? this.lastCalculatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'current_streak': currentStreak,
        'longest_streak': longestStreak,
        'last_qualifying_date': lastQualifyingDate,
        'qualified_activity_days': qualifiedActivityDays,
        'is_today_qualified': isTodayQualified,
        'last_calculated_at': lastCalculatedAt.toIso8601String(),
      };

  factory UserStreakSummary.fromJson(Map<String, dynamic> json) {
    return UserStreakSummary(
      userId: json['user_id']?.toString() ?? '',
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
      lastQualifyingDate: json['last_qualifying_date']?.toString(),
      qualifiedActivityDays: (json['qualified_activity_days'] as num?)?.toInt() ?? 0,
      isTodayQualified: json['is_today_qualified'] == true,
      lastCalculatedAt: json['last_calculated_at'] != null
          ? DateTime.tryParse(json['last_calculated_at'].toString()) ?? DateTime.now().toUtc()
          : DateTime.now().toUtc(),
    );
  }
}

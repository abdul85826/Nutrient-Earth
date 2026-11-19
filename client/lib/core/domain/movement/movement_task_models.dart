// ==============================================================================
// Nutrient Earth — Goal-Driven Movement & Action Engine Domain Models
// Just-In-Time Adaptive Intervention (JITAI) lifecycle with environmental
// adaptation and verifiable sensor completion modes.
// ==============================================================================

import 'package:uuid/uuid.dart';

enum MovementCategory {
  aerobicEndurance,
  musculoskeletalStrength,
  postprandialMetabolic,
  circadianPhotobiology,
  restorativeMobility;

  String get dbValue {
    switch (this) {
      case MovementCategory.aerobicEndurance:
        return 'aerobic_endurance';
      case MovementCategory.musculoskeletalStrength:
        return 'musculoskeletal_strength';
      case MovementCategory.postprandialMetabolic:
        return 'postprandial_metabolic';
      case MovementCategory.circadianPhotobiology:
        return 'circadian_photobiology';
      case MovementCategory.restorativeMobility:
        return 'restorative_mobility';
    }
  }

  static MovementCategory fromDbValue(String value) {
    return MovementCategory.values.firstWhere(
      (e) => e.dbValue == value || e.name == value,
      orElse: () => MovementCategory.restorativeMobility,
    );
  }

  String get displayName {
    switch (this) {
      case MovementCategory.aerobicEndurance:
        return 'Aerobic Endurance';
      case MovementCategory.musculoskeletalStrength:
        return 'Musculoskeletal Strength';
      case MovementCategory.postprandialMetabolic:
        return 'Postprandial Metabolic Clearance';
      case MovementCategory.circadianPhotobiology:
        return 'Circadian Sunlight & Movement';
      case MovementCategory.restorativeMobility:
        return 'Restorative Mobility & Decompression';
    }
  }
}

enum TaskLifecycleStatus {
  planned,
  available,
  started,
  completed,
  skipped,
  deferred;

  String get dbValue => name;

  static TaskLifecycleStatus fromDbValue(String value) {
    return TaskLifecycleStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskLifecycleStatus.planned,
    );
  }

  String get label {
    switch (this) {
      case TaskLifecycleStatus.planned:
        return 'Planned';
      case TaskLifecycleStatus.available:
        return 'Ready Now';
      case TaskLifecycleStatus.started:
        return 'In Progress';
      case TaskLifecycleStatus.completed:
        return 'Completed';
      case TaskLifecycleStatus.skipped:
        return 'Skipped';
      case TaskLifecycleStatus.deferred:
        return 'Deferred';
    }
  }

  bool get isTerminal => this == completed || this == skipped || this == deferred;
}

enum CompletionMode {
  userSelfReported,
  sensorStepVerified,
  sensorHrVerified,
  hybridVerified;

  String get dbValue {
    switch (this) {
      case CompletionMode.userSelfReported:
        return 'user_self_reported';
      case CompletionMode.sensorStepVerified:
        return 'sensor_step_verified';
      case CompletionMode.sensorHrVerified:
        return 'sensor_hr_verified';
      case CompletionMode.hybridVerified:
        return 'hybrid_verified';
    }
  }

  static CompletionMode fromDbValue(String value) {
    return CompletionMode.values.firstWhere(
      (e) => e.dbValue == value || e.name == value,
      orElse: () => CompletionMode.userSelfReported,
    );
  }

  String get label {
    switch (this) {
      case CompletionMode.userSelfReported:
        return 'Self Reported';
      case CompletionMode.sensorStepVerified:
        return 'Sensor Step Verified';
      case CompletionMode.sensorHrVerified:
        return 'Sensor HR Verified';
      case CompletionMode.hybridVerified:
        return 'Hybrid Verified';
    }
  }
}

enum TimeOfDayPreference {
  morning,
  midday,
  afternoon,
  evening,
  anytime;

  String get dbValue => name;

  static TimeOfDayPreference fromDbValue(String value) {
    return TimeOfDayPreference.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TimeOfDayPreference.anytime,
    );
  }

  bool isAvailableForHour(int currentHour) {
    switch (this) {
      case TimeOfDayPreference.morning:
        return currentHour >= 5 && currentHour < 12;
      case TimeOfDayPreference.midday:
        return currentHour >= 11 && currentHour < 15;
      case TimeOfDayPreference.afternoon:
        return currentHour >= 14 && currentHour < 18;
      case TimeOfDayPreference.evening:
        return currentHour >= 17 && currentHour < 24;
      case TimeOfDayPreference.anytime:
        return true;
    }
  }
}

class MovementTask {
  final String id;
  final String userId;
  final String? goalId;
  final String title;
  final String? description;
  final MovementCategory movementCategory;
  final int targetDurationMinutes;
  final int? targetSteps;
  final double? targetMetHours;
  final TimeOfDayPreference preferredTimeOfDay;
  final bool isOutdoorDependent;
  final String? indoorAlternativeTitle;
  final String? indoorAlternativeDescription;
  final TaskLifecycleStatus currentStatus;
  final CompletionMode? completionMode;
  final Map<String, dynamic>? completionTelemetry;
  final String? adaptationReason;
  final DateTime scheduledDate;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MovementTask({
    required this.id,
    required this.userId,
    this.goalId,
    required this.title,
    this.description,
    required this.movementCategory,
    this.targetDurationMinutes = 15,
    this.targetSteps,
    this.targetMetHours,
    this.preferredTimeOfDay = TimeOfDayPreference.anytime,
    this.isOutdoorDependent = false,
    this.indoorAlternativeTitle,
    this.indoorAlternativeDescription,
    this.currentStatus = TaskLifecycleStatus.planned,
    this.completionMode,
    this.completionTelemetry,
    this.adaptationReason,
    required this.scheduledDate,
    this.startedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  MovementTask copyWith({
    TaskLifecycleStatus? currentStatus,
    CompletionMode? completionMode,
    Map<String, dynamic>? completionTelemetry,
    String? title,
    String? description,
    int? targetDurationMinutes,
    int? targetSteps,
    bool? isOutdoorDependent,
    String? adaptationReason,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return MovementTask(
      id: id,
      userId: userId,
      goalId: goalId,
      title: title ?? this.title,
      description: description ?? this.description,
      movementCategory: movementCategory,
      targetDurationMinutes: targetDurationMinutes ?? this.targetDurationMinutes,
      targetSteps: targetSteps ?? this.targetSteps,
      targetMetHours: targetMetHours,
      preferredTimeOfDay: preferredTimeOfDay,
      isOutdoorDependent: isOutdoorDependent ?? this.isOutdoorDependent,
      indoorAlternativeTitle: indoorAlternativeTitle,
      indoorAlternativeDescription: indoorAlternativeDescription,
      currentStatus: currentStatus ?? this.currentStatus,
      completionMode: completionMode ?? this.completionMode,
      completionTelemetry: completionTelemetry ?? this.completionTelemetry,
      adaptationReason: adaptationReason ?? this.adaptationReason,
      scheduledDate: scheduledDate,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'goalId': goalId,
        'title': title,
        'description': description,
        'movementCategory': movementCategory.dbValue,
        'targetDurationMinutes': targetDurationMinutes,
        'targetSteps': targetSteps,
        'targetMetHours': targetMetHours,
        'preferredTimeOfDay': preferredTimeOfDay.dbValue,
        'isOutdoorDependent': isOutdoorDependent,
        'indoorAlternativeTitle': indoorAlternativeTitle,
        'indoorAlternativeDescription': indoorAlternativeDescription,
        'currentStatus': currentStatus.dbValue,
        'completionMode': completionMode?.dbValue,
        'completionTelemetry': completionTelemetry,
        'adaptationReason': adaptationReason,
        'scheduledDate': scheduledDate.toIso8601String().substring(0, 10),
        'startedAt': startedAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory MovementTask.fromJson(Map<String, dynamic> json) {
    return MovementTask(
      id: json['id'] as String? ?? const Uuid().v4(),
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
      goalId: json['goal_id'] as String? ?? json['goalId'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      movementCategory: MovementCategory.fromDbValue(
        json['movement_category'] as String? ?? json['movementCategory'] as String? ?? 'restorative_mobility',
      ),
      targetDurationMinutes: (json['target_duration_minutes'] as num? ?? json['targetDurationMinutes'] as num? ?? 15).toInt(),
      targetSteps: (json['target_steps'] as num? ?? json['targetSteps'] as num?)?.toInt(),
      targetMetHours: (json['target_met_hours'] as num? ?? json['targetMetHours'] as num?)?.toDouble(),
      preferredTimeOfDay: TimeOfDayPreference.fromDbValue(
        json['preferred_time_of_day'] as String? ?? json['preferredTimeOfDay'] as String? ?? 'anytime',
      ),
      isOutdoorDependent: json['is_outdoor_dependent'] as bool? ?? json['isOutdoorDependent'] as bool? ?? false,
      indoorAlternativeTitle: json['indoor_alternative_title'] as String? ?? json['indoorAlternativeTitle'] as String?,
      indoorAlternativeDescription: json['indoor_alternative_description'] as String? ?? json['indoorAlternativeDescription'] as String?,
      currentStatus: TaskLifecycleStatus.fromDbValue(
        json['current_status'] as String? ?? json['currentStatus'] as String? ?? 'planned',
      ),
      completionMode: json['completion_mode'] != null
          ? CompletionMode.fromDbValue(json['completion_mode'] as String)
          : (json['completionMode'] != null ? CompletionMode.fromDbValue(json['completionMode'] as String) : null),
      completionTelemetry: json['completion_telemetry'] != null
          ? Map<String, dynamic>.from(json['completion_telemetry'] as Map)
          : (json['completionTelemetry'] != null ? Map<String, dynamic>.from(json['completionTelemetry'] as Map) : null),
      adaptationReason: json['adaptation_reason'] as String? ?? json['adaptationReason'] as String?,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String? ?? json['scheduledDate'] as String),
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'] as String)
          : (json['startedAt'] != null ? DateTime.tryParse(json['startedAt'] as String) : null),
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : (json['completedAt'] != null ? DateTime.tryParse(json['completedAt'] as String) : null),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : DateTime.now(),
    );
  }
}

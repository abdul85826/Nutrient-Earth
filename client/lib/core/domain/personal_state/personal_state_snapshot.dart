// ==============================================================================
// Nutrient Earth — Contextual Personal State Snapshot Model
// Represents the current and historical holistic understanding of an individual.
// Explicitly tracks known facts vs. unknowns to eliminate AI confabulation.
// ==============================================================================

import 'package:uuid/uuid.dart';

enum ActivityStatus {
  rest('rest'),
  light('light'),
  moderate('moderate'),
  intense('intense'),
  recoveryNeeded('recovery_needed'),
  nominal('nominal');

  final String value;
  const ActivityStatus(this.value);

  static ActivityStatus fromString(String val) {
    return ActivityStatus.values.firstWhere(
      (a) => a.value == val,
      orElse: () => ActivityStatus.nominal,
    );
  }
}

enum WillingnessTier {
  low('low'),
  moderate('moderate'),
  high('high'),
  unreceptive('unreceptive');

  final String value;
  const WillingnessTier(this.value);

  static WillingnessTier fromString(String val) {
    return WillingnessTier.values.firstWhere(
      (w) => w.value == val,
      orElse: () => WillingnessTier.moderate,
    );
  }
}

class PersonalStateSnapshot {
  final String id;
  final String userId;
  final DateTime snapshotDate;
  final String circadianPhase;
  final ActivityStatus activityStatus;
  final double? sleepHours;
  final int? stepsCount;
  final int? environmentalAqi;
  final String? weatherCondition;
  final double? readinessScore;
  final List<String> activeConstraints;
  final WillingnessTier willingnessTier;
  final Map<String, dynamic> knownFacts;
  final List<String> unknowns;
  final double confidenceScore;
  final DateTime createdAt;

  const PersonalStateSnapshot({
    required this.id,
    required this.userId,
    required this.snapshotDate,
    required this.circadianPhase,
    this.activityStatus = ActivityStatus.nominal,
    this.sleepHours,
    this.stepsCount,
    this.environmentalAqi,
    this.weatherCondition,
    this.readinessScore,
    this.activeConstraints = const [],
    this.willingnessTier = WillingnessTier.moderate,
    this.knownFacts = const {},
    this.unknowns = const [],
    this.confidenceScore = 0.80,
    required this.createdAt,
  });

  factory PersonalStateSnapshot.synthesize({
    required String userId,
    required String circadianPhase,
    double? sleepHours,
    int? stepsCount,
    int? environmentalAqi,
    String? weatherCondition,
    List<String> activeConstraints = const [],
    WillingnessTier willingnessTier = WillingnessTier.moderate,
    Map<String, dynamic> additionalFacts = const {},
    List<String> userUnknowns = const [],
  }) {
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);

    final resolvedUnknowns = List<String>.from(userUnknowns);
    if (sleepHours == null) resolvedUnknowns.add('sleep_duration');
    if (stepsCount == null) resolvedUnknowns.add('daily_steps');
    if (environmentalAqi == null) resolvedUnknowns.add('ambient_aqi');

    // Calculate readiness heuristically from sleep & steps
    double? readiness;
    if (sleepHours != null) {
      final sleepScore = (sleepHours / 8.0).clamp(0.4, 1.0);
      readiness = double.parse(sleepScore.toStringAsFixed(2));
    }

    ActivityStatus status = ActivityStatus.nominal;
    if (stepsCount != null) {
      if (stepsCount > 10000) {
        status = ActivityStatus.intense;
      } else if (stepsCount > 6000) {
        status = ActivityStatus.moderate;
      } else if (stepsCount > 2000) {
        status = ActivityStatus.light;
      } else {
        status = ActivityStatus.rest;
      }
    }

    final facts = <String, dynamic>{
      ...additionalFacts,
      if (sleepHours != null) 'sleep_hours': sleepHours,
      if (stepsCount != null) 'steps_count': stepsCount,
      if (environmentalAqi != null) 'environmental_aqi': environmentalAqi,
      if (weatherCondition != null) 'weather_condition': weatherCondition,
    };

    return PersonalStateSnapshot(
      id: const Uuid().v4(),
      userId: userId,
      snapshotDate: today,
      circadianPhase: circadianPhase,
      activityStatus: status,
      sleepHours: sleepHours,
      stepsCount: stepsCount,
      environmentalAqi: environmentalAqi,
      weatherCondition: weatherCondition,
      readinessScore: readiness,
      activeConstraints: activeConstraints,
      willingnessTier: willingnessTier,
      knownFacts: facts,
      unknowns: resolvedUnknowns.toSet().toList(),
      confidenceScore: (1.0 - (resolvedUnknowns.length * 0.15)).clamp(0.20, 0.95),
      createdAt: now,
    );
  }

  factory PersonalStateSnapshot.fromJson(Map<String, dynamic> json) {
    return PersonalStateSnapshot(
      id: json['id'] as String? ?? const Uuid().v4(),
      userId: json['user_id'] as String? ?? '',
      snapshotDate: DateTime.tryParse(json['snapshot_date'] as String? ?? '') ??
          DateTime.now().toUtc(),
      circadianPhase: json['circadian_phase'] as String? ?? 'morning',
      activityStatus: ActivityStatus.fromString(
        json['activity_status'] as String? ?? '',
      ),
      sleepHours: (json['sleep_hours'] as num?)?.toDouble(),
      stepsCount: json['steps_count'] as int?,
      environmentalAqi: json['environmental_aqi'] as int?,
      weatherCondition: json['weather_condition'] as String?,
      readinessScore: (json['readiness_score'] as num?)?.toDouble(),
      activeConstraints: (json['active_constraints'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      willingnessTier: WillingnessTier.fromString(
        json['willingness_tier'] as String? ?? '',
      ),
      knownFacts: json['known_facts'] is Map<String, dynamic>
          ? json['known_facts'] as Map<String, dynamic>
          : const {},
      unknowns: (json['unknowns'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.80,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'snapshot_date': snapshotDate.toIso8601String().split('T').first,
      'circadian_phase': circadianPhase,
      'activity_status': activityStatus.value,
      if (sleepHours != null) 'sleep_hours': sleepHours,
      if (stepsCount != null) 'steps_count': stepsCount,
      if (environmentalAqi != null) 'environmental_aqi': environmentalAqi,
      if (weatherCondition != null) 'weather_condition': weatherCondition,
      if (readinessScore != null) 'readiness_score': readinessScore,
      'active_constraints': activeConstraints,
      'willingness_tier': willingnessTier.value,
      'known_facts': knownFacts,
      'unknowns': unknowns,
      'confidence_score': confidenceScore,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

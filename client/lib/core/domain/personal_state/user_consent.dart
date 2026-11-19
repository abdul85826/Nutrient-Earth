// ==============================================================================
// Nutrient Earth — User Consent & Data Governance Model
// Explicit granular permissions per data category.
// Enforces zero-unauthorized ingestion and auditable consent history.
// ==============================================================================

import 'package:uuid/uuid.dart';

enum ConsentScope {
  healthRead('health_read', 'Apple Health & Health Connect Read'),
  environmentRead('environment_read', 'Local Weather & Air Quality Exposure'),
  activityTrack('activity_track', 'Activity & Exercise Logging'),
  nutritionLog('nutrition_log', 'Nutritional Intake & Meal Logs'),
  aiPersonalization('ai_personalization', 'Personalized Body Intelligence Reasoning'),
  biomarkerRead('biomarker_read', 'Clinical Lab Biomarkers & Diagnostics'),
  memoryStorage('memory_storage', 'Transparent Personal Memory Storage');

  final String value;
  final String description;

  const ConsentScope(this.value, this.description);

  static ConsentScope fromString(String val) {
    return ConsentScope.values.firstWhere(
      (s) => s.value == val,
      orElse: () => ConsentScope.healthRead,
    );
  }
}

class UserConsent {
  final String id;
  final String userId;
  final ConsentScope scope;
  final bool isGranted;
  final DateTime grantedAt;
  final DateTime? revokedAt;

  const UserConsent({
    required this.id,
    required this.userId,
    required this.scope,
    required this.isGranted,
    required this.grantedAt,
    this.revokedAt,
  });

  factory UserConsent.grant({
    required String userId,
    required ConsentScope scope,
  }) {
    return UserConsent(
      id: const Uuid().v4(),
      userId: userId,
      scope: scope,
      isGranted: true,
      grantedAt: DateTime.now().toUtc(),
    );
  }

  UserConsent revoke() {
    return UserConsent(
      id: id,
      userId: userId,
      scope: scope,
      isGranted: false,
      grantedAt: grantedAt,
      revokedAt: DateTime.now().toUtc(),
    );
  }

  factory UserConsent.fromJson(Map<String, dynamic> json) {
    return UserConsent(
      id: json['id'] as String? ?? const Uuid().v4(),
      userId: json['user_id'] as String? ?? '',
      scope: ConsentScope.fromString(json['scope'] as String? ?? ''),
      isGranted: json['is_granted'] as bool? ?? false,
      grantedAt: DateTime.tryParse(json['granted_at'] as String? ?? '') ?? DateTime.now(),
      revokedAt: json['revoked_at'] != null ? DateTime.tryParse(json['revoked_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'scope': scope.value,
      'is_granted': isGranted,
      'granted_at': grantedAt.toIso8601String(),
      if (revokedAt != null) 'revoked_at': revokedAt!.toIso8601String(),
    };
  }
}

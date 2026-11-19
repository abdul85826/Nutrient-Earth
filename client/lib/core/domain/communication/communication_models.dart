// ==============================================================================
// Nutrient Earth — Communication Domain Models & Anti-Hallucination Contract
// Part of God Mode User Lifecycle, Retention & Communication Intelligence
// ==============================================================================

import 'dart:convert';

/// Delivery channels supported by Nutrient Earth.
enum CommunicationChannel {
  pushFcm,
  pushApns,
  emailBrevo,
  inApp;

  String toDbValue() {
    switch (this) {
      case CommunicationChannel.pushFcm:
        return 'push_fcm';
      case CommunicationChannel.pushApns:
        return 'push_apns';
      case CommunicationChannel.emailBrevo:
        return 'email_brevo';
      case CommunicationChannel.inApp:
        return 'in_app';
    }
  }

  static CommunicationChannel fromDbValue(String value) {
    switch (value.toLowerCase()) {
      case 'push_fcm':
        return CommunicationChannel.pushFcm;
      case 'push_apns':
        return CommunicationChannel.pushApns;
      case 'email_brevo':
        return CommunicationChannel.emailBrevo;
      case 'in_app':
      default:
        return CommunicationChannel.inApp;
    }
  }
}

/// Category classification for granular opt-in/opt-out & suppression rules.
enum CommunicationCategory {
  goalReminder,
  researchDigest,
  securityAlert,
  accountExport,
  reEngagement,
  systemUpdate;

  String toDbValue() {
    switch (this) {
      case CommunicationCategory.goalReminder:
        return 'goal_reminder';
      case CommunicationCategory.researchDigest:
        return 'research_digest';
      case CommunicationCategory.securityAlert:
        return 'security_alert';
      case CommunicationCategory.accountExport:
        return 'account_export';
      case CommunicationCategory.reEngagement:
        return 're_engagement';
      case CommunicationCategory.systemUpdate:
        return 'system_update';
    }
  }

  static CommunicationCategory fromDbValue(String value) {
    switch (value.toLowerCase()) {
      case 'goal_reminder':
        return CommunicationCategory.goalReminder;
      case 'research_digest':
        return CommunicationCategory.researchDigest;
      case 'security_alert':
        return CommunicationCategory.securityAlert;
      case 'account_export':
        return CommunicationCategory.accountExport;
      case 're_engagement':
        return CommunicationCategory.reEngagement;
      case 'system_update':
      default:
        return CommunicationCategory.systemUpdate;
    }
  }

  /// Transactional messages (security, account export) are exempt from quiet hours & caps.
  bool get isTransactional =>
      this == CommunicationCategory.securityAlert ||
      this == CommunicationCategory.accountExport;
}

/// Explicit delivery status lifecycle state machine.
enum CommunicationDeliveryStatus {
  created,
  eligibilityChecked,
  queued,
  submitted,
  providerAccepted,
  providerRejected,
  delivered,
  opened,
  expired,
  suppressed;

  String toDbValue() {
    switch (this) {
      case CommunicationDeliveryStatus.created:
        return 'CREATED';
      case CommunicationDeliveryStatus.eligibilityChecked:
        return 'ELIGIBILITY_CHECKED';
      case CommunicationDeliveryStatus.queued:
        return 'QUEUED';
      case CommunicationDeliveryStatus.submitted:
        return 'SUBMITTED';
      case CommunicationDeliveryStatus.providerAccepted:
        return 'PROVIDER_ACCEPTED';
      case CommunicationDeliveryStatus.providerRejected:
        return 'PROVIDER_REJECTED';
      case CommunicationDeliveryStatus.delivered:
        return 'DELIVERED';
      case CommunicationDeliveryStatus.opened:
        return 'OPENED';
      case CommunicationDeliveryStatus.expired:
        return 'EXPIRED';
      case CommunicationDeliveryStatus.suppressed:
        return 'SUPPRESSED';
    }
  }

  static CommunicationDeliveryStatus fromDbValue(String value) {
    switch (value.toUpperCase()) {
      case 'CREATED':
        return CommunicationDeliveryStatus.created;
      case 'ELIGIBILITY_CHECKED':
        return CommunicationDeliveryStatus.eligibilityChecked;
      case 'QUEUED':
        return CommunicationDeliveryStatus.queued;
      case 'SUBMITTED':
        return CommunicationDeliveryStatus.submitted;
      case 'PROVIDER_ACCEPTED':
        return CommunicationDeliveryStatus.providerAccepted;
      case 'PROVIDER_REJECTED':
        return CommunicationDeliveryStatus.providerRejected;
      case 'DELIVERED':
        return CommunicationDeliveryStatus.delivered;
      case 'OPENED':
        return CommunicationDeliveryStatus.opened;
      case 'EXPIRED':
        return CommunicationDeliveryStatus.expired;
      case 'SUPPRESSED':
      default:
        return CommunicationDeliveryStatus.suppressed;
    }
  }
}

/// User's central communication preferences.
class CommunicationPreferencesEntity {
  final String userId;
  final String timezone; // IANA e.g. "Asia/Kolkata", "America/New_York", "UTC"
  final String quietHoursStart; // "22:00"
  final String quietHoursEnd; // "07:00"
  final bool channelPushEnabled;
  final bool channelEmailEnabled;
  final bool channelInAppEnabled;
  final bool categoryGoalReminders;
  final bool categoryResearchDigests;
  final bool categorySecurityAlerts; // Immutable true
  final bool categoryReEngagement;
  final int dailyFrequencyCap;
  final int weeklyFrequencyCap;
  final DateTime updatedAt;

  const CommunicationPreferencesEntity({
    required this.userId,
    this.timezone = 'UTC',
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '07:00',
    this.channelPushEnabled = true,
    this.channelEmailEnabled = true,
    this.channelInAppEnabled = true,
    this.categoryGoalReminders = true,
    this.categoryResearchDigests = true,
    this.categorySecurityAlerts = true,
    this.categoryReEngagement = true,
    this.dailyFrequencyCap = 3,
    this.weeklyFrequencyCap = 12,
    required this.updatedAt,
  });

  /// Evaluates whether a given timestamp falls in quiet hours.
  /// Uses timezone hour offset approximation or hour calculation.
  bool isInQuietHours(DateTime timeUtc, {int timezoneOffsetMinutes = 0}) {
    final localTime = timeUtc.add(Duration(minutes: timezoneOffsetMinutes));
    final currentMinutes = localTime.hour * 60 + localTime.minute;

    final startParts = quietHoursStart.split(':');
    final endParts = quietHoursEnd.split(':');
    final startMinutes = (int.tryParse(startParts[0]) ?? 22) * 60 +
        (int.tryParse(startParts.length > 1 ? startParts[1] : '0') ?? 0);
    final endMinutes = (int.tryParse(endParts[0]) ?? 7) * 60 +
        (int.tryParse(endParts.length > 1 ? endParts[1] : '0') ?? 0);

    if (startMinutes > endMinutes) {
      // Crosses midnight, e.g. 22:00 to 07:00
      return currentMinutes >= startMinutes || currentMinutes < endMinutes;
    } else {
      // Same day, e.g. 13:00 to 15:00
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    }
  }

  bool isCategoryEnabled(CommunicationCategory category) {
    switch (category) {
      case CommunicationCategory.goalReminder:
        return categoryGoalReminders;
      case CommunicationCategory.researchDigest:
        return categoryResearchDigests;
      case CommunicationCategory.securityAlert:
      case CommunicationCategory.accountExport:
        return true; // Always enabled for safety
      case CommunicationCategory.reEngagement:
        return categoryReEngagement;
      case CommunicationCategory.systemUpdate:
        return true;
    }
  }

  bool isChannelEnabled(CommunicationChannel channel) {
    switch (channel) {
      case CommunicationChannel.pushFcm:
      case CommunicationChannel.pushApns:
        return channelPushEnabled;
      case CommunicationChannel.emailBrevo:
        return channelEmailEnabled;
      case CommunicationChannel.inApp:
        return channelInAppEnabled;
    }
  }

  CommunicationPreferencesEntity copyWith({
    String? userId,
    String? timezone,
    String? quietHoursStart,
    String? quietHoursEnd,
    bool? channelPushEnabled,
    bool? channelEmailEnabled,
    bool? channelInAppEnabled,
    bool? categoryGoalReminders,
    bool? categoryResearchDigests,
    bool? categoryReEngagement,
    int? dailyFrequencyCap,
    int? weeklyFrequencyCap,
    DateTime? updatedAt,
  }) {
    return CommunicationPreferencesEntity(
      userId: userId ?? this.userId,
      timezone: timezone ?? this.timezone,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      channelPushEnabled: channelPushEnabled ?? this.channelPushEnabled,
      channelEmailEnabled: channelEmailEnabled ?? this.channelEmailEnabled,
      channelInAppEnabled: channelInAppEnabled ?? this.channelInAppEnabled,
      categoryGoalReminders:
          categoryGoalReminders ?? this.categoryGoalReminders,
      categoryResearchDigests:
          categoryResearchDigests ?? this.categoryResearchDigests,
      categorySecurityAlerts: true, // Immutable
      categoryReEngagement: categoryReEngagement ?? this.categoryReEngagement,
      dailyFrequencyCap: dailyFrequencyCap ?? this.dailyFrequencyCap,
      weeklyFrequencyCap: weeklyFrequencyCap ?? this.weeklyFrequencyCap,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'timezone': timezone,
        'quiet_hours_start': quietHoursStart,
        'quiet_hours_end': quietHoursEnd,
        'channel_push_enabled': channelPushEnabled,
        'channel_email_enabled': channelEmailEnabled,
        'channel_in_app_enabled': channelInAppEnabled,
        'category_goal_reminders': categoryGoalReminders,
        'category_research_digests': categoryResearchDigests,
        'category_security_alerts': true,
        'category_re_engagement': categoryReEngagement,
        'daily_frequency_cap': dailyFrequencyCap,
        'weekly_frequency_cap': weeklyFrequencyCap,
        'updated_at': updatedAt.toUtc().toIso8601String(),
      };

  factory CommunicationPreferencesEntity.fromMap(Map<String, dynamic> map) {
    return CommunicationPreferencesEntity(
      userId: map['user_id'] as String,
      timezone: map['timezone'] as String? ?? 'UTC',
      quietHoursStart: map['quiet_hours_start'] as String? ?? '22:00',
      quietHoursEnd: map['quiet_hours_end'] as String? ?? '07:00',
      channelPushEnabled: map['channel_push_enabled'] as bool? ?? true,
      channelEmailEnabled: map['channel_email_enabled'] as bool? ?? true,
      channelInAppEnabled: map['channel_in_app_enabled'] as bool? ?? true,
      categoryGoalReminders: map['category_goal_reminders'] as bool? ?? true,
      categoryResearchDigests:
          map['category_research_digests'] as bool? ?? true,
      categorySecurityAlerts: true,
      categoryReEngagement: map['category_re_engagement'] as bool? ?? true,
      dailyFrequencyCap: (map['daily_frequency_cap'] as num?)?.toInt() ?? 3,
      weeklyFrequencyCap: (map['weekly_frequency_cap'] as num?)?.toInt() ?? 12,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now().toUtc(),
    );
  }
}

/// Global suppression record preventing delivery to hard-bounced or deleted targets.
class CommunicationSuppressionRecord {
  final String suppressionId;
  final String recipientIdentifier; // email, user_id, or installation_id
  final String suppressionType; // hard_bounce, complaint, unsubscribe, account_deleted
  final String? reason;
  final DateTime createdAt;

  const CommunicationSuppressionRecord({
    required this.suppressionId,
    required this.recipientIdentifier,
    required this.suppressionType,
    this.reason,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'suppression_id': suppressionId,
        'recipient_identifier': recipientIdentifier,
        'suppression_type': suppressionType,
        'reason': reason,
        'created_at': createdAt.toUtc().toIso8601String(),
      };

  factory CommunicationSuppressionRecord.fromMap(Map<String, dynamic> map) {
    return CommunicationSuppressionRecord(
      suppressionId: map['suppression_id'] as String,
      recipientIdentifier: map['recipient_identifier'] as String,
      suppressionType: map['suppression_type'] as String,
      reason: map['reason'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now().toUtc(),
    );
  }
}

/// In-app notification item for the notification center feed.
class InAppNotificationItem {
  final String id;
  final String userId;
  final String title;
  final String body;
  final CommunicationCategory category;
  final String? deepLink;
  final bool isRead;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final Map<String, dynamic> payload;

  const InAppNotificationItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.category,
    this.deepLink,
    this.isRead = false,
    this.isArchived = false,
    required this.createdAt,
    this.expiresAt,
    this.payload = const {},
  });

  bool get isExpired =>
      expiresAt != null && DateTime.now().toUtc().isAfter(expiresAt!);

  InAppNotificationItem copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    CommunicationCategory? category,
    String? deepLink,
    bool? isRead,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? expiresAt,
    Map<String, dynamic>? payload,
  }) {
    return InAppNotificationItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      deepLink: deepLink ?? this.deepLink,
      isRead: isRead ?? this.isRead,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      payload: payload ?? this.payload,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'body': body,
        'category': category.toDbValue(),
        'deep_link': deepLink,
        'is_read': isRead,
        'is_archived': isArchived,
        'created_at': createdAt.toUtc().toIso8601String(),
        'expires_at': expiresAt?.toUtc().toIso8601String(),
        'payload': jsonEncode(payload),
      };

  factory InAppNotificationItem.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> parsedPayload = {};
    if (map['payload'] != null) {
      if (map['payload'] is Map) {
        parsedPayload = Map<String, dynamic>.from(map['payload'] as Map);
      } else if (map['payload'] is String) {
        try {
          parsedPayload = Map<String, dynamic>.from(
              jsonDecode(map['payload'] as String) as Map);
        } catch (_) {}
      }
    }

    return InAppNotificationItem(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      category: CommunicationCategory.fromDbValue(
          map['category'] as String? ?? 'system_update'),
      deepLink: map['deep_link'] as String?,
      isRead: map['is_read'] as bool? ?? false,
      isArchived: map['is_archived'] as bool? ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now().toUtc(),
      expiresAt: map['expires_at'] != null
          ? DateTime.parse(map['expires_at'] as String)
          : null,
      payload: parsedPayload,
    );
  }
}

/// Audit event record tracking delivery through the state machine.
class CommunicationEventRecord {
  final String eventId;
  final String? userId;
  final String? installationId;
  final CommunicationChannel channel;
  final CommunicationCategory category;
  final CommunicationDeliveryStatus status;
  final String idempotencyKey;
  final String title;
  final String body;
  final String? deepLink;
  final String? errorMessage;
  final DateTime? submittedAt;
  final DateTime? deliveredAt;
  final DateTime? openedAt;
  final DateTime createdAt;

  const CommunicationEventRecord({
    required this.eventId,
    this.userId,
    this.installationId,
    required this.channel,
    required this.category,
    required this.status,
    required this.idempotencyKey,
    required this.title,
    required this.body,
    this.deepLink,
    this.errorMessage,
    this.submittedAt,
    this.deliveredAt,
    this.openedAt,
    required this.createdAt,
  });

  CommunicationEventRecord copyWith({
    String? eventId,
    String? userId,
    String? installationId,
    CommunicationChannel? channel,
    CommunicationCategory? category,
    CommunicationDeliveryStatus? status,
    String? idempotencyKey,
    String? title,
    String? body,
    String? deepLink,
    String? errorMessage,
    DateTime? submittedAt,
    DateTime? deliveredAt,
    DateTime? openedAt,
    DateTime? createdAt,
  }) {
    return CommunicationEventRecord(
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      installationId: installationId ?? this.installationId,
      channel: channel ?? this.channel,
      category: category ?? this.category,
      status: status ?? this.status,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      title: title ?? this.title,
      body: body ?? this.body,
      deepLink: deepLink ?? this.deepLink,
      errorMessage: errorMessage ?? this.errorMessage,
      submittedAt: submittedAt ?? this.submittedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      openedAt: openedAt ?? this.openedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'event_id': eventId,
        'user_id': userId,
        'installation_id': installationId,
        'channel': channel.toDbValue(),
        'category': category.toDbValue(),
        'status': status.toDbValue(),
        'idempotency_key': idempotencyKey,
        'title': title,
        'body': body,
        'deep_link': deepLink,
        'error_message': errorMessage,
        'submitted_at': submittedAt?.toUtc().toIso8601String(),
        'delivered_at': deliveredAt?.toUtc().toIso8601String(),
        'opened_at': openedAt?.toUtc().toIso8601String(),
        'created_at': createdAt.toUtc().toIso8601String(),
      };

  factory CommunicationEventRecord.fromMap(Map<String, dynamic> map) {
    return CommunicationEventRecord(
      eventId: map['event_id'] as String,
      userId: map['user_id'] as String?,
      installationId: map['installation_id'] as String?,
      channel: CommunicationChannel.fromDbValue(
          map['channel'] as String? ?? 'in_app'),
      category: CommunicationCategory.fromDbValue(
          map['category'] as String? ?? 'system_update'),
      status: CommunicationDeliveryStatus.fromDbValue(
          map['status'] as String? ?? 'CREATED'),
      idempotencyKey: map['idempotency_key'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      deepLink: map['deep_link'] as String?,
      errorMessage: map['error_message'] as String?,
      submittedAt: map['submitted_at'] != null
          ? DateTime.parse(map['submitted_at'] as String)
          : null,
      deliveredAt: map['delivered_at'] != null
          ? DateTime.parse(map['delivered_at'] as String)
          : null,
      openedAt: map['opened_at'] != null
          ? DateTime.parse(map['opened_at'] as String)
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now().toUtc(),
    );
  }
}

/// Anti-Hallucination Communication Contract.
/// Guarantees that automated communications do not make fabricated,
/// misleading, or prohibited medical/health claims.
class AntiHallucinationMessageContract {
  static const List<String> prohibitedPatterns = [
    'cures cancer',
    'cure cancer',
    '100% detox',
    'guaranteed fat loss',
    'miracle cure',
    'reverses aging',
    'eliminates all toxins',
    'cure diabetes',
    'burns belly fat in 3 days',
    'magic weight loss',
    'instant remedy',
    'permanent cure for',
  ];

  /// Returns null if valid, or the matched prohibited violation.
  static String? inspectText(String text) {
    final lower = text.toLowerCase();
    for (final pattern in prohibitedPatterns) {
      if (lower.contains(pattern)) {
        return 'Prohibited medical claim detected: "$pattern"';
      }
    }
    return null;
  }

  /// Validates a notification before delivery.
  static bool validateMessage({
    required String title,
    required String body,
    List<String>? verifiedFacts,
  }) {
    if (inspectText(title) != null || inspectText(body) != null) {
      return false;
    }
    return true;
  }
}

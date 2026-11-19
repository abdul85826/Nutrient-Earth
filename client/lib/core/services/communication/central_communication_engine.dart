// ==============================================================================
// Nutrient Earth — Central Communication Engine & 15-Step Eligibility Pipeline
// Part of God Mode User Lifecycle, Retention & Communication Intelligence
// ==============================================================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/communication/communication_models.dart';
import '../../domain/lifecycle/installation_models.dart';
import '../lifecycle/installation_lifecycle_service.dart';
import 'fcm_push_dispatch_service.dart';
import 'brevo_email_dispatch_service.dart';

class CommunicationSendResult {
  final bool success;
  final CommunicationDeliveryStatus status;
  final String? suppressionReason;
  final int stepFailed; // 0 if passed, 1-15 if suppressed/failed
  final String? providerMessageId;
  final CommunicationEventRecord eventRecord;

  const CommunicationSendResult({
    required this.success,
    required this.status,
    this.suppressionReason,
    this.stepFailed = 0,
    this.providerMessageId,
    required this.eventRecord,
  });
}

abstract class CentralCommunicationEngine {
  Future<CommunicationSendResult> dispatchCommunication({
    String? userId,
    String? installationId,
    String? recipientEmail,
    required CommunicationChannel channel,
    required CommunicationCategory category,
    required String idempotencyKey,
    required String title,
    required String body,
    String? deepLink,
    DateTime? expiresAt,
    Future<bool> Function()? dynamicStateRevalidation,
    Map<String, dynamic>? metadata,
    int timezoneOffsetMinutes = 0,
  });

  Future<CommunicationPreferencesEntity> getPreferences(String userId);
  Future<void> updatePreferences(CommunicationPreferencesEntity preferences);
  Future<void> recordSuppression(CommunicationSuppressionRecord suppression);
  Future<bool> isSuppressed(String recipientIdentifier);

  Future<List<InAppNotificationItem>> getInAppNotifications(String userId);
  Future<void> markInAppAsRead(String notificationId);
  Future<void> archiveInApp(String notificationId);
}

class DefaultCentralCommunicationEngine implements CentralCommunicationEngine {
  final SupabaseClient? _supabase;
  final InstallationLifecycleService _installationService;
  final FcmPushDispatchService _fcmService;
  final BrevoEmailDispatchService _brevoService;

  final Map<String, CommunicationPreferencesEntity> _preferencesCache = {};
  final Map<String, CommunicationSuppressionRecord> _suppressionsCache = {};
  final Map<String, CommunicationEventRecord> _eventsCache = {};
  final List<InAppNotificationItem> _inAppCache = [];

  DefaultCentralCommunicationEngine({
    SupabaseClient? supabase,
    required InstallationLifecycleService installationService,
    FcmPushDispatchService? fcmService,
    BrevoEmailDispatchService? brevoService,
  })  : _supabase = supabase,
        _installationService = installationService,
        _fcmService = fcmService ?? DefaultFcmPushDispatchService(),
        _brevoService = brevoService ?? DefaultBrevoEmailDispatchService();

  @override
  Future<CommunicationSendResult> dispatchCommunication({
    String? userId,
    String? installationId,
    String? recipientEmail,
    required CommunicationChannel channel,
    required CommunicationCategory category,
    required String idempotencyKey,
    required String title,
    required String body,
    String? deepLink,
    DateTime? expiresAt,
    Future<bool> Function()? dynamicStateRevalidation,
    Map<String, dynamic>? metadata,
    int timezoneOffsetMinutes = 0,
  }) async {
    final now = DateTime.now().toUtc();
    final eventId = 'comm_${now.millisecondsSinceEpoch}_${idempotencyKey.hashCode.abs()}';

    // Helper to create & record terminal suppressed event
    CommunicationSendResult returnSuppressed(int step, String reason) {
      final rec = CommunicationEventRecord(
        eventId: eventId,
        userId: userId,
        installationId: installationId,
        channel: channel,
        category: category,
        status: CommunicationDeliveryStatus.suppressed,
        idempotencyKey: idempotencyKey,
        title: title,
        body: body,
        deepLink: deepLink,
        errorMessage: reason,
        submittedAt: null,
        deliveredAt: null,
        openedAt: null,
        createdAt: now,
      );
      _recordEvent(rec);
      return CommunicationSendResult(
        success: false,
        status: CommunicationDeliveryStatus.suppressed,
        suppressionReason: reason,
        stepFailed: step,
        eventRecord: rec,
      );
    }

    // --------------------------------------------------------------------------
    // STEP 1: Event Resolution & Initialization
    // --------------------------------------------------------------------------
    if (idempotencyKey.isEmpty) {
      return returnSuppressed(1, 'Missing required idempotencyKey.');
    }

    // --------------------------------------------------------------------------
    // STEP 2: Source Authentication / Validation
    // --------------------------------------------------------------------------
    if (category == CommunicationCategory.securityAlert &&
        userId == null &&
        recipientEmail == null) {
      return returnSuppressed(2, 'Security alerts must have a verified user or recipient email.');
    }

    // --------------------------------------------------------------------------
    // STEP 3: Recipient Identity Resolution
    // --------------------------------------------------------------------------
    AppInstallationEntity? resolvedInstallation;
    if (channel == CommunicationChannel.pushFcm ||
        channel == CommunicationChannel.pushApns) {
      if (installationId != null) {
        resolvedInstallation =
            await _installationService.getInstallation(installationId);
      } else if (userId != null) {
        final devices = await _installationService.getUserInstallations(userId);
        if (devices.isNotEmpty) {
          // Select most recently active device with valid token
          devices.sort((a, b) => b.lastSeenAt.compareTo(a.lastSeenAt));
          resolvedInstallation = devices.firstWhere(
            (d) => d.tokenValidity == TokenValidityState.valid,
            orElse: () => devices.first,
          );
        }
      }

      if (resolvedInstallation == null) {
        return returnSuppressed(3, 'No valid installation found for push dispatch.');
      }
    } else if (channel == CommunicationChannel.emailBrevo) {
      if (recipientEmail == null || recipientEmail.isEmpty) {
        return returnSuppressed(3, 'No recipient email specified for Brevo dispatch.');
      }
    } else if (channel == CommunicationChannel.inApp) {
      if (userId == null || userId.isEmpty) {
        return returnSuppressed(3, 'In-app notification requires a valid userId.');
      }
    }

    // --------------------------------------------------------------------------
    // STEP 4: Recipient Account Lifecycle Status Check
    // --------------------------------------------------------------------------
    final identifierToCheck = userId ?? recipientEmail ?? installationId ?? '';
    if (await isSuppressed(identifierToCheck)) {
      return returnSuppressed(4, 'Recipient is registered in suppression table (account deleted/hard bounced).');
    }

    // --------------------------------------------------------------------------
    // STEP 5: Consent Verification
    // --------------------------------------------------------------------------
    if (await _isUnsubscribed(identifierToCheck)) {
      if (!category.isTransactional) {
        return returnSuppressed(5, 'User has unsubscribed from marketing/engagement communications.');
      }
    }

    // --------------------------------------------------------------------------
    // STEP 6: Channel Authorization
    // --------------------------------------------------------------------------
    final prefs = userId != null
        ? await getPreferences(userId)
        : CommunicationPreferencesEntity(
            userId: 'anonymous',
            updatedAt: now,
          );

    if (!prefs.isChannelEnabled(channel) && !category.isTransactional) {
      return returnSuppressed(6, 'Communication channel $channel is disabled by user preferences.');
    }

    // --------------------------------------------------------------------------
    // STEP 7: Category Preference Evaluation
    // --------------------------------------------------------------------------
    if (!prefs.isCategoryEnabled(category) && !category.isTransactional) {
      return returnSuppressed(7, 'Communication category $category is disabled by user preferences.');
    }

    // --------------------------------------------------------------------------
    // STEP 8: Quiet Hours & Timezone Computation
    // --------------------------------------------------------------------------
    if (!category.isTransactional) {
      if (prefs.isInQuietHours(now, timezoneOffsetMinutes: timezoneOffsetMinutes)) {
        return returnSuppressed(8, 'Current time falls within recipient quiet hours (${prefs.quietHoursStart} - ${prefs.quietHoursEnd}).');
      }
    }

    // --------------------------------------------------------------------------
    // STEP 9: Deduplication & Idempotency Check
    // --------------------------------------------------------------------------
    if (_eventsCache.containsKey(idempotencyKey)) {
      final existing = _eventsCache[idempotencyKey]!;
      if (existing.status != CommunicationDeliveryStatus.suppressed) {
        return returnSuppressed(9, 'Duplicate transmission prevented by idempotency lock: $idempotencyKey.');
      }
    }

    // --------------------------------------------------------------------------
    // STEP 10: Frequency Capping
    // --------------------------------------------------------------------------
    if (!category.isTransactional && userId != null) {
      final dailyCount = _getSentCountInWindow(userId, const Duration(days: 1), now);
      if (dailyCount >= prefs.dailyFrequencyCap) {
        return returnSuppressed(10, 'Daily frequency cap of ${prefs.dailyFrequencyCap} reached for user.');
      }

      final weeklyCount = _getSentCountInWindow(userId, const Duration(days: 7), now);
      if (weeklyCount >= prefs.weeklyFrequencyCap) {
        return returnSuppressed(10, 'Weekly frequency cap of ${prefs.weeklyFrequencyCap} reached for user.');
      }
    }

    // --------------------------------------------------------------------------
    // STEP 11: Time-to-Live / Expiry Evaluation
    // --------------------------------------------------------------------------
    if (expiresAt != null && now.isAfter(expiresAt)) {
      return returnSuppressed(11, 'Communication payload expired before dispatch.');
    }

    // --------------------------------------------------------------------------
    // STEP 12: Recipient State Revalidation
    // --------------------------------------------------------------------------
    if (dynamicStateRevalidation != null) {
      final bool stateStillValid = await dynamicStateRevalidation();
      if (!stateStillValid) {
        return returnSuppressed(12, 'Recipient state invalidated before dispatch (e.g. goal already completed).');
      }
    }

    // --------------------------------------------------------------------------
    // STEP 13: Anti-Hallucination Verification
    // --------------------------------------------------------------------------
    final claimViolation = AntiHallucinationMessageContract.inspectText('$title $body');
    if (claimViolation != null) {
      return returnSuppressed(13, 'Anti-hallucination contract violation: $claimViolation');
    }

    // --------------------------------------------------------------------------
    // STEP 14: Dispatch Queuing & Provider Submission
    // --------------------------------------------------------------------------
    String? providerMessageId;
    String? providerError;
    bool isProviderSuccess = false;

    if (channel == CommunicationChannel.pushFcm ||
        channel == CommunicationChannel.pushApns) {
      final pushResult = await _fcmService.dispatchPush(
        installation: resolvedInstallation!,
        title: title,
        body: body,
        deepLink: deepLink,
        data: metadata,
      );

      if (pushResult.success) {
        isProviderSuccess = true;
        providerMessageId = pushResult.messageId;
      } else {
        providerError = pushResult.errorCode;
        if (pushResult.isTokenInvalid) {
          // Immediately mark installation token invalid
          await _installationService.markTokenInvalid(
            installationId: resolvedInstallation.installationId,
            reason: pushResult.errorCode ?? 'PUSH_PROVIDER_REJECTED',
          );
        }
      }
    } else if (channel == CommunicationChannel.emailBrevo) {
      final emailResult = await _brevoService.dispatchEmail(
        recipientEmail: recipientEmail!,
        subject: title,
        htmlBody: body,
        isTransactional: category.isTransactional,
        tags: metadata,
      );

      if (emailResult.success) {
        isProviderSuccess = true;
        providerMessageId = emailResult.messageId;
      } else {
        providerError = emailResult.errorCode;
        if (emailResult.isHardBounce) {
          await recordSuppression(CommunicationSuppressionRecord(
            suppressionId: 'sup_${DateTime.now().millisecondsSinceEpoch}',
            recipientIdentifier: recipientEmail,
            suppressionType: 'hard_bounce',
            reason: emailResult.errorCode,
            createdAt: now,
          ));
        }
      }
    } else if (channel == CommunicationChannel.inApp) {
      final inAppItem = InAppNotificationItem(
        id: 'inapp_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId!,
        title: title,
        body: body,
        category: category,
        deepLink: deepLink,
        createdAt: now,
        expiresAt: expiresAt,
        payload: metadata ?? {},
      );
      _inAppCache.insert(0, inAppItem);
      isProviderSuccess = true;
      providerMessageId = inAppItem.id;

      if (_supabase != null) {
        try {
          await _supabase.from('in_app_notifications').insert(inAppItem.toMap());
        } catch (_) {}
      }
    }

    // --------------------------------------------------------------------------
    // STEP 15: Post-Dispatch Receipt Tracking & Audit Recording
    // --------------------------------------------------------------------------
    final finalStatus = isProviderSuccess
        ? CommunicationDeliveryStatus.providerAccepted
        : CommunicationDeliveryStatus.providerRejected;

    final record = CommunicationEventRecord(
      eventId: eventId,
      userId: userId,
      installationId: installationId ?? resolvedInstallation?.installationId,
      channel: channel,
      category: category,
      status: finalStatus,
      idempotencyKey: idempotencyKey,
      title: title,
      body: body,
      deepLink: deepLink,
      errorMessage: providerError,
      submittedAt: now,
      deliveredAt: isProviderSuccess ? now : null,
      openedAt: null,
      createdAt: now,
    );

    _recordEvent(record);

    return CommunicationSendResult(
      success: isProviderSuccess,
      status: finalStatus,
      suppressionReason: providerError,
      stepFailed: isProviderSuccess ? 0 : 15,
      providerMessageId: providerMessageId,
      eventRecord: record,
    );
  }

  void _recordEvent(CommunicationEventRecord record) {
    _eventsCache[record.idempotencyKey] = record;
    if (_supabase != null) {
      try {
        _supabase.from('communication_events').insert(record.toMap());
      } catch (_) {}
    }
  }

  int _getSentCountInWindow(String userId, Duration window, DateTime now) {
    final threshold = now.subtract(window);
    return _eventsCache.values
        .where((e) =>
            e.userId == userId &&
            (e.status == CommunicationDeliveryStatus.providerAccepted ||
                e.status == CommunicationDeliveryStatus.delivered) &&
            e.createdAt.isAfter(threshold))
        .length;
  }

  Future<bool> _isUnsubscribed(String identifier) async {
    final sup = _suppressionsCache[identifier];
    return sup != null && (sup.suppressionType == 'unsubscribe' || sup.suppressionType == 'account_deleted');
  }

  @override
  Future<bool> isSuppressed(String recipientIdentifier) async {
    if (_suppressionsCache.containsKey(recipientIdentifier)) {
      return true;
    }
    if (_supabase != null) {
      try {
        final res = await _supabase
            .from('communication_suppressions')
            .select()
            .eq('recipient_identifier', recipientIdentifier)
            .maybeSingle();
        return res != null;
      } catch (_) {}
    }
    return false;
  }

  @override
  Future<void> recordSuppression(CommunicationSuppressionRecord suppression) async {
    _suppressionsCache[suppression.recipientIdentifier] = suppression;
    if (_supabase != null) {
      try {
        await _supabase
            .from('communication_suppressions')
            .upsert(suppression.toMap(), onConflict: 'recipient_identifier');
      } catch (_) {}
    }
  }

  @override
  Future<CommunicationPreferencesEntity> getPreferences(String userId) async {
    if (_preferencesCache.containsKey(userId)) {
      return _preferencesCache[userId]!;
    }

    if (_supabase != null) {
      try {
        final res = await _supabase
            .from('communication_preferences')
            .select()
            .eq('user_id', userId)
            .maybeSingle();
        if (res != null) {
          final p = CommunicationPreferencesEntity.fromMap(
              Map<String, dynamic>.from(res as Map));
          _preferencesCache[userId] = p;
          return p;
        }
      } catch (_) {}
    }

    final defaultPrefs = CommunicationPreferencesEntity(
      userId: userId,
      updatedAt: DateTime.now().toUtc(),
    );
    _preferencesCache[userId] = defaultPrefs;
    return defaultPrefs;
  }

  @override
  Future<void> updatePreferences(CommunicationPreferencesEntity preferences) async {
    _preferencesCache[preferences.userId] = preferences;
    if (_supabase != null) {
      try {
        await _supabase
            .from('communication_preferences')
            .upsert(preferences.toMap(), onConflict: 'user_id');
      } catch (_) {}
    }
  }

  @override
  Future<List<InAppNotificationItem>> getInAppNotifications(String userId) async {
    final unexpired = _inAppCache
        .where((n) => n.userId == userId && !n.isArchived && !n.isExpired)
        .toList();
    if (_supabase == null) return unexpired;

    try {
      final res = await _supabase
          .from('in_app_notifications')
          .select()
          .eq('user_id', userId)
          .eq('is_archived', false)
          .order('created_at', ascending: false);
      final List list = res as List;
      final items = list
          .map((m) =>
              InAppNotificationItem.fromMap(Map<String, dynamic>.from(m as Map)))
          .where((n) => !n.isExpired)
          .toList();
      return items;
    } catch (_) {
      return unexpired;
    }
  }

  @override
  Future<void> markInAppAsRead(String notificationId) async {
    final idx = _inAppCache.indexWhere((n) => n.id == notificationId);
    if (idx != -1) {
      _inAppCache[idx] = _inAppCache[idx].copyWith(isRead: true);
    }
    if (_supabase != null) {
      try {
        await _supabase
            .from('in_app_notifications')
            .update({'is_read': true})
            .eq('id', notificationId);
      } catch (_) {}
    }
  }

  @override
  Future<void> archiveInApp(String notificationId) async {
    final idx = _inAppCache.indexWhere((n) => n.id == notificationId);
    if (idx != -1) {
      _inAppCache[idx] = _inAppCache[idx].copyWith(isArchived: true);
    }
    if (_supabase != null) {
      try {
        await _supabase
            .from('in_app_notifications')
            .update({'is_archived': true})
            .eq('id', notificationId);
      } catch (_) {}
    }
  }
}

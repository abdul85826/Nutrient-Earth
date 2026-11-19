// ==============================================================================
// Nutrient Earth — Retention & Goal Communication Service
// Part of God Mode User Lifecycle, Retention & Communication Intelligence
// ==============================================================================

import '../../domain/communication/communication_models.dart';
import '../communication/central_communication_engine.dart';

enum RetentionInactivityWindow {
  day1,
  day3,
  day7,
  day14,
  day30,
  day60,
  day90;

  int get days {
    switch (this) {
      case RetentionInactivityWindow.day1:
        return 1;
      case RetentionInactivityWindow.day3:
        return 3;
      case RetentionInactivityWindow.day7:
        return 7;
      case RetentionInactivityWindow.day14:
        return 14;
      case RetentionInactivityWindow.day30:
        return 30;
      case RetentionInactivityWindow.day60:
        return 60;
      case RetentionInactivityWindow.day90:
        return 90;
    }
  }

  String get notificationTitle {
    switch (this) {
      case RetentionInactivityWindow.day1:
        return 'Diurnal Rhythm Insights';
      case RetentionInactivityWindow.day3:
        return 'Scientific Research Update';
      case RetentionInactivityWindow.day7:
        return 'Weekly Rhythm Reflection';
      case RetentionInactivityWindow.day14:
        return 'Personal Baseline Update';
      case RetentionInactivityWindow.day30:
        return 'Seasonal Health Transition';
      case RetentionInactivityWindow.day60:
        return 'Bi-Monthly Evidence Digest';
      case RetentionInactivityWindow.day90:
        return 'Personal Intelligence Context';
    }
  }

  String get notificationBody {
    switch (this) {
      case RetentionInactivityWindow.day1:
        return 'Your personalized circadian rhythm insights are ready for your review.';
      case RetentionInactivityWindow.day3:
        return 'New peer-reviewed findings on nutrient preservation are available.';
      case RetentionInactivityWindow.day7:
        return 'Reflect on your weekly circadian balance and physical movement.';
      case RetentionInactivityWindow.day14:
        return 'Your metabolic health baseline remains securely encrypted and saved.';
      case RetentionInactivityWindow.day30:
        return 'Seasonal dietary guidance for your region is now accessible.';
      case RetentionInactivityWindow.day60:
        return 'Scientific evidence updates on plant compounds and cooking methods.';
      case RetentionInactivityWindow.day90:
        return 'Welcome back: your long-term personal intelligence context is preserved.';
    }
  }
}

abstract class RetentionAndGoalCommunicationService {
  Future<CommunicationSendResult> evaluateAndSendRetentionNotification({
    required String userId,
    required RetentionInactivityWindow window,
    CommunicationChannel channel = CommunicationChannel.pushFcm,
    int timezoneOffsetMinutes = 0,
  });

  Future<CommunicationSendResult> sendGoalReminder({
    required String userId,
    required String goalId,
    required String goalTitle,
    required Future<bool> Function() isGoalCompleted,
    CommunicationChannel channel = CommunicationChannel.pushFcm,
    int timezoneOffsetMinutes = 0,
  });

  Future<CommunicationSendResult> sendResearchDigest({
    required String userId,
    required String articleTitle,
    required String articleDoi,
    required String summary,
    CommunicationChannel channel = CommunicationChannel.inApp,
    int timezoneOffsetMinutes = 0,
  });
}

class DefaultRetentionAndGoalCommunicationService
    implements RetentionAndGoalCommunicationService {
  final CentralCommunicationEngine _communicationEngine;

  DefaultRetentionAndGoalCommunicationService({
    required CentralCommunicationEngine communicationEngine,
  }) : _communicationEngine = communicationEngine;

  @override
  Future<CommunicationSendResult> evaluateAndSendRetentionNotification({
    required String userId,
    required RetentionInactivityWindow window,
    CommunicationChannel channel = CommunicationChannel.pushFcm,
    int timezoneOffsetMinutes = 0,
  }) async {
    final now = DateTime.now().toUtc();
    final dateStr = '${now.year}-${now.month}-${now.day}';
    final idempotencyKey =
        'retention_${userId}_${window.days}d_$dateStr';

    return await _communicationEngine.dispatchCommunication(
      userId: userId,
      channel: channel,
      category: CommunicationCategory.reEngagement,
      idempotencyKey: idempotencyKey,
      title: window.notificationTitle,
      body: window.notificationBody,
      deepLink: 'nutrientearth://today?ref=retention_${window.days}d',
      timezoneOffsetMinutes: timezoneOffsetMinutes,
      metadata: {
        'inactivity_days': window.days,
        'window': window.name,
      },
    );
  }

  @override
  Future<CommunicationSendResult> sendGoalReminder({
    required String userId,
    required String goalId,
    required String goalTitle,
    required Future<bool> Function() isGoalCompleted,
    CommunicationChannel channel = CommunicationChannel.pushFcm,
    int timezoneOffsetMinutes = 0,
  }) async {
    final now = DateTime.now().toUtc();
    final dateStr = '${now.year}-${now.month}-${now.day}';
    final idempotencyKey = 'goal_reminder_${userId}_${goalId}_$dateStr';

    return await _communicationEngine.dispatchCommunication(
      userId: userId,
      channel: channel,
      category: CommunicationCategory.goalReminder,
      idempotencyKey: idempotencyKey,
      title: 'Goal Reminder: $goalTitle',
      body: 'Take a moment to advance your daily activity and circadian wellness.',
      deepLink: 'nutrientearth://goals/$goalId',
      timezoneOffsetMinutes: timezoneOffsetMinutes,
      // Dynamic state revalidation (Step 12): abort reminder if goal already completed!
      dynamicStateRevalidation: () async {
        final alreadyDone = await isGoalCompleted();
        // If already done, state is no longer valid for a reminder!
        return !alreadyDone;
      },
      metadata: {
        'goal_id': goalId,
      },
    );
  }

  @override
  Future<CommunicationSendResult> sendResearchDigest({
    required String userId,
    required String articleTitle,
    required String articleDoi,
    required String summary,
    CommunicationChannel channel = CommunicationChannel.inApp,
    int timezoneOffsetMinutes = 0,
  }) async {
    final idempotencyKey =
        'digest_${userId}_${articleDoi.replaceAll('/', '_')}';

    return await _communicationEngine.dispatchCommunication(
      userId: userId,
      channel: channel,
      category: CommunicationCategory.researchDigest,
      idempotencyKey: idempotencyKey,
      title: 'Daily Science: $articleTitle',
      body: summary,
      deepLink: 'nutrientearth://research/$articleDoi',
      timezoneOffsetMinutes: timezoneOffsetMinutes,
      metadata: {
        'doi': articleDoi,
      },
    );
  }
}

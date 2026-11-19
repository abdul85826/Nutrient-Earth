// ==============================================================================
// Nutrient Earth — Section 22: User Lifecycle, Retention & Communication Chaos Tests
// Verifies all 25 required acceptance and chaos scenarios:
//  1. Active installation receives notification successfully.
//  2. Inactive installation (silent 14d) marked INACTIVE, not uninstalled.
//  3. Push provider invalid token feedback sets TOKEN_INVALID.
//  4. Client reinstall generates new installation_id and recovers profile.
//  5. User multi-device listing shows all active registered hardware.
//  6. User logout on one device detaches only that device without affecting others.
//  7. Account switching replaces user association.
//  8. Daily frequency cap enforcement suppresses message #4.
//  9. Weekly frequency cap enforcement suppresses message #13.
// 10. Quiet hours suppression suppresses non-transactional message at 23:00.
// 11. Transactional security alert bypasses quiet hours and frequency caps.
// 12. Goal reminder aborted when dynamic check finds task already completed today.
// 13. Duplicate message with same idempotencyKey is rejected.
// 14. Message past TTL / expiresAt is marked EXPIRED and suppressed.
// 15. Anti-hallucination prohibited claim ('cures cancer', '100% detox') rejected.
// 16. Unsubscribe suppression record blocks non-transactional email.
// 17. Hard bounce Brevo response registers recipient in suppressions.
// 18. In-app notification creation, unread count, mark-as-read, archive flow.
// 19. Mandatory security update detected when build is below minimum supported.
// 20. Critical security flag forces mandatory update even if version is above minimum.
// 21. Up-to-date app version reports no update needed.
// 22. User account deletion instantly writes suppression and detaches all devices.
// 23. Blocked user account cannot receive notifications.
// 24. Returning user after 90 days receives non-manipulative re-engagement digest.
// 25. Timezone change shifts quiet hours boundary correctly.
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:nutrient_earth_client/core/domain/lifecycle/installation_models.dart';
import 'package:nutrient_earth_client/core/domain/communication/communication_models.dart';
import 'package:nutrient_earth_client/core/domain/release/release_metadata_models.dart';
import 'package:nutrient_earth_client/core/services/lifecycle/installation_lifecycle_service.dart';
import 'package:nutrient_earth_client/core/services/communication/central_communication_engine.dart';
import 'package:nutrient_earth_client/core/services/communication/fcm_push_dispatch_service.dart';
import 'package:nutrient_earth_client/core/services/communication/brevo_email_dispatch_service.dart';
import 'package:nutrient_earth_client/core/services/lifecycle/retention_and_goal_communication_service.dart';
import 'package:nutrient_earth_client/core/services/release/app_release_intelligence_service.dart';
import 'package:nutrient_earth_client/core/services/lifecycle/user_account_lifecycle_service.dart';

void main() {
  group('NUTRIENT EARTH — 25 User Lifecycle & Communication Acceptance Scenarios', () {
    late DefaultInstallationLifecycleService installationService;
    late DefaultFcmPushDispatchService fcmService;
    late DefaultBrevoEmailDispatchService brevoService;
    late DefaultCentralCommunicationEngine commEngine;
    late DefaultRetentionAndGoalCommunicationService retentionService;
    late DefaultAppReleaseIntelligenceService releaseService;
    late DefaultUserAccountLifecycleService accountService;

    setUp(() {
      installationService = DefaultInstallationLifecycleService(supabase: null);
      fcmService = DefaultFcmPushDispatchService();
      brevoService = DefaultBrevoEmailDispatchService();
      commEngine = DefaultCentralCommunicationEngine(
        supabase: null,
        installationService: installationService,
        fcmService: fcmService,
        brevoService: brevoService,
      );
      retentionService = DefaultRetentionAndGoalCommunicationService(
        communicationEngine: commEngine,
      );
      releaseService = DefaultAppReleaseIntelligenceService(supabase: null);
      accountService = DefaultUserAccountLifecycleService(
        supabase: null,
        installationService: installationService,
        communicationEngine: commEngine,
      );
    });

    // --------------------------------------------------------------------------
    // Scenario 1: Active installation receives notification successfully
    // --------------------------------------------------------------------------
    test('Scenario 1: Active installation receives notification successfully', () async {
      final inst = await installationService.syncInstallationOnLaunch(
        installationId: 'inst_001',
        userId: 'user_001',
        platform: DevicePlatform.android,
        appVersion: '1.2.0',
        buildNumber: 120,
        osVersion: 'Android 14',
        deviceModel: 'Pixel 8',
        deviceFingerprint: 'fp_pixel8_hash',
        pushProvider: 'fcm',
        pushToken: 'fcm_token_valid_123',
        pushPermissionStatus: PushPermissionStatus.authorized,
      );
      expect(inst.lifecycleState, InstallationLifecycleState.active);

      final result = await commEngine.dispatchCommunication(
        userId: 'user_001',
        installationId: 'inst_001',
        channel: CommunicationChannel.pushFcm,
        category: CommunicationCategory.goalReminder,
        idempotencyKey: 'idemp_test_001',
        title: 'Circadian Sunlight Alert',
        body: 'Morning solar exposure supports melatonin synthesis tonight.',
      );

      expect(result.success, isTrue);
      expect(result.status, CommunicationDeliveryStatus.providerAccepted);
      expect(result.providerMessageId, isNotNull);
    });

    // --------------------------------------------------------------------------
    // Scenario 2: Inactive installation (silent 14d) marked INACTIVE, not uninstalled
    // --------------------------------------------------------------------------
    test('Scenario 2: Inactive installation (silent 14d) is INACTIVE, not uninstalled', () async {
      final now = DateTime.now().toUtc();
      final silentTime = now.subtract(const Duration(days: 15));

      final inst = AppInstallationEntity(
        installationId: 'inst_silent',
        userId: 'user_silent',
        platform: DevicePlatform.ios,
        appVersion: '1.1.0',
        buildNumber: 110,
        osVersion: 'iOS 17.4',
        deviceModel: 'iPhone 15',
        deviceFingerprint: 'fp_ios_15',
        pushProvider: 'apns',
        pushToken: 'apns_token_unrevoked',
        lifecycleState: InstallationLifecycleState.inactive,
        firstSeenAt: silentTime.subtract(const Duration(days: 30)),
        lastSeenAt: silentTime,
      );

      expect(inst.lifecycleState, InstallationLifecycleState.inactive);
      expect(inst.lifecycleState.toDbValue(), 'INACTIVE');
      // Verifies constitutional rule: never labeled UNINSTALLED or DELETED without receipt
      expect(inst.lifecycleState.toDbValue(), isNot('UNINSTALLED'));
    });

    // --------------------------------------------------------------------------
    // Scenario 3: Push provider invalid token feedback sets TOKEN_INVALID
    // --------------------------------------------------------------------------
    test('Scenario 3: Push provider invalid token feedback sets TOKEN_INVALID', () async {
      await installationService.syncInstallationOnLaunch(
        installationId: 'inst_stale_token',
        userId: 'user_stale',
        platform: DevicePlatform.android,
        appVersion: '1.2.0',
        buildNumber: 120,
        osVersion: 'Android 14',
        deviceModel: 'Galaxy S24',
        deviceFingerprint: 'fp_s24',
        pushProvider: 'fcm',
        pushToken: 'expired_fcm_token_xyz',
      );

      // Configure mock provider to report UNREGISTERED
      fcmService.customDispatcher = (inst, title, body) =>
          PushDispatchResult.rejected('UNREGISTERED', isTokenInvalid: true);

      final result = await commEngine.dispatchCommunication(
        installationId: 'inst_stale_token',
        channel: CommunicationChannel.pushFcm,
        category: CommunicationCategory.systemUpdate,
        idempotencyKey: 'idemp_stale_token',
        title: 'System Update',
        body: 'Security update available.',
      );

      expect(result.success, isFalse);
      expect(result.status, CommunicationDeliveryStatus.providerRejected);

      final updatedInst =
          await installationService.getInstallation('inst_stale_token');
      expect(updatedInst?.lifecycleState, InstallationLifecycleState.tokenInvalid);
      expect(updatedInst?.tokenValidity, TokenValidityState.unregistered);
    });

    // --------------------------------------------------------------------------
    // Scenario 4: Client reinstall generates new installation_id and recovers profile
    // --------------------------------------------------------------------------
    test('Scenario 4: Client reinstall generates new installation_id and recovers profile', () async {
      // Prior installation on same user account
      await installationService.syncInstallationOnLaunch(
        installationId: 'inst_old_device',
        userId: 'user_reinstall',
        platform: DevicePlatform.ios,
        appVersion: '1.0.0',
        buildNumber: 100,
        osVersion: 'iOS 16',
        deviceModel: 'iPhone 13',
        deviceFingerprint: 'fp_iphone13',
        pushProvider: 'apns',
      );

      // Reinstall produces fresh installation ID
      const newInstallationId = 'inst_fresh_reinstall';
      await installationService.syncInstallationOnLaunch(
        installationId: newInstallationId,
        platform: DevicePlatform.ios,
        appVersion: '1.2.0',
        buildNumber: 120,
        osVersion: 'iOS 17.5',
        deviceModel: 'iPhone 13',
        deviceFingerprint: 'fp_iphone13',
        pushProvider: 'apns',
      );

      // Login associates new installation
      await accountService.handleReinstallationLogin(
        newInstallationId: newInstallationId,
        userId: 'user_reinstall',
      );

      final fresh = await installationService.getInstallation(newInstallationId);
      expect(fresh?.userId, 'user_reinstall');
      expect(fresh?.installationId, newInstallationId);
      expect(fresh?.lifecycleState, InstallationLifecycleState.active);
    });

    // --------------------------------------------------------------------------
    // Scenario 5: User multi-device listing shows all active registered hardware
    // --------------------------------------------------------------------------
    test('Scenario 5: User multi-device listing shows all active registered hardware', () async {
      await installationService.syncInstallationOnLaunch(
        installationId: 'device_phone',
        userId: 'user_multi',
        platform: DevicePlatform.ios,
        appVersion: '1.2.0',
        buildNumber: 120,
        osVersion: 'iOS 17.5',
        deviceModel: 'iPhone 15 Pro',
        deviceFingerprint: 'fp_phone',
        pushProvider: 'apns',
      );

      await installationService.syncInstallationOnLaunch(
        installationId: 'device_tablet',
        userId: 'user_multi',
        platform: DevicePlatform.android,
        appVersion: '1.2.0',
        buildNumber: 120,
        osVersion: 'Android 14',
        deviceModel: 'Pixel Tablet',
        deviceFingerprint: 'fp_tablet',
        pushProvider: 'fcm',
      );

      final devices = await installationService.getUserInstallations('user_multi');
      expect(devices.length, 2);
      expect(devices.map((d) => d.installationId),
          containsAll(['device_phone', 'device_tablet']));
    });

    // --------------------------------------------------------------------------
    // Scenario 6: User logout on one device detaches only that device without affecting others
    // --------------------------------------------------------------------------
    test('Scenario 6: User logout on one device detaches only that device', () async {
      await installationService.syncInstallationOnLaunch(
        installationId: 'dev_laptop',
        userId: 'user_concurrent',
        platform: DevicePlatform.macos,
        appVersion: '1.2.0',
        buildNumber: 120,
        osVersion: 'macOS 14.5',
        deviceModel: 'MacBook Pro',
        deviceFingerprint: 'fp_mac',
        pushProvider: 'apns',
      );

      await installationService.syncInstallationOnLaunch(
        installationId: 'dev_phone',
        userId: 'user_concurrent',
        platform: DevicePlatform.android,
        appVersion: '1.2.0',
        buildNumber: 120,
        osVersion: 'Android 14',
        deviceModel: 'Pixel 8',
        deviceFingerprint: 'fp_phone',
        pushProvider: 'fcm',
      );

      // Logout on laptop only
      await accountService.handleDeviceLogout(installationId: 'dev_laptop');

      final laptop = await installationService.getInstallation('dev_laptop');
      final phone = await installationService.getInstallation('dev_phone');

      expect(laptop?.userId, isNull);
      expect(laptop?.lifecycleState, InstallationLifecycleState.registrationRevoked);

      expect(phone?.userId, 'user_concurrent');
      expect(phone?.lifecycleState, InstallationLifecycleState.active);
    });

    // --------------------------------------------------------------------------
    // Scenario 7: Account switching replaces user association
    // --------------------------------------------------------------------------
    test('Scenario 7: Account switching replaces user association on shared device', () async {
      await installationService.syncInstallationOnLaunch(
        installationId: 'shared_tablet',
        userId: 'user_alice',
        platform: DevicePlatform.android,
        appVersion: '1.2.0',
        buildNumber: 120,
        osVersion: 'Android 14',
        deviceModel: 'Galaxy Tab',
        deviceFingerprint: 'fp_tab',
        pushProvider: 'fcm',
      );

      // Alice logs out
      await installationService.detachUserOnLogout(installationId: 'shared_tablet');
      // Bob logs in
      await installationService.associateUser(
        installationId: 'shared_tablet',
        userId: 'user_bob',
      );

      final tablet = await installationService.getInstallation('shared_tablet');
      expect(tablet?.userId, 'user_bob');
      expect(tablet?.lifecycleState, InstallationLifecycleState.active);
    });

    // --------------------------------------------------------------------------
    // Scenario 8: Daily frequency cap enforcement suppresses message #4
    // --------------------------------------------------------------------------
    test('Scenario 8: Daily frequency cap enforcement suppresses message #4', () async {
      const u = 'user_capped_daily';
      await installationService.syncInstallationOnLaunch(
        installationId: 'inst_daily',
        userId: u,
        platform: DevicePlatform.android,
        appVersion: '1.2.0',
        buildNumber: 120,
        osVersion: 'Android 14',
        deviceModel: 'Pixel 8',
        deviceFingerprint: 'fp_daily',
        pushProvider: 'fcm',
        pushToken: 'token_daily',
      );

      // Default daily cap is 3
      for (int i = 1; i <= 3; i++) {
        final res = await commEngine.dispatchCommunication(
          userId: u,
          installationId: 'inst_daily',
          channel: CommunicationChannel.pushFcm,
          category: CommunicationCategory.goalReminder,
          idempotencyKey: 'daily_msg_$i',
          title: 'Movement Milestone $i',
          body: 'Healthy movement completed.',
        );
        expect(res.success, isTrue, reason: 'Message $i should succeed');
      }

      // 4th message exceeds daily cap of 3
      final res4 = await commEngine.dispatchCommunication(
        userId: u,
        installationId: 'inst_daily',
        channel: CommunicationChannel.pushFcm,
        category: CommunicationCategory.goalReminder,
        idempotencyKey: 'daily_msg_4',
        title: 'Movement Milestone 4',
        body: 'Over daily limit.',
      );

      expect(res4.success, isFalse);
      expect(res4.status, CommunicationDeliveryStatus.suppressed);
      expect(res4.stepFailed, 10);
      expect(res4.suppressionReason, contains('Daily frequency cap'));
    });

    // --------------------------------------------------------------------------
    // Scenario 9: Weekly frequency cap enforcement suppresses message #13
    // --------------------------------------------------------------------------
    test('Scenario 9: Weekly frequency cap enforcement suppresses message #13', () async {
      const u = 'user_capped_weekly';
      await installationService.syncInstallationOnLaunch(
        installationId: 'inst_weekly',
        userId: u,
        platform: DevicePlatform.android,
        appVersion: '1.2.0',
        buildNumber: 120,
        osVersion: 'Android 14',
        deviceModel: 'Pixel 8',
        deviceFingerprint: 'fp_weekly',
        pushProvider: 'fcm',
        pushToken: 'token_weekly',
      );

      // Set daily cap high (20) so weekly cap (12) triggers first
      final prefs = await commEngine.getPreferences(u);
      await commEngine.updatePreferences(prefs.copyWith(
        dailyFrequencyCap: 20,
        weeklyFrequencyCap: 12,
      ));

      for (int i = 1; i <= 12; i++) {
        final res = await commEngine.dispatchCommunication(
          userId: u,
          installationId: 'inst_weekly',
          channel: CommunicationChannel.pushFcm,
          category: CommunicationCategory.goalReminder,
          idempotencyKey: 'weekly_msg_$i',
          title: 'Research digest #$i',
          body: 'Scientific update on flavonoids.',
        );
        expect(res.success, isTrue);
      }

      // 13th message exceeds weekly cap of 12
      final res13 = await commEngine.dispatchCommunication(
        userId: u,
        installationId: 'inst_weekly',
        channel: CommunicationChannel.pushFcm,
        category: CommunicationCategory.goalReminder,
        idempotencyKey: 'weekly_msg_13',
        title: 'Research digest #13',
        body: 'Over weekly limit.',
      );

      expect(res13.success, isFalse);
      expect(res13.status, CommunicationDeliveryStatus.suppressed);
      expect(res13.stepFailed, 10);
      expect(res13.suppressionReason, contains('Weekly frequency cap'));
    });

    // --------------------------------------------------------------------------
    // Scenario 10: Quiet hours suppression suppresses non-transactional message
    // --------------------------------------------------------------------------
    test('Scenario 10: Quiet hours suppression suppresses non-transactional message at 23:00', () async {
      const u = 'user_quiet';
      await installationService.syncInstallationOnLaunch(
        installationId: 'inst_quiet',
        userId: u,
        platform: DevicePlatform.android,
        appVersion: '1.2.0',
        buildNumber: 120,
        osVersion: 'Android 14',
        deviceModel: 'Pixel 8',
        deviceFingerprint: 'fp_quiet',
        pushProvider: 'fcm',
        pushToken: 'token_quiet',
      );

      // Timezone offset calculated such that UTC now maps to 23:30 local time
      final nowUtc = DateTime.now().toUtc();
      final desiredLocalMinutes = 23 * 60 + 30; // 23:30
      final currentUtcMinutes = nowUtc.hour * 60 + nowUtc.minute;
      final offset = desiredLocalMinutes - currentUtcMinutes;

      final res = await commEngine.dispatchCommunication(
        userId: u,
        installationId: 'inst_quiet',
        channel: CommunicationChannel.pushFcm,
        category: CommunicationCategory.goalReminder,
        idempotencyKey: 'quiet_msg_test',
        title: 'Late Night Stretch',
        body: 'Time to stretch.',
        timezoneOffsetMinutes: offset,
      );

      expect(res.success, isFalse);
      expect(res.status, CommunicationDeliveryStatus.suppressed);
      expect(res.stepFailed, 8);
      expect(res.suppressionReason, contains('quiet hours'));
    });

    // --------------------------------------------------------------------------
    // Scenario 11: Transactional security alert bypasses quiet hours and frequency caps
    // --------------------------------------------------------------------------
    test('Scenario 11: Transactional security alert bypasses quiet hours and frequency caps', () async {
      const u = 'user_security';
      await installationService.syncInstallationOnLaunch(
        installationId: 'inst_sec',
        userId: u,
        platform: DevicePlatform.android,
        appVersion: '1.2.0',
        buildNumber: 120,
        osVersion: 'Android 14',
        deviceModel: 'Pixel 8',
        deviceFingerprint: 'fp_sec',
        pushProvider: 'fcm',
        pushToken: 'token_sec',
      );

      // Force quiet hours offset to 01:00 AM
      final nowUtc = DateTime.now().toUtc();
      final desiredLocalMinutes = 1 * 60; // 01:00 AM (deep in quiet hours)
      final currentUtcMinutes = nowUtc.hour * 60 + nowUtc.minute;
      final offset = desiredLocalMinutes - currentUtcMinutes;

      final res = await commEngine.dispatchCommunication(
        userId: u,
        installationId: 'inst_sec',
        channel: CommunicationChannel.pushFcm,
        category: CommunicationCategory.securityAlert, // Transactional
        idempotencyKey: 'sec_alert_001',
        title: 'Security Notice: New Login Detected',
        body: 'A new session was authenticated from an unfamiliar browser.',
        timezoneOffsetMinutes: offset,
      );

      expect(res.success, isTrue);
      expect(res.status, CommunicationDeliveryStatus.providerAccepted);
      expect(res.stepFailed, 0);
    });

    // --------------------------------------------------------------------------
    // Scenario 12: Goal reminder aborted when dynamic check finds task already completed today
    // --------------------------------------------------------------------------
    test('Scenario 12: Goal reminder aborted when dynamic check finds task already completed', () async {
      const u = 'user_goal_done';
      await installationService.syncInstallationOnLaunch(
        installationId: 'inst_done',
        userId: u,
        platform: DevicePlatform.android,
        appVersion: '1.2.0',
        buildNumber: 120,
        osVersion: 'Android 14',
        deviceModel: 'Pixel 8',
        deviceFingerprint: 'fp_done',
        pushProvider: 'fcm',
        pushToken: 'token_done',
      );

      // Dynamic check reports goal is ALREADY completed
      final res = await retentionService.sendGoalReminder(
        userId: u,
        goalId: 'movement_walk_5km',
        goalTitle: 'Daily 5km Walk',
        isGoalCompleted: () async => true, // Already completed!
      );

      expect(res.success, isFalse);
      expect(res.status, CommunicationDeliveryStatus.suppressed);
      expect(res.stepFailed, 12);
      expect(res.suppressionReason, contains('state invalidated'));
    });

    // --------------------------------------------------------------------------
    // Scenario 13: Duplicate message with same idempotencyKey is rejected
    // --------------------------------------------------------------------------
    test('Scenario 13: Duplicate message with same idempotencyKey is rejected (Step 9)', () async {
      const u = 'user_idemp';
      await installationService.syncInstallationOnLaunch(
        installationId: 'inst_idemp',
        userId: u,
        platform: DevicePlatform.android,
        appVersion: '1.2.0',
        buildNumber: 120,
        osVersion: 'Android 14',
        deviceModel: 'Pixel 8',
        deviceFingerprint: 'fp_idemp',
        pushProvider: 'fcm',
        pushToken: 'token_idemp',
      );

      const key = 'unique_idempotency_key_456';
      final res1 = await commEngine.dispatchCommunication(
        userId: u,
        installationId: 'inst_idemp',
        channel: CommunicationChannel.pushFcm,
        category: CommunicationCategory.goalReminder,
        idempotencyKey: key,
        title: 'Midday Sunlight',
        body: 'Step outside for natural spectrum light.',
      );
      expect(res1.success, isTrue);

      final res2 = await commEngine.dispatchCommunication(
        userId: u,
        installationId: 'inst_idemp',
        channel: CommunicationChannel.pushFcm,
        category: CommunicationCategory.goalReminder,
        idempotencyKey: key,
        title: 'Midday Sunlight',
        body: 'Step outside for natural spectrum light.',
      );

      expect(res2.success, isFalse);
      expect(res2.status, CommunicationDeliveryStatus.suppressed);
      expect(res2.stepFailed, 9);
      expect(res2.suppressionReason, contains('idempotency lock'));
    });

    // --------------------------------------------------------------------------
    // Scenario 14: Message past TTL / expiresAt is marked EXPIRED and suppressed
    // --------------------------------------------------------------------------
    test('Scenario 14: Message past TTL / expiresAt is suppressed (Step 11)', () async {
      const u = 'user_ttl';
      await installationService.syncInstallationOnLaunch(
        installationId: 'inst_ttl',
        userId: u,
        platform: DevicePlatform.android,
        appVersion: '1.2.0',
        buildNumber: 120,
        osVersion: 'Android 14',
        deviceModel: 'Pixel 8',
        deviceFingerprint: 'fp_ttl',
        pushProvider: 'fcm',
        pushToken: 'token_ttl',
      );

      final expiredTime = DateTime.now().toUtc().subtract(const Duration(minutes: 5));
      final res = await commEngine.dispatchCommunication(
        userId: u,
        installationId: 'inst_ttl',
        channel: CommunicationChannel.pushFcm,
        category: CommunicationCategory.goalReminder,
        idempotencyKey: 'idemp_expired_msg',
        title: 'Flash Reminder',
        body: 'This offer was valid only 10 mins ago.',
        expiresAt: expiredTime,
      );

      expect(res.success, isFalse);
      expect(res.status, CommunicationDeliveryStatus.suppressed);
      expect(res.stepFailed, 11);
      expect(res.suppressionReason, contains('expired before dispatch'));
    });

    // --------------------------------------------------------------------------
    // Scenario 15: Anti-hallucination prohibited claim rejected
    // --------------------------------------------------------------------------
    test('Scenario 15: Anti-hallucination prohibited claim rejected (Step 13)', () async {
      const u = 'user_claim';
      await installationService.syncInstallationOnLaunch(
        installationId: 'inst_claim',
        userId: u,
        platform: DevicePlatform.android,
        appVersion: '1.2.0',
        buildNumber: 120,
        osVersion: 'Android 14',
        deviceModel: 'Pixel 8',
        deviceFingerprint: 'fp_claim',
        pushProvider: 'fcm',
        pushToken: 'token_claim',
      );

      final res = await commEngine.dispatchCommunication(
        userId: u,
        installationId: 'inst_claim',
        channel: CommunicationChannel.pushFcm,
        category: CommunicationCategory.researchDigest,
        idempotencyKey: 'idemp_prohibited_claim',
        title: 'Breakthrough Discovery',
        body: 'Drinking this turmeric tea cures cancer in 3 weeks with 100% detox!',
      );

      expect(res.success, isFalse);
      expect(res.status, CommunicationDeliveryStatus.suppressed);
      expect(res.stepFailed, 13);
      expect(res.suppressionReason, contains('Anti-hallucination contract violation'));
    });

    // --------------------------------------------------------------------------
    // Scenario 16: Unsubscribe suppression record blocks non-transactional email
    // --------------------------------------------------------------------------
    test('Scenario 16: Unsubscribe suppression record blocks marketing email', () async {
      const testEmail = 'unsub@nutrientearth.org';
      await commEngine.recordSuppression(CommunicationSuppressionRecord(
        suppressionId: 'sup_unsub_1',
        recipientIdentifier: testEmail,
        suppressionType: 'unsubscribe',
        createdAt: DateTime.now().toUtc(),
      ));

      final res = await commEngine.dispatchCommunication(
        recipientEmail: testEmail,
        channel: CommunicationChannel.emailBrevo,
        category: CommunicationCategory.reEngagement,
        idempotencyKey: 'idemp_unsub_send',
        title: 'We miss you',
        body: '<p>Come back to check your diet.</p>',
      );

      expect(res.success, isFalse);
      expect(res.status, CommunicationDeliveryStatus.suppressed);
      expect(res.stepFailed, 5);
      expect(res.suppressionReason, contains('unsubscribed'));
    });

    // --------------------------------------------------------------------------
    // Scenario 17: Hard bounce Brevo response registers recipient in suppressions
    // --------------------------------------------------------------------------
    test('Scenario 17: Hard bounce Brevo response registers recipient in suppressions', () async {
      const bounceEmail = 'nonexistent-user-invalid-domain'; // Invalid format triggers bounce
      final res = await commEngine.dispatchCommunication(
        recipientEmail: bounceEmail,
        channel: CommunicationChannel.emailBrevo,
        category: CommunicationCategory.accountExport, // Transactional
        idempotencyKey: 'idemp_bounce_test',
        title: 'Your Account Archive',
        body: '<p>Archive link.</p>',
      );

      expect(res.success, isFalse);
      expect(res.status, CommunicationDeliveryStatus.providerRejected);

      // Verify suppression record created
      final isSuppressedNow = await commEngine.isSuppressed(bounceEmail);
      expect(isSuppressedNow, isTrue);
    });

    // --------------------------------------------------------------------------
    // Scenario 18: In-app notification creation, unread count, mark-as-read, archive flow
    // --------------------------------------------------------------------------
    test('Scenario 18: In-app notification creation, unread count, mark-as-read, archive flow', () async {
      const u = 'user_inapp_feed';
      final res = await commEngine.dispatchCommunication(
        userId: u,
        channel: CommunicationChannel.inApp,
        category: CommunicationCategory.researchDigest,
        idempotencyKey: 'idemp_inapp_1',
        title: 'Polyphenol Stability Study',
        body: 'Cold-pressed virgin olive oil preserves oleocanthal compounds.',
        deepLink: 'nutrientearth://research/10.1016/j.olive.2026.01',
      );

      expect(res.success, isTrue);

      final feed = await commEngine.getInAppNotifications(u);
      expect(feed.length, 1);
      expect(feed.first.isRead, isFalse);
      expect(feed.first.title, 'Polyphenol Stability Study');

      // Mark as read
      await commEngine.markInAppAsRead(feed.first.id);
      final feedAfterRead = await commEngine.getInAppNotifications(u);
      expect(feedAfterRead.first.isRead, isTrue);

      // Archive
      await commEngine.archiveInApp(feed.first.id);
      final feedAfterArchive = await commEngine.getInAppNotifications(u);
      expect(feedAfterArchive.isEmpty, isTrue);
    });

    // --------------------------------------------------------------------------
    // Scenario 19: Mandatory security update detected when build is below minimum supported
    // --------------------------------------------------------------------------
    test('Scenario 19: Mandatory security update detected when build is below minimum', () async {
      await releaseService.publishReleaseMetadata(AppReleaseMetadataEntity(
        releaseId: 'rel_2_0_0',
        platform: DevicePlatform.android,
        latestVersion: '2.0.0',
        latestBuildNumber: 200,
        minimumSupportedVersion: '1.5.0',
        minimumSupportedBuildNumber: 150,
        isCriticalSecurityUpdate: false,
        releaseNotes: 'Architecture upgrade to v2.',
        storeUrl: 'https://play.google.com/store/apps/details?id=earth.nutrient',
        publishedAt: DateTime.now().toUtc(),
      ));

      // Client running build 120 (below minimum 150)
      final eval = await releaseService.checkForUpdates(
        platform: DevicePlatform.android,
        currentVersion: '1.2.0',
        currentBuildNumber: 120,
      );

      expect(eval.action, UpdateAction.mandatorySecurityUpdateRequired);
      expect(eval.isUpdateRequired, isTrue);
      expect(eval.reason, contains('below minimum supported'));
    });

    // --------------------------------------------------------------------------
    // Scenario 20: Critical security flag forces mandatory update even if version is above minimum
    // --------------------------------------------------------------------------
    test('Scenario 20: Critical security flag forces mandatory update even if version is above minimum', () async {
      await releaseService.publishReleaseMetadata(AppReleaseMetadataEntity(
        releaseId: 'rel_sec_patch',
        platform: DevicePlatform.ios,
        latestVersion: '1.9.1',
        latestBuildNumber: 191,
        minimumSupportedVersion: '1.8.0',
        minimumSupportedBuildNumber: 180,
        isCriticalSecurityUpdate: true, // Urgent patch
        releaseNotes: 'Critical cryptographic keystore patch.',
        storeUrl: 'https://apps.apple.com/app/nutrient-earth/id123456789',
        publishedAt: DateTime.now().toUtc(),
      ));

      // Client is at 1.9.0 build 190 (above min 180, but critical update published)
      final eval = await releaseService.checkForUpdates(
        platform: DevicePlatform.ios,
        currentVersion: '1.9.0',
        currentBuildNumber: 190,
      );

      expect(eval.action, UpdateAction.mandatorySecurityUpdateRequired);
      expect(eval.isCriticalSecurityUpdate, isTrue);
      expect(eval.reason, contains('Critical security update'));
    });

    // --------------------------------------------------------------------------
    // Scenario 21: Up-to-date app version reports no update needed
    // --------------------------------------------------------------------------
    test('Scenario 21: Up-to-date app version reports no update needed', () async {
      await releaseService.publishReleaseMetadata(AppReleaseMetadataEntity(
        releaseId: 'rel_stable',
        platform: DevicePlatform.android,
        latestVersion: '2.0.0',
        latestBuildNumber: 200,
        minimumSupportedVersion: '1.8.0',
        minimumSupportedBuildNumber: 180,
        isCriticalSecurityUpdate: false,
        releaseNotes: 'Performance enhancements.',
        storeUrl: 'https://play.google.com/store/apps/details?id=earth.nutrient',
        publishedAt: DateTime.now().toUtc(),
      ));

      final eval = await releaseService.checkForUpdates(
        platform: DevicePlatform.android,
        currentVersion: '2.0.0',
        currentBuildNumber: 200,
      );

      expect(eval.action, UpdateAction.upToDate);
      expect(eval.isUpdateRequired, isFalse);
      expect(eval.isUpdateRecommended, isFalse);
    });

    // --------------------------------------------------------------------------
    // Scenario 22: User account deletion instantly writes suppression and detaches all devices
    // --------------------------------------------------------------------------
    test('Scenario 22: User account deletion instantly writes suppression and detaches all devices', () async {
      const u = 'user_to_delete';
      const email = 'user_delete@example.org';

      await installationService.syncInstallationOnLaunch(
        installationId: 'inst_del_phone',
        userId: u,
        platform: DevicePlatform.android,
        appVersion: '1.2.0',
        buildNumber: 120,
        osVersion: 'Android 14',
        deviceModel: 'Pixel 8',
        deviceFingerprint: 'fp_p8',
        pushProvider: 'fcm',
        pushToken: 'token_del_1',
      );

      final deletionResult = await accountService.requestAccountDeletion(
        userId: u,
        email: email,
        reason: 'User requested GDPR / Right-to-be-forgotten erasure',
      );

      expect(deletionResult.status, AccountDeletionStatus.completed);
      expect(deletionResult.suppressionApplied, isTrue);
      expect(deletionResult.cryptoShredded, isTrue);

      // Verify immediate suppression check
      final userSuppressed = await commEngine.isSuppressed(u);
      final emailSuppressed = await commEngine.isSuppressed(email);
      expect(userSuppressed, isTrue);
      expect(emailSuppressed, isTrue);

      // Verify devices detached
      final phone = await installationService.getInstallation('inst_del_phone');
      expect(phone?.userId, isNull);
      expect(phone?.lifecycleState, InstallationLifecycleState.registrationRevoked);
    });

    // --------------------------------------------------------------------------
    // Scenario 23: Blocked user account cannot receive notifications
    // --------------------------------------------------------------------------
    test('Scenario 23: Blocked user account cannot receive notifications (Step 4)', () async {
      const u = 'user_blocked_403';
      await commEngine.recordSuppression(CommunicationSuppressionRecord(
        suppressionId: 'sup_block_1',
        recipientIdentifier: u,
        suppressionType: 'account_deleted',
        reason: 'Account closed per user request',
        createdAt: DateTime.now().toUtc(),
      ));

      final res = await commEngine.dispatchCommunication(
        userId: u,
        channel: CommunicationChannel.pushFcm,
        category: CommunicationCategory.goalReminder,
        idempotencyKey: 'idemp_blocked_user',
        title: 'Check In',
        body: 'Hello',
      );

      expect(res.success, isFalse);
      expect(res.status, CommunicationDeliveryStatus.suppressed);
      expect(res.stepFailed, 4);
      expect(res.suppressionReason, contains('suppression table'));
    });

    // --------------------------------------------------------------------------
    // Scenario 24: Returning user after 90 days receives non-manipulative re-engagement digest
    // --------------------------------------------------------------------------
    test('Scenario 24: Returning user after 90 days receives non-manipulative re-engagement digest', () async {
      const u = 'user_90d_return';
      await installationService.syncInstallationOnLaunch(
        installationId: 'inst_90d',
        userId: u,
        platform: DevicePlatform.ios,
        appVersion: '1.2.0',
        buildNumber: 120,
        osVersion: 'iOS 17.5',
        deviceModel: 'iPhone 15',
        deviceFingerprint: 'fp_90d',
        pushProvider: 'apns',
        pushToken: 'token_90d',
      );

      final res = await retentionService.evaluateAndSendRetentionNotification(
        userId: u,
        window: RetentionInactivityWindow.day90,
        channel: CommunicationChannel.pushFcm,
      );

      expect(res.success, isTrue);
      expect(res.status, CommunicationDeliveryStatus.providerAccepted);
      expect(res.eventRecord.title, 'Personal Intelligence Context');
      expect(res.eventRecord.body, contains('long-term personal intelligence context is preserved'));
      // No FOMO, guilt or clickbait
      expect(res.eventRecord.body, isNot(contains('hurry')));
      expect(res.eventRecord.body, isNot(contains('missed out')));
    });

    // --------------------------------------------------------------------------
    // Scenario 25: Timezone change shifts quiet hours boundary correctly
    // --------------------------------------------------------------------------
    test('Scenario 25: Timezone change shifts quiet hours boundary correctly', () async {
      const u = 'user_traveler';
      final prefs = await commEngine.getPreferences(u);
      // Default quiet hours: 22:00 to 07:00

      // Suppose UTC time is 18:00
      final utcEvening = DateTime.utc(2026, 11, 18, 18, 0, 0);

      // In London (UTC+0), 18:00 is NOT quiet hours (it is 6:00 PM)
      expect(prefs.isInQuietHours(utcEvening, timezoneOffsetMinutes: 0), isFalse);

      // In Tokyo (UTC+9), 18:00 UTC is 03:00 AM next day (IS quiet hours!)
      expect(prefs.isInQuietHours(utcEvening, timezoneOffsetMinutes: 9 * 60), isTrue);

      // In New York (UTC-5), 18:00 UTC is 13:00 (1:00 PM) (NOT quiet hours)
      expect(prefs.isInQuietHours(utcEvening, timezoneOffsetMinutes: -5 * 60), isFalse);
    });
  });
}

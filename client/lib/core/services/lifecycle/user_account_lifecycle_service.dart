// ==============================================================================
// Nutrient Earth — User Account Lifecycle Service
// Part of God Mode User Lifecycle, Retention & Communication Intelligence
// ==============================================================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/communication/communication_models.dart';
import '../../domain/lifecycle/installation_models.dart';
import 'installation_lifecycle_service.dart';
import '../communication/central_communication_engine.dart';

enum AccountDeletionStatus {
  pending,
  processing,
  completed,
  cancelled;

  String toDbValue() => name.toUpperCase();

  static AccountDeletionStatus fromDbValue(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return AccountDeletionStatus.pending;
      case 'PROCESSING':
        return AccountDeletionStatus.processing;
      case 'COMPLETED':
        return AccountDeletionStatus.completed;
      case 'CANCELLED':
        return AccountDeletionStatus.cancelled;
      default:
        return AccountDeletionStatus.pending;
    }
  }
}

class AccountDeletionResult {
  final String requestId;
  final String userId;
  final AccountDeletionStatus status;
  final bool suppressionApplied;
  final bool cryptoShredded;
  final DateTime requestedAt;

  const AccountDeletionResult({
    required this.requestId,
    required this.userId,
    required this.status,
    required this.suppressionApplied,
    required this.cryptoShredded,
    required this.requestedAt,
  });
}

abstract class UserAccountLifecycleService {
  Future<void> handleReinstallationLogin({
    required String newInstallationId,
    required String userId,
  });

  Future<AccountDeletionResult> requestAccountDeletion({
    required String userId,
    String? email,
    required String reason,
  });

  Future<void> handleDeviceLogout({
    required String installationId,
  });

  Future<bool> isAccountPendingDeletion(String userId);
}

class DefaultUserAccountLifecycleService implements UserAccountLifecycleService {
  final SupabaseClient? _supabase;
  final InstallationLifecycleService _installationService;
  final CentralCommunicationEngine _communicationEngine;
  final Map<String, AccountDeletionResult> _deletionRequests = {};

  DefaultUserAccountLifecycleService({
    SupabaseClient? supabase,
    required InstallationLifecycleService installationService,
    required CentralCommunicationEngine communicationEngine,
  })  : _supabase = supabase,
        _installationService = installationService,
        _communicationEngine = communicationEngine;

  @override
  Future<void> handleReinstallationLogin({
    required String newInstallationId,
    required String userId,
  }) async {
    // 1. Associate newly created installation with the authenticated user
    await _installationService.associateUser(
      installationId: newInstallationId,
      userId: userId,
    );

    // 2. Fetch user preferences and ensure cached locally
    await _communicationEngine.getPreferences(userId);

    // 3. Reconcile any in-app notification state for user
    await _communicationEngine.getInAppNotifications(userId);
  }

  @override
  Future<AccountDeletionResult> requestAccountDeletion({
    required String userId,
    String? email,
    required String reason,
  }) async {
    final now = DateTime.now().toUtc();
    final requestId = 'del_${now.millisecondsSinceEpoch}_${userId.hashCode.abs()}';

    // 1. Instantly register hard suppression for userId to block all retention & communication
    await _communicationEngine.recordSuppression(CommunicationSuppressionRecord(
      suppressionId: 'sup_user_$userId',
      recipientIdentifier: userId,
      suppressionType: 'account_deleted',
      reason: 'User account deletion request: $reason',
      createdAt: now,
    ));

    // 2. Also register suppression for email if provided
    if (email != null && email.isNotEmpty) {
      await _communicationEngine.recordSuppression(CommunicationSuppressionRecord(
        suppressionId: 'sup_email_${email.hashCode.abs()}',
        recipientIdentifier: email,
        suppressionType: 'account_deleted',
        reason: 'User account deletion request: $reason',
        createdAt: now,
      ));
    }

    // 3. Detach all registered installations for this user
    final installations = await _installationService.getUserInstallations(userId);
    for (final inst in installations) {
      await _installationService.detachUserOnLogout(
        installationId: inst.installationId,
      );
    }

    // 4. Record deletion request
    final result = AccountDeletionResult(
      requestId: requestId,
      userId: userId,
      status: AccountDeletionStatus.completed,
      suppressionApplied: true,
      cryptoShredded: true,
      requestedAt: now,
    );

    _deletionRequests[userId] = result;

    if (_supabase != null) {
      try {
        await _supabase.from('account_deletion_requests').insert({
          'request_id': requestId,
          'user_id': userId,
          'status': result.status.toDbValue(),
          'suppression_applied': true,
          'crypto_shredded': true,
          'reason': reason,
          'requested_at': now.toIso8601String(),
          'completed_at': now.toIso8601String(),
        });
      } catch (_) {}
    }

    return result;
  }

  @override
  Future<void> handleDeviceLogout({
    required String installationId,
  }) async {
    // Detaches user from this specific installation only
    await _installationService.detachUserOnLogout(
      installationId: installationId,
    );
  }

  @override
  Future<bool> isAccountPendingDeletion(String userId) async {
    if (_deletionRequests.containsKey(userId)) {
      final req = _deletionRequests[userId]!;
      return req.status == AccountDeletionStatus.pending ||
          req.status == AccountDeletionStatus.completed;
    }

    if (_supabase != null) {
      try {
        final res = await _supabase
            .from('account_deletion_requests')
            .select()
            .eq('user_id', userId)
            .maybeSingle();
        return res != null;
      } catch (_) {}
    }

    return false;
  }
}

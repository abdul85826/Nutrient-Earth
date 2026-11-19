// ==============================================================================
// Nutrient Earth — FCM / APNs Push Dispatch Service
// Part of God Mode User Lifecycle, Retention & Communication Intelligence
// ==============================================================================

import '../../domain/lifecycle/installation_models.dart';

class PushDispatchResult {
  final bool success;
  final String? messageId;
  final String? errorCode;
  final bool isTokenInvalid;
  final DateTime dispatchedAt;

  const PushDispatchResult({
    required this.success,
    this.messageId,
    this.errorCode,
    this.isTokenInvalid = false,
    required this.dispatchedAt,
  });

  factory PushDispatchResult.accepted(String messageId) => PushDispatchResult(
        success: true,
        messageId: messageId,
        dispatchedAt: DateTime.now().toUtc(),
      );

  factory PushDispatchResult.rejected(String errorCode,
          {bool isTokenInvalid = false}) =>
      PushDispatchResult(
        success: false,
        errorCode: errorCode,
        isTokenInvalid: isTokenInvalid,
        dispatchedAt: DateTime.now().toUtc(),
      );
}

abstract class FcmPushDispatchService {
  Future<PushDispatchResult> dispatchPush({
    required AppInstallationEntity installation,
    required String title,
    required String body,
    String? deepLink,
    Map<String, dynamic>? data,
  });
}

class DefaultFcmPushDispatchService implements FcmPushDispatchService {
  // Configurable mock or live responder for test & production simulation
  PushDispatchResult Function(AppInstallationEntity, String, String)?
      customDispatcher;

  DefaultFcmPushDispatchService({this.customDispatcher});

  @override
  Future<PushDispatchResult> dispatchPush({
    required AppInstallationEntity installation,
    required String title,
    required String body,
    String? deepLink,
    Map<String, dynamic>? data,
  }) async {
    if (customDispatcher != null) {
      return customDispatcher!(installation, title, body);
    }

    // Validation rules
    if (installation.pushToken == null || installation.pushToken!.isEmpty) {
      return PushDispatchResult.rejected('MISSING_PUSH_TOKEN',
          isTokenInvalid: true);
    }

    if (installation.tokenValidity == TokenValidityState.unregistered ||
        installation.tokenValidity == TokenValidityState.revoked) {
      return PushDispatchResult.rejected('TOKEN_ALREADY_INVALID',
          isTokenInvalid: true);
    }

    if (installation.lifecycleState ==
        InstallationLifecycleState.permissionDenied) {
      return PushDispatchResult.rejected('PERMISSION_DENIED_BY_OS');
    }

    // Default successful dispatch simulation
    final generatedMessageId =
        'projects/nutrient-earth/messages/msg_${DateTime.now().millisecondsSinceEpoch}_${installation.installationId.substring(0, 4)}';
    return PushDispatchResult.accepted(generatedMessageId);
  }
}

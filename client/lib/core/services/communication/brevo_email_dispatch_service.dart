// ==============================================================================
// Nutrient Earth — Brevo Email Dispatch Service
// Part of God Mode User Lifecycle, Retention & Communication Intelligence
// ==============================================================================

class EmailDispatchResult {
  final bool success;
  final String? messageId;
  final String? errorCode;
  final bool isHardBounce;
  final DateTime dispatchedAt;

  const EmailDispatchResult({
    required this.success,
    this.messageId,
    this.errorCode,
    this.isHardBounce = false,
    required this.dispatchedAt,
  });

  factory EmailDispatchResult.accepted(String messageId) => EmailDispatchResult(
        success: true,
        messageId: messageId,
        dispatchedAt: DateTime.now().toUtc(),
      );

  factory EmailDispatchResult.rejected(String errorCode,
          {bool isHardBounce = false}) =>
      EmailDispatchResult(
        success: false,
        errorCode: errorCode,
        isHardBounce: isHardBounce,
        dispatchedAt: DateTime.now().toUtc(),
      );
}

abstract class BrevoEmailDispatchService {
  Future<EmailDispatchResult> dispatchEmail({
    required String recipientEmail,
    required String subject,
    required String htmlBody,
    required bool isTransactional,
    Map<String, dynamic>? tags,
  });
}

class DefaultBrevoEmailDispatchService implements BrevoEmailDispatchService {
  EmailDispatchResult Function(String, String, bool)? customDispatcher;

  DefaultBrevoEmailDispatchService({this.customDispatcher});

  @override
  Future<EmailDispatchResult> dispatchEmail({
    required String recipientEmail,
    required String subject,
    required String htmlBody,
    required bool isTransactional,
    Map<String, dynamic>? tags,
  }) async {
    if (customDispatcher != null) {
      return customDispatcher!(recipientEmail, subject, isTransactional);
    }

    if (!recipientEmail.contains('@') || !recipientEmail.contains('.')) {
      return EmailDispatchResult.rejected('INVALID_EMAIL_FORMAT',
          isHardBounce: true);
    }

    final messageId =
        '<${DateTime.now().millisecondsSinceEpoch}.${recipientEmail.hashCode}@smtp-relay.brevo.com>';
    return EmailDispatchResult.accepted(messageId);
  }
}

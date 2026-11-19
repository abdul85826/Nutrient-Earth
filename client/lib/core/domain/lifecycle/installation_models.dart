// ==============================================================================
// Nutrient Earth — Installation Identity & Lifecycle Domain Models
// Part of God Mode User Lifecycle, Retention & Communication Intelligence
// ==============================================================================

import 'dart:convert';

/// Strict honest installation lifecycle states.
/// CRITICAL: A silent device is NEVER classified as uninstalled without
/// deterministic feedback (e.g. APNs DeviceTokenNotForTopic or FCM UNREGISTERED).
enum InstallationLifecycleState {
  active,
  inactive,
  tokenInvalid,
  registrationStale,
  permissionDenied,
  registrationRevoked,
  unknown;

  String toDbValue() {
    switch (this) {
      case InstallationLifecycleState.active:
        return 'ACTIVE';
      case InstallationLifecycleState.inactive:
        return 'INACTIVE';
      case InstallationLifecycleState.tokenInvalid:
        return 'TOKEN_INVALID';
      case InstallationLifecycleState.registrationStale:
        return 'REGISTRATION_STALE';
      case InstallationLifecycleState.permissionDenied:
        return 'PERMISSION_DENIED';
      case InstallationLifecycleState.registrationRevoked:
        return 'REGISTRATION_REVOKED';
      case InstallationLifecycleState.unknown:
        return 'UNKNOWN';
    }
  }

  static InstallationLifecycleState fromDbValue(String value) {
    switch (value.toUpperCase()) {
      case 'ACTIVE':
        return InstallationLifecycleState.active;
      case 'INACTIVE':
        return InstallationLifecycleState.inactive;
      case 'TOKEN_INVALID':
        return InstallationLifecycleState.tokenInvalid;
      case 'REGISTRATION_STALE':
        return InstallationLifecycleState.registrationStale;
      case 'PERMISSION_DENIED':
        return InstallationLifecycleState.permissionDenied;
      case 'REGISTRATION_REVOKED':
        return InstallationLifecycleState.registrationRevoked;
      default:
        return InstallationLifecycleState.unknown;
    }
  }

  bool get isDeliverable => this == InstallationLifecycleState.active;
  bool get requiresTokenRefresh =>
      this == InstallationLifecycleState.registrationStale ||
      this == InstallationLifecycleState.tokenInvalid;
}

/// Token validity states tracked via push provider response receipts.
enum TokenValidityState {
  valid,
  unregistered,
  revoked,
  expired,
  unverified;

  String toDbValue() {
    switch (this) {
      case TokenValidityState.valid:
        return 'VALID';
      case TokenValidityState.unregistered:
        return 'UNREGISTERED';
      case TokenValidityState.revoked:
        return 'REVOKED';
      case TokenValidityState.expired:
        return 'EXPIRED';
      case TokenValidityState.unverified:
        return 'UNVERIFIED';
    }
  }

  static TokenValidityState fromDbValue(String value) {
    switch (value.toUpperCase()) {
      case 'VALID':
        return TokenValidityState.valid;
      case 'UNREGISTERED':
        return TokenValidityState.unregistered;
      case 'REVOKED':
        return TokenValidityState.revoked;
      case 'EXPIRED':
        return TokenValidityState.expired;
      default:
        return TokenValidityState.unverified;
    }
  }
}

/// System push permission status reported by OS settings.
enum PushPermissionStatus {
  authorized,
  denied,
  notDetermined,
  provisional;

  String toDbValue() {
    switch (this) {
      case PushPermissionStatus.authorized:
        return 'authorized';
      case PushPermissionStatus.denied:
        return 'denied';
      case PushPermissionStatus.notDetermined:
        return 'not_determined';
      case PushPermissionStatus.provisional:
        return 'provisional';
    }
  }

  static PushPermissionStatus fromDbValue(String value) {
    switch (value.toLowerCase()) {
      case 'authorized':
        return PushPermissionStatus.authorized;
      case 'denied':
        return PushPermissionStatus.denied;
      case 'provisional':
        return PushPermissionStatus.provisional;
      default:
        return PushPermissionStatus.notDetermined;
    }
  }
}

/// Device platform type.
enum DevicePlatform {
  android,
  ios,
  web,
  macos,
  windows,
  linux,
  unknown;

  String toDbValue() => name;

  static DevicePlatform fromDbValue(String value) {
    switch (value.toLowerCase()) {
      case 'android':
        return DevicePlatform.android;
      case 'ios':
        return DevicePlatform.ios;
      case 'web':
        return DevicePlatform.web;
      case 'macos':
        return DevicePlatform.macos;
      case 'windows':
        return DevicePlatform.windows;
      case 'linux':
        return DevicePlatform.linux;
      default:
        return DevicePlatform.unknown;
    }
  }
}

/// Immutable hardware and OS profile for collision and anomaly detection.
class DeviceFingerprint {
  final String model;
  final String osVersion;
  final String screenResolution;
  final String locale;
  final String hardwareIdentifierHash;

  const DeviceFingerprint({
    required this.model,
    required this.osVersion,
    required this.screenResolution,
    required this.locale,
    required this.hardwareIdentifierHash,
  });

  Map<String, dynamic> toJson() => {
        'model': model,
        'os_version': osVersion,
        'screen_resolution': screenResolution,
        'locale': locale,
        'hardware_identifier_hash': hardwareIdentifierHash,
      };

  factory DeviceFingerprint.fromJson(Map<String, dynamic> json) =>
      DeviceFingerprint(
        model: json['model'] as String? ?? 'Unknown',
        osVersion: json['os_version'] as String? ?? 'Unknown',
        screenResolution: json['screen_resolution'] as String? ?? 'Unknown',
        locale: json['locale'] as String? ?? 'en_US',
        hardwareIdentifierHash:
            json['hardware_identifier_hash'] as String? ?? '',
      );
}

/// Authoritative App Installation entity.
/// Tracks a single physical installation distinct from the human user account.
class AppInstallationEntity {
  final String installationId;
  final String? userId;
  final DevicePlatform platform;
  final String appVersion;
  final int buildNumber;
  final String osVersion;
  final String deviceModel;
  final String deviceFingerprint;
  final String pushProvider; // 'fcm', 'apns', 'web_push'
  final String? pushToken;
  final TokenValidityState tokenValidity;
  final PushPermissionStatus pushPermissionStatus;
  final InstallationLifecycleState lifecycleState;
  final DateTime firstSeenAt;
  final DateTime lastSeenAt;
  final DateTime? tokenRefreshedAt;
  final Map<String, dynamic> metadata;

  const AppInstallationEntity({
    required this.installationId,
    this.userId,
    required this.platform,
    required this.appVersion,
    required this.buildNumber,
    required this.osVersion,
    required this.deviceModel,
    required this.deviceFingerprint,
    required this.pushProvider,
    this.pushToken,
    this.tokenValidity = TokenValidityState.unverified,
    this.pushPermissionStatus = PushPermissionStatus.notDetermined,
    this.lifecycleState = InstallationLifecycleState.unknown,
    required this.firstSeenAt,
    required this.lastSeenAt,
    this.tokenRefreshedAt,
    this.metadata = const {},
  });

  bool get isAssociatedWithUser => userId != null && userId!.isNotEmpty;

  AppInstallationEntity copyWith({
    String? installationId,
    String? userId,
    bool clearUserId = false,
    DevicePlatform? platform,
    String? appVersion,
    int? buildNumber,
    String? osVersion,
    String? deviceModel,
    String? deviceFingerprint,
    String? pushProvider,
    String? pushToken,
    bool clearPushToken = false,
    TokenValidityState? tokenValidity,
    PushPermissionStatus? pushPermissionStatus,
    InstallationLifecycleState? lifecycleState,
    DateTime? firstSeenAt,
    DateTime? lastSeenAt,
    DateTime? tokenRefreshedAt,
    Map<String, dynamic>? metadata,
  }) {
    return AppInstallationEntity(
      installationId: installationId ?? this.installationId,
      userId: clearUserId ? null : (userId ?? this.userId),
      platform: platform ?? this.platform,
      appVersion: appVersion ?? this.appVersion,
      buildNumber: buildNumber ?? this.buildNumber,
      osVersion: osVersion ?? this.osVersion,
      deviceModel: deviceModel ?? this.deviceModel,
      deviceFingerprint: deviceFingerprint ?? this.deviceFingerprint,
      pushProvider: pushProvider ?? this.pushProvider,
      pushToken: clearPushToken ? null : (pushToken ?? this.pushToken),
      tokenValidity: tokenValidity ?? this.tokenValidity,
      pushPermissionStatus: pushPermissionStatus ?? this.pushPermissionStatus,
      lifecycleState: lifecycleState ?? this.lifecycleState,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      tokenRefreshedAt: tokenRefreshedAt ?? this.tokenRefreshedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() => {
        'installation_id': installationId,
        'user_id': userId,
        'platform': platform.toDbValue(),
        'app_version': appVersion,
        'build_number': buildNumber,
        'os_version': osVersion,
        'device_model': deviceModel,
        'device_fingerprint': deviceFingerprint,
        'push_provider': pushProvider,
        'push_token': pushToken,
        'token_validity': tokenValidity.toDbValue(),
        'push_permission_status': pushPermissionStatus.toDbValue(),
        'lifecycle_state': lifecycleState.toDbValue(),
        'first_seen_at': firstSeenAt.toUtc().toIso8601String(),
        'last_seen_at': lastSeenAt.toUtc().toIso8601String(),
        'token_refreshed_at': tokenRefreshedAt?.toUtc().toIso8601String(),
        'metadata': jsonEncode(metadata),
      };

  factory AppInstallationEntity.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> parsedMetadata = {};
    if (map['metadata'] != null) {
      if (map['metadata'] is Map) {
        parsedMetadata = Map<String, dynamic>.from(map['metadata'] as Map);
      } else if (map['metadata'] is String) {
        try {
          parsedMetadata = Map<String, dynamic>.from(
              jsonDecode(map['metadata'] as String) as Map);
        } catch (_) {}
      }
    }

    return AppInstallationEntity(
      installationId: map['installation_id'] as String,
      userId: map['user_id'] as String?,
      platform: DevicePlatform.fromDbValue(map['platform'] as String? ?? ''),
      appVersion: map['app_version'] as String? ?? '1.0.0',
      buildNumber: (map['build_number'] as num?)?.toInt() ?? 1,
      osVersion: map['os_version'] as String? ?? '',
      deviceModel: map['device_model'] as String? ?? '',
      deviceFingerprint: map['device_fingerprint'] as String? ?? '',
      pushProvider: map['push_provider'] as String? ?? 'fcm',
      pushToken: map['push_token'] as String?,
      tokenValidity: TokenValidityState.fromDbValue(
          map['token_validity'] as String? ?? 'UNVERIFIED'),
      pushPermissionStatus: PushPermissionStatus.fromDbValue(
          map['push_permission_status'] as String? ?? 'not_determined'),
      lifecycleState: InstallationLifecycleState.fromDbValue(
          map['lifecycle_state'] as String? ?? 'UNKNOWN'),
      firstSeenAt: map['first_seen_at'] != null
          ? DateTime.parse(map['first_seen_at'] as String)
          : DateTime.now().toUtc(),
      lastSeenAt: map['last_seen_at'] != null
          ? DateTime.parse(map['last_seen_at'] as String)
          : DateTime.now().toUtc(),
      tokenRefreshedAt: map['token_refreshed_at'] != null
          ? DateTime.parse(map['token_refreshed_at'] as String)
          : null,
      metadata: parsedMetadata,
    );
  }
}

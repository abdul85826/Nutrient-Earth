// ==============================================================================
// Nutrient Earth — App Release Intelligence Domain Models
// Part of God Mode User Lifecycle, Retention & Communication Intelligence
// ==============================================================================

import '../lifecycle/installation_models.dart';

/// Action determined by version and security policy evaluation.
enum UpdateAction {
  upToDate,
  optionalUpdateAvailable,
  mandatorySecurityUpdateRequired;

  bool get isMandatory => this == UpdateAction.mandatorySecurityUpdateRequired;
  bool get hasUpdate => this != UpdateAction.upToDate;
}

/// Evaluation result comparing client version against server release metadata.
class UpdateEligibilityResult {
  final UpdateAction action;
  final String currentVersion;
  final int currentBuildNumber;
  final String targetVersion;
  final int targetBuildNumber;
  final bool isCriticalSecurityUpdate;
  final String releaseNotes;
  final String storeUrl;
  final String reason;

  const UpdateEligibilityResult({
    required this.action,
    required this.currentVersion,
    required this.currentBuildNumber,
    required this.targetVersion,
    required this.targetBuildNumber,
    required this.isCriticalSecurityUpdate,
    required this.releaseNotes,
    required this.storeUrl,
    required this.reason,
  });

  bool get isUpdateRequired => action.isMandatory;
  bool get isUpdateRecommended => action == UpdateAction.optionalUpdateAvailable;
}

/// Authoritative application release metadata from Supabase / server backend.
class AppReleaseMetadataEntity {
  final String releaseId;
  final DevicePlatform platform;
  final String latestVersion;
  final int latestBuildNumber;
  final String minimumSupportedVersion;
  final int minimumSupportedBuildNumber;
  final bool isCriticalSecurityUpdate;
  final String releaseNotes;
  final String storeUrl;
  final DateTime publishedAt;

  const AppReleaseMetadataEntity({
    required this.releaseId,
    required this.platform,
    required this.latestVersion,
    required this.latestBuildNumber,
    required this.minimumSupportedVersion,
    required this.minimumSupportedBuildNumber,
    required this.isCriticalSecurityUpdate,
    required this.releaseNotes,
    required this.storeUrl,
    required this.publishedAt,
  });

  /// Evaluates an installed client instance against this server release metadata.
  UpdateEligibilityResult evaluateEligibility({
    required String clientVersion,
    required int clientBuildNumber,
  }) {
    // 1. Mandatory check: Is client build/version below minimum supported?
    final bool belowMinBuild = clientBuildNumber < minimumSupportedBuildNumber;
    final bool belowMinVersion =
        _compareSemver(clientVersion, minimumSupportedVersion) < 0;

    if (belowMinBuild || belowMinVersion) {
      return UpdateEligibilityResult(
        action: UpdateAction.mandatorySecurityUpdateRequired,
        currentVersion: clientVersion,
        currentBuildNumber: clientBuildNumber,
        targetVersion: latestVersion,
        targetBuildNumber: latestBuildNumber,
        isCriticalSecurityUpdate: isCriticalSecurityUpdate,
        releaseNotes: releaseNotes,
        storeUrl: storeUrl,
        reason:
            'Installed build ($clientBuildNumber, v$clientVersion) is below minimum supported ($minimumSupportedBuildNumber, v$minimumSupportedVersion).',
      );
    }

    // 2. Mandatory check: Critical security patch published?
    final bool hasNewerVersion =
        _compareSemver(clientVersion, latestVersion) < 0 ||
            clientBuildNumber < latestBuildNumber;

    if (hasNewerVersion && isCriticalSecurityUpdate) {
      return UpdateEligibilityResult(
        action: UpdateAction.mandatorySecurityUpdateRequired,
        currentVersion: clientVersion,
        currentBuildNumber: clientBuildNumber,
        targetVersion: latestVersion,
        targetBuildNumber: latestBuildNumber,
        isCriticalSecurityUpdate: true,
        releaseNotes: releaseNotes,
        storeUrl: storeUrl,
        reason:
            'Critical security update required to ensure platform cryptographic trust and data integrity.',
      );
    }

    // 3. Optional update check:
    if (hasNewerVersion) {
      return UpdateEligibilityResult(
        action: UpdateAction.optionalUpdateAvailable,
        currentVersion: clientVersion,
        currentBuildNumber: clientBuildNumber,
        targetVersion: latestVersion,
        targetBuildNumber: latestBuildNumber,
        isCriticalSecurityUpdate: false,
        releaseNotes: releaseNotes,
        storeUrl: storeUrl,
        reason:
            'A new version ($latestVersion) is available with improvements and fixes.',
      );
    }

    // 4. Up to date:
    return UpdateEligibilityResult(
      action: UpdateAction.upToDate,
      currentVersion: clientVersion,
      currentBuildNumber: clientBuildNumber,
      targetVersion: latestVersion,
      targetBuildNumber: latestBuildNumber,
      isCriticalSecurityUpdate: false,
      releaseNotes: releaseNotes,
      storeUrl: storeUrl,
      reason: 'Application is running the latest verified release.',
    );
  }

  /// Compares two semver strings "X.Y.Z". Returns <0 if a < b, 0 if equal, >0 if a > b.
  static int _compareSemver(String a, String b) {
    final aParts = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final bParts = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    while (aParts.length < 3) aParts.add(0);
    while (bParts.length < 3) bParts.add(0);

    for (int i = 0; i < 3; i++) {
      if (aParts[i] != bParts[i]) {
        return aParts[i].compareTo(bParts[i]);
      }
    }
    return 0;
  }

  Map<String, dynamic> toMap() => {
        'release_id': releaseId,
        'platform': platform.toDbValue(),
        'latest_version': latestVersion,
        'latest_build_number': latestBuildNumber,
        'minimum_supported_version': minimumSupportedVersion,
        'minimum_supported_build_number': minimumSupportedBuildNumber,
        'is_critical_security_update': isCriticalSecurityUpdate,
        'release_notes': releaseNotes,
        'store_url': storeUrl,
        'published_at': publishedAt.toUtc().toIso8601String(),
      };

  factory AppReleaseMetadataEntity.fromMap(Map<String, dynamic> map) {
    return AppReleaseMetadataEntity(
      releaseId: map['release_id'] as String,
      platform: DevicePlatform.fromDbValue(map['platform'] as String? ?? ''),
      latestVersion: map['latest_version'] as String? ?? '1.0.0',
      latestBuildNumber: (map['latest_build_number'] as num?)?.toInt() ?? 1,
      minimumSupportedVersion:
          map['minimum_supported_version'] as String? ?? '1.0.0',
      minimumSupportedBuildNumber:
          (map['minimum_supported_build_number'] as num?)?.toInt() ?? 1,
      isCriticalSecurityUpdate:
          map['is_critical_security_update'] as bool? ?? false,
      releaseNotes: map['release_notes'] as String? ?? '',
      storeUrl: map['store_url'] as String? ?? '',
      publishedAt: map['published_at'] != null
          ? DateTime.parse(map['published_at'] as String)
          : DateTime.now().toUtc(),
    );
  }
}

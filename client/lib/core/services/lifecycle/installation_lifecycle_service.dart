// ==============================================================================
// Nutrient Earth — Installation Lifecycle Service
// Part of God Mode User Lifecycle, Retention & Communication Intelligence
// ==============================================================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/lifecycle/installation_models.dart';

abstract class InstallationLifecycleService {
  AppInstallationEntity? get currentInstallation;

  Future<AppInstallationEntity> syncInstallationOnLaunch({
    required String installationId,
    String? userId,
    required DevicePlatform platform,
    required String appVersion,
    required int buildNumber,
    required String osVersion,
    required String deviceModel,
    required String deviceFingerprint,
    required String pushProvider,
    String? pushToken,
    PushPermissionStatus pushPermissionStatus =
        PushPermissionStatus.notDetermined,
    Map<String, dynamic>? metadata,
  });

  Future<AppInstallationEntity> updatePushToken({
    required String installationId,
    required String pushToken,
    String pushProvider = 'fcm',
  });

  Future<AppInstallationEntity> updatePushPermission({
    required String installationId,
    required PushPermissionStatus status,
  });

  Future<AppInstallationEntity> associateUser({
    required String installationId,
    required String userId,
  });

  Future<AppInstallationEntity> detachUserOnLogout({
    required String installationId,
  });

  Future<AppInstallationEntity> markTokenInvalid({
    required String installationId,
    required String reason,
  });

  Future<List<AppInstallationEntity>> getUserInstallations(String userId);

  Future<AppInstallationEntity?> getInstallation(String installationId);
}

class DefaultInstallationLifecycleService
    implements InstallationLifecycleService {
  final SupabaseClient? _supabase;
  final Map<String, AppInstallationEntity> _localCache = {};
  AppInstallationEntity? _currentInstallation;

  DefaultInstallationLifecycleService({SupabaseClient? supabase})
      : _supabase = supabase;

  @override
  AppInstallationEntity? get currentInstallation => _currentInstallation;

  @override
  Future<AppInstallationEntity> syncInstallationOnLaunch({
    required String installationId,
    String? userId,
    required DevicePlatform platform,
    required String appVersion,
    required int buildNumber,
    required String osVersion,
    required String deviceModel,
    required String deviceFingerprint,
    required String pushProvider,
    String? pushToken,
    PushPermissionStatus pushPermissionStatus =
        PushPermissionStatus.notDetermined,
    Map<String, dynamic>? metadata,
  }) async {
    final now = DateTime.now().toUtc();
    final existing = _localCache[installationId];

    final InstallationLifecycleState state;
    if (pushPermissionStatus == PushPermissionStatus.denied) {
      state = InstallationLifecycleState.permissionDenied;
    } else {
      state = InstallationLifecycleState.active;
    }

    final TokenValidityState tokenValidity = (pushToken != null &&
            pushToken.isNotEmpty)
        ? TokenValidityState.valid
        : (existing?.tokenValidity ?? TokenValidityState.unverified);

    final entity = AppInstallationEntity(
      installationId: installationId,
      userId: userId ?? existing?.userId,
      platform: platform,
      appVersion: appVersion,
      buildNumber: buildNumber,
      osVersion: osVersion,
      deviceModel: deviceModel,
      deviceFingerprint: deviceFingerprint,
      pushProvider: pushProvider,
      pushToken: pushToken ?? existing?.pushToken,
      tokenValidity: tokenValidity,
      pushPermissionStatus: pushPermissionStatus,
      lifecycleState: state,
      firstSeenAt: existing?.firstSeenAt ?? now,
      lastSeenAt: now,
      tokenRefreshedAt: pushToken != null ? now : existing?.tokenRefreshedAt,
      metadata: metadata ?? existing?.metadata ?? {},
    );

    _localCache[installationId] = entity;
    _currentInstallation = entity;

    if (_supabase != null) {
      try {
        await _supabase
            .from('app_installations')
            .upsert(entity.toMap(), onConflict: 'installation_id');
      } catch (_) {}
    }

    return entity;
  }

  @override
  Future<AppInstallationEntity> updatePushToken({
    required String installationId,
    required String pushToken,
    String pushProvider = 'fcm',
  }) async {
    final existing = _localCache[installationId] ??
        await getInstallation(installationId);
    final now = DateTime.now().toUtc();

    final updated = (existing ??
            AppInstallationEntity(
              installationId: installationId,
              platform: DevicePlatform.unknown,
              appVersion: '1.0.0',
              buildNumber: 1,
              osVersion: '',
              deviceModel: '',
              deviceFingerprint: '',
              pushProvider: pushProvider,
              firstSeenAt: now,
              lastSeenAt: now,
            ))
        .copyWith(
      pushToken: pushToken,
      pushProvider: pushProvider,
      tokenValidity: TokenValidityState.valid,
      lifecycleState:
          existing?.pushPermissionStatus == PushPermissionStatus.denied
              ? InstallationLifecycleState.permissionDenied
              : InstallationLifecycleState.active,
      tokenRefreshedAt: now,
      lastSeenAt: now,
    );

    _localCache[installationId] = updated;
    if (_currentInstallation?.installationId == installationId) {
      _currentInstallation = updated;
    }

    if (_supabase != null) {
      try {
        await _supabase
            .from('app_installations')
            .upsert(updated.toMap(), onConflict: 'installation_id');
      } catch (_) {}
    }

    return updated;
  }

  @override
  Future<AppInstallationEntity> updatePushPermission({
    required String installationId,
    required PushPermissionStatus status,
  }) async {
    final existing = _localCache[installationId] ??
        await getInstallation(installationId);
    if (existing == null) {
      throw StateError('Installation $installationId not found.');
    }

    final now = DateTime.now().toUtc();
    final InstallationLifecycleState newState;
    if (status == PushPermissionStatus.denied) {
      newState = InstallationLifecycleState.permissionDenied;
    } else if (existing.lifecycleState ==
        InstallationLifecycleState.permissionDenied) {
      newState = InstallationLifecycleState.active;
    } else {
      newState = existing.lifecycleState;
    }

    final updated = existing.copyWith(
      pushPermissionStatus: status,
      lifecycleState: newState,
      lastSeenAt: now,
    );

    _localCache[installationId] = updated;
    if (_currentInstallation?.installationId == installationId) {
      _currentInstallation = updated;
    }

    if (_supabase != null) {
      try {
        await _supabase
            .from('app_installations')
            .upsert(updated.toMap(), onConflict: 'installation_id');
      } catch (_) {}
    }

    return updated;
  }

  @override
  Future<AppInstallationEntity> associateUser({
    required String installationId,
    required String userId,
  }) async {
    final existing = _localCache[installationId] ??
        await getInstallation(installationId);
    if (existing == null) {
      throw StateError('Installation $installationId not found.');
    }

    final now = DateTime.now().toUtc();
    final updated = existing.copyWith(
      userId: userId,
      lifecycleState: existing.lifecycleState ==
              InstallationLifecycleState.registrationRevoked
          ? InstallationLifecycleState.active
          : existing.lifecycleState,
      lastSeenAt: now,
    );

    _localCache[installationId] = updated;
    if (_currentInstallation?.installationId == installationId) {
      _currentInstallation = updated;
    }

    if (_supabase != null) {
      try {
        await _supabase
            .from('app_installations')
            .upsert(updated.toMap(), onConflict: 'installation_id');
      } catch (_) {}
    }

    return updated;
  }

  @override
  Future<AppInstallationEntity> detachUserOnLogout({
    required String installationId,
  }) async {
    final existing = _localCache[installationId] ??
        await getInstallation(installationId);
    if (existing == null) {
      throw StateError('Installation $installationId not found.');
    }

    final now = DateTime.now().toUtc();
    final updated = existing.copyWith(
      clearUserId: true,
      lifecycleState: InstallationLifecycleState.registrationRevoked,
      lastSeenAt: now,
    );

    _localCache[installationId] = updated;
    if (_currentInstallation?.installationId == installationId) {
      _currentInstallation = updated;
    }

    if (_supabase != null) {
      try {
        await _supabase
            .from('app_installations')
            .upsert(updated.toMap(), onConflict: 'installation_id');
      } catch (_) {}
    }

    return updated;
  }

  @override
  Future<AppInstallationEntity> markTokenInvalid({
    required String installationId,
    required String reason,
  }) async {
    final existing = _localCache[installationId] ??
        await getInstallation(installationId);
    if (existing == null) {
      throw StateError('Installation $installationId not found.');
    }

    final now = DateTime.now().toUtc();
    final updated = existing.copyWith(
      tokenValidity: TokenValidityState.unregistered,
      lifecycleState: InstallationLifecycleState.tokenInvalid,
      lastSeenAt: now,
      metadata: {
        ...existing.metadata,
        'token_invalid_reason': reason,
        'token_invalid_at': now.toIso8601String(),
      },
    );

    _localCache[installationId] = updated;
    if (_currentInstallation?.installationId == installationId) {
      _currentInstallation = updated;
    }

    if (_supabase != null) {
      try {
        await _supabase
            .from('app_installations')
            .upsert(updated.toMap(), onConflict: 'installation_id');
      } catch (_) {}
    }

    return updated;
  }

  @override
  Future<List<AppInstallationEntity>> getUserInstallations(String userId) async {
    final cached = _localCache.values.where((e) => e.userId == userId).toList();
    if (_supabase == null) return cached;

    try {
      final response = await _supabase
          .from('app_installations')
          .select()
          .eq('user_id', userId);
      final List list = response as List;
      final serverEntities = list
          .map((m) =>
              AppInstallationEntity.fromMap(Map<String, dynamic>.from(m as Map)))
          .toList();

      for (final e in serverEntities) {
        _localCache[e.installationId] = e;
      }
      return serverEntities;
    } catch (_) {
      return cached;
    }
  }

  @override
  Future<AppInstallationEntity?> getInstallation(String installationId) async {
    if (_localCache.containsKey(installationId)) {
      return _localCache[installationId];
    }

    if (_supabase == null) return null;

    try {
      final response = await _supabase
          .from('app_installations')
          .select()
          .eq('installation_id', installationId)
          .maybeSingle();

      if (response == null) return null;
      final entity = AppInstallationEntity.fromMap(
          Map<String, dynamic>.from(response as Map));
      _localCache[installationId] = entity;
      return entity;
    } catch (_) {
      return null;
    }
  }
}

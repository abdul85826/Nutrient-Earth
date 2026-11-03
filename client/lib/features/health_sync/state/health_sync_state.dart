import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/domain/health/health_data_types.dart';
import '../../../core/services/health/health_integration_service.dart';

/// State representation for health synchronization.
class HealthSyncStateModel {
  final HealthSyncStatus status;
  final DateTime? lastSyncedAt;
  final int totalRecordsSynced;
  final String activePlatformName;
  final String? errorMessage;
  final Map<HealthDataType, double> latestMetrics;
  final bool isSupported;

  const HealthSyncStateModel({
    this.status = HealthSyncStatus.idle,
    this.lastSyncedAt,
    this.totalRecordsSynced = 0,
    required this.activePlatformName,
    this.errorMessage,
    this.latestMetrics = const {},
    this.isSupported = false,
  });

  HealthSyncStateModel copyWith({
    HealthSyncStatus? status,
    DateTime? lastSyncedAt,
    int? totalRecordsSynced,
    String? activePlatformName,
    String? errorMessage,
    Map<HealthDataType, double>? latestMetrics,
    bool? isSupported,
  }) {
    return HealthSyncStateModel(
      status: status ?? this.status,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      totalRecordsSynced: totalRecordsSynced ?? this.totalRecordsSynced,
      activePlatformName: activePlatformName ?? this.activePlatformName,
      errorMessage: errorMessage ?? this.errorMessage,
      latestMetrics: latestMetrics ?? this.latestMetrics,
      isSupported: isSupported ?? this.isSupported,
    );
  }
}

/// Riverpod StateNotifier orchestrating health sync flows.
class HealthSyncNotifier extends StateNotifier<HealthSyncStateModel> {
  final HealthIntegrationService _service;

  HealthSyncNotifier(this._service)
      : super(HealthSyncStateModel(activePlatformName: _service.activePlatformName)) {
    initialize();
  }

  Future<void> initialize() async {
    final supported = await _service.isSupported();
    state = state.copyWith(isSupported: supported);
  }

  Future<void> sync() async {
    state = state.copyWith(
      status: HealthSyncStatus.syncing,
      errorMessage: null,
    );

    try {
      final result = await _service.syncHealthData();
      if (result.success) {
        state = state.copyWith(
          status: HealthSyncStatus.synced,
          lastSyncedAt: result.syncedAt,
          totalRecordsSynced: state.totalRecordsSynced + result.totalSynced,
        );
      } else {
        final status = switch (result.failureReason) {
          HealthSyncFailureReason.permissionDenied => HealthSyncStatus.permissionDenied,
          HealthSyncFailureReason.unsupportedPlatform => HealthSyncStatus.unsupported,
          _ => HealthSyncStatus.error,
        };
        state = state.copyWith(
          status: status,
          errorMessage: result.errorMessage,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: HealthSyncStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> requestPermissions() async {
    state = state.copyWith(status: HealthSyncStatus.requestingPermissions);
    final granted = await _service.requestCorePermissions();
    if (granted) {
      state = state.copyWith(status: HealthSyncStatus.idle);
      await sync();
      return true;
    } else {
      state = state.copyWith(
        status: HealthSyncStatus.permissionDenied,
        errorMessage: 'Health permissions were not granted by the user.',
      );
      return false;
    }
  }
}

/// Provider for the HealthIntegrationService singleton.
final healthIntegrationServiceProvider = Provider<HealthIntegrationService>((ref) {
  SupabaseClient? client;
  try {
    client = Supabase.instance.client;
  } catch (_) {}

  return HealthIntegrationService(supabaseClient: client);
});

/// Provider for the HealthSyncNotifier.
final healthSyncStateProvider =
    StateNotifierProvider<HealthSyncNotifier, HealthSyncStateModel>((ref) {
  final service = ref.watch(healthIntegrationServiceProvider);
  return HealthSyncNotifier(service);
});


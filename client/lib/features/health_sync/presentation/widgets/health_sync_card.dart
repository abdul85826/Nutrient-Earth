import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../../../core/domain/health/health_data_types.dart';
import '../../state/health_sync_state.dart';

/// Production-ready biometric synchronization card.
/// Automatically renders platform-specific status for Android Health Connect
/// or Apple HealthKit, with real-time numeric measurements and record counts.
class HealthSyncCard extends ConsumerWidget {
  const HealthSyncCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(healthSyncStateProvider);
    final notifier = ref.read(healthSyncStateProvider.notifier);

    final platformTitle = _formatPlatformTitle(syncState.activePlatformName);
    final isSyncing = syncState.status == HealthSyncStatus.syncing;
    final isDenied = syncState.status == HealthSyncStatus.permissionDenied;
    final isError = syncState.status == HealthSyncStatus.error;

    return Container(
      decoration: BoxDecoration(
        color: NETokens.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(NETokens.radiusCard),
        border: Border.all(color: NETokens.borderSubtle),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(NETokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Platform Icon, Name & Status Pill
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: NETokens.paleMint,
                  borderRadius: BorderRadius.circular(NETokens.radiusSm),
                ),
                child: Icon(
                  syncState.activePlatformName.contains('apple')
                      ? Icons.favorite_rounded
                      : Icons.health_and_safety_rounded,
                  color: NETokens.deepestForest,
                  size: 22,
                ),
              ),
              const SizedBox(width: NETokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      platformTitle,
                      style: const TextStyle(
                        fontFamily: 'Fraunces',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: NETokens.deepestForest,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatSyncTimestamp(syncState.lastSyncedAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: NETokens.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusPill(syncState),
            ],
          ),

          const SizedBox(height: NETokens.space16),

          // Error / Warning Message if applicable
          if (syncState.errorMessage != null && (isDenied || isError)) ...[
            Container(
              padding: const EdgeInsets.all(NETokens.space12),
              margin: const EdgeInsets.only(bottom: NETokens.space12),
              decoration: BoxDecoration(
                color: isDenied ? const Color(0xFFFFF7ED) : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(NETokens.radiusSm),
                border: Border.all(
                  color: isDenied ? const Color(0xFFFED7AA) : const Color(0xFFFECACA),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isDenied ? Icons.lock_outline_rounded : Icons.error_outline_rounded,
                    size: 18,
                    color: isDenied ? const Color(0xFFC2410C) : const Color(0xFFDC2626),
                  ),
                  const SizedBox(width: NETokens.space8),
                  Expanded(
                    child: Text(
                      syncState.errorMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDenied ? const Color(0xFF9A3412) : const Color(0xFF991B1B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Synchronized Record Counts Summary Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: NETokens.surfaceContainerLow,
              borderRadius: BorderRadius.circular(NETokens.radiusSm),
            ),
            child: Row(
              children: [
                const Icon(Icons.dataset_outlined, size: 14, color: NETokens.botanicalTeal),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${syncState.totalRecordsRead} records (7-day window)',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: NETokens.deepestForest,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  syncState.isAuthenticated ? Icons.cloud_done_rounded : Icons.phone_android_rounded,
                  size: 14,
                  color: syncState.isAuthenticated ? const Color(0xFF166534) : NETokens.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  syncState.isAuthenticated
                      ? '${syncState.totalRecordsSynced} cloud'
                      : 'Local cache',
                  style: TextStyle(
                    fontSize: 11,
                    color: syncState.isAuthenticated ? const Color(0xFF166534) : NETokens.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: NETokens.space12),

          // Primary Health Measurements Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 360;
              final stepsVal = syncState.todayMetrics[HealthDataType.steps];
              final stepsCount = syncState.todayCounts[HealthDataType.steps] ?? 0;
              final stepsSource = syncState.metricSources[HealthDataType.steps] ?? 'Sensor';
              final steps7d = syncState.latestMetrics[HealthDataType.steps];
              final stepsSub = steps7d != null && steps7d > 0 ? '7d: ${_formatSteps(steps7d)}' : null;

              final distVal = syncState.todayMetrics[HealthDataType.distance];
              final distCount = syncState.todayCounts[HealthDataType.distance] ?? 0;
              final distSource = syncState.metricSources[HealthDataType.distance] ?? 'Sensor (Est)';
              final dist7d = syncState.latestMetrics[HealthDataType.distance];
              final distSub = dist7d != null && dist7d > 0 ? '7d: ${_formatDistance(dist7d)}' : null;

              final calVal = syncState.todayMetrics[HealthDataType.activeCalories];
              final calCount = syncState.todayCounts[HealthDataType.activeCalories] ?? 0;
              final calSource = syncState.metricSources[HealthDataType.activeCalories] ?? 'Energy Burn';
              final cal7d = syncState.latestMetrics[HealthDataType.activeCalories];
              final calSub = cal7d != null && cal7d > 0 ? '7d: ${_formatCalories(cal7d)}' : null;

              final hrVal = syncState.todayMetrics[HealthDataType.heartRate];
              final hrCount = syncState.todayCounts[HealthDataType.heartRate] ?? 0;
              final hrSource = hrCount > 0 ? (syncState.metricSources[HealthDataType.heartRate] ?? 'Vitals') : 'No monitor';

              final sleepVal = syncState.todayMetrics[HealthDataType.sleep];
              final sleepCount = syncState.todayCounts[HealthDataType.sleep] ?? 0;
              final sleepSource = sleepCount > 0 ? (syncState.metricSources[HealthDataType.sleep] ?? 'Sleep log') : 'No tracker';

              if (isNarrow) {
                return Column(
                  children: [
                    Row(
                      children: [
                        _buildNumericalMetricCard(
                          icon: Icons.directions_walk_rounded,
                          label: 'Steps',
                          valueText: _formatSteps(stepsVal),
                          recordCount: stepsCount,
                          source: stepsSource,
                          cumulativeSubtitle: stepsSub,
                        ),
                        const SizedBox(width: NETokens.space8),
                        _buildNumericalMetricCard(
                          icon: Icons.straighten_rounded,
                          label: 'Distance',
                          valueText: _formatDistance(distVal),
                          recordCount: distCount,
                          source: distSource,
                          cumulativeSubtitle: distSub,
                        ),
                      ],
                    ),
                    const SizedBox(height: NETokens.space8),
                    Row(
                      children: [
                        _buildNumericalMetricCard(
                          icon: Icons.local_fire_department_rounded,
                          label: 'Active Cal',
                          valueText: _formatCalories(calVal),
                          recordCount: calCount,
                          source: calSource,
                          cumulativeSubtitle: calSub,
                        ),
                        const SizedBox(width: NETokens.space8),
                        _buildNumericalMetricCard(
                          icon: Icons.favorite_border_rounded,
                          label: 'Heart Rate',
                          valueText: _formatHeartRate(hrVal),
                          recordCount: hrCount,
                          source: hrSource,
                        ),
                      ],
                    ),
                    const SizedBox(height: NETokens.space8),
                    Row(
                      children: [
                        _buildNumericalMetricCard(
                          icon: Icons.bedtime_outlined,
                          label: 'Sleep',
                          valueText: _formatSleep(sleepVal),
                          recordCount: sleepCount,
                          source: sleepSource,
                        ),
                        const SizedBox(width: NETokens.space8),
                        const Expanded(child: SizedBox.shrink()),
                      ],
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      _buildNumericalMetricCard(
                        icon: Icons.directions_walk_rounded,
                        label: 'Steps',
                        valueText: _formatSteps(stepsVal),
                        recordCount: stepsCount,
                        source: stepsSource,
                        cumulativeSubtitle: stepsSub,
                      ),
                      const SizedBox(width: NETokens.space8),
                      _buildNumericalMetricCard(
                        icon: Icons.straighten_rounded,
                        label: 'Distance',
                        valueText: _formatDistance(distVal),
                        recordCount: distCount,
                        source: distSource,
                        cumulativeSubtitle: distSub,
                      ),
                    ],
                  ),
                  const SizedBox(height: NETokens.space8),
                  Row(
                    children: [
                      _buildNumericalMetricCard(
                        icon: Icons.local_fire_department_rounded,
                        label: 'Active Cal',
                        valueText: _formatCalories(calVal),
                        recordCount: calCount,
                        source: calSource,
                        cumulativeSubtitle: calSub,
                      ),
                      const SizedBox(width: NETokens.space8),
                      _buildNumericalMetricCard(
                        icon: Icons.favorite_border_rounded,
                        label: 'Heart Rate',
                        valueText: _formatHeartRate(hrVal),
                        recordCount: hrCount,
                        source: hrSource,
                      ),
                      const SizedBox(width: NETokens.space8),
                      _buildNumericalMetricCard(
                        icon: Icons.bedtime_outlined,
                        label: 'Sleep',
                        valueText: _formatSleep(sleepVal),
                        recordCount: sleepCount,
                        source: sleepSource,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: NETokens.space16),

          // Bottom Action: Sync Now or Grant Permissions
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSyncing
                  ? null
                  : (isDenied
                      ? () => notifier.requestPermissions()
                      : () => notifier.sync()),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDenied ? NETokens.botanicalTeal : NETokens.deepestForest,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(NETokens.radiusSm),
                ),
                elevation: 0,
              ),
              child: isSyncing
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      isDenied
                          ? 'Grant Health Permissions'
                          : (syncState.totalRecordsRead > 0 ? 'Sync Latest Health Data' : 'Connect & Sync Health'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(HealthSyncStateModel state) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (state.status) {
      case HealthSyncStatus.syncing:
        bg = NETokens.paleMint;
        fg = NETokens.deepestForest;
        label = 'Syncing';
        icon = Icons.sync_rounded;
        break;
      case HealthSyncStatus.synced:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF166534);
        label = state.isAuthenticated ? 'Cloud Synced' : 'Connected';
        icon = Icons.check_circle_outline_rounded;
        break;
      case HealthSyncStatus.permissionDenied:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        label = 'Access Needed';
        icon = Icons.shield_outlined;
        break;
      case HealthSyncStatus.unsupported:
        bg = const Color(0xFFF3F4F6);
        fg = const Color(0xFF4B5563);
        label = 'Unavailable';
        icon = Icons.info_outline_rounded;
        break;
      case HealthSyncStatus.error:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        label = 'Sync Error';
        icon = Icons.error_outline_rounded;
        break;
      case HealthSyncStatus.idle:
      case HealthSyncStatus.checkingPermissions:
      case HealthSyncStatus.requestingPermissions:
        bg = NETokens.surfaceContainer;
        fg = NETokens.onSurfaceVariant;
        label = 'Ready';
        icon = Icons.sensors_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(NETokens.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumericalMetricCard({
    required IconData icon,
    required String label,
    required String valueText,
    required int recordCount,
    required String source,
    String? cumulativeSubtitle,
  }) {
    final hasData = recordCount > 0;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: hasData ? NETokens.surfaceContainerLow : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(NETokens.radiusSm),
          border: Border.all(
            color: hasData ? NETokens.borderSubtle : const Color(0xFFEEEEEE),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: hasData ? NETokens.botanicalTeal : NETokens.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: hasData ? NETokens.deepestForest : NETokens.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              valueText,
              style: TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: hasData ? NETokens.deepestForest : const Color(0xFF9E9E9E),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (cumulativeSubtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                cumulativeSubtitle,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  color: NETokens.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    hasData ? '$recordCount rec' : 'No records',
                    style: TextStyle(
                      fontSize: 9,
                      color: hasData ? const Color(0xFF166534) : const Color(0xFF9E9E9E),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    source,
                    style: const TextStyle(
                      fontSize: 8,
                      color: NETokens.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatSteps(double? value) {
    if (value == null) return '0';
    return NumberFormat('#,###').format(value.toInt());
  }

  String _formatDistance(double? value) {
    if (value == null || value == 0.0) return '0.00 km';
    final km = value / 1000.0;
    return '${km.toStringAsFixed(2)} km';
  }

  String _formatCalories(double? value) {
    if (value == null || value == 0.0) return '0 kcal';
    return '${value.toStringAsFixed(0)} kcal';
  }

  String _formatHeartRate(double? value) {
    if (value == null || value == 0.0) return 'No monitor';
    return '${value.toStringAsFixed(0)} bpm';
  }

  String _formatSleep(double? value) {
    if (value == null || value == 0.0) return 'No log';
    final totalMinutes = value.toInt();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours == 0) return '${minutes}m';
    return '${hours}h ${minutes}m';
  }

  String _formatPlatformTitle(String platformName) {
    if (platformName.contains('android')) {
      return 'Android Health Connect';
    } else if (platformName.contains('apple')) {
      return 'Apple HealthKit';
    }
    return 'Native Health Provider';
  }

  String _formatSyncTimestamp(DateTime? timestamp) {
    if (timestamp == null) return 'Never synced';
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 2) {
      return 'Synced just now';
    } else if (diff.inHours < 1) {
      return 'Synced ${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return 'Synced today at ${DateFormat('h:mm a').format(timestamp)}';
    } else {
      return 'Synced ${DateFormat('MMM d, h:mm a').format(timestamp)}';
    }
  }
}

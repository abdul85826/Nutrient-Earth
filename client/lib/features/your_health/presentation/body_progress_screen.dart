import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/design_system/design_system.dart';
import '../data/health_repository.dart';
import '../domain/measurement.dart';

class BodyProgressScreen extends ConsumerWidget {
  const BodyProgressScreen({super.key});

  void _showExportDialog(BuildContext context, WidgetRef ref) async {
    final jsonReport = await ref
        .read(healthRepositoryProvider)
        .exportHealthReportJson();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NETokens.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NETokens.radiusLg),
          side: const BorderSide(color: NETokens.borderSubtle),
        ),
        title: Row(
          children: const [
            Icon(Icons.shield_outlined, color: NETokens.primary, size: 20),
            SizedBox(width: NETokens.space8),
            Text(
              'Secure Health Data Export',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This verified report includes your health profile and full measurement history. Sensitive metadata is scrubbed per HIPAA/GDPR data-rights specifications.',
                style: TextStyle(color: NETokens.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: NETokens.space12),
              Container(
                height: 180,
                padding: const EdgeInsets.all(NETokens.space8),
                decoration: BoxDecoration(
                  color: NETokens.surfaceElevated,
                  borderRadius: BorderRadius.circular(NETokens.radiusMd),
                  border: Border.all(color: NETokens.borderSubtle),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    jsonReport,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: NETokens.primaryLight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          NEButton(
            label: 'Copy JSON',
            icon: Icons.copy_rounded,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonReport));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Health report JSON copied to clipboard.'),
                  backgroundColor: NETokens.success,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(healthProfileProvider);
    final measurementsAsync = ref.watch(healthMeasurementsProvider);

    return ListView(
      padding: const EdgeInsets.all(NETokens.space16),
      children: [
        // Health Profile Overview Card
        profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text('Error: $err'),
          data: (profile) => NECard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: NETokens.primary.withOpacity(0.15),
                      child: const Icon(
                        Icons.person_rounded,
                        color: NETokens.primary,
                      ),
                    ),
                    const SizedBox(width: NETokens.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: NETokens.textPrimary,
                            ),
                          ),
                          Text(
                            '${profile.age} years • ${profile.biologicalSex} • ${profile.activityLevel}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: NETokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.file_download_outlined,
                        color: NETokens.primary,
                      ),
                      tooltip: 'Export Verified Health Report',
                      onPressed: () => _showExportDialog(context, ref),
                    ),
                  ],
                ),
                const SizedBox(height: NETokens.space16),
                const Text(
                  'Active Health Goals:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: NETokens.textMuted,
                  ),
                ),
                const SizedBox(height: NETokens.space8),
                Wrap(
                  spacing: NETokens.space8,
                  runSpacing: NETokens.space8,
                  children: profile.primaryGoals
                      .map(
                        (g) => NEChip(
                          label: g,
                          type: NEChipType.outline,
                          isSelected: true,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: NETokens.space16),

        // Causation vs Correlation Educational Callout
        Container(
          padding: const EdgeInsets.all(NETokens.space12),
          decoration: BoxDecoration(
            color: NETokens.secondary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(NETokens.radiusMd),
            border: Border.all(
              color: NETokens.secondary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: NETokens.secondaryLight,
              ),
              SizedBox(width: NETokens.space8),
              Expanded(
                child: Text(
                  'Scientific Interpretation Policy: Metric trends represent observational correlation rather than definitive clinical causation. Always confirm biomarker changes with clinical blood panels.',
                  style: TextStyle(
                    color: NETokens.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: NETokens.space20),

        // Section Title: Biomarkers & Vitals
        Row(
          children: const [
            Text(
              'Biomarkers & Vitals',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: NETokens.textPrimary,
              ),
            ),
            Spacer(),
            Text(
              'Tap for trends & provenance',
              style: TextStyle(fontSize: 12, color: NETokens.textMuted),
            ),
          ],
        ),

        const SizedBox(height: NETokens.space12),

        // Measurements List
        measurementsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text('Error loading measurements: $err'),
          data: (measurements) => Column(
            children: measurements
                .map((m) => _MeasurementCard(measurement: m))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _MeasurementCard extends StatefulWidget {
  final HealthMeasurement measurement;

  const _MeasurementCard({required this.measurement});

  @override
  State<_MeasurementCard> createState() => _MeasurementCardState();
}

class _MeasurementCardState extends State<_MeasurementCard> {
  bool _expanded = false;

  NEChipType _chipTypeForSource(DataSourceType type) {
    switch (type) {
      case DataSourceType.measured:
        return NEChipType.measured;
      case DataSourceType.userReported:
        return NEChipType.userReported;
      case DataSourceType.aiEstimated:
        return NEChipType.aiEstimated;
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.measurement;

    return Padding(
      padding: const EdgeInsets.only(bottom: NETokens.space12),
      child: NECard(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            m.metricName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: NETokens.textPrimary,
                            ),
                          ),
                          const SizedBox(width: NETokens.space8),
                          NEChip(
                            label: m.dataSource.displayName,
                            type: _chipTypeForSource(m.dataSource),
                          ),
                        ],
                      ),
                      const SizedBox(height: NETokens.space4),
                      Text(
                        'Category: ${m.category} • Target: ${m.targetValue} ${m.unit}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: NETokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${m.currentValue} ${m.unit}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: m.isInNormalRange
                            ? NETokens.primary
                            : NETokens.warning,
                      ),
                    ),
                    Text(
                      m.isInNormalRange
                          ? 'Within Normal Range'
                          : 'Out of Normal Range',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: m.isInNormalRange
                            ? NETokens.primaryLight
                            : NETokens.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (_expanded) ...[
              const SizedBox(height: NETokens.space16),
              const Divider(height: 1),
              const SizedBox(height: NETokens.space12),

              // Provenance / Note
              Text(
                'Data Provenance: ${m.dataSource.description}',
                style: const TextStyle(
                  fontSize: 11,
                  color: NETokens.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              if (m.note.isNotEmpty) ...[
                const SizedBox(height: NETokens.space4),
                Text(
                  'Clinical Note: ${m.note}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: NETokens.textMuted,
                  ),
                ),
              ],

              const SizedBox(height: NETokens.space16),

              // Trend Chart using fl_chart
              if (m.history.isNotEmpty)
                SizedBox(
                  height: 120,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: m.history.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              entry.value.value,
                            );
                          }).toList(),
                          isCurved: true,
                          color: NETokens.primary,
                          barWidth: 2.5,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: NETokens.primary.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

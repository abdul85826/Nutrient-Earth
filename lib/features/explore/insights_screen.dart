import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/engine_providers.dart';
import '../../shared/widgets/traceability_bottom_sheet.dart';
import 'package:intl/intl.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(observationTimelineProvider);

    return Scaffold(
      backgroundColor: NEColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Timeline', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: timelineAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return const _HonestEmptyState(
              icon: Icons.timeline,
              title: 'Your Biological Timeline',
              subtitle: 'Complete daily check-ins to start building your historical memory.',
            );
          }
          return _buildTimelineDashboard(events, context);
        },
        loading: () => const Center(child: CircularProgressIndicator(color: NEColors.accent)),
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }

  Widget _buildTimelineDashboard(List<Map<String, dynamic>> events, BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildObservationSourceBanner(),
        const SizedBox(height: 24),
        const Text(
          'Chronological Memory',
          style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'An immutable log of every biological event.',
          style: TextStyle(color: Colors.white38, fontSize: 11),
        ),
        const SizedBox(height: 16),
        ...events.map((e) => _buildEventCard(e, context)),
        const SizedBox(height: 32),
        _buildAIComingSoonBanner(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildObservationSourceBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NEColors.accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NEColors.accent.withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.history, color: NEColors.accent, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'This timeline represents your actual collected data. '
              'Phase 2 AI models will use this exact history to generate personalized insights.',
              style: TextStyle(color: NEColors.accent, fontSize: 11, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIComingSoonBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_outlined, color: Colors.white38, size: 16),
              SizedBox(width: 8),
              Text('Insight Engine — Phase 2', style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Nutrient Earth is currently in the data collection phase. '
            'Predictive modeling will unlock once sufficient baseline data is collected.',
            style: TextStyle(color: Colors.white24, fontSize: 11, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, BuildContext context) {
    final type = event['event_type'] as String? ?? 'unknown';
    final payload = event['payload'] as Map<String, dynamic>? ?? {};
    final confidence = event['confidence'] as double? ?? 1.0;
    
    DateTime? occurredAt;
    try {
      occurredAt = DateTime.parse(event['occurred_at'] as String);
    } catch (_) {}

    final dateStr = occurredAt != null ? DateFormat('MMM d, h:mm a').format(occurredAt) : 'Unknown time';

    IconData icon = Icons.event;
    Color color = Colors.white70;
    String title = 'Event';
    String description = payload.toString();

    if (type == 'daily_check_in') {
      icon = Icons.fact_check_outlined;
      color = NEColors.accent;
      title = 'Daily Check-In';
      description = 'Energy: ${payload['energy_level']}/10 • Stress: ${payload['stress_level']}/10\n'
                    'Mood: ${payload['mood_level']}/10 • Sleep: ${payload['sleep_quality']}/10';
    } else if (type == 'profile_update') {
      icon = Icons.manage_accounts_outlined;
      color = Colors.blueAccent;
      title = 'Profile Update';
      final keys = payload.keys.take(3).join(', ');
      description = 'Updated fields: $keys${payload.length > 3 ? '...' : ''}';
    }

    return GestureDetector(
      onTap: () {
        TraceabilityBottomSheet.show(
          context,
          observation: title,
          evidence: description,
          confidence: 'Local Data (${(confidence * 100).toInt()}% conf)',
          lastUpdated: dateStr,
          dataSource: 'IsarBiologicalEvent ($type)',
          missingInformation: '',
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: NEColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      Text(dateStr, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(description, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HonestEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _HonestEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white24, size: 56),
            const SizedBox(height: 20),
            Text(title,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle,
                style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

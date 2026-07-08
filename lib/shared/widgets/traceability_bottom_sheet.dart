import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TraceabilityBottomSheet extends StatelessWidget {
  final String observation;
  final String evidence;
  final String confidence;
  final String lastUpdated;
  final String dataSource;
  final String missingInformation;

  const TraceabilityBottomSheet({
    super.key,
    required this.observation,
    required this.evidence,
    required this.confidence,
    required this.lastUpdated,
    required this.dataSource,
    required this.missingInformation,
  });

  static void show(BuildContext context, {
    required String observation,
    required String evidence,
    required String confidence,
    required String lastUpdated,
    required String dataSource,
    required String missingInformation,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TraceabilityBottomSheet(
        observation: observation,
        evidence: evidence,
        confidence: confidence,
        lastUpdated: lastUpdated,
        dataSource: dataSource,
        missingInformation: missingInformation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: NEColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Why am I seeing this?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildRow('Observation', observation, isPrimary: true),
              const Divider(color: Colors.white12, height: 32),
              _buildRow('Evidence Base', evidence),
              const SizedBox(height: 16),
              _buildRow('Confidence Level', confidence, highlight: true),
              const SizedBox(height: 16),
              _buildRow('Data Source', dataSource),
              const SizedBox(height: 16),
              _buildRow('Last Updated', lastUpdated),
              if (missingInformation.isNotEmpty) ...[
                const Divider(color: Colors.white12, height: 32),
                _buildRow('Missing Information', missingInformation, isWarning: true),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isPrimary = false, bool highlight = false, bool isWarning = false}) {
    Color valueColor = Colors.white70;
    if (isPrimary) valueColor = Colors.white;
    if (highlight) valueColor = NEColors.accent;
    if (isWarning) valueColor = NEColors.statusRed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(color: NEColors.textTertiary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: isPrimary ? 16 : 14,
            fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w400,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

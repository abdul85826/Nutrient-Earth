import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system/design_system.dart';

class GrowthScreen extends ConsumerWidget {
  const GrowthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: NeTokens.warmIvory,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(NeTokens.spacing20),
          children: [
            const Text(
              'Biomarkers & Trajectories',
              style: TextStyle(
                fontFamily: NeTokens.fontFamilySerif,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: NeTokens.deepForest,
              ),
            ),
            const SizedBox(height: NeTokens.spacing6),
            const Text(
              'Longitudinal health memory tracking physiological adaptations and evidence adherence over time.',
              style: TextStyle(
                fontFamily: NeTokens.fontFamilySans,
                fontSize: 13,
                color: NeTokens.slateMuted,
              ),
            ),
            const SizedBox(height: NeTokens.spacing20),

            _buildMetricTile(
              label: 'Metabolic Flexibility Score',
              current: '92 / 100',
              trend: '+4.2% (Last 30d)',
              isPositive: true,
              detail: 'Stable fasting glucose proxy and steady energy distribution.',
            ),
            const SizedBox(height: NeTokens.spacing12),

            _buildMetricTile(
              label: 'Vascular Endothelial Compliance',
              current: '88 / 100',
              trend: '+2.1% (Last 30d)',
              isPositive: true,
              detail: 'Optimal urinary electrolyte ratios and dietary nitrate intake.',
            ),
            const SizedBox(height: NeTokens.spacing12),

            _buildMetricTile(
              label: 'Circadian Sleep Synchrony',
              current: '95 / 100',
              trend: '+6.5% (Last 30d)',
              isPositive: true,
              detail: 'Morning solar light calibration anchored deep restorative NREM cycles.',
            ),
            const SizedBox(height: NeTokens.spacing12),

            _buildMetricTile(
              label: 'Micronutrient Sufficiency Index',
              current: '90 / 100',
              trend: '+3.0% (Last 30d)',
              isPositive: true,
              detail: 'Key targets (Magnesium, Vitamin D, Zinc, Calcium) within target ranges.',
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String current,
    required String trend,
    required bool isPositive,
    required String detail,
  }) {
    return NeCard(
      padding: const EdgeInsets.all(NeTokens.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: NeTokens.fontFamilySans,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: NeTokens.deepForest,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPositive ? NeTokens.mossGreen.withValues(alpha: 0.12) : NeTokens.alertCrimson.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(NeTokens.radiusFull),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    fontFamily: NeTokens.fontFamilySans,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isPositive ? NeTokens.botanicalEvergreen : NeTokens.alertCrimson,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: NeTokens.spacing8),
          Text(
            current,
            style: const TextStyle(
              fontFamily: NeTokens.fontFamilySerif,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: NeTokens.deepForest,
            ),
          ),
          const SizedBox(height: NeTokens.spacing4),
          Text(
            detail,
            style: const TextStyle(
              fontFamily: NeTokens.fontFamilySans,
              fontSize: 12,
              color: NeTokens.slateMuted,
            ),
          ),
        ],
      ),
    );
  }
}

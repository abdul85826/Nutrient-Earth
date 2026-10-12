import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system/design_system.dart';

class BodyScreen extends ConsumerWidget {
  const BodyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: NeTokens.warmIvory,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(NeTokens.spacing20),
          children: [
            const Text(
              'Digital Physiological Systems',
              style: TextStyle(
                fontFamily: NeTokens.fontFamilySerif,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: NeTokens.deepForest,
              ),
            ),
            const SizedBox(height: NeTokens.spacing6),
            const Text(
              'Real-time organ system integrity mapped to current nutritional saturation and environmental telemetry.',
              style: TextStyle(
                fontFamily: NeTokens.fontFamilySans,
                fontSize: 13,
                color: NeTokens.slateMuted,
              ),
            ),
            const SizedBox(height: NeTokens.spacing20),

            _buildSystemCard(
              title: 'Metabolic & Hepatic Network',
              status: 'Optimal Homeostasis',
              score: '94%',
              icon: Icons.bubble_chart_outlined,
              details: 'Glycogen replenishment nominal; insulin sensitivity stabilized via regular meal intervals.',
            ),
            const SizedBox(height: NeTokens.spacing12),

            _buildSystemCard(
              title: 'Cardiovascular & Endothelial',
              status: 'Stable Compliance',
              score: '91%',
              icon: Icons.favorite_border_rounded,
              details: 'Vascular nitric oxide synthesis supported by balanced dietary nitrates and potassium intake.',
            ),
            const SizedBox(height: NeTokens.spacing12),

            _buildSystemCard(
              title: 'Musculoskeletal Integrity',
              status: 'Adaptation Phase',
              score: '88%',
              icon: Icons.fitness_center_rounded,
              details: 'Amino acid pool adequate for myofibrillar repair; calcium homeostasis maintained.',
            ),
            const SizedBox(height: NeTokens.spacing12),

            _buildSystemCard(
              title: 'Neuro-Endocrine & Circadian',
              status: 'High Synchrony',
              score: '96%',
              icon: Icons.wb_sunny_outlined,
              details: 'Daylight photon exposure aligns melatonin suppression curve for evening restorative sleep.',
            ),
            const SizedBox(height: NeTokens.spacing12),

            _buildSystemCard(
              title: 'Immune & Mucosal Barrier',
              status: 'Active Defense',
              score: '92%',
              icon: Icons.shield_outlined,
              details: 'Gut microbiome short-chain fatty acid synthesis supported by fermentable plant prebiotic fibers.',
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemCard({
    required String title,
    required String status,
    required String score,
    required IconData icon,
    required String details,
  }) {
    return NeCard(
      padding: const EdgeInsets.all(NeTokens.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(NeTokens.spacing8),
                decoration: BoxDecoration(
                  color: NeTokens.botanicalEvergreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(NeTokens.radius10),
                ),
                child: Icon(icon, color: NeTokens.botanicalEvergreen, size: 20),
              ),
              const SizedBox(width: NeTokens.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: NeTokens.fontFamilySans,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: NeTokens.deepForest,
                      ),
                    ),
                    Text(
                      status,
                      style: const TextStyle(
                        fontFamily: NeTokens.fontFamilySans,
                        fontSize: 12,
                        color: NeTokens.mossGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                score,
                style: const TextStyle(
                  fontFamily: NeTokens.fontFamilySerif,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: NeTokens.deepForest,
                ),
              ),
            ],
          ),
          const SizedBox(height: NeTokens.spacing10),
          Text(
            details,
            style: const TextStyle(
              fontFamily: NeTokens.fontFamilySans,
              fontSize: 12,
              color: NeTokens.slateMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

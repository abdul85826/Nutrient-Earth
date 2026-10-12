import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';

/// Evidence-based protocol definition
class EvidenceProtocol {
  final String id;
  final String title;
  final String timing;
  final String biologicalMechanism;
  final String researchQuery;

  const EvidenceProtocol({
    required this.id,
    required this.title,
    required this.timing,
    required this.biologicalMechanism,
    required this.researchQuery,
  });
}

const List<EvidenceProtocol> kStandardEvidenceProtocols = [
  EvidenceProtocol(
    id: 'circadian_lux',
    title: 'Circadian Solar Photon Exposure',
    timing: 'Within 60 min of waking (15–20 min)',
    biologicalMechanism:
        'Stimulates retinal intrinsically photosensitive ganglion cells (ipRGCs) to synchronize the suprachiasmatic nucleus (SCN), anchoring cortisol awakening response and nocturnal melatonin synthesis.',
    researchQuery:
        'Circadian photobiology suprachiasmatic nucleus solar light melatonin',
  ),
  EvidenceProtocol(
    id: 'morning_hydration',
    title: 'Electrolyte & Fluid Restoration',
    timing: 'Upon waking (500 mL)',
    biologicalMechanism:
        'Restores vascular volume and renal perfusion after overnight transepidermal and respiratory water loss with balanced sodium/potassium cellular osmolarity.',
    researchQuery:
        'Dehydration cognitive performance vascular endothelial response',
  ),
  EvidenceProtocol(
    id: 'protein_pacing',
    title: 'Complete Protein Bolus (≥30g)',
    timing: 'First meal of the day',
    biologicalMechanism:
        'Exceeds the leucine trigger threshold (~2.7–3g leucine) to initiate mTORC1 signaling and stimulate myofibrillar protein synthesis.',
    researchQuery:
        'Dietary protein distribution myofibrillar protein synthesis leucine trigger',
  ),
  EvidenceProtocol(
    id: 'postprandial_walk',
    title: 'Postprandial Muscular Ambulation',
    timing: '10–20 min after carbohydrate meal',
    biologicalMechanism:
        'Triggers non-insulin-dependent GLUT4 translocation in contracting skeletal muscle, blunting postprandial glucose excursions and reactive insulin spikes.',
    researchQuery:
        'Postprandial walking glucose excursion muscle contraction GLUT4',
  ),
  EvidenceProtocol(
    id: 'evening_attenuation',
    title: 'Blue Spectrum Light Attenuation',
    timing: '90 min before planned sleep',
    biologicalMechanism:
        'Prevents acute melanopsin-mediated melatonin suppression, facilitating physiological sleep latency and deep slow-wave restorative NREM cycles.',
    researchQuery: 'Blue light melanopsin pineal melatonin sleep architecture',
  ),
];

/// State provider for tracking protocol completion for today
final protocolCompletionProvider =
    StateNotifierProvider<ProtocolCompletionNotifier, Set<String>>((ref) {
      return ProtocolCompletionNotifier();
    });

class ProtocolCompletionNotifier extends StateNotifier<Set<String>> {
  ProtocolCompletionNotifier() : super({});

  void toggleProtocol(String id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }

  void resetAll() {
    state = {};
  }
}

class GrowthScreen extends ConsumerWidget {
  const GrowthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedSet = ref.watch(protocolCompletionProvider);
    final completedCount = completedSet.length;
    final totalCount = kStandardEvidenceProtocols.length;

    return Scaffold(
      backgroundColor: NeTokens.warmIvory,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(NeTokens.spacing20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Growth & Habits',
                        style: TextStyle(
                          fontFamily: NeTokens.fontFamilySerif,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: NeTokens.deepForest,
                        ),
                      ),
                      SizedBox(height: NeTokens.spacing4),
                      Text(
                        'Evidence-based protocol adherence and longitudinal health memory.',
                        style: TextStyle(
                          fontFamily: NeTokens.fontFamilySans,
                          fontSize: 13,
                          color: NeTokens.slateMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Account & Data Rights',
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: NeTokens.deepForest,
                  ),
                  onPressed: () => context.push('/settings'),
                ),
              ],
            ),
            const SizedBox(height: NeTokens.spacing16),

            // Truth in Health Telemetry Notice
            Container(
              padding: const EdgeInsets.all(NeTokens.spacing12),
              decoration: BoxDecoration(
                color: NeTokens.pureWhite,
                borderRadius: BorderRadius.circular(NeTokens.radius12),
                border: Border.all(color: NeTokens.sandDune),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.sensors_off_outlined,
                    color: NeTokens.mossGreen,
                    size: 20,
                  ),
                  SizedBox(width: NeTokens.spacing10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Passive Sensors Disconnected',
                          style: TextStyle(
                            fontFamily: NeTokens.fontFamilySans,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: NeTokens.deepForest,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Nutrient Earth rejects simulated metrics and fake live scores. No Apple HealthKit or Health Connect wearables are currently connected. Protocol adherence below reflects your verified daily actions.',
                          style: TextStyle(
                            fontFamily: NeTokens.fontFamilySans,
                            fontSize: 11,
                            color: NeTokens.slateMuted,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: NeTokens.spacing20),

            // Adherence Progress Card
            NeCard(
              padding: const EdgeInsets.all(NeTokens.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Today’s Protocol Adherence',
                        style: TextStyle(
                          fontFamily: NeTokens.fontFamilySans,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: NeTokens.deepForest,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: completedCount == totalCount
                              ? NeTokens.mossGreen.withValues(alpha: 0.15)
                              : NeTokens.sandDune.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(
                            NeTokens.radiusFull,
                          ),
                        ),
                        child: Text(
                          '$completedCount of $totalCount completed',
                          style: TextStyle(
                            fontFamily: NeTokens.fontFamilySans,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: completedCount == totalCount
                                ? NeTokens.botanicalEvergreen
                                : NeTokens.deepForest,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: NeTokens.spacing12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(NeTokens.radiusFull),
                    child: LinearProgressIndicator(
                      value: totalCount > 0 ? completedCount / totalCount : 0.0,
                      backgroundColor: NeTokens.sandDune.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        NeTokens.botanicalEvergreen,
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: NeTokens.spacing20),

            // Protocols Section
            const Text(
              'Evidence Protocols',
              style: TextStyle(
                fontFamily: NeTokens.fontFamilySerif,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: NeTokens.deepForest,
              ),
            ),
            const SizedBox(height: NeTokens.spacing8),

            ...kStandardEvidenceProtocols.map((protocol) {
              final isDone = completedSet.contains(protocol.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: NeTokens.spacing12),
                child: NeCard(
                  padding: const EdgeInsets.all(NeTokens.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: isDone,
                            activeColor: NeTokens.botanicalEvergreen,
                            onChanged: (_) {
                              ref
                                  .read(protocolCompletionProvider.notifier)
                                  .toggleProtocol(protocol.id);
                            },
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  protocol.title,
                                  style: TextStyle(
                                    fontFamily: NeTokens.fontFamilySans,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: NeTokens.deepForest,
                                    decoration: isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Timing: ${protocol.timing}',
                                  style: const TextStyle(
                                    fontFamily: NeTokens.fontFamilySans,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: NeTokens.mossGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: NeTokens.spacing8),
                      Padding(
                        padding: const EdgeInsets.only(left: 48),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              protocol.biologicalMechanism,
                              style: const TextStyle(
                                fontFamily: NeTokens.fontFamilySans,
                                fontSize: 12,
                                color: NeTokens.slateMuted,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: NeTokens.spacing10),
                            InkWell(
                              onTap: () {
                                context.push(
                                  '/research?q=${Uri.encodeComponent(protocol.researchQuery)}',
                                );
                              },
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.biotech_outlined,
                                    size: 14,
                                    color: NeTokens.botanicalEvergreen,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Research Scientific Mechanism →',
                                    style: TextStyle(
                                      fontFamily: NeTokens.fontFamilySans,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: NeTokens.botanicalEvergreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: NeTokens.spacing16),

            // Honest Biomarker Empty State
            NeCard(
              padding: const EdgeInsets.all(NeTokens.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        color: NeTokens.deepForest,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Longitudinal Biomarkers',
                        style: TextStyle(
                          fontFamily: NeTokens.fontFamilySans,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: NeTokens.deepForest,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: NeTokens.spacing8),
                  const Text(
                    'No clinical laboratory records (lipids, hs-CRP, metabolic panels) have been logged. When you upload or record laboratory panels, verified trends and reference ranges will be documented here without speculative extrapolations.',
                    style: TextStyle(
                      fontFamily: NeTokens.fontFamilySans,
                      fontSize: 12,
                      color: NeTokens.slateMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: NeTokens.spacing12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: NeTokens.deepForest,
                      side: const BorderSide(color: NeTokens.sandDune),
                    ),
                    icon: const Icon(Icons.add_circle_outline, size: 16),
                    label: const Text('Analyze Lab Panel in Ask Workspace'),
                    onPressed: () {
                      context.push(
                        '/research?q=${Uri.encodeComponent("Analyze comprehensive metabolic panel biomarkers and clinical reference ranges")}',
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

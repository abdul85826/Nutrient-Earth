import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/intelligence/product_intelligence_catalog.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const evidenceList = ProductIntelligenceCatalog.scientificEvidence;

    return Scaffold(
      backgroundColor: NeTokens.warmIvory,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(NeTokens.spacing20),
          children: [
            const Text(
              'Evidence & Nutrient Explorer',
              style: TextStyle(
                fontFamily: NeTokens.fontFamilySerif,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: NeTokens.deepForest,
              ),
            ),
            const SizedBox(height: NeTokens.spacing6),
            const Text(
              'Search peer-reviewed clinical studies, bioavailability indices, and verified botanical research.',
              style: TextStyle(
                fontFamily: NeTokens.fontFamilySans,
                fontSize: 13,
                color: NeTokens.slateMuted,
              ),
            ),
            const SizedBox(height: NeTokens.spacing16),

            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  NeChip(
                    label: 'All Clinical Trials',
                    isSelected: true,
                    onTap: () {},
                  ),
                  const SizedBox(width: NeTokens.spacing8),
                  NeChip(
                    label: 'Proteins & Amino Acids',
                    onTap: () => context.push('/research?q=Pea protein vs whey protein'),
                  ),
                  const SizedBox(width: NeTokens.spacing8),
                  NeChip(
                    label: 'Minerals & Electrolytes',
                    onTap: () => context.push('/research?q=Magnesium glycinate'),
                  ),
                  const SizedBox(width: NeTokens.spacing8),
                  NeChip(
                    label: 'Vitamins & Cofactors',
                    onTap: () => context.push('/research?q=Vitamin D3 K2 absorption'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: NeTokens.spacing20),

            const Text(
              'Verified Peer-Reviewed Catalog',
              style: TextStyle(
                fontFamily: NeTokens.fontFamilySerif,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: NeTokens.deepForest,
              ),
            ),
            const SizedBox(height: NeTokens.spacing10),

            ...evidenceList.map((ev) => Padding(
              padding: const EdgeInsets.only(bottom: NeTokens.spacing12),
              child: InkWell(
                onTap: () => context.push('/research?q=${ev.title}'),
                borderRadius: BorderRadius.circular(NeTokens.radius16),
                child: NeCard(
                  padding: const EdgeInsets.all(NeTokens.spacing14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: NeTokens.mossGreen.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(NeTokens.radiusFull),
                            ),
                            child: Text(
                              ev.studyType,
                              style: const TextStyle(
                                fontFamily: NeTokens.fontFamilySans,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: NeTokens.botanicalEvergreen,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Score: ${(ev.qualityScore * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontFamily: NeTokens.fontFamilySans,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: NeTokens.mossGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: NeTokens.spacing8),
                      Text(
                        ev.title,
                        style: const TextStyle(
                          fontFamily: NeTokens.fontFamilySans,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: NeTokens.deepForest,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${ev.authors} (${ev.year}) — ${ev.source}',
                        style: const TextStyle(
                          fontFamily: NeTokens.fontFamilySans,
                          fontSize: 11,
                          color: NeTokens.slateMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ev.keyFinding,
                        style: const TextStyle(
                          fontFamily: NeTokens.fontFamilySans,
                          fontSize: 12,
                          color: NeTokens.deepForest,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

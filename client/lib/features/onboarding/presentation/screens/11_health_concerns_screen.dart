// ==============================================================================
// Nutrient Earth — Screen 11: Health Focus & Priorities (Stitch Ref: screen_11_what_would_you_like_help_with)
// Phase 2: Step 3 of 8. Synchronized goal prioritization carrying forward Step 04 selections
// with informative synchronization banner, toggling, and returnTo support.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../state/onboarding_journey_state.dart';

class HealthConcernsScreen extends ConsumerWidget {
  final String? returnTo;

  const HealthConcernsScreen({super.key, this.returnTo});

  static const List<Map<String, String>> _concernsCatalog = [
    {'title': 'Energy & Vitality Optimization', 'desc': 'Cellular mitochondrial output and daytime alertness', 'code': 'PRI-01'},
    {'title': 'Digestive & Gut Sensitivity', 'desc': 'Microbiome balance, bloating reduction, barrier integrity', 'code': 'GUT-04'},
    {'title': 'Improve sleep quality', 'desc': 'Circadian rhythm alignment and restorative deep sleep', 'code': 'SLP-02'},
    {'title': 'Build consistent daily movement', 'desc': 'Habitual physical activity and metabolic pacing', 'code': 'MOV-01'},
    {'title': 'Support healthy blood sugar', 'desc': 'Glycemic stabilization and sustained insulin sensitivity', 'code': 'MET-02'},
    {'title': 'Reduce everyday stress', 'desc': 'Parasympathetic activation and nervous system recovery', 'code': 'STR-03'},
    {'title': 'Cardiovascular endurance', 'desc': 'Aerobic capacity, stroke volume, and stamina', 'code': 'CRD-06'},
  ];

  void _handleContinue(BuildContext context) {
    if (returnTo != null && returnTo!.isNotEmpty) {
      context.go('/onboarding/$returnTo');
    } else {
      context.go('/onboarding/food-restrictions');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingJourneyProvider);
    final notifier = ref.read(onboardingJourneyProvider.notifier);

    return Scaffold(
      backgroundColor: NETokens.background,
      appBar: AppBar(
        backgroundColor: NETokens.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: NETokens.darkEvergreen),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/onboarding/body-measurements');
            }
          },
        ),
        title: Column(
          children: [
            Text(
              'STEP 3 OF 9 • SOIL PROFILE',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: NETokens.botanicalTeal,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Health Focus',
              style: GoogleFonts.manrope(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: NETokens.darkEvergreen,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: NETokens.surfaceContainer,
                            borderRadius: BorderRadius.circular(NETokens.radiusFull),
                          ),
                          child: Text(
                            'STAGE 11 • HEALTH PRIORITIES',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: NETokens.darkEvergreen,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'What would you like help with?',
                          style: GoogleFonts.manrope(
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            color: NETokens.darkEvergreen,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Confirm or adjust your primary target areas so we can prioritize relevant research and habits.',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: NETokens.textSecondary,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Pre-selected Sync Banner
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: NETokens.paleMint.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFC0E5CB)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.sync_rounded, size: 18, color: NETokens.deepestForest),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Pre-selected from your earlier answers. Confirm or adjust your primary target areas.',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: NETokens.deepestForest,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Cards List
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _concernsCatalog.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, idx) {
                            final item = _concernsCatalog[idx];
                            final title = item['title']!;
                            final desc = item['desc']!;
                            final code = item['code']!;
                            final isSelected = state.prioritizedConcerns.contains(title);

                            return InkWell(
                              onTap: () => notifier.togglePrioritizedConcern(title),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected ? NETokens.paleMint.withValues(alpha: 0.5) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? NETokens.emerald : NETokens.borderDefault,
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                  boxShadow: NETokens.cardShadow,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      margin: const EdgeInsets.only(top: 2),
                                      decoration: BoxDecoration(
                                        color: isSelected ? NETokens.darkEvergreen : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isSelected ? NETokens.darkEvergreen : NETokens.borderDefault,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: isSelected ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  title,
                                                  style: GoogleFonts.manrope(
                                                    fontSize: 15,
                                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                                    color: NETokens.primary,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                code,
                                                style: GoogleFonts.jetBrainsMono(fontSize: 10, color: NETokens.textMuted),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            desc,
                                            style: GoogleFonts.manrope(fontSize: 12.5, color: NETokens.textSecondary, height: 1.35),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Action Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: NETokens.borderDefault)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _handleContinue(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NETokens.darkEvergreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue',
                            style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


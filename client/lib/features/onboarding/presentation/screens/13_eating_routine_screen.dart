// ==============================================================================
// Nutrient Earth — Screen 13: Eating Routine (Stitch Ref: screen_13_what_does_your_eating_routine_look_like)
// Phase 2: Step 5 of 8. Single-select eating cadence cards, circadian timing
// alignment, skip support, and returnTo integration.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../state/onboarding_journey_state.dart';

class EatingRoutineScreen extends ConsumerWidget {
  final String? returnTo;

  const EatingRoutineScreen({super.key, this.returnTo});

  static const List<Map<String, String>> _routines = [
    {
      'id': 'regular',
      'title': 'Regular schedule',
      'desc': 'Consistent breakfast, lunch, and dinner at predictable times each day',
    },
    {
      'id': 'intuitive',
      'title': 'Intuitive / when hungry',
      'desc': 'Flexible eating windows guided naturally by internal appetite cues',
    },
    {
      'id': 'intermittent_fasting',
      'title': 'Intermittent fasting',
      'desc': 'Structured time-restricted eating window (e.g. 16:8, 14:10, or one meal a day)',
    },
    {
      'id': 'grazing',
      'title': 'Grazing / frequent small meals',
      'desc': 'Multiple lighter meals, snacks, and continuous fueling throughout the day',
    },
    {
      'id': 'shift_work',
      'title': 'Shift-work / irregular schedule',
      'desc': 'Changing shifts, night work, travel, or rotating daily sleep-wake cadences',
    },
  ];

  void _handleContinue(BuildContext context) {
    if (returnTo != null && returnTo!.isNotEmpty) {
      context.go('/onboarding/$returnTo');
    } else {
      context.go('/onboarding/daily-activity');
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
              context.go('/onboarding/food-restrictions');
            }
          },
        ),
        title: Column(
          children: [
            Text(
              'STEP 10 OF 14 • SOIL PROFILE',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: NETokens.botanicalTeal,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Eating Routine',
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
                            'STAGE 13 • MEAL CADENCE',
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
                          'What does your eating routine look like?',
                          style: GoogleFonts.manrope(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: NETokens.darkEvergreen,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Understanding when and how you eat helps align recommendations with your natural circadian rhythm.',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: NETokens.textSecondary,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 20),

                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _routines.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, idx) {
                            final item = _routines[idx];
                            final id = item['id']!;
                            final isSelected = state.eatingRoutine == id;

                            return InkWell(
                              onTap: () => notifier.setEatingRoutine(id),
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
                                        shape: BoxShape.circle,
                                        color: isSelected ? NETokens.darkEvergreen : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected ? NETokens.darkEvergreen : NETokens.borderDefault,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: isSelected
                                          ? Center(
                                              child: Container(
                                                width: 8,
                                                height: 8,
                                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['title']!,
                                            style: GoogleFonts.manrope(
                                              fontSize: 15,
                                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                              color: NETokens.primary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item['desc']!,
                                            style: GoogleFonts.manrope(
                                              fontSize: 12.5,
                                              color: NETokens.textSecondary,
                                              height: 1.35,
                                            ),
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

                        const SizedBox(height: 20),

                        // Circadian science callout
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: NETokens.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: NETokens.borderDefault),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.wb_sunny_outlined, size: 20, color: NETokens.botanicalTeal),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Circadian Nutrition: Meal timing interacts with your body\'s peripheral clocks, influencing insulin sensitivity, digestion, and nighttime recovery.',
                                  style: GoogleFonts.manrope(fontSize: 12, color: NETokens.textSecondary, height: 1.45),
                                ),
                              ),
                            ],
                          ),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
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
                      const SizedBox(height: 6),
                      TextButton(
                        onPressed: () => _handleContinue(context),
                        child: Text(
                          'Skip this step for now',
                          style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w600, color: NETokens.botanicalTeal),
                        ),
                      ),
                    ],
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


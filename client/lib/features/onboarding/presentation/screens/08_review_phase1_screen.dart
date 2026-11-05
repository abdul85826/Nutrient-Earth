// ==============================================================================
// Nutrient Earth — Screen 08: Review Health Profile Checkpoint (Stitch Ref: screen_08_review_your_health_profile_refined_typography_clear_logo)
// Phase 1: Step 5 of 5. Synthesizes Phase 1 answers with live deep-link [Edit] jumps
// that return directly to this review screen, honest fallback states, and transition to Phase 2.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../state/onboarding_journey_state.dart';

class ReviewPhase1Screen extends ConsumerWidget {
  const ReviewPhase1Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingJourneyProvider);

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
              context.go('/onboarding/food-choices');
            }
          },
        ),
        title: Column(
          children: [
            Text(
              'STEP 5 OF 14 • REVIEW',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: NETokens.botanicalTeal,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Phase 1 Milestone',
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
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Phase 1 100% Progress Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: NETokens.surfaceContainer,
                                  borderRadius: BorderRadius.circular(NETokens.radiusFull),
                                ),
                                child: Text(
                                  'STAGE 08 • PROFILE VERIFICATION',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    color: NETokens.darkEvergreen,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Phase 1 · 100%',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: NETokens.emerald,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(5, (idx) {
                            return Expanded(
                              child: Container(
                                height: 4,
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  color: NETokens.emerald,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          'Your health profile',
                          style: GoogleFonts.manrope(
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            color: NETokens.darkEvergreen,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Let\'s review your answers before we personalize your daily bio-individual experience.',
                          style: GoogleFonts.manrope(
                            fontSize: 13.5,
                            color: NETokens.textSecondary,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Section 1: Health Goals
                        _buildReviewSection(
                          context,
                          title: 'Your health concerns',
                          icon: Icons.track_changes_rounded,
                          onEdit: () => context.go('/onboarding/health-goals?returnTo=review-phase1'),
                          content: state.healthGoals.isEmpty
                              ? _buildEmptyRow('No goals selected (skipped)')
                              : Column(
                                  children: state.healthGoals.map((g) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: NETokens.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.check_circle_rounded, size: 16, color: NETokens.botanicalTeal),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              g,
                                              style: GoogleFonts.manrope(fontSize: 13.5, fontWeight: FontWeight.w600, color: NETokens.primary),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ),

                        const SizedBox(height: 14),

                        // Section 2: Difficulties
                        _buildReviewSection(
                          context,
                          title: 'Your difficulties',
                          icon: Icons.monitor_heart_outlined,
                          onEdit: () => context.go('/onboarding/difficulties?returnTo=review-phase1'),
                          content: state.difficulties.isEmpty
                              ? _buildEmptyRow('No functional difficulties reported')
                              : Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: state.difficulties.map((code) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: NETokens.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: NETokens.borderDefault),
                                      ),
                                      child: Text(
                                        code,
                                        style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w700, color: NETokens.deepestForest),
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ),

                        const SizedBox(height: 14),

                        // Section 3: Daily Impact
                        _buildReviewSection(
                          context,
                          title: 'How these difficulties affect you',
                          icon: Icons.speed_rounded,
                          onEdit: () => context.go('/onboarding/daily-impact?returnTo=review-phase1'),
                          content: state.dailyImpacts.isEmpty
                              ? _buildEmptyRow('Impact ratings skipped')
                              : Column(
                                  children: state.dailyImpacts.entries.map((e) {
                                    final pct = (e.value / 4.0).clamp(0.0, 1.0);
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(e.key, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w600)),
                                              Text('Rating ${e.value} of 4', style: GoogleFonts.manrope(fontSize: 11, color: NETokens.textSecondary)),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          LinearProgressIndicator(
                                            value: pct,
                                            backgroundColor: NETokens.surfaceContainerLow,
                                            valueColor: const AlwaysStoppedAnimation(NETokens.botanicalTeal),
                                            minHeight: 5,
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ),

                        const SizedBox(height: 14),

                        // Section 4: Food Preferences
                        _buildReviewSection(
                          context,
                          title: 'Your food preferences',
                          icon: Icons.restaurant_rounded,
                          onEdit: () => context.go('/onboarding/food-choices?returnTo=review-phase1'),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('Dietary Pattern: ', style: GoogleFonts.manrope(fontSize: 12.5, fontWeight: FontWeight.w500, color: NETokens.textSecondary)),
                                  Text(state.dietaryPattern.toUpperCase(), style: GoogleFonts.jetBrainsMono(fontSize: 12.5, fontWeight: FontWeight.w700, color: NETokens.darkEvergreen)),
                                ],
                              ),
                              if (state.foodIntolerances.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: state.foodIntolerances.map((i) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: NETokens.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(i, style: GoogleFonts.manrope(fontSize: 11.5, color: NETokens.primary)),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
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
                      onPressed: () {
                        ref.read(onboardingJourneyProvider.notifier).setPhase1Reviewed(true);
                        context.go('/onboarding/personal-details');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NETokens.darkEvergreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              'Continue to Personal Details',
                              style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis,
                            ),
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

  Widget _buildReviewSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onEdit,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: NETokens.borderDefault),
        boxShadow: NETokens.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: NETokens.botanicalTeal),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700, color: NETokens.darkEvergreen),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined, size: 14, color: NETokens.botanicalTeal),
                      const SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: GoogleFonts.manrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: NETokens.botanicalTeal),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildEmptyRow(String text) {
    return Text(
      text,
      style: GoogleFonts.manrope(fontSize: 12.5, color: NETokens.textMuted, fontStyle: FontStyle.italic),
    );
  }
}


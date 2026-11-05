// ==============================================================================
// Nutrient Earth — Screen 17: Onboarding Completion (Stitch Ref: screen_17_your_journey_starts_here)
// Authentic summary of calibrated parameters, PostgREST atomic persistence to Supabase,
// offline resilience, and transition to Screen 18 (Today).
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/profile_repository.dart';
import '../../../../core/services/task_repository.dart';
import '../../../today/state/today_state.dart';
import '../../state/onboarding_journey_state.dart';

class CompletionScreen extends ConsumerWidget {
  const CompletionScreen({super.key});

  Future<void> _handleComplete(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(onboardingJourneyProvider.notifier);
    final auth = ref.read(authServiceProvider);
    final profileRepo = ref.read(profileRepositoryProvider);
    final taskRepo = ref.read(taskRepositoryProvider);

    final success = await notifier.saveAndComplete(
      auth: auth,
      profileRepo: profileRepo,
      taskRepo: taskRepo,
    );

    if (success && context.mounted) {
      // Reload Today Screen state with authentic user profile and fresh tasks
      final todayNotifier = ref.read(todayStateProvider.notifier);
      await todayNotifier.loadUserProfile();
      await todayNotifier.loadDailyTasks();
      await todayNotifier.refreshTelemetry();

      if (context.mounted) {
        context.go('/today');
      }
    }
  }

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
              context.go('/onboarding/knowledge-level');
            }
          },
        ),
        title: Column(
          children: [
            Text(
              'STEP 14 OF 14 • PROFILE COMPLETE',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: NETokens.botanicalTeal,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Your Journey Starts Here',
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: NETokens.surfaceContainer,
                            borderRadius: BorderRadius.circular(NETokens.radiusFull),
                          ),
                          child: Text(
                            'STAGE 17 • ONBOARDING COMPLETION',
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
                          'Your journey starts here',
                          style: GoogleFonts.manrope(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: NETokens.darkEvergreen,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Welcome, ${state.firstName}. Your biological baseline is calibrated. Here is how Nutrient Earth will personalize your daily experience.',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: NETokens.textSecondary,
                            height: 1.45,
                          ),
                        ),

                        if (state.saveError != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: NETokens.error.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: NETokens.error.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, size: 20, color: NETokens.error),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    state.saveError!,
                                    style: GoogleFonts.manrope(fontSize: 12.5, color: NETokens.error, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Section 1: Primary Focus
                        _buildSummaryCard(
                          context,
                          title: 'Primary Health Focus',
                          icon: Icons.track_changes_rounded,
                          onEdit: () => context.go('/onboarding/health-concerns?returnTo=completion'),
                          content: state.prioritizedConcerns.isEmpty
                              ? Text('General wellness baseline', style: GoogleFonts.manrope(fontSize: 13, color: NETokens.textMuted))
                              : Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: state.prioritizedConcerns.map((c) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: NETokens.paleMint.withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFC0E5CB)),
                                      ),
                                      child: Text(
                                        c,
                                        style: GoogleFonts.manrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: NETokens.deepestForest),
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ),

                        const SizedBox(height: 14),

                        // Section 2: Dietary Baseline
                        _buildSummaryCard(
                          context,
                          title: 'Dietary Baseline & Preferences',
                          icon: Icons.restaurant_rounded,
                          onEdit: () => context.go('/onboarding/food-choices?returnTo=completion'),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pattern: ${state.dietaryPattern.toUpperCase()}',
                                style: GoogleFonts.jetBrainsMono(fontSize: 12.5, fontWeight: FontWeight.w700, color: NETokens.darkEvergreen),
                              ),
                              if (state.foodIntolerances.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Intolerances: ${state.foodIntolerances.join(", ")}',
                                  style: GoogleFonts.manrope(fontSize: 12, color: NETokens.textSecondary),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Section 3: Safety & Exclusions
                        _buildSummaryCard(
                          context,
                          title: 'Clinical Safety & Exclusions',
                          icon: Icons.health_and_safety_rounded,
                          onEdit: () => context.go('/onboarding/food-restrictions?returnTo=completion'),
                          content: state.strictlyNoRestrictions
                              ? Text('No mandatory medical food restrictions declared', style: GoogleFonts.manrope(fontSize: 12.5, color: NETokens.botanicalTeal, fontWeight: FontWeight.w600))
                              : Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: state.allergens.map((a) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFDAD6),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.shield_rounded, size: 12, color: Color(0xFFBA1A1A)),
                                          const SizedBox(width: 4),
                                          Text(
                                            a,
                                            style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF93000A)),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ),

                        const SizedBox(height: 14),

                        // Section 4: Daily Cadence
                        _buildSummaryCard(
                          context,
                          title: 'Daily Cadence & Physiology',
                          icon: Icons.schedule_rounded,
                          onEdit: () => context.go('/onboarding/daily-activity?returnTo=completion'),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Movement: ${state.activityLevel.toUpperCase()}', style: GoogleFonts.manrope(fontSize: 12.5, color: NETokens.primary, fontWeight: FontWeight.w600)),
                              Text('Sleep Architecture: ${state.sleepQuality.replaceAll("_", " ").toUpperCase()}', style: GoogleFonts.manrope(fontSize: 12.5, color: NETokens.textSecondary)),
                              Text('Eating Cadence: ${state.eatingRoutine.replaceAll("_", " ").toUpperCase()}', style: GoogleFonts.manrope(fontSize: 12.5, color: NETokens.textSecondary)),
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
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: state.isSaving ? null : () => _handleComplete(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NETokens.darkEvergreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: state.isSaving
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Explore Your Daily Plan',
                                  style: GoogleFonts.manrope(fontSize: 15.5, fontWeight: FontWeight.w700),
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

  Widget _buildSummaryCard(
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
                        style: GoogleFonts.manrope(fontSize: 14.5, fontWeight: FontWeight.w700, color: NETokens.darkEvergreen),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined, size: 13, color: NETokens.botanicalTeal),
                      const SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700, color: NETokens.botanicalTeal),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          content,
        ],
      ),
    );
  }
}


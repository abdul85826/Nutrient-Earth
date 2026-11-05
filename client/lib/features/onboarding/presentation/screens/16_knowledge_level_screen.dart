// ==============================================================================
// Nutrient Earth — Screen 16: Fitness & Nutrition Knowledge (Stitch Ref: screen_16_how_familiar_are_you_with_fitness_and_nutrition)
// Phase 2: Step 8 of 8. Calibrates scientific depth of explanations, study citations,
// and practical recommendations across the intelligence engine.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../state/onboarding_journey_state.dart';

class KnowledgeLevelScreen extends ConsumerWidget {
  final String? returnTo;

  const KnowledgeLevelScreen({super.key, this.returnTo});

  static const List<Map<String, String>> _levels = [
    {
      'id': 'beginner',
      'title': 'Beginner',
      'desc': 'Simple, jargon-free guidance focused on practical daily actions without complex jargon',
    },
    {
      'id': 'basics',
      'title': 'Basics',
      'desc': 'Clear fundamentals with accessible explanations of why recommendations work',
    },
    {
      'id': 'intermediate',
      'title': 'Intermediate',
      'desc': 'Comfortable with macronutrient ratios, clinical study types, and metabolic concepts',
    },
    {
      'id': 'advanced',
      'title': 'Advanced',
      'desc': 'In-depth biochemical pathways, pharmacokinetic mechanisms, and statistical trial rigor',
    },
  ];

  void _handleContinue(BuildContext context) {
    if (returnTo != null && returnTo!.isNotEmpty) {
      context.go('/onboarding/$returnTo');
    } else {
      context.go('/onboarding/completion');
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
              context.go('/onboarding/sleep-patterns');
            }
          },
        ),
        title: Column(
          children: [
            Text(
              'STEP 13 OF 14 • SOIL PROFILE',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: NETokens.botanicalTeal,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Knowledge Level',
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
                            'STAGE 16 • KNOWLEDGE CALIBRATION',
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
                          'How familiar are you with fitness & nutrition?',
                          style: GoogleFonts.manrope(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: NETokens.darkEvergreen,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'We adapt the scientific depth of research syntheses, biochemistry explanations, and practical takeaways to your preference.',
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
                          itemCount: _levels.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, idx) {
                            final item = _levels[idx];
                            final id = item['id']!;
                            final isSelected = state.knowledgeLevel == id;

                            return InkWell(
                              onTap: () => notifier.setKnowledgeLevel(id),
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

                        // Adaptive intelligence card
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
                              const Icon(Icons.psychology_alt_outlined, size: 20, color: NETokens.botanicalTeal),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Adaptive Engine: Calibrates research depth across Explore and Today answers without oversimplifying verified empirical evidence.',
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
                                'Complete Setup',
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


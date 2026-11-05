// ==============================================================================
// Nutrient Earth — Screen 06: Daily Impact Rating (Stitch Ref: screen_06_daily_impact_difficulty_rating)
// Phase 1: Step 3 of 5. Rates 1..4 everyday life impact per difficulty, flexible fluctuation toggle,
// clinical pacing justification, and mandatory emergency medical advisory.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../state/onboarding_journey_state.dart';

class DailyImpactScreen extends ConsumerStatefulWidget {
  final String? returnTo;

  const DailyImpactScreen({super.key, this.returnTo});

  @override
  ConsumerState<DailyImpactScreen> createState() => _DailyImpactScreenState();
}

class _DailyImpactScreenState extends ConsumerState<DailyImpactScreen> {
  static const Map<String, String> _difficultyTitles = {
    'MSK-01': 'Difficulty walking',
    'MSK-02': 'Difficulty standing for long periods',
    'MSK-03': 'Arm or leg weakness',
    'MSK-04': 'Difficulty lifting objects',
    'MSK-05': 'Difficulty getting up',
    'NRG-01': 'Feeling tired or weak',
    'NRG-02': 'Difficulty completing everyday tasks',
    'NRG-03': 'Daytime sleepiness',
    'NRG-04': 'Slow recovery after physical activity',
    'NRG-05': 'Difficulty climbing stairs',
    'REN-01': 'Frequent urination',
    'REN-02': 'Excessive thirst',
    'REN-03': 'Difficulty controlling urination',
    'DIG-01': 'Constipation',
    'DIG-02': 'Bloating or stomach discomfort',
    'DIG-03': 'Nausea',
    'NRV-01': 'Numbness or tingling in hands/feet',
    'NRV-02': 'Burning sensations',
    'OTH-01': 'Another problem',
    'OTH-02': 'I\'m not sure how to describe it',
  };

  void _handleContinue() {
    if (widget.returnTo != null && widget.returnTo!.isNotEmpty) {
      context.go('/onboarding/${widget.returnTo}');
    } else {
      context.go('/onboarding/food-choices');
    }
  }

  String _getImpactLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Not affected';
      case 2:
        return 'A little';
      case 3:
        return 'Moderately';
      case 4:
        return 'Severely';
      default:
        return 'Select impact';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingJourneyProvider);
    final notifier = ref.read(onboardingJourneyProvider.notifier);

    // If no difficulties were selected in Step 05, provide a baseline energy difficulty
    final activeItems = state.difficulties.isNotEmpty ? state.difficulties.toList() : ['NRG-01', 'NRG-04'];

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
              context.go('/onboarding/difficulties');
            }
          },
        ),
        title: Column(
          children: [
            Text(
              'STEP 3 OF 14',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: NETokens.botanicalTeal,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Getting to know you',
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
                            'STAGE 06 • DAILY IMPACT RATING',
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
                          'How much do these difficulties affect you?',
                          style: GoogleFonts.manrope(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: NETokens.darkEvergreen,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Rate how much each difficulty affects your everyday life. Your answers help us personalize your guidance.',
                          style: GoogleFonts.manrope(
                            fontSize: 13.5,
                            color: NETokens.textSecondary,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Impact Cards
                        ...activeItems.map((code) {
                          final title = _difficultyTitles[code] ?? code;
                          final currentRating = state.dailyImpacts[code] ?? 2;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: NETokens.borderDefault),
                              boxShadow: NETokens.cardShadow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: NETokens.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        code,
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: NETokens.deepestForest,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: currentRating >= 3 ? NETokens.paleMint : NETokens.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(NETokens.radiusFull),
                                      ),
                                      child: Text(
                                        _getImpactLabel(currentRating),
                                        style: GoogleFonts.manrope(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: NETokens.deepestForest,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  title,
                                  style: GoogleFonts.manrope(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: NETokens.primary,
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // 4 Segmented Rating Buttons
                                Row(
                                  children: [1, 2, 3, 4].map((ratingVal) {
                                    final isSelected = currentRating == ratingVal;
                                    final labels = ['Not at all', 'A little', 'Moderately', 'Severely'];

                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                                        child: InkWell(
                                          onTap: () => notifier.setDailyImpact(code, ratingVal),
                                          borderRadius: BorderRadius.circular(10),
                                          child: Container(
                                            height: 38,
                                            decoration: BoxDecoration(
                                              color: isSelected ? NETokens.darkEvergreen : NETokens.surfaceContainerLow,
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                color: isSelected ? NETokens.darkEvergreen : NETokens.borderDefault,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                labels[ratingVal - 1],
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.manrope(
                                                  fontSize: 11,
                                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                                  color: isSelected ? Colors.white : NETokens.textSecondary,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),

                                const SizedBox(height: 12),
                                const Divider(height: 1, color: NETokens.borderDefault),
                                const SizedBox(height: 8),

                                // Fluctuates Checkbox
                                InkWell(
                                  onTap: () => notifier.setImpactFluctuates(!state.impactFluctuates),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Checkbox(
                                          value: state.impactFluctuates,
                                          activeColor: NETokens.darkEvergreen,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                          onChanged: (val) => notifier.setImpactFluctuates(val ?? false),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'I\'m not sure / fluctuates unpredictably',
                                          style: GoogleFonts.manrope(fontSize: 12, color: NETokens.textSecondary),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        // Clinical Pacing Notice
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
                              const Icon(Icons.verified_user_outlined, size: 20, color: NETokens.botanicalTeal),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'WHY WE EVALUATE DAILY IMPACT',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: NETokens.deepestForest,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Perceived daily impact helps us adapt evidence-based lifestyle pacing and nutritional recommendations. This does not measure clinical severity or provide a diagnostic score.',
                                      style: GoogleFonts.manrope(fontSize: 12, color: NETokens.textSecondary, height: 1.45),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Emergency Advisory Notice
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFDAD6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFBA1A1A).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.warning_amber_rounded, size: 20, color: Color(0xFFBA1A1A)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.manrope(fontSize: 12, color: const Color(0xFF93000A), height: 1.4),
                                    children: const [
                                      TextSpan(text: 'Emergency Advisory: ', style: TextStyle(fontWeight: FontWeight.w700)),
                                      TextSpan(text: 'If you experience sudden, severe, or one-sided weakness, seek immediate emergency medical care.'),
                                    ],
                                  ),
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
                          onPressed: _handleContinue,
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
                        onPressed: _handleContinue,
                        child: Text(
                          'Skip impact ratings for now',
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


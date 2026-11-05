// ==============================================================================
// Nutrient Earth — Screen 05: Practical Difficulties (Stitch Ref: screen_05_practical_difficulties_functional_challenges)
// Phase 1: Step 2 of 5. Reflects Step 04 selections with edit link, displays 6 clinical
// functional categories with codes, freeform input, and why-we-ask reassurance.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../state/onboarding_journey_state.dart';

class PracticalDifficultiesScreen extends ConsumerStatefulWidget {
  final String? returnTo;

  const PracticalDifficultiesScreen({super.key, this.returnTo});

  @override
  ConsumerState<PracticalDifficultiesScreen> createState() => _PracticalDifficultiesScreenState();
}

class _PracticalDifficultiesScreenState extends ConsumerState<PracticalDifficultiesScreen> {
  late final TextEditingController _noteController;

  final Map<String, List<Map<String, String>>> _categories = {
    'Muscles & movement': [
      {'code': 'MSK-01', 'label': 'Difficulty walking'},
      {'code': 'MSK-02', 'label': 'Difficulty standing for long periods'},
      {'code': 'MSK-03', 'label': 'Arm or leg weakness'},
      {'code': 'MSK-04', 'label': 'Difficulty lifting objects'},
      {'code': 'MSK-05', 'label': 'Difficulty getting up'},
    ],
    'Energy & daily activities': [
      {'code': 'NRG-01', 'label': 'Feeling tired or weak'},
      {'code': 'NRG-02', 'label': 'Difficulty completing everyday tasks'},
      {'code': 'NRG-03', 'label': 'Daytime sleepiness'},
      {'code': 'NRG-04', 'label': 'Slow recovery after physical activity'},
      {'code': 'NRG-05', 'label': 'Difficulty climbing stairs'},
    ],
    'Urination & thirst': [
      {'code': 'REN-01', 'label': 'Frequent urination'},
      {'code': 'REN-02', 'label': 'Excessive thirst'},
      {'code': 'REN-03', 'label': 'Difficulty controlling urination'},
    ],
    'Digestive health': [
      {'code': 'DIG-01', 'label': 'Constipation'},
      {'code': 'DIG-02', 'label': 'Bloating or stomach discomfort'},
      {'code': 'DIG-03', 'label': 'Nausea'},
    ],
    'Nerve-related sensations': [
      {'code': 'NRV-01', 'label': 'Numbness or tingling in hands/feet'},
      {'code': 'NRV-02', 'label': 'Burning sensations'},
    ],
    'Other difficulties': [
      {'code': 'OTH-01', 'label': 'Another problem'},
      {'code': 'OTH-02', 'label': 'I\'m not sure how to describe it'},
    ],
  };

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingJourneyProvider);
    _noteController = TextEditingController(text: state.difficultiesNote);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    ref.read(onboardingJourneyProvider.notifier).setDifficultiesNote(_noteController.text.trim());
    if (widget.returnTo != null && widget.returnTo!.isNotEmpty) {
      context.go('/onboarding/${widget.returnTo}');
    } else {
      context.go('/onboarding/daily-impact');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingJourneyProvider);
    final notifier = ref.read(onboardingJourneyProvider.notifier);
    final selectedCount = state.difficulties.length;

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
              context.go('/onboarding/health-goals');
            }
          },
        ),
        title: Column(
          children: [
            Text(
              'STEP 2 OF 5',
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
                        // Summary of Screen 04 selections
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: NETokens.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: NETokens.borderDefault),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded, size: 16, color: NETokens.botanicalTeal),
                                      const SizedBox(width: 6),
                                      Text(
                                        'YOUR SELECTIONS SO FAR',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          color: NETokens.botanicalTeal,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () => context.go('/onboarding/health-goals?returnTo=difficulties'),
                                    child: Text(
                                      'Edit selections',
                                      style: GoogleFonts.manrope(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: NETokens.forest,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: state.healthGoals.isEmpty
                                    ? [
                                        Text('No goals selected (skipped)',
                                            style: GoogleFonts.manrope(fontSize: 12, color: NETokens.textMuted))
                                      ]
                                    : state.healthGoals.map((g) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(NETokens.radiusFull),
                                            border: Border.all(color: NETokens.borderDefault),
                                          ),
                                          child: Text(
                                            g,
                                            style: GoogleFonts.manrope(fontSize: 11.5, fontWeight: FontWeight.w600, color: NETokens.primary),
                                          ),
                                        );
                                      }).toList(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          'What difficulties are you experiencing?',
                          style: GoogleFonts.manrope(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: NETokens.darkEvergreen,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Select the problems that apply. We\'ll use your answers to make your health guidance more relevant.',
                          style: GoogleFonts.manrope(
                            fontSize: 13.5,
                            color: NETokens.textSecondary,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Render All 6 Functional Categories
                        ..._categories.entries.map((entry) {
                          final categoryTitle = entry.key;
                          final items = entry.value;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      categoryTitle,
                                      style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700, color: NETokens.darkEvergreen),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: items.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                                  itemBuilder: (context, idx) {
                                    final item = items[idx];
                                    final code = item['code']!;
                                    final label = item['label']!;
                                    final isSelected = state.difficulties.contains(code);

                                    return InkWell(
                                      onTap: () => notifier.toggleDifficulty(code),
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: isSelected ? NETokens.paleMint.withValues(alpha: 0.5) : Colors.white,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: isSelected ? NETokens.emerald : NETokens.borderDefault,
                                            width: isSelected ? 1.5 : 1.0,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: isSelected ? NETokens.darkEvergreen : Colors.transparent,
                                                borderRadius: BorderRadius.circular(5),
                                                border: Border.all(
                                                  color: isSelected ? NETokens.darkEvergreen : NETokens.borderDefault,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: isSelected
                                                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                                                  : null,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                label,
                                                style: GoogleFonts.manrope(
                                                  fontSize: 13.5,
                                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        }),

                        // Free-form notes area
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: NETokens.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: NETokens.borderDefault),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Anything else you\'d like to tell us?',
                                    style: GoogleFonts.manrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: NETokens.darkEvergreen),
                                  ),
                                  Text('Optional', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: NETokens.textMuted)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _noteController,
                                maxLength: 300,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: 'Describe what is happening in your own words...',
                                  hintStyle: GoogleFonts.manrope(fontSize: 13, color: NETokens.textMuted),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.all(12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: NETokens.borderDefault)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: NETokens.borderDefault)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: NETokens.emerald, width: 1.5)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Why we ask reassurance card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: NETokens.paleMint.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFC0E5CB)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.shield_outlined, size: 20, color: NETokens.deepestForest),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'WHY WE ASK',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: NETokens.deepestForest,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Collecting functional difficulties helps personalize evidence-based guidance, nutrition, and daily habit adjustments to your real needs. This does not constitute a clinical diagnosis.',
                                      style: GoogleFonts.manrope(fontSize: 12, color: NETokens.deepestForest, height: 1.45),
                                    ),
                                  ],
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
                                selectedCount > 0 ? 'Continue ($selectedCount selected)' : 'Continue',
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
                          'Skip for now',
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


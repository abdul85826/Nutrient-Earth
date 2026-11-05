// ==============================================================================
// Nutrient Earth — Screen 12: Clinical Safety & Food Restrictions (Stitch Ref: screen_12_food_restrictions_allergies)
// Phase 2: Step 4 of 8. Clinical safety banner, strictly mutually exclusive
// "No restrictions or allergies" toggle, allergen chip selection, and custom allergy entry.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../state/onboarding_journey_state.dart';

class FoodRestrictionsScreen extends ConsumerStatefulWidget {
  final String? returnTo;

  const FoodRestrictionsScreen({super.key, this.returnTo});

  @override
  ConsumerState<FoodRestrictionsScreen> createState() => _FoodRestrictionsScreenState();
}

class _FoodRestrictionsScreenState extends ConsumerState<FoodRestrictionsScreen> {
  final TextEditingController _customAllergenController = TextEditingController();

  final List<String> _commonAllergens = [
    'Peanuts',
    'Tree nuts (almond, walnut, cashew)',
    'Crustacean shellfish (shrimp, crab)',
    'Eggs',
    'Milk / Dairy allergy',
    'Wheat (IgE allergy / Celiac)',
    'Soy',
    'Fish (finfish)',
    'Sesame',
  ];

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingJourneyProvider);
    _customAllergenController.text = state.customAllergen;
  }

  @override
  void dispose() {
    _customAllergenController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    ref.read(onboardingJourneyProvider.notifier).setCustomAllergen(_customAllergenController.text.trim());
    if (widget.returnTo != null && widget.returnTo!.isNotEmpty) {
      context.go('/onboarding/${widget.returnTo}');
    } else {
      context.go('/onboarding/eating-routine');
    }
  }

  @override
  Widget build(BuildContext context) {
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
              context.go('/onboarding/health-concerns');
            }
          },
        ),
        title: Column(
          children: [
            Text(
              'STEP 9 OF 14 • SOIL PROFILE',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: NETokens.botanicalTeal,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Dietary Restrictions',
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
                            'STAGE 12 • CLINICAL SAFETY PROTOCOL',
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
                          'Are there any foods you need to avoid?',
                          style: GoogleFonts.manrope(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: NETokens.darkEvergreen,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Immunological food allergies require strict exclusion locks across all nutrition guidance.',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: NETokens.textSecondary,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Clinical Safety Callout
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBF4EE),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE8D7C9)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.health_and_safety_rounded, size: 22, color: Color(0xFF9A4B1D)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CLINICAL SAFETY EXCLUSIONS',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF9A4B1D),
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Declared allergens trigger non-substitutable exclusion filters in our scientific food intelligence engine. They are never overridden by general taste preferences.',
                                      style: GoogleFonts.manrope(fontSize: 12, color: const Color(0xFF7A3814), height: 1.45),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Mutually Exclusive "No restrictions or allergies" Toggle
                        InkWell(
                          onTap: () => notifier.setStrictlyNoRestrictions(!state.strictlyNoRestrictions),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: state.strictlyNoRestrictions ? NETokens.paleMint.withValues(alpha: 0.5) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: state.strictlyNoRestrictions ? NETokens.emerald : NETokens.borderDefault,
                                width: state.strictlyNoRestrictions ? 1.5 : 1.0,
                              ),
                              boxShadow: NETokens.cardShadow,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: state.strictlyNoRestrictions ? NETokens.darkEvergreen : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: state.strictlyNoRestrictions ? NETokens.darkEvergreen : NETokens.borderDefault,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: state.strictlyNoRestrictions
                                      ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'No restrictions or allergies',
                                        style: GoogleFonts.manrope(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: NETokens.primary,
                                        ),
                                      ),
                                      Text(
                                        'I have no diagnosed food allergies or mandatory medical diet restrictions',
                                        style: GoogleFonts.manrope(fontSize: 12, color: NETokens.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        Text(
                          'Or select diagnosed allergens:',
                          style: GoogleFonts.manrope(fontSize: 14.5, fontWeight: FontWeight.w700, color: NETokens.darkEvergreen),
                        ),
                        const SizedBox(height: 10),

                        // Common Allergens Wrap Chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _commonAllergens.map((allergen) {
                            final isSelected = state.allergens.contains(allergen);

                            return FilterChip(
                              label: Text(allergen),
                              selected: isSelected,
                              onSelected: (_) => notifier.toggleAllergen(allergen),
                              selectedColor: NETokens.darkEvergreen,
                              backgroundColor: Colors.white,
                              labelStyle: GoogleFonts.manrope(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? Colors.white : NETokens.textSecondary,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected ? NETokens.darkEvergreen : NETokens.borderDefault,
                                ),
                              ),
                              showCheckmark: isSelected,
                              checkmarkColor: Colors.white,
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 20),

                        // Custom allergen text field
                        TextField(
                          controller: _customAllergenController,
                          onChanged: (val) => notifier.setCustomAllergen(val),
                          decoration: InputDecoration(
                            labelText: 'Other diagnosed allergens (optional)',
                            labelStyle: GoogleFonts.manrope(fontSize: 12.5),
                            hintText: 'e.g. Mustard, Lupin, Kiwi, Sulfites...',
                            hintStyle: GoogleFonts.manrope(fontSize: 13, color: NETokens.textMuted),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: NETokens.borderDefault)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: NETokens.borderDefault)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: NETokens.emerald, width: 1.5)),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


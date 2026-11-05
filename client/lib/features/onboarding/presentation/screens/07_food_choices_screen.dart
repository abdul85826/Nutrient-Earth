// ==============================================================================
// Nutrient Earth — Screen 07: Food Choices & Dietary Profile (Stitch Ref: screen_07_food_choices_dietary_profile)
// Phase 1: Step 4 of 5. Calibrates baseline eating patterns (Vegetarian, Vegan, Omnivorous, etc.),
// digestive intolerances, and lifestyle food avoidances while clarifying that clinical allergies
// have their dedicated safety protocol in Phase 2.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../state/onboarding_journey_state.dart';

class FoodChoicesScreen extends ConsumerStatefulWidget {
  final String? returnTo;

  const FoodChoicesScreen({super.key, this.returnTo});

  @override
  ConsumerState<FoodChoicesScreen> createState() => _FoodChoicesScreenState();
}

class _FoodChoicesScreenState extends ConsumerState<FoodChoicesScreen> {
  final TextEditingController _customDietController = TextEditingController();

  final List<Map<String, String>> _dietPatterns = [
    {'id': 'none', 'name': 'No specific preference', 'desc': 'Eat a wide variety of foods without restriction'},
    {'id': 'vegetarian', 'name': 'Vegetarian', 'desc': 'Plant foods, dairy, and eggs; no meat or seafood'},
    {'id': 'vegan', 'name': 'Vegan', 'desc': 'Exclusively plant-based; no animal products'},
    {'id': 'eggetarian', 'name': 'Eggetarian', 'desc': 'Vegetarian diet including eggs, no meat or poultry'},
    {'id': 'pescatarian', 'name': 'Pescatarian', 'desc': 'Vegetarian diet supplemented with fish and seafood'},
    {'id': 'other', 'name': 'Other dietary framework', 'desc': 'Custom, therapeutic, keto, or ancestral regimen'},
  ];

  final List<Map<String, String>> _intolerances = [
    {'title': 'Lactose intolerance', 'desc': 'Enzyme deficiency, dairy distress'},
    {'title': 'Gluten-related concerns', 'desc': 'Non-celiac grain sensitivity'},
    {'title': 'FODMAP / Fermentables', 'desc': 'Gas, bloating from complex oligosaccharides'},
    {'title': 'Nightshades or Histamine', 'desc': 'Aged foods, tomatoes, peppers'},
  ];

  final List<String> _avoidanceTags = [
    'Cilantro / Coriander',
    'Pork',
    'Beef',
    'Added sugars & Syrups',
    'Artificial sweeteners',
    'Caffeine',
    'Alcohol',
    'Highly refined seed oils',
  ];

  @override
  void dispose() {
    _customDietController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (widget.returnTo != null && widget.returnTo!.isNotEmpty) {
      context.go('/onboarding/${widget.returnTo}');
    } else {
      context.go('/onboarding/review-phase1');
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
              context.go('/onboarding/daily-impact');
            }
          },
        ),
        title: Column(
          children: [
            Text(
              'STEP 4 OF 14',
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
                            'STAGE 07 • NUTRITIONAL FOUNDATION',
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
                          'Let\'s understand your food choices',
                          style: GoogleFonts.manrope(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: NETokens.darkEvergreen,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tell us about your food preferences so we can personalize your nutrition guidance with clinical precision.',
                          style: GoogleFonts.manrope(
                            fontSize: 13.5,
                            color: NETokens.textSecondary,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Section 1: Dietary Pattern
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'How do you usually eat?',
                                style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: NETokens.darkEvergreen),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'SINGLE CHOICE',
                              style: GoogleFonts.jetBrainsMono(fontSize: 9.5, fontWeight: FontWeight.w600, color: NETokens.botanicalTeal),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _dietPatterns.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, idx) {
                            final pattern = _dietPatterns[idx];
                            final id = pattern['id']!;
                            final isSelected = state.dietaryPattern == id;

                            return InkWell(
                              onTap: () => notifier.setDietaryPattern(id),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isSelected ? NETokens.paleMint.withValues(alpha: 0.5) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
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
                                        shape: BoxShape.circle,
                                        color: isSelected ? NETokens.darkEvergreen : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected ? NETokens.darkEvergreen : NETokens.borderDefault,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: isSelected
                                          ? Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)))
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pattern['name']!,
                                            style: GoogleFonts.manrope(
                                              fontSize: 14.5,
                                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                              color: NETokens.primary,
                                            ),
                                          ),
                                          Text(
                                            pattern['desc']!,
                                            style: GoogleFonts.manrope(fontSize: 12, color: NETokens.textSecondary),
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

                        if (state.dietaryPattern == 'other') ...[
                          const SizedBox(height: 10),
                          TextField(
                            controller: _customDietController,
                            onChanged: (val) => notifier.setDietaryPattern('other', custom: val),
                            decoration: InputDecoration(
                              hintText: 'Specify your eating style (e.g. Ketogenic, Low-Histamine)...',
                              hintStyle: GoogleFonts.manrope(fontSize: 13, color: NETokens.textMuted),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: NETokens.borderDefault)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: NETokens.borderDefault)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: NETokens.emerald, width: 1.5)),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Section 2: Clinical Allergy Separation Banner
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
                              const Icon(Icons.security_rounded, size: 20, color: NETokens.botanicalTeal),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CLINICAL SAFETY SEPARATION',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: NETokens.darkEvergreen,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Food allergies that cause severe immunological reactions (such as peanuts, shellfish, or gluten in celiac) are kept strictly separate from lifestyle choices and will be calibrated in your safety profile.',
                                      style: GoogleFonts.manrope(fontSize: 12, color: NETokens.textSecondary, height: 1.45),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Section 3: Food Intolerances & Sensitivities
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Do any foods cause discomfort?',
                                style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: NETokens.darkEvergreen),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'MULTI-SELECT',
                              style: GoogleFonts.jetBrainsMono(fontSize: 9.5, fontWeight: FontWeight.w600, color: NETokens.botanicalTeal),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _intolerances.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, idx) {
                            final item = _intolerances[idx];
                            final title = item['title']!;
                            final isChecked = state.foodIntolerances.contains(title);

                            return InkWell(
                              onTap: () => notifier.toggleFoodIntolerance(title),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isChecked ? NETokens.paleMint.withValues(alpha: 0.4) : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isChecked ? NETokens.emerald : NETokens.borderDefault,
                                    width: isChecked ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: isChecked ? NETokens.darkEvergreen : Colors.transparent,
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(color: isChecked ? NETokens.darkEvergreen : NETokens.borderDefault, width: 1.5),
                                      ),
                                      child: isChecked ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: GoogleFonts.manrope(fontSize: 14, fontWeight: isChecked ? FontWeight.w700 : FontWeight.w500, color: NETokens.primary),
                                          ),
                                          Text(
                                            item['desc']!,
                                            style: GoogleFonts.manrope(fontSize: 12, color: NETokens.textSecondary),
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

                        // Section 4: Foods to Avoid (Lifestyle / Taste avoidances)
                        Text(
                          'Foods you prefer to avoid',
                          style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: NETokens.darkEvergreen),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Ingredients you choose to omit for personal, cultural, or religious reasons.',
                          style: GoogleFonts.manrope(fontSize: 12.5, color: NETokens.textSecondary),
                        ),
                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _avoidanceTags.map((tag) {
                            final isSelected = state.foodsToAvoid.contains(tag);
                            return FilterChip(
                              label: Text(tag),
                              selected: isSelected,
                              onSelected: (_) => notifier.toggleFoodToAvoid(tag),
                              selectedColor: NETokens.darkEvergreen,
                              backgroundColor: Colors.white,
                              labelStyle: GoogleFonts.manrope(
                                fontSize: 12.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? Colors.white : NETokens.textSecondary,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: isSelected ? NETokens.darkEvergreen : NETokens.borderDefault),
                              ),
                              showCheckmark: isSelected,
                              checkmarkColor: Colors.white,
                            );
                          }).toList(),
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
                                'Continue to Review',
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
                          'Skip dietary preferences for now',
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


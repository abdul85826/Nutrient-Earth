// ==============================================================================
// Nutrient Earth — Screen 04: Health Goals Discovery (Stitch Ref: screen_04_health_goals_conditions_discovery_refined_typography)
// Phase 1: Step 1 of 5. Searchable catalog, categorized chips, multi-select goal cards,
// skip capability, and returnTo support.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../state/onboarding_journey_state.dart';

class HealthGoalsScreen extends ConsumerStatefulWidget {
  final String? returnTo;

  const HealthGoalsScreen({super.key, this.returnTo});

  @override
  ConsumerState<HealthGoalsScreen> createState() => _HealthGoalsScreenState();
}

class _HealthGoalsScreenState extends ConsumerState<HealthGoalsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'General Wellness',
    'Energy & Vitality',
    'Brain & Sleep',
    'Digestion & Gut',
    'Movement & Strength',
    'Heart & Metabolism',
  ];

  final List<Map<String, String>> _allGoals = [
    {'title': 'Increase everyday energy', 'category': 'Energy & Vitality', 'code': 'PRI-01'},
    {'title': 'Improve sleep quality', 'category': 'Brain & Sleep', 'code': 'SLP-02'},
    {'title': 'Manage digestion & bloating', 'category': 'Digestion & Gut', 'code': 'GUT-04'},
    {'title': 'Build consistent daily movement', 'category': 'Movement & Strength', 'code': 'MOV-01'},
    {'title': 'Support healthy blood sugar', 'category': 'Heart & Metabolism', 'code': 'MET-02'},
    {'title': 'Reduce everyday stress', 'category': 'Brain & Sleep', 'code': 'STR-03'},
    {'title': 'Eat more nutritious meals', 'category': 'General Wellness', 'code': 'NUT-01'},
    {'title': 'Strength and muscle tone', 'category': 'Movement & Strength', 'code': 'STR-04'},
    {'title': 'Joint comfort & mobility', 'category': 'Movement & Strength', 'code': 'JNT-05'},
    {'title': 'Cardiovascular endurance', 'category': 'Heart & Metabolism', 'code': 'CRD-06'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (widget.returnTo != null && widget.returnTo!.isNotEmpty) {
      context.go('/onboarding/${widget.returnTo}');
    } else {
      context.go('/onboarding/difficulties');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingJourneyProvider);
    final notifier = ref.read(onboardingJourneyProvider.notifier);

    final searchQuery = _searchController.text.trim().toLowerCase();
    final filteredGoals = _allGoals.where((item) {
      final matchesCategory = _selectedCategory == 'All' || item['category'] == _selectedCategory;
      final matchesQuery = searchQuery.isEmpty || item['title']!.toLowerCase().contains(searchQuery);
      return matchesCategory && matchesQuery;
    }).toList();

    final selectedCount = state.healthGoals.length;

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
              context.go('/auth');
            }
          },
        ),
        title: Column(
          children: [
            Text(
              'STEP 1 OF 5',
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
                            'STAGE 04 • HEALTH GOALS & CONDITIONS',
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
                          'Choose the areas you want to focus on. We\'ll use your answers to tailor your health suggestions.',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: NETokens.textSecondary,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Search Input
                        TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search_rounded, size: 20, color: NETokens.textSecondary),
                            hintText: 'Search goals, symptoms, or conditions...',
                            hintStyle: GoogleFonts.manrope(fontSize: 13.5, color: NETokens.textMuted),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: NETokens.borderDefault)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: NETokens.borderDefault)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: NETokens.emerald, width: 1.5)),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Categories Horizontal Filter
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _categories.map((cat) {
                              final isSelected = _selectedCategory == cat;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(cat),
                                  selected: isSelected,
                                  onSelected: (val) {
                                    if (val) setState(() => _selectedCategory = cat);
                                  },
                                  selectedColor: NETokens.darkEvergreen,
                                  backgroundColor: NETokens.surfaceContainerLow,
                                  labelStyle: GoogleFonts.manrope(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? Colors.white : NETokens.textSecondary,
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NETokens.radiusFull)),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Goal Selection List
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredGoals.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final goal = filteredGoals[index];
                            final title = goal['title']!;
                            final isChecked = state.healthGoals.contains(title);

                            return InkWell(
                              onTap: () => notifier.toggleHealthGoal(title),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: isChecked ? NETokens.paleMint.withValues(alpha: 0.5) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isChecked ? NETokens.emerald : NETokens.borderDefault,
                                    width: isChecked ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: isChecked ? NETokens.darkEvergreen : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isChecked ? NETokens.darkEvergreen : NETokens.borderDefault,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: isChecked
                                          ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: GoogleFonts.manrope(
                                              fontSize: 14.5,
                                              fontWeight: isChecked ? FontWeight.w700 : FontWeight.w500,
                                              color: NETokens.primary,
                                            ),
                                          ),
                                          Text(
                                            goal['category']!,
                                            style: GoogleFonts.manrope(fontSize: 11.5, color: NETokens.textMuted),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      goal['code']!,
                                      style: GoogleFonts.jetBrainsMono(fontSize: 10, color: NETokens.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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


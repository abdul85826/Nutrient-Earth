import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';
import '../domain/onboarding_state.dart';

class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  static const List<String> availableGoals = [
    'Metabolic Balance',
    'Muscle Recovery',
    'Deep Restorative Sleep',
    'Cellular Longevity',
    'Cognitive Clarity',
    'Digestive Health',
  ];

  static const List<String> availableDiets = [
    'Plant-forward',
    'Whole Food Omnivore',
    'Mediterranean Protocol',
    'Ketogenic / Low-Carb',
    'Strict Vegan',
  ];

  static const List<String> availableActivity = [
    'Sedentary / Desk-focused',
    'Moderate (5k-8k steps/day)',
    'Active Outdoor (8k-12k steps)',
    'High Athletic Training',
  ];

  void _nextPage() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() async {
    await ref.read(onboardingProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go('/today');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(onboardingProvider);

    return Scaffold(
      backgroundColor: NeTokens.warmIvory,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation & Step Indicator
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: NeTokens.spacing24,
                vertical: NeTokens.spacing16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(3, (index) {
                      final isActive = index == _currentStep;
                      final isPassed = index < _currentStep;
                      return Container(
                        margin: const EdgeInsets.only(right: NeTokens.spacing6),
                        width: isActive ? 24 : 8,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive || isPassed
                              ? NeTokens.botanicalEvergreen
                              : NeTokens.sandDune,
                          borderRadius: BorderRadius.circular(
                            NeTokens.radiusFull,
                          ),
                        ),
                      );
                    }),
                  ),
                  TextButton(
                    onPressed: _finishOnboarding,
                    child: const Text(
                      'Skip to Today',
                      style: TextStyle(
                        fontFamily: NeTokens.fontFamilySans,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: NeTokens.slateMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentStep = page),
                children: [
                  // Step 1: Health Focus
                  _buildStep(
                    title: 'What are your core health priorities?',
                    subtitle:
                        'Nutrient Earth calibrates personalized clinical reasoning around your physiological goals.',
                    content: Wrap(
                      spacing: NeTokens.spacing8,
                      runSpacing: NeTokens.spacing10,
                      children: availableGoals.map((goal) {
                        final isSelected = profile.primaryGoals.contains(goal);
                        return NeChip(
                          label: goal,
                          isSelected: isSelected,
                          onTap: () => ref
                              .read(onboardingProvider.notifier)
                              .toggleGoal(goal),
                        );
                      }).toList(),
                    ),
                  ),

                  // Step 2: Dietary Baseline
                  _buildStep(
                    title: 'What is your dietary foundation?',
                    subtitle:
                        'Helps us verify micronutrient bioavailability and identify potential nutritional deficits.',
                    content: Column(
                      children: availableDiets.map((diet) {
                        final isSelected = profile.dietaryBaseline == diet;
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: NeTokens.spacing8,
                          ),
                          child: InkWell(
                            onTap: () => ref
                                .read(onboardingProvider.notifier)
                                .setDietaryBaseline(diet),
                            borderRadius: BorderRadius.circular(
                              NeTokens.radius12,
                            ),
                            child: NeCard(
                              padding: const EdgeInsets.all(NeTokens.spacing14),
                              border: Border.all(
                                color: isSelected
                                    ? NeTokens.botanicalEvergreen
                                    : NeTokens.sandDune,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    size: 20,
                                    color: isSelected
                                        ? NeTokens.botanicalEvergreen
                                        : NeTokens.slateMuted,
                                  ),
                                  const SizedBox(width: NeTokens.spacing12),
                                  Text(
                                    diet,
                                    style: TextStyle(
                                      fontFamily: NeTokens.fontFamilySans,
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: NeTokens.deepForest,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Step 3: Activity & Environment
                  _buildStep(
                    title: 'What is your typical daily movement?',
                    subtitle:
                        'Correlates metabolic turnover with external ambient temperature and UV exposure.',
                    content: Column(
                      children: availableActivity.map((activity) {
                        final isSelected = profile.activityLevel == activity;
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: NeTokens.spacing8,
                          ),
                          child: InkWell(
                            onTap: () => ref
                                .read(onboardingProvider.notifier)
                                .setActivityLevel(activity),
                            borderRadius: BorderRadius.circular(
                              NeTokens.radius12,
                            ),
                            child: NeCard(
                              padding: const EdgeInsets.all(NeTokens.spacing14),
                              border: Border.all(
                                color: isSelected
                                    ? NeTokens.botanicalEvergreen
                                    : NeTokens.sandDune,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    size: 20,
                                    color: isSelected
                                        ? NeTokens.botanicalEvergreen
                                        : NeTokens.slateMuted,
                                  ),
                                  const SizedBox(width: NeTokens.spacing12),
                                  Text(
                                    activity,
                                    style: TextStyle(
                                      fontFamily: NeTokens.fontFamilySans,
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: NeTokens.deepForest,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom CTA
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: NeTokens.spacing24,
                vertical: NeTokens.spacing16,
              ),
              child: NeButton(
                label: _currentStep == 2
                    ? 'Initialize Health Memory'
                    : 'Continue',
                icon: _currentStep == 2
                    ? Icons.bolt_rounded
                    : Icons.arrow_forward_rounded,
                onPressed: _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({
    required String title,
    required String subtitle,
    required Widget content,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: NeTokens.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: NeTokens.spacing16),
          Text(
            title,
            style: const TextStyle(
              fontFamily: NeTokens.fontFamilySerif,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: NeTokens.deepForest,
              height: 1.25,
            ),
          ),
          const SizedBox(height: NeTokens.spacing8),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: NeTokens.fontFamilySans,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: NeTokens.slateMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: NeTokens.spacing24),
          content,
        ],
      ),
    );
  }
}

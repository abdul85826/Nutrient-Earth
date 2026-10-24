import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 11: Personal Goal and Desired Outcome
/// Authoritative Stitch Design: personal_goal_and_desired_outcome
class PersonalGoalScreen extends StatefulWidget {
  const PersonalGoalScreen({super.key});

  @override
  State<PersonalGoalScreen> createState() => _PersonalGoalScreenState();
}

class _PersonalGoalScreenState extends State<PersonalGoalScreen> {
  String _selectedGoal = 'nutrition';
  final _specificGoalController = TextEditingController();

  final List<Map<String, dynamic>> _goals = const [
    {
      'id': 'health_concern',
      'label': 'Understand a health concern',
      'icon': Icons.medical_services_outlined,
    },
    {
      'id': 'nutrition',
      'label': 'Improve everyday nutrition',
      'icon': Icons.restaurant_outlined,
    },
    {
      'id': 'weight',
      'label': 'Manage my weight',
      'icon': Icons.scale_outlined,
    },
    {
      'id': 'fitness',
      'label': 'Improve fitness and recovery',
      'icon': Icons.monitor_heart_outlined,
    },
    {
      'id': 'supplements',
      'label': 'Understand foods or supplements',
      'icon': Icons.medication_outlined,
    },
    {
      'id': 'explore',
      'label': 'Explore another topic',
      'icon': Icons.explore_outlined,
    },
  ];

  @override
  void dispose() {
    _specificGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NETokens.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Soil Profile Analysis',
          style: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: NETokens.onSurface,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Step 1 of 4',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: NETokens.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: NETokens.space20, vertical: NETokens.space12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What would you like to improve first?',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: NETokens.onSurface,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: NETokens.space6),
              Text(
                'Pick one area to begin with. You can change this or add more anytime.',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: NETokens.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: NETokens.space20),

              // Goal options
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _goals.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = _goals[index];
                  final isSelected = _selectedGoal == item['id'];

                  return InkWell(
                    onTap: () => setState(() => _selectedGoal = item['id'] as String),
                    borderRadius: BorderRadius.circular(NETokens.radiusMd),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? NETokens.secondaryContainer.withOpacity(0.4)
                            : NETokens.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(NETokens.radiusMd),
                        border: Border.all(
                          color: isSelected
                              ? NETokens.secondary
                              : NETokens.outlineVariant.withOpacity(0.5),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? NETokens.secondaryContainer
                                  : NETokens.surfaceContainer,
                              borderRadius: BorderRadius.circular(NETokens.radiusSm),
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              size: 18,
                              color: isSelected
                                  ? NETokens.onSecondaryContainer
                                  : NETokens.secondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item['label'] as String,
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: NETokens.onSurface,
                              ),
                            ),
                          ),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? NETokens.primaryContainer
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? NETokens.primaryContainer
                                    : NETokens.outlineVariant,
                                width: 1.5,
                              ),
                            ),
                            child: isSelected
                                ? const Center(
                                    child: Icon(
                                      Icons.circle,
                                      size: 8,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: NETokens.space20),

              // Specific goal text area
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Anything specific you want to focus on?',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: NETokens.onSurface,
                    ),
                  ),
                  Text(
                    'Optional',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: NETokens.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: NETokens.space6),
              TextFormField(
                controller: _specificGoalController,
                maxLines: 3,
                maxLength: 280,
                decoration: InputDecoration(
                  hintText: 'Describe your goal in your own words (e.g. improve deep sleep)',
                  hintStyle: const TextStyle(color: NETokens.outline, fontSize: 13),
                  filled: true,
                  fillColor: NETokens.surfaceContainerLowest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(NETokens.radiusMd),
                    borderSide: const BorderSide(color: NETokens.outlineVariant),
                  ),
                ),
              ),

              const SizedBox(height: NETokens.space24),

              // Buttons
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NETokens.primaryContainer,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NETokens.radiusMd),
                    ),
                  ),
                  onPressed: () => context.go('/onboarding/diet'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: NETokens.space8),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/onboarding/diet'),
                  child: Text(
                    'Skip for now',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: NETokens.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

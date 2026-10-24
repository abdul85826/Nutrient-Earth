import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 14: Daily Routine Practical Constraints and Readiness
/// Authoritative Stitch Design: daily_routine_practical_constraints_and_readiness
class DailyRoutineConstraintsScreen extends StatefulWidget {
  const DailyRoutineConstraintsScreen({super.key});

  @override
  State<DailyRoutineConstraintsScreen> createState() =>
      _DailyRoutineConstraintsScreenState();
}

class _DailyRoutineConstraintsScreenState
    extends State<DailyRoutineConstraintsScreen> {
  String _selectedReadiness = 'small_changes';

  final List<Map<String, dynamic>> _options = const [
    {
      'id': 'small_changes',
      'title': 'Small, manageable changes',
      'description': 'Incremental micro-habits that fit smoothly into an existing daily routine.',
      'icon': Icons.spa_outlined,
    },
    {
      'id': 'structured_plan',
      'title': 'A structured plan',
      'description': 'Clear daily targets with specific schedules and tracking milestones.',
      'icon': Icons.checklist_rounded,
    },
    {
      'id': 'explore_first',
      'title': 'Explore options before deciding',
      'description': 'Prioritize understanding scientific evidence before committing to daily changes.',
      'icon': Icons.search_rounded,
    },
    {
      'id': 'not_sure',
      'title': 'Not sure yet',
      'description': 'Let Nutrient Earth suggest gentle starting points and adapt to your feedback.',
      'icon': Icons.help_outline_rounded,
    },
  ];

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
          'Baseline Verification',
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
                'Step 4 of 4',
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
                'What would make a plan realistic for you?',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: NETokens.onSurface,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: NETokens.space6),
              Text(
                'Understanding your preferred pace helps design recommendations you can actually sustain over time.',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: NETokens.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: NETokens.space24),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _options.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = _options[index];
                  final isSelected = _selectedReadiness == item['id'];

                  return InkWell(
                    onTap: () => setState(() => _selectedReadiness = item['id'] as String),
                    borderRadius: BorderRadius.circular(NETokens.radiusMd),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.all(16),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? NETokens.secondaryContainer
                                  : NETokens.surfaceContainer,
                              borderRadius: BorderRadius.circular(NETokens.radiusSm),
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              size: 20,
                              color: isSelected
                                  ? NETokens.onSecondaryContainer
                                  : NETokens.secondary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'] as String,
                                  style: GoogleFonts.manrope(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: NETokens.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['description'] as String,
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    height: 1.4,
                                    color: NETokens.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? NETokens.secondary : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? NETokens.secondary : NETokens.outlineVariant,
                                width: 1.5,
                              ),
                            ),
                            child: isSelected
                                ? const Center(
                                    child: Icon(Icons.check, size: 14, color: Colors.white),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: NETokens.space32),

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
                  onPressed: () => context.go('/onboarding/review'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue to review',
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
            ],
          ),
        ),
      ),
    );
  }
}

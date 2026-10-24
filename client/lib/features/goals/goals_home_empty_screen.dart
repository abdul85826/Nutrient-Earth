import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 21: Goals Home (Empty & Active State)
/// Primary Tab 1: /goals
/// Authoritative Stitch Design: goals_home_first_use_empty_state
class GoalsHomeEmptyScreen extends StatefulWidget {
  const GoalsHomeEmptyScreen({super.key});

  @override
  State<GoalsHomeEmptyScreen> createState() => _GoalsHomeEmptyScreenState();
}

class _GoalsHomeEmptyScreenState extends State<GoalsHomeEmptyScreen> {
  // If user has created a goal in session, show active goal card alongside create
  final bool _hasActiveGoal = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NETokens.surface,
      appBar: AppBar(
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.eco, size: 22, color: NETokens.secondary),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NUTRIENT EARTH',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: NETokens.secondary,
                  ),
                ),
                Text(
                  'Goals Home',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: NETokens.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded, color: NETokens.secondary),
            tooltip: 'Account Profile',
            onPressed: () => context.go('/profile/context'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: NETokens.outline),
            tooltip: 'Settings',
            onPressed: () => context.go('/profile/privacy'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: NETokens.space20, vertical: NETokens.space12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Tag & Intro
              Row(
                children: [
                  Text(
                    'ACTION PLAN',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: NETokens.secondary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: NETokens.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _hasActiveGoal ? 'Active Initiative' : 'Unconfigured',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: NETokens.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: NETokens.space4),

              Text(
                'Goals',
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: NETokens.onSurface,
                ),
              ),
              const SizedBox(height: NETokens.space4),
              Text(
                'Turn what matters to you into practical steps you can take and review over time.',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: NETokens.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: NETokens.space16),

              // Create a goal primary trigger button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NETokens.primaryContainer,
                    foregroundColor: const Color(0xFFC5EBDD),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NETokens.radiusMd),
                    ),
                  ),
                  onPressed: () => context.go('/goals/create'),
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  label: Text(
                    'Create a goal',
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: NETokens.space16),

              // Active Goal Card (If active)
              if (_hasActiveGoal) ...[
                Text(
                  'CURRENT INITIATIVE',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: NETokens.secondary,
                  ),
                ),
                const SizedBox(height: 8),

                InkWell(
                  onTap: () => context.go('/goals/detail'),
                  borderRadius: BorderRadius.circular(NETokens.radiusLg),
                  child: Container(
                    padding: const EdgeInsets.all(NETokens.space16),
                    decoration: BoxDecoration(
                      color: NETokens.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(NETokens.radiusLg),
                      border: Border.all(color: NETokens.secondary.withOpacity(0.4), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: NETokens.secondaryContainer,
                                borderRadius: BorderRadius.circular(NETokens.radiusFull),
                              ),
                              child: Text(
                                'DAY 4 OF 21',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: NETokens.onSecondaryContainer,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.local_fire_department, size: 16, color: Color(0xFFB45309)),
                                const SizedBox(width: 4),
                                Text(
                                  '3 day streak',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Consistent Evening Sleep Routine',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: NETokens.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Next Action: Establish 30-Minute Screen-Free Wind-Down & Magnesium Glycinate Timing',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: NETokens.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              'View practical plan',
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: NETokens.secondary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_rounded, size: 15, color: NETokens.secondary),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: NETokens.space16),
              ],

              // Serene First-Use Botanical Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(NETokens.space20),
                decoration: BoxDecoration(
                  color: NETokens.primaryContainer,
                  borderRadius: BorderRadius.circular(NETokens.radiusLg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: NETokens.secondary.withOpacity(0.35),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.yard_outlined, size: 24, color: Color(0xFFC5EBDD)),
                      ),
                    ),
                    const SizedBox(height: NETokens.space14),
                    Text(
                      'Your goals start with what matters to you.',
                      style: GoogleFonts.manrope(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFC5EBDD),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Create a goal to begin building a practical plan around your priorities and circumstances.',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: const Color(0xFFA9CEC2),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.spa_outlined, size: 14, color: Color(0xFFBBEDDC)),
                        const SizedBox(width: 6),
                        Text(
                          'Awaiting your first initiative',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: const Color(0xFFBBEDDC),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: NETokens.space16),

              // Bridge to Research
              Container(
                padding: const EdgeInsets.all(NETokens.space16),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainer,
                  borderRadius: BorderRadius.circular(NETokens.radiusMd),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: NETokens.secondaryContainer,
                        borderRadius: BorderRadius.circular(NETokens.radiusSm),
                      ),
                      child: const Icon(Icons.biotech_outlined, size: 20, color: NETokens.onSecondaryContainer),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Have an active inquiry?',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: NETokens.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Turn findings into a goal directly from any research answer.',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: NETokens.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => context.go('/research'),
                            child: Row(
                              children: [
                                Text(
                                  'Go to research findings',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: NETokens.secondary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_rounded, size: 13, color: NETokens.secondary),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: NETokens.space20),

              Center(
                child: TextButton.icon(
                  onPressed: () => context.go('/support/feedback'),
                  icon: const Icon(Icons.help_outline_rounded, size: 16, color: NETokens.outline),
                  label: Text(
                    'Feedback & report a problem',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: NETokens.outline,
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

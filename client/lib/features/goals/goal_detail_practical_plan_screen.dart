import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 23: Goal Detail & Practical Plan
/// Route: /goals/detail
/// Authoritative Stitch Reference: goal_detail_practical_plan
class GoalDetailPracticalPlanScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const GoalDetailPracticalPlanScreen({
    super.key,
    this.initialData,
  });

  @override
  State<GoalDetailPracticalPlanScreen> createState() =>
      _GoalDetailPracticalPlanScreenState();
}

class _GoalDetailPracticalPlanScreenState
    extends State<GoalDetailPracticalPlanScreen> {
  int _selectedActionIndex = 0;

  @override
  Widget build(BuildContext context) {
    final title = widget.initialData?['title'] as String? ??
        'Consistent Evening Sleep Routine';
    final outcome = widget.initialData?['outcome'] as String? ??
        'Improve restorative sleep latency and calm evening nervous system without next-day grogginess.';
    final constraints = widget.initialData?['constraints'] as String? ??
        'Limited evening preparation time (15–20 mins); avoiding stimulant ingredients.';

    return Scaffold(
      backgroundColor: NETokens.surface,
      appBar: AppBar(
        backgroundColor: NETokens.surface.withValues(alpha: 0.85),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NETokens.onSurface),
          onPressed: () => context.pop(),
          tooltip: 'Navigate back',
        ),
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                width: 24,
                height: 24,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.eco, size: 20, color: NETokens.secondary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Goal Detail',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: NETokens.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: NETokens.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: NETokens.onPrimary, size: 18),
            ),
            onPressed: () => context.push('/profile/context'),
            tooltip: 'Account profile',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Secondary Back & Subheader Navigation Breadcrumb
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => context.go('/goals'),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.west, size: 15, color: NETokens.secondary),
                          const SizedBox(width: 4),
                          Text(
                            'GOALS',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: NETokens.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: NETokens.secondaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: NETokens.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'PHASE 01 — PLANNING',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6,
                            color: NETokens.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Goal Header Dossier Card
              Container(
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: NETokens.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.verified,
                                size: 13,
                                color: NETokens.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'ACTIVE GOAL DEFINITION',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                  color: NETokens.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'ID #GL-9482',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: NETokens.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: NETokens.onSurface,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      outcome,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: NETokens.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Context Provided Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: NETokens.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.tune,
                            size: 16,
                            color: NETokens.secondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CONTEXT PROVIDED',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: NETokens.secondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  constraints,
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    color: NETokens.onSurfaceVariant,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Target & Edit Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.psychology_outlined,
                              size: 15,
                              color: NETokens.secondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Target: Delta wave stability',
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: NETokens.secondary,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => context.push('/goals/create'),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: NETokens.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.edit,
                                  size: 12,
                                  color: NETokens.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Edit goal',
                                  style: GoogleFonts.manrope(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: NETokens.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Practical Action Plan Header
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: NETokens.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Practical Action Plan',
                    style: GoogleFonts.manrope(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: NETokens.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "A useful plan should fit your circumstances and the outcome you're working toward. Select an achievable first action to evaluate.",
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: NETokens.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),

              // Action Card 1: Proposed First Action
              _buildActionCard(
                index: 0,
                badge: 'PROPOSED FIRST ACTION',
                badgeColor: NETokens.secondaryContainer,
                badgeTextColor: NETokens.onSecondaryContainer,
                duration: '~10 mins',
                title:
                    'Establish 30-Minute Screen-Free Wind-Down & Magnesium Glycinate Timing',
                body:
                    'Pair taking chelated magnesium bisglycinate with warm water 45 minutes before sleep with dimming ambient lights.',
                feasibility: 'Feasibility: High — No complex equipment',
                fitScore: '98% Adherence fit',
                onInspect: () => context.push('/goals/action'),
              ),
              const SizedBox(height: 12),

              // Action Card 2: Alternative Option
              _buildActionCard(
                index: 1,
                badge: 'ALTERNATIVE OPTION',
                badgeColor: NETokens.surfaceContainerHighest,
                badgeTextColor: NETokens.onSurfaceVariant,
                duration: '~5 mins',
                title: 'Evening Herbal Infusion & Breathing Reset',
                body:
                    'Gentle non-caffeinated chamomile/lemon balm tea with 5 minutes of relaxed diaphragmatic breathing.',
                feasibility: 'Feasibility: High — Gentle baseline',
                fitScore: '92% Adherence fit',
                onInspect: () => context.push('/goals/action'),
              ),
              const SizedBox(height: 12),

              // Action Card 3: Environmental
              _buildActionCard(
                index: 2,
                badge: 'ENVIRONMENTAL ADJUSTMENT',
                badgeColor: NETokens.surfaceContainerHighest,
                badgeTextColor: NETokens.onSurfaceVariant,
                duration: '~15 mins',
                title: 'Circadian Lux Shifting & Bedroom Thermal Drop',
                body:
                    'Lower room temperature to 66°F (19°C) and eliminate blue-enriched light after 9 PM to support natural melatonin synthesis.',
                feasibility: 'Feasibility: Medium — Thermostat control',
                fitScore: '89% Adherence fit',
                onInspect: () => context.push('/goals/action'),
              ),
              const SizedBox(height: 24),

              // Actions: Check-in & Commit
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => context.push('/goals/checkin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NETokens.primaryContainer,
                    foregroundColor: NETokens.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.fact_check_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Record a check-in',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () => context.push('/goals/action'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: NETokens.secondary,
                    side: BorderSide(
                      color: NETokens.secondary.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Evaluate selected action in detail',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required int index,
    required String badge,
    required Color badgeColor,
    required Color badgeTextColor,
    required String duration,
    required String title,
    required String body,
    required String feasibility,
    required String fitScore,
    required VoidCallback onInspect,
  }) {
    final isSelected = _selectedActionIndex == index;

    return InkWell(
      onTap: () => setState(() => _selectedActionIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? NETokens.surfaceContainerLowest
              : NETokens.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? NETokens.primaryContainer
                : NETokens.outlineVariant.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: NETokens.primary.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badge,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: NETokens.surfaceContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 11,
                            color: NETokens.onSurfaceVariant,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            duration,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              color: NETokens.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? NETokens.primary
                        : NETokens.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 14,
                    color: isSelected ? NETokens.onPrimary : Colors.transparent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: NETokens.onSurface,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              body,
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: NETokens.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: NETokens.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.eco, size: 13, color: NETokens.secondary),
                      const SizedBox(width: 4),
                      Text(
                        feasibility,
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: NETokens.secondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: NETokens.primaryFixed.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      fitScore,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: NETokens.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onInspect,
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.arrow_forward, size: 14),
                label: Text(
                  'Evaluate & inspect action',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: NETokens.secondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

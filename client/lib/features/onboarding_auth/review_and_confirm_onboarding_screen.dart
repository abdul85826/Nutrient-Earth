import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 15: Review and Confirm Onboarding Information
/// Authoritative Stitch Design: review_and_confirm_onboarding_information
class ReviewAndConfirmOnboardingScreen extends StatelessWidget {
  const ReviewAndConfirmOnboardingScreen({super.key});

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
          'Review your information',
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: NETokens.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: NETokens.space20, vertical: NETokens.space12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Review your context',
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: NETokens.onSurface,
                ),
              ),
              const SizedBox(height: NETokens.space6),
              Text(
                'Verify your starting selections before opening your research workspace. You can update these anytime in your profile.',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: NETokens.onSurfaceVariant,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: NETokens.space20),

              // 4 Review Summary Cards
              _ReviewCard(
                title: 'PRIMARY FOCUS & GOAL',
                value: 'Improve everyday nutrition & sleep recovery',
                onEdit: () => context.go('/onboarding/goals'),
              ),
              const SizedBox(height: NETokens.space12),
              _ReviewCard(
                title: 'DIETARY PATTERNS',
                value: 'Mediterranean • No specific restrictions',
                onEdit: () => context.go('/onboarding/diet'),
              ),
              const SizedBox(height: NETokens.space12),
              _ReviewCard(
                title: 'HEALTH CONTEXT CONSIDERATIONS',
                value: 'Sleep disruption / Insomnia management',
                onEdit: () => context.go('/onboarding/health-context'),
              ),
              const SizedBox(height: NETokens.space12),
              _ReviewCard(
                title: 'PACE & READINESS',
                value: 'Small, manageable changes',
                onEdit: () => context.go('/onboarding/constraints'),
              ),

              const SizedBox(height: NETokens.space24),

              // Trust & Transparency Card
              Container(
                padding: const EdgeInsets.all(NETokens.space16),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainer,
                  borderRadius: BorderRadius.circular(NETokens.radiusMd),
                  border: Border.all(color: NETokens.outlineVariant, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: NETokens.secondaryContainer,
                        borderRadius: BorderRadius.circular(NETokens.radiusSm),
                      ),
                      child: const Icon(Icons.verified_user_outlined, size: 18, color: NETokens.onSecondaryContainer),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trust & Transparency',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: NETokens.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your preferences are stored privately and used only to calibrate evidence synthesis and recommended daily actions.',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              height: 1.4,
                              color: NETokens.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: NETokens.space28),

              // Confirm and continue button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NETokens.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NETokens.radiusFull),
                    ),
                  ),
                  onPressed: () => context.go('/research'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Confirm and continue',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
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

class _ReviewCard extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onEdit;

  const _ReviewCard({
    required this.title,
    required this.value,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NETokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(NETokens.radiusMd),
        border: Border.all(color: NETokens.outlineVariant, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: NETokens.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: NETokens.onSurface,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18, color: NETokens.secondary),
            onPressed: onEdit,
            tooltip: 'Edit $title',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 3: Onboarding Welcome Roadmap
/// Authoritative Stitch Design: screen_3_onboarding_welcome_mobile
class Screen3OnboardingWelcomeMobile extends StatelessWidget {
  const Screen3OnboardingWelcomeMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NETokens.primaryContainer,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: NETokens.space20, vertical: NETokens.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.eco, size: 20, color: Color(0xFFC5EBDD)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'NUTRIENT EARTH',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: const Color(0xFFC5EBDD),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF002614),
                      borderRadius: BorderRadius.circular(NETokens.radiusFull),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Color(0xFFC3ECCF),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Getting started',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFC3ECCF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: NETokens.space16),

              // Step Indicator Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(NETokens.radiusFull),
                    child: LinearProgressIndicator(
                      value: 0.33,
                      minHeight: 6,
                      backgroundColor: NETokens.primary,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFBBEDDC)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'STEP 1 OF 3',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          letterSpacing: 1.0,
                          color: const Color(0xFF6B8E83),
                        ),
                      ),
                      Text(
                        'Foundations',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B8E83),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: NETokens.space20),

              // Hero Statement
              Row(
                children: [
                  const Icon(Icons.eco, size: 15, color: Color(0xFFC5EBDD)),
                  const SizedBox(width: 4),
                  Text(
                    'Personalized Soil-to-Cell Intelligence',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: const Color(0xFFC5EBDD),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: NETokens.space8),
              Text(
                'Let’s make this useful for you.',
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFC5EBDD),
                ),
              ),
              const SizedBox(height: NETokens.space8),
              Text(
                'Share only what you’re comfortable sharing. We’ll use the context you provide to help make your research and goals more relevant.',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: const Color(0xFFA9CEC2),
                ),
              ),

              const SizedBox(height: NETokens.space24),

              // 3 Capability Cards
              _CapabilityCard(
                icon: Icons.menu_book_rounded,
                title: 'Research with evidence',
                tag: 'Indexed',
                description:
                    'Explore health and nutrition questions with clear explanations, supporting sources, and uncertainty where it matters.',
              ),
              const SizedBox(height: NETokens.space12),
              _CapabilityCard(
                icon: Icons.checklist_rounded,
                title: 'Practical next steps',
                tag: 'Actionable',
                description:
                    'Turn what you learn into manageable actions that fit your circumstances and natural biological pace.',
              ),
              const SizedBox(height: NETokens.space12),
              _CapabilityCard(
                icon: Icons.explore_rounded,
                title: 'Goals that adapt',
                tag: 'Dynamic',
                description:
                    'Review your progress and adjust your plan as your needs, lab biomarkers, and seasonal rhythms change.',
              ),

              const SizedBox(height: NETokens.space16),

              // Privacy Notice
              Container(
                padding: const EdgeInsets.all(NETokens.space12),
                decoration: BoxDecoration(
                  color: NETokens.primary.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(NETokens.radiusMd),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lock_outline, size: 16, color: Color(0xFFBBEDDC)),
                    const SizedBox(width: NETokens.space8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: const Color(0xFFA9CEC2),
                            height: 1.4,
                          ),
                          children: const [
                            TextSpan(
                              text: 'You control what you share. ',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFC5EBDD),
                              ),
                            ),
                            TextSpan(
                              text:
                                  'You can review your information and available privacy settings anytime later.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: NETokens.space24),

              // Actions
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NETokens.secondary,
                    foregroundColor: const Color(0xFFC3ECCF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NETokens.radiusMd),
                    ),
                  ),
                  onPressed: () => context.go('/onboarding/intent'),
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
                  onPressed: () => context.go('/auth/gateway'),
                  child: Text(
                    'Skip for now',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFA9CEC2),
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

class _CapabilityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String tag;
  final String description;

  const _CapabilityCard({
    required this.icon,
    required this.title,
    required this.tag,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(NETokens.space16),
      decoration: BoxDecoration(
        color: const Color(0xFF002614).withOpacity(0.8),
        borderRadius: BorderRadius.circular(NETokens.radiusMd),
        border: Border.all(
          color: const Color(0xFFBBEDDC).withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: NETokens.primaryContainer,
              borderRadius: BorderRadius.circular(NETokens.radiusSm),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFFBBEDDC)),
          ),
          const SizedBox(width: NETokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFC5EBDD),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: NETokens.primary.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(NETokens.radiusXs),
                      ),
                      child: Text(
                        tag,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B8E83),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: NETokens.space4),
                Text(
                  description,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    height: 1.4,
                    color: const Color(0xFFA9CEC2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

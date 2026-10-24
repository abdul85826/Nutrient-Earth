import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 2: Brand Introduction
/// Authoritative Stitch Design: screen_2_brand_introduction_mobile
class Screen2BrandIntroductionMobile extends StatelessWidget {
  const Screen2BrandIntroductionMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NETokens.primaryContainer,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: NETokens.space24, vertical: NETokens.space20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  40,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Telemetry Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: NETokens.secondaryContainer.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(NETokens.radiusFull),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFFC3ECCF),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'LAB v2.4 VERIFIED',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                              color: const Color(0xFFBBEDDC),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.shield_outlined,
                          size: 15,
                          color: Color(0xFFBBEDDC),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '256-BIT AES',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            letterSpacing: 0.8,
                            color: const Color(0xFF9FD1C1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: NETokens.space24),

                // Center Identity & Value Proposition
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Emblem
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFBBEDDC).withOpacity(0.35),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: NETokens.secondary,
                            child: const Icon(Icons.eco, size: 54, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: NETokens.space20),

                    // Title
                    Text(
                      'Nutrient Earth',
                      style: GoogleFonts.manrope(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: const Color(0xFFC3ECCF),
                      ),
                    ),
                    const SizedBox(height: NETokens.space8),

                    // Evidence First Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: NETokens.secondary.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(NETokens.radiusFull),
                        border: Border.all(
                          color: const Color(0xFFBBEDDC).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: Color(0xFFBBEDDC),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'EVIDENCE-FIRST INTELLIGENCE',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                              color: const Color(0xFFBBEDDC),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: NETokens.space20),

                    // Core Value Statement
                    Text(
                      'Understand your health.\nMake informed choices.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: const Color(0xFFC3ECCF),
                      ),
                    ),
                    const SizedBox(height: NETokens.space12),

                    // Subtitle
                    Text(
                      'Explore evidence, understand your options, and build practical habits around your personal metabolic goals.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        color: const Color(0xFF9FD1C1).withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: NETokens.space24),

                    // Micro-feature Chips
                    Row(
                      children: [
                        Expanded(
                          child: _MicroFeatureChip(
                            icon: Icons.biotech_outlined,
                            label: 'Clinical Data',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MicroFeatureChip(
                            icon: Icons.monitor_heart_outlined,
                            label: 'Bio-Adaptive',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MicroFeatureChip(
                            icon: Icons.spa_outlined,
                            label: 'Whole Organics',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: NETokens.space32),

                // Bottom Action Buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: NETokens.secondary,
                          foregroundColor: const Color(0xFFC3ECCF),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(NETokens.radiusMd),
                          ),
                        ),
                        onPressed: () => context.go('/onboarding/intro'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Get started',
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
                    const SizedBox(height: NETokens.space12),
                    TextButton(
                      onPressed: () => context.go('/auth/signin'),
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: const Color(0xFF9FD1C1).withOpacity(0.8),
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign in',
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFBBEDDC),
                                decoration: TextDecoration.underline,
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
        ),
      ),
    );
  }
}

class _MicroFeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MicroFeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE4E2DD).withOpacity(0.08),
        borderRadius: BorderRadius.circular(NETokens.radiusMd),
        border: Border.all(
          color: const Color(0xFFBBEDDC).withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFBBEDDC)),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF9FD1C1),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

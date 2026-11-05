// ==============================================================================
// Nutrient Earth — Screen 02: Welcome Screen (Stitch Ref: nutrient_earth_welcome_screen_botanical_evidence_edition)
// Botanical specimen verification edition with floating bio-signals, editorial serif
// typography, honest non-miracle guidance, and primary actions.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NETokens.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Brand Header
                  Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: NETokens.surfaceContainer,
                          border: Border.all(color: NETokens.borderDefault),
                        ),
                        child: const Center(
                          child: Icon(Icons.eco_rounded, size: 28, color: NETokens.forest),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'NUTRIENT EARTH',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.8,
                          color: NETokens.darkEvergreen,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'EVIDENCE COMPANION',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.6,
                          color: NETokens.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Editorial Headline
                  Text(
                    'Your health is a journey.\nUnderstand what shapes it.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.newsreader(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: NETokens.darkEvergreen,
                      height: 1.2,
                      letterSpacing: -0.4,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Explore your body\'s signals, discover nutrition that fits your goals, investigate scientific research, and find practical ways to improve your everyday habits.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      color: NETokens.textSecondary,
                      height: 1.55,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: NETokens.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(NETokens.radiusFull),
                      border: Border.all(color: NETokens.borderDefault),
                    ),
                    child: Text(
                      'RESEARCH • NUTRITION • MOVEMENT • HEALTH',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: NETokens.deepestForest,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Center Botanical Specimen Illustration with Bio-signal Badges
                  SizedBox(
                    height: 220,
                    width: 280,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Soft green aura
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: NETokens.paleMint.withValues(alpha: 0.6),
                          ),
                        ),
                        // Specimen Art Canvas
                        Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            color: NETokens.surfaceContainerLow,
                            border: Border.all(color: NETokens.borderDefault),
                            boxShadow: NETokens.cardShadow,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.spa_rounded,
                              size: 72,
                              color: NETokens.botanicalTeal,
                            ),
                          ),
                        ),
                        // Floating Badge 1: Body Signals
                        Positioned(
                          top: 8,
                          left: 0,
                          child: _buildBioBadge(Icons.monitor_heart_outlined, 'Body signals'),
                        ),
                        // Floating Badge 2: Evidence answers
                        Positioned(
                          top: 18,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => context.push('/processing-view'),
                            child: _buildBioBadge(Icons.verified_outlined, 'Evidence answers'),
                          ),
                        ),
                        // Floating Badge 3: Nutrition
                        Positioned(
                          bottom: 12,
                          left: 8,
                          child: _buildBioBadge(Icons.restaurant_rounded, 'Nutrition'),
                        ),
                        // Floating Badge 4: Movement
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: _buildBioBadge(Icons.directions_run_rounded, 'Movement'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Honesty Disclaimer & Primary Actions
                  Text(
                    'No miracle promises. Just evidence to explore, knowledge to build, and better-informed choices to make.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: NETokens.textMuted,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => context.go('/auth?mode=signup'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NETokens.darkEvergreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(NETokens.radiusFull),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Get started',
                            style: GoogleFonts.manrope(fontSize: 15.5, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () => context.go('/auth?mode=signin'),
                      style: TextButton.styleFrom(
                        foregroundColor: NETokens.botanicalTeal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(NETokens.radiusFull),
                        ),
                      ),
                      child: Text(
                        'I already have an account',
                        style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  TextButton(
                    onPressed: () => context.push('/processing-view'),
                    style: TextButton.styleFrom(
                      foregroundColor: NETokens.forest,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF2E7D32)),
                          const SizedBox(width: 6),
                          Text(
                            'Preview Multimodal Evidence AI →',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBioBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(NETokens.radiusFull),
        border: Border.all(color: NETokens.borderDefault),
        boxShadow: NETokens.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: NETokens.botanicalTeal),
          const SizedBox(width: 5),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: NETokens.darkEvergreen,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}


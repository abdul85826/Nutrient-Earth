import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 38: Accessibility & Alternate Input States
/// Route: /status/a11y
/// Authoritative Stitch Reference: accessibility_alternate_input_states
class AccessibilityAlternateInputScreen extends StatefulWidget {
  const AccessibilityAlternateInputScreen({super.key});

  @override
  State<AccessibilityAlternateInputScreen> createState() =>
      _AccessibilityAlternateInputScreenState();
}

class _AccessibilityAlternateInputScreenState
    extends State<AccessibilityAlternateInputScreen> {
  bool _isScaled200 = false;
  bool _reducedMotion = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NETokens.surface,
      appBar: AppBar(
        backgroundColor: NETokens.surface.withValues(alpha: 0.85),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NETokens.onSurface),
          onPressed: () => Navigator.pop(context),
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
              'Accessibility Audit',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: NETokens.onSurface,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Badge & Introductions
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: NETokens.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.accessibility_new,
                      size: 14,
                      color: NETokens.onSecondaryContainer,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ACCESSIBILITY STANDARDS • WCAG 2.2 AA / SECTION 508',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: NETokens.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Accessibility & Input States',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: NETokens.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rigorous ergonomic adaptations ensuring equitable, non-discriminatory scientific comprehension across diverse cognitive, visual, and motor abilities.',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: NETokens.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),

              // Section 1: Dynamic Text Scaling (200% Font Scale Demonstration)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.format_size,
                              size: 18,
                              color: NETokens.secondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '1. DYNAMIC TEXT SCALING',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: NETokens.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _isScaled200,
                          onChanged: (val) => setState(() => _isScaled200 = val),
                          activeColor: NETokens.secondary,
                        ),
                      ],
                    ),
                    Text(
                      _isScaled200 ? 'Active scale: 200%' : 'Active scale: 100% (Baseline)',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: NETokens.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: NETokens.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Magnesium Bisglycinate Bioavailability & Sleep Architecture',
                            style: GoogleFonts.manrope(
                              fontSize: _isScaled200 ? 20 : 13,
                              fontWeight: FontWeight.w800,
                              color: NETokens.onSurface,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Text container reflows naturally with zero truncation, ellipsis, or hidden data layers when scaled to 200% system font size.',
                            style: GoogleFonts.manrope(
                              fontSize: _isScaled200 ? 16 : 12,
                              color: NETokens.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Section 2: Screen Reader Semantics & ARIA
              _buildFeatureCard(
                icon: Icons.record_voice_over,
                title: '2. SCREEN READER SEMANTICS & ACCESSIBLE LABELS',
                desc:
                    'All interactive controls possess explicit Semantics widgets with label, hint, and state information for TalkBack and VoiceOver navigation.',
              ),
              const SizedBox(height: 14),

              // Section 3: Keyboard Sequence & Focus Indicators
              _buildFeatureCard(
                icon: Icons.keyboard_alt_outlined,
                title: '3. KEYBOARD SEQUENCE & FOCUS RINGS',
                desc:
                    'Sequential tab-order traversal with distinct 3px high-contrast outline focus rings meeting WCAG 2.2 AA non-text contrast guidelines (>3:1).',
              ),
              const SizedBox(height: 14),

              // Section 4: Reduced Motion Compliance
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.motion_photos_off_outlined,
                                size: 18,
                                color: NETokens.secondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '4. REDUCED MOTION COMPLIANCE',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                  color: NETokens.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Instantly swaps out spring physics and pulsing indicators for simple static transitions when prefers-reduced-motion is requested.',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: NETokens.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _reducedMotion,
                      onChanged: (val) =>
                          setState(() => _reducedMotion = val),
                      activeColor: NETokens.secondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Section 5: Touch Targets & Non-Color Validation
              _buildFeatureCard(
                icon: Icons.touch_app_outlined,
                title: '5. TOUCH TARGETS (48x48 DP) & NON-COLOR CUES',
                desc:
                    'Every button, chip, and slider hit-test box strictly adheres to the 48x48 dp minimum bounding box. Error and success states always incorporate distinct iconography alongside color.',
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NETokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: NETokens.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: NETokens.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: NETokens.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

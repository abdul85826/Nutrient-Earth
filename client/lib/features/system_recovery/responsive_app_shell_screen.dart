import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 36: Responsive App Shell (Multi-Viewport Layout Engine)
/// Route: /shell
/// Authoritative Stitch Reference: responsive_app_shell
class ResponsiveAppShellScreen extends StatefulWidget {
  const ResponsiveAppShellScreen({super.key});

  @override
  State<ResponsiveAppShellScreen> createState() =>
      _ResponsiveAppShellScreenState();
}

class _ResponsiveAppShellScreenState extends State<ResponsiveAppShellScreen> {
  String _selectedBreakpoint = 'mobile'; // mobile, tablet, desktop

  @override
  Widget build(BuildContext context) {
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
              'Responsive Architecture',
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
            icon: const Icon(Icons.verified, color: NETokens.secondary, size: 20),
            onPressed: () => context.push('/audit/consistency'),
            tooltip: 'System Audit',
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
              // Header Badge & Framing
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
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: NETokens.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'RESPONSIVE ARCHITECTURE • BREAKPOINT MATRIX v2.4',
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Responsive App Shell',
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: NETokens.onSurface,
                    ),
                  ),
                  Text(
                    'NE-SPEC-SHL-2025',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: NETokens.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'A unified layout engine adapting seamlessly from narrow mobile viewports to wide scientific research workstations without fragmenting navigation or cryptographic telemetry integrity.',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: NETokens.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),

              // Interactive Device Viewport Simulator Switcher
              Container(
                padding: const EdgeInsets.all(14),
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
                              Icons.devices,
                              size: 18,
                              color: NETokens.secondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ACTIVE TOPOLOGY SIMULATION',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: NETokens.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Selector Bar
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: NETokens.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          _buildBreakpointBtn(
                            'mobile',
                            Icons.stay_current_portrait,
                            'Mobile 390px',
                          ),
                          _buildBreakpointBtn(
                            'tablet',
                            Icons.tablet_mac,
                            'Tablet 768px',
                          ),
                          _buildBreakpointBtn(
                            'desktop',
                            Icons.desktop_mac,
                            'Web 1280px+',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Live Preview Canvas Frame
                    Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _selectedBreakpoint == 'mobile'
                            ? 320
                            : (_selectedBreakpoint == 'tablet' ? 440 : 540),
                        decoration: BoxDecoration(
                          color: NETokens.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: NETokens.outlineVariant.withValues(alpha: 0.4),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Simulated Header
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: NETokens.surface.withValues(alpha: 0.9),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(14),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: NETokens.primaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'NE',
                                            style: GoogleFonts.jetBrainsMono(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: NETokens.onPrimary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'NUTRIENT EARTH',
                                            style: GoogleFonts.jetBrainsMono(
                                              fontSize: 7,
                                              fontWeight: FontWeight.w700,
                                              color: NETokens.secondary,
                                            ),
                                          ),
                                          Text(
                                            'Specimen Feed',
                                            style: GoogleFonts.manrope(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: NETokens.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: NETokens.secondaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '99.4% VERIFIED',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 7,
                                        fontWeight: FontWeight.w700,
                                        color: NETokens.onSecondaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Simulated Content
                            Container(
                              padding: const EdgeInsets.all(12),
                              color: NETokens.surfaceContainerLow,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: NETokens.surfaceContainerLowest,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'ACTIVE DOSSIER #492-B',
                                              style: GoogleFonts.jetBrainsMono(
                                                fontSize: 8,
                                                fontWeight: FontWeight.w700,
                                                color: NETokens.secondary,
                                              ),
                                            ),
                                            Text(
                                              'SPECTRUM OK',
                                              style: GoogleFonts.jetBrainsMono(
                                                fontSize: 7,
                                                color: NETokens.onPrimaryContainer,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Soil Phytochemical Biomarker Synthesis',
                                          style: GoogleFonts.manrope(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: NETokens.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Simulated Dual-Tab Navigation (Strictly 2 Tabs: Research & Goals)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: const BoxDecoration(
                                color: NETokens.surface,
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(14),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        const Icon(
                                          Icons.biotech,
                                          size: 16,
                                          color: NETokens.secondary,
                                        ),
                                        Text(
                                          'Research',
                                          style: GoogleFonts.manrope(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: NETokens.secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        const Icon(
                                          Icons.flag_circle,
                                          size: 16,
                                          color: NETokens.onSurfaceVariant,
                                        ),
                                        Text(
                                          'Goals',
                                          style: GoogleFonts.manrope(
                                            fontSize: 9,
                                            color: NETokens.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Breakpoint Specifications Grid
              _buildSpecCard(
                title: 'Mobile Shell',
                badge: '390px COMPACT',
                icon: Icons.stay_current_portrait,
                desc:
                    'Engineered for thumb-driven one-handed reach with bottom app bar hosting strictly two primary destinations (Research & Goals) and modal contextual sheets.',
              ),
              const SizedBox(height: 10),
              _buildSpecCard(
                title: 'Tablet / Mid-Width',
                badge: '768px ADAPTIVE',
                icon: Icons.tablet_mac,
                desc:
                    'Side navigation rail with expanded dossier dual-column panels. Contextual food analysis docks smoothly alongside evidence citations.',
              ),
              const SizedBox(height: 10),
              _buildSpecCard(
                title: 'Web Workstation',
                badge: '1280px+ WORKSPACE',
                icon: Icons.desktop_mac,
                desc:
                    'Three-column workstation layout: persistent primary navigation, central inquiry synthesis, and right-hand corroborating literature inspector.',
              ),
              const SizedBox(height: 20),

              // Architectural Inviolables
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ARCHITECTURAL INVIOLABLES',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: NETokens.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInviolableRow('1', 'Exactly two primary navigation tabs: Research & Goals.'),
                    _buildInviolableRow('2', 'Food analysis remains strictly contextual within Research.'),
                    _buildInviolableRow('3', 'History, Profile, Privacy, and Feedback remain secondary destinations.'),
                    _buildInviolableRow('4', 'Canonical 6-color botanical palette preserved across all viewports.'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakpointBtn(String id, IconData icon, String label) {
    final isSelected = _selectedBreakpoint == id;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedBreakpoint = id),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? NETokens.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? NETokens.onPrimary : NETokens.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? NETokens.onPrimary
                      : NETokens.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecCard({
    required String title,
    required String badge,
    required IconData icon,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NETokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: NETokens.secondary),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: NETokens.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: NETokens.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: NETokens.onSecondaryContainer,
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

  Widget _buildInviolableRow(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$num. ',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: NETokens.secondary,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: NETokens.onSurface,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

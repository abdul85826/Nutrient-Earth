import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 40: Product-Wide Design System & Consistency Audit
/// Route: /audit/consistency
/// Authoritative Stitch Reference: product_wide_consistency_audit
class ProductWideConsistencyAuditScreen extends StatefulWidget {
  const ProductWideConsistencyAuditScreen({super.key});

  @override
  State<ProductWideConsistencyAuditScreen> createState() =>
      _ProductWideConsistencyAuditScreenState();
}

class _ProductWideConsistencyAuditScreenState
    extends State<ProductWideConsistencyAuditScreen> {
  final List<Map<String, String>> _colorMatrix = [
    {
      'hex': '#FBF9F4',
      'name': 'Light Cream Surface',
      'role': 'Base background & canvas'
    },
    {
      'hex': '#000A06',
      'name': 'Deep Obsidian',
      'role': 'On-surface & primary text'
    },
    {
      'hex': '#38675A',
      'name': 'Botanical Sage Green',
      'role': 'Primary brand accent'
    },
    {
      'hex': '#B8EADA',
      'name': 'Secondary Sage Mint',
      'role': 'Badges & active container'
    },
    {
      'hex': '#00251D',
      'name': 'Dark Pine Forest',
      'role': 'Primary container & high contrast'
    },
    {
      'hex': '#BA1A1A',
      'name': 'Clinical Alert Error',
      'role': 'Validation & destructive'
    },
  ];

  final List<Map<String, dynamic>> _batches = [
    {
      'name': 'Batch 1: Onboarding Start',
      'screens': 'Screens 1–5',
      'status': '100% VERIFIED',
    },
    {
      'name': 'Batch 2: Authentication & Privacy',
      'screens': 'Screens 6–10',
      'status': '100% VERIFIED',
    },
    {
      'name': 'Batch 3: Questionnaire Intake',
      'screens': 'Screens 11–15',
      'status': '100% VERIFIED',
    },
    {
      'name': 'Batch 4: Research Protocol',
      'screens': 'Screens 16–20',
      'status': '100% VERIFIED',
    },
    {
      'name': 'Batch 5: Goals & Action Plan',
      'screens': 'Screens 21–25',
      'status': '100% VERIFIED',
    },
    {
      'name': 'Batch 6: Food & Label Intelligence',
      'screens': 'Screens 26–29 & 35',
      'status': '100% VERIFIED',
    },
    {
      'name': 'Batch 7: History & Secondary Controls',
      'screens': 'Screens 30–34',
      'status': '100% VERIFIED',
    },
    {
      'name': 'Batch 8: Responsive & Recovery States',
      'screens': 'Screens 36–40',
      'status': '100% VERIFIED',
    },
  ];

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
              'Consistency Audit',
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
                      'SYSTEM AUDIT • SPECIFICATION CONSOLIDATION v8.0',
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
                'Design System & State Consistency',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: NETokens.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Consolidated interaction matrix, typography tokens, destructive safeguards, and two-tab architectural harmony.',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: NETokens.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),

              // SECTION 1: Canonical 6-Color Brand Matrix
              Row(
                children: [
                  const Icon(Icons.palette_outlined, size: 18, color: NETokens.secondary),
                  const SizedBox(width: 8),
                  Text(
                    '1. CANONICAL 6-COLOR BRAND MATRIX',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: NETokens.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.4,
                children: _colorMatrix.map((c) {
                  final colorHex = c['hex']!;
                  final colorVal = Color(
                    int.parse(colorHex.replaceAll('#', '0xFF')),
                  );
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: NETokens.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: NETokens.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: colorVal,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                colorHex,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: NETokens.onSurface,
                                ),
                              ),
                              Text(
                                c['name']!,
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  color: NETokens.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // SECTION 2: Universal Interaction State Matrix
              Row(
                children: [
                  const Icon(Icons.touch_app_outlined, size: 18, color: NETokens.secondary),
                  const SizedBox(width: 8),
                  Text(
                    '2. INTERACTION STATE MATRIX',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: NETokens.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NETokens.primaryContainer,
                              foregroundColor: NETokens.onPrimary,
                              elevation: 0,
                            ),
                            child: const Text('Enabled'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: ElevatedButton(
                            onPressed: null,
                            child: Text('Disabled'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            child: const Text('Secondary Outlined'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextButton(
                            onPressed: () {},
                            child: const Text('Tertiary Ghost'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // SECTION 3: Destructive Action Safeguard Protocol
              Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 18, color: NETokens.secondary),
                  const SizedBox(width: 8),
                  Text(
                    '3. DESTRUCTIVE ACTION PROTOCOL',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: NETokens.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

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
                      'Tier A: Non-Destructive Prune (Undoable)',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: NETokens.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'History entries can be pruned with a persistent 6-second UNDO snackbar.',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: NETokens.onSurfaceVariant,
                      ),
                    ),
                    const Divider(height: 16),
                    Text(
                      'Tier B: Irreversible Account Erasure',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: NETokens.error,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Requires double-confirmation modal dialog with explicit confirmation prompt.',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: NETokens.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // SECTION 4: Final 8-Batch Coherence Audit
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.fact_check_outlined, size: 18, color: NETokens.secondary),
                      const SizedBox(width: 8),
                      Text(
                        '4. FINAL 8-BATCH AUDIT (40 SCREENS)',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: NETokens.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '40 / 40',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: NETokens.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              ..._batches.map((b) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: NETokens.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b['name'] as String,
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: NETokens.onSurface,
                            ),
                          ),
                          Text(
                            b['screens'] as String,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              color: NETokens.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: NETokens.secondaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check,
                              size: 11,
                              color: NETokens.onSecondaryContainer,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              b['status'] as String,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: NETokens.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

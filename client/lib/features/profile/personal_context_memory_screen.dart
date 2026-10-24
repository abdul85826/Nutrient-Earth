import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 31: Personal Context Memory (Secondary Destination)
/// Route: /profile/context
/// Authoritative Stitch Reference: personal_context_memory
class PersonalContextMemoryScreen extends StatefulWidget {
  const PersonalContextMemoryScreen({super.key});

  @override
  State<PersonalContextMemoryScreen> createState() =>
      _PersonalContextMemoryScreenState();
}

class _PersonalContextMemoryScreenState
    extends State<PersonalContextMemoryScreen> {
  bool _isPurged = false;

  void _handlePurge() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NETokens.surfaceContainer,
        title: Text(
          'Confirm Purge',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w800,
            color: NETokens.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to clear your personal context ledger? All preferences, constraints, and health context entries will be removed immediately.',
          style: GoogleFonts.manrope(
            fontSize: 13,
            color: NETokens.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
                color: NETokens.secondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isPurged = true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Personal context ledger cleared.',
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: NETokens.surfaceContainerHighest,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NETokens.error,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Purge Ledger',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

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
              'Personal Context',
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
            icon: const Icon(Icons.security, color: NETokens.secondary, size: 20),
            onPressed: () => context.push('/profile/privacy'),
            tooltip: 'Privacy controls',
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
              // Confidentiality Protocol Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainer,
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
                      'CONFIDENTIAL USER LEDGER • ZERO-KNOWLEDGE',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: NETokens.secondary,
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
                    'Personal context',
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: NETokens.onSurface,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: NETokens.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock,
                          size: 11,
                          color: NETokens.onSecondaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Client-side',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: NETokens.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Review the information you've chosen to share. You decide what to share, update, or remove at any time.",
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: NETokens.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Medical Disclaimer / Privacy Trust Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: NETokens.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        size: 16,
                        color: NETokens.secondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Non-clinical research alignment',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: NETokens.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Your context informs recommendation feasibility, but does not constitute a medical diagnosis, clinical treatment, or physician consultation. You can inspect or purge any entry below.',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
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
              const SizedBox(height: 18),

              if (_isPurged) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: NETokens.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 32,
                        color: NETokens.secondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ledger Cleared',
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: NETokens.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'All local context memories have been purged from device storage.',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: NETokens.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Card 1: Goals and priorities
                _buildContextCard(
                  icon: Icons.adjust,
                  title: 'Goals and priorities',
                  badge: 'USER-ENTERED • ACTIVE',
                  content:
                      'Consistent Evening Sleep Routine (Target: Delta wave stability, wind-down protocol)',
                  editLabel: 'Edit goal',
                  onEdit: () => context.push('/onboarding/goals'),
                ),
                const SizedBox(height: 12),

                // Card 2: Food preferences & dietary pattern
                _buildContextCard(
                  icon: Icons.restaurant,
                  title: 'Food preferences & dietary pattern',
                  badge: 'ACTIVE • PREFERENCE',
                  content:
                      'Pescatarian; high fiber; low added sugar; no artificial sweeteners',
                  editLabel: 'Edit preferences',
                  onEdit: () => context.push('/onboarding/diet'),
                ),
                const SizedBox(height: 12),

                // Card 3: Practical constraints & routine
                _buildContextCard(
                  icon: Icons.schedule,
                  title: 'Practical constraints & routine',
                  badge: 'TIME-BOUND • WORK SCHEDULE',
                  content:
                      'Evening wind-down limited to 15–20 minutes; shift worker schedule',
                  editLabel: 'Edit routine',
                  onEdit: () => context.push('/onboarding/constraints'),
                ),
                const SizedBox(height: 12),

                // Card 4: Health information & notes
                _buildContextCard(
                  icon: Icons.medical_information_outlined,
                  title: 'Health information & notes',
                  badge: 'USER-ENTERED CONTEXT',
                  content:
                      'Sensitive to caffeine after 14:00; monitoring magnesium intake',
                  editLabel: 'Edit context',
                  onEdit: () => context.push('/onboarding/health-context'),
                ),
                const SizedBox(height: 12),

                // Card 5: Connected data sources
                _buildContextCard(
                  icon: Icons.hub_outlined,
                  title: 'Connected data sources',
                  badge: 'ZERO EXTERNAL LINKS',
                  content:
                      '0 external integrations linked. Zero continuous background telemetry active.',
                  editLabel: 'Manage integrations',
                  onEdit: () => context.push('/profile/privacy'),
                ),
                const SizedBox(height: 24),

                // Purge Action Button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: _handlePurge,
                    icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                    label: Text(
                      'Purge all personal context',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: NETokens.error,
                      side: BorderSide(
                        color: NETokens.error.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContextCard({
    required IconData icon,
    required String title,
    required String badge,
    required String content,
    required String editLabel,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NETokens.surfaceContainer,
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
                  borderRadius: BorderRadius.circular(10),
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
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: NETokens.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              content,
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: NETokens.onSurface,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.edit,
                      size: 12,
                      color: NETokens.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      editLabel,
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: NETokens.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

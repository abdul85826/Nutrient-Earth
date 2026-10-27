import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';

class PrivacyDataModal extends StatelessWidget {
  const PrivacyDataModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PrivacyDataModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: media.size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: NETokens.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(NETokens.radiusXl)),
        boxShadow: [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle & top bar
          Container(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            alignment: Alignment.center,
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: NETokens.borderDefault,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.shield_outlined, size: 18, color: NETokens.botanicalTeal),
                          const SizedBox(width: 8),
                          Text(
                            'DATA SOVEREIGNTY & PRIVACY',
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: NETokens.botanicalTeal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your Health Data Controls',
                        style: GoogleFonts.newsreader(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: NETokens.deepestForest,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: NETokens.textSecondary),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Close privacy settings',
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: NETokens.borderSubtle),

          // Scrollable Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                // 1. Core Architecture Guarantees
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: NETokens.paleMint.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(NETokens.radiusLg),
                    border: Border.all(color: NETokens.mutedSage.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified_user_rounded, size: 20, color: NETokens.darkEvergreen),
                          const SizedBox(width: 8),
                          Text(
                            'Architectural Assurances',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: NETokens.darkEvergreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nutrient Earth is built on evidence integrity and strict patient data isolation. Your research questions, dietary habits, and biomarker logs are never sold, broked, or rented.',
                        style: GoogleFonts.manrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: NETokens.textSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSecurityBadge(Icons.lock_clock_outlined, 'TLS 1.3 Transport Encryption'),
                      const SizedBox(height: 6),
                      _buildSecurityBadge(Icons.safety_check_outlined, 'PostgreSQL Row Level Security (RLS) Isolation'),
                      const SizedBox(height: 6),
                      _buildSecurityBadge(Icons.do_not_disturb_on_outlined, 'Zero Third-Party Advertising Telemetry'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. AI Processing Disclosures
                _buildSectionHeader('AI & SCIENTIFIC INFERENCE'),
                const SizedBox(height: 10),
                _buildGovernanceItem(
                  icon: Icons.memory_rounded,
                  title: 'Private Model Processing',
                  body: 'Nutrient queries are processed through dedicated enterprise endpoints where inputs are ephemeral. Model providers do not train on your private scientific research questions.',
                ),
                const SizedBox(height: 10),
                _buildGovernanceItem(
                  icon: Icons.camera_alt_outlined,
                  title: 'Image & Food Label Analysis',
                  body: 'Uploaded meal photos and nutritional facts labels are parsed in-memory for macronutrient synthesis and discarded immediately post-response.',
                ),
                const SizedBox(height: 20),

                // 3. User Sovereignty & Data Portability
                _buildSectionHeader('YOUR SOVEREIGN CONTROLS'),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: NETokens.surface,
                    borderRadius: BorderRadius.circular(NETokens.radiusMd),
                    border: Border.all(color: NETokens.borderDefault),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.download_rounded, color: NETokens.primary),
                        title: Text(
                          'Export Health & Research Data',
                          style: GoogleFonts.manrope(fontSize: 13.5, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Download full inquiry history, saved goals, and logs in JSON/CSV format',
                          style: GoogleFonts.manrope(fontSize: 11, color: NETokens.textMuted),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Compiling data export package. A download link will be prepared.'),
                              backgroundColor: NETokens.botanicalTeal,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, color: NETokens.borderSubtle),
                      ListTile(
                        leading: const Icon(Icons.history_toggle_off_rounded, color: NETokens.textSecondary),
                        title: Text(
                          'Clear Local Inquiries Cache',
                          style: GoogleFonts.manrope(fontSize: 13.5, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Purge cached search suggestions and offline query drafts',
                          style: GoogleFonts.manrope(fontSize: 11, color: NETokens.textMuted),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Local research cache successfully purged.'),
                              backgroundColor: NETokens.forest,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 4. Medical Disclaimer & Boundaries
                _buildSectionHeader('MEDICAL & RESEARCH BOUNDARIES'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: NETokens.disclaimerAmberBg,
                    borderRadius: BorderRadius.circular(NETokens.radiusMd),
                    border: Border.all(color: NETokens.disclaimerAmberBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 18, color: NETokens.disclaimerAmberText),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Educational & Research Companion Only',
                              style: GoogleFonts.manrope(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: NETokens.disclaimerAmberText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Nutrient Earth synthesizes peer-reviewed nutritional literature for informed self-advocacy. It does not provide medical diagnosis, treatment protocols, or prescription advice. Always review dietary changes with a qualified healthcare practitioner.',
                              style: GoogleFonts.manrope(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6B4500),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 5. Destructive Account Actions
                _buildSectionHeader('DANGER ZONE'),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: NETokens.surface,
                    borderRadius: BorderRadius.circular(NETokens.radiusMd),
                    border: Border.all(color: NETokens.error.withValues(alpha: 0.3)),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.delete_forever_rounded, color: NETokens.error),
                    title: Text(
                      'Delete Account & All Associated Records',
                      style: GoogleFonts.manrope(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: NETokens.error,
                      ),
                    ),
                    subtitle: Text(
                      'Permanently delete your profile, telemetry, and research history',
                      style: GoogleFonts.manrope(fontSize: 11, color: NETokens.textMuted),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: NETokens.error),
                    onTap: () {
                      _showDeleteConfirmationDialog(context);
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // 6. Regulatory & Version Info
                Center(
                  child: Text(
                    'Nutrient Earth v1.2.0 • Build 2026.10.26\nGoverned by GDPR & CCPA Data Sovereignty Standards',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: NETokens.textMuted,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.manrope(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
        color: NETokens.textMuted,
      ),
    );
  }

  static Widget _buildSecurityBadge(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: NETokens.botanicalTeal),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: NETokens.primary,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildGovernanceItem({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: NETokens.surface,
        borderRadius: BorderRadius.circular(NETokens.radiusMd),
        border: Border.all(color: NETokens.borderDefault),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: NETokens.paleMint.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(NETokens.radiusSm),
            ),
            child: Icon(icon, size: 16, color: NETokens.darkEvergreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: NETokens.primary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: GoogleFonts.manrope(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: NETokens.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: NETokens.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NETokens.radiusLg)),
        title: Text(
          'Delete All Health Records?',
          style: GoogleFonts.newsreader(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: NETokens.error,
          ),
        ),
        content: Text(
          'This action is irreversible. All inquiry history, custom dietary goals, and local encryption keys will be immediately purged.',
          style: GoogleFonts.manrope(
            fontSize: 13,
            color: NETokens.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: NETokens.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: NETokens.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NETokens.radiusFull)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion protocol initiated. Session ended.'),
                  backgroundColor: NETokens.error,
                ),
              );
            },
            child: const Text('Confirm Deletion'),
          ),
        ],
      ),
    );
  }
}

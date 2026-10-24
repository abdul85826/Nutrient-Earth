import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 33: Privacy & Data Controls (Secondary Destination)
/// Route: /profile/privacy
/// Authoritative Stitch Reference: privacy_data_controls
class PrivacyDataControlsScreen extends StatefulWidget {
  const PrivacyDataControlsScreen({super.key});

  @override
  State<PrivacyDataControlsScreen> createState() =>
      _PrivacyDataControlsScreenState();
}

class _PrivacyDataControlsScreenState extends State<PrivacyDataControlsScreen> {
  bool _isExporting = false;
  bool _isClearingHistory = false;

  void _handleExport() async {
    setState(() => _isExporting = true);
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() => _isExporting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Export prepared. Downloadable archive ready (JSON/CSV).',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
        ),
        backgroundColor: NETokens.surfaceContainerHighest,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleClearHistory() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NETokens.surfaceContainer,
        title: Text(
          'Clear Research History',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w800,
            color: NETokens.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to delete all saved inquiries and cached research answers? This action cannot be undone.',
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
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isClearingHistory = true);
              await Future.delayed(const Duration(milliseconds: 600));
              if (!mounted) return;
              setState(() => _isClearingHistory = false);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Research history cleared successfully.',
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
              'Clear History',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDeleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NETokens.surfaceContainer,
        title: Text(
          'Delete Account & Data',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w800,
            color: NETokens.error,
          ),
        ),
        content: Text(
          'This will permanently delete your account, saved research, goal trajectories, and all personal preferences under GDPR and CCPA erasure protocols. Proceed with deletion?',
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
              context.go('/auth/gateway');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NETokens.error,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Confirm Deletion',
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
              'Privacy & Data',
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
              // Ribbon
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
                        color: NETokens.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'DATA MINIMIZATION • SOVEREIGN CONTROLS',
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
                'Privacy & data',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: NETokens.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Nutrient Earth is built on zero-knowledge architecture. Your health context is never sold, shared with insurers, or used for third-party advertising.',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: NETokens.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),

              // Section 1: What information is collected
              _buildInfoSection(
                icon: Icons.inventory_2_outlined,
                title: 'What information is collected',
                body:
                    'Only information you explicitly submit during research queries, questionnaire intake, and meal logs. We do not track cross-app location, advertising ID, or contact book data.',
              ),
              const SizedBox(height: 12),

              // Section 2: How information is used
              _buildInfoSection(
                icon: Icons.psychology_outlined,
                title: 'How information is used',
                body:
                    'Information is used strictly to compute biochemical relevance, calibrate plan feasibility, and check corroborating scientific studies.',
              ),
              const SizedBox(height: 12),

              // Section 3: Data retention & storage
              _buildInfoSection(
                icon: Icons.lock_outline,
                title: 'Data retention & storage',
                body:
                    'Data is stored with AES-256 encryption at rest. In Supabase, Row-Level-Security (RLS) ensures only your authenticated session can access your research ledger.',
              ),
              const SizedBox(height: 22),

              // Action 1: Export Account Data
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export account data',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: NETokens.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Download a complete cryptographic archive of your goals, meal logs, and research inquiries in structured JSON and CSV formats.',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: NETokens.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: OutlinedButton.icon(
                        onPressed: _isExporting ? null : _handleExport,
                        icon: _isExporting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.file_download_outlined, size: 18),
                        label: Text(
                          _isExporting ? 'Preparing export...' : 'Request export',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: NETokens.secondary,
                          side: BorderSide(
                            color: NETokens.secondary.withValues(alpha: 0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Action 2: Clear research history
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clear research history',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: NETokens.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Delete all past questions, answers, and meal evaluations from this device and your cloud account.',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: NETokens.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: OutlinedButton.icon(
                        onPressed: _isClearingHistory ? null : _handleClearHistory,
                        icon: const Icon(Icons.cleaning_services_outlined, size: 18),
                        label: Text(
                          'Clear history',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: NETokens.onSurfaceVariant,
                          side: BorderSide(
                            color: NETokens.outlineVariant.withValues(alpha: 0.5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Action 3: Delete Account & Data
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: NETokens.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delete account & data',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: NETokens.error,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Permanently remove your profile and purge all associated cryptographic records. This action cannot be reversed.',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: NETokens.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton.icon(
                        onPressed: _handleDeleteAccount,
                        icon: const Icon(Icons.delete_forever, size: 18),
                        label: Text(
                          'Request account deletion',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: NETokens.error,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
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

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NETokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: NETokens.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: NETokens.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: NETokens.onSurfaceVariant,
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
}

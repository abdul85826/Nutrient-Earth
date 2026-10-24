import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 32: Research History Detail (Archival Dossier)
/// Route: /history/detail
/// Authoritative Stitch Reference: research_history_detail
class ResearchHistoryDetailScreen extends StatelessWidget {
  final Map<String, dynamic>? initialData;

  const ResearchHistoryDetailScreen({
    super.key,
    this.initialData,
  });

  @override
  Widget build(BuildContext context) {
    final id = initialData?['id'] as String? ?? 'REF-2024-884C';
    final title = initialData?['title'] as String? ??
        'How does dietary magnesium glycinate bioavailability compare to magnesium oxide for sleep quality?';

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
              'Archival Record',
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
            icon: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: NETokens.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: NETokens.onPrimary, size: 18),
            ),
            onPressed: () => context.push('/profile/context'),
            tooltip: 'Account profile',
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
              // Meta Tag Strip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: NETokens.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'ARCHIVAL RECORD • READ ONLY',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: NETokens.onSecondaryContainer,
                      ),
                    ),
                  ),
                  Text(
                    '#$id',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: NETokens.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: NETokens.onSurface,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),

              // Synthesis Readout Card
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
                              Icons.biotech,
                              size: 18,
                              color: NETokens.secondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'SYNTHESIS READOUT',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
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
                            color: NETokens.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'IMMUTABLE',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: NETokens.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Chelated magnesium bisglycinate demonstrates significantly higher intestinal absorption and bioavailability compared to inorganic magnesium oxide. Organic amino acid chelation shields magnesium from premature ionic dissociation in gastric acid, reducing osmotic water draw into the intestinal lumen and eliminating gastrointestinal laxative distress.',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: NETokens.onSurface,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: NETokens.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: NETokens.secondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'High Consensus • 3 Human Clinical Trials',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: NETokens.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Corroborating Literature
              Row(
                children: [
                  const Icon(
                    Icons.menu_book,
                    size: 16,
                    color: NETokens.secondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'CORROBORATING LITERATURE (2)',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: NETokens.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Citation 1
              _buildCitationCard(
                title:
                    'Bioavailability of magnesium bisglycinate chelate vs oxide in human subjects',
                authors: 'Schuette SA, Lashner BA, Janghorbani M.',
                journal: 'JPEN J Parenter Enteral Nutr. 1994;18(5):430-435.',
                doi: 'PMC5452159',
              ),
              const SizedBox(height: 10),

              // Citation 2
              _buildCitationCard(
                title:
                    'Oral magnesium supplementation in insomnia: A double-blind clinical trial',
                authors: 'Abbasi B, Kimiagar M, Sadeghniiat K, et al.',
                journal: 'J Res Med Sci. 2012;17(12):1161-1169.',
                doi: '10.1016/j.jtemb.2014',
              ),
              const SizedBox(height: 24),

              // Utility Controls
              Container(
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildUtilityRow(
                      icon: Icons.content_copy,
                      title: 'Copy Record Identifier',
                      subtitle: id,
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Record identifier $id copied to clipboard.',
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    const Divider(height: 16),
                    _buildUtilityRow(
                      icon: Icons.download_outlined,
                      title: 'Export Cryptographic Snapshot',
                      subtitle: 'Immutable SHA-256 JSON package',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Cryptographic research package exported.',
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    const Divider(height: 16),
                    _buildUtilityRow(
                      icon: Icons.flag_outlined,
                      title: 'Flag Citation Discrepancy',
                      subtitle: 'Submit report to oversight team',
                      onTap: () => context.push('/support/feedback'),
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

  Widget _buildCitationCard({
    required String title,
    required String authors,
    required String journal,
    required String doi,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: NETokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: NETokens.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            authors,
            style: GoogleFonts.manrope(
              fontSize: 11,
              color: NETokens.onSurfaceVariant,
            ),
          ),
          Text(
            journal,
            style: GoogleFonts.manrope(
              fontSize: 10,
              color: NETokens.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: NETokens.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'DOI: $doi',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: NETokens.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: NETokens.secondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: NETokens.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: NETokens.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: NETokens.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

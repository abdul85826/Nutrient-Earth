// ==============================================================================
// Nutrient Earth — Verified Scientific Citation Card
// Displays peer-reviewed publication details, study design grades, sample size,
// and PubMed PMID / DOI links with clipboard actions.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../../../core/services/research_pipeline_service.dart';

class CitationCard extends StatelessWidget {
  final ResearchCitation citation;

  const CitationCard({
    super.key,
    required this.citation,
  });

  void _copyReference(BuildContext context) {
    final ref = '${citation.title}. ${citation.authorsOrJournal} (${citation.year}). ${citation.pmid != null ? "PMID: ${citation.pmid}" : ""}';
    Clipboard.setData(ClipboardData(text: ref));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Citation reference copied to clipboard.'),
        duration: Duration(seconds: 2),
        backgroundColor: NETokens.deepGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(NETokens.space14),
      decoration: BoxDecoration(
        color: NETokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(NETokens.radiusMd),
        border: Border.all(color: NETokens.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Evidence Grade & PMID Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: NETokens.secondaryContainer,
                    borderRadius: BorderRadius.circular(NETokens.radiusSm),
                  ),
                  child: Text(
                    citation.evidenceGrade.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: NETokens.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
              if (citation.pmid != null) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _copyReference(context),
                  borderRadius: BorderRadius.circular(NETokens.radiusSm),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: NETokens.surfaceContainer,
                      borderRadius: BorderRadius.circular(NETokens.radiusXs),
                      border: Border.all(color: NETokens.borderDefault),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'PMID: ${citation.pmid}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: NETokens.botanicalTeal,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.copy_rounded, size: 10, color: NETokens.textMuted),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: NETokens.space8),

          // Title
          Text(
            citation.title,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: NETokens.primary,
              height: 1.35,
            ),
          ),

          const SizedBox(height: NETokens.space4),

          // Authors and Journal
          Text(
            '${citation.authorsOrJournal} • ${citation.year}',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: NETokens.textSecondary,
            ),
          ),

          if (citation.supportingClaim != null) ...[
            const SizedBox(height: NETokens.space8),
            Container(
              padding: const EdgeInsets.all(NETokens.space8),
              decoration: BoxDecoration(
                color: NETokens.surface,
                borderRadius: BorderRadius.circular(NETokens.radiusSm),
              ),
              child: Text(
                'Key finding: ${citation.supportingClaim}',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  color: NETokens.textPrimary,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

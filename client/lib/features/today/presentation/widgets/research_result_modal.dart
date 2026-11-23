// ==============================================================================
// Nutrient Earth — Research Result Modal
// Dynamic Block-Based Presentation (Schema v2026.3)
// Dynamically renders polymorphic ResponseContentBlocks or falls back gracefully.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../../../core/domain/answer_contract/universal_intelligence_answer.dart';
import '../../../../core/services/research_pipeline_service.dart';
import 'dynamic_block_renderers.dart';

class ResearchResultModal extends StatelessWidget {
  final ResearchAnswer answer;
  final ValueChanged<String>? onSuggestionTap;

  const ResearchResultModal({
    super.key,
    required this.answer,
    this.onSuggestionTap,
  });

  static Future<void> show(
    BuildContext context,
    ResearchAnswer answer, {
    ValueChanged<String>? onSuggestionTap,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ResearchResultModal(
        answer: answer,
        onSuggestionTap: onSuggestionTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final universal = answer.universalAnswer;
    final hasDynamicBlocks = universal != null && universal.blocks.isNotEmpty;
    final isConversational = universal?.responseType == UniversalResponseType.conversation;

    return Container(
      decoration: const BoxDecoration(
        color: NETokens.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 12.0),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: NETokens.borderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Content in scrollable view
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dynamic Header
                    Text(
                      isConversational ? 'Nutrient Earth Intelligence' : answer.query,
                      style: GoogleFonts.newsreader(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: NETokens.primary,
                        height: 1.2,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Primary Rendering: Polymorphic Blocks (Schema v2026.3)
                    if (hasDynamicBlocks) ...[
                      for (final block in universal.blocks)
                        DynamicBlockRenderer(
                          block: block,
                          onSuggestionTap: (prompt) {
                            Navigator.pop(context);
                            if (onSuggestionTap != null) {
                              onSuggestionTap!(prompt);
                            }
                          },
                        ),
                      const SizedBox(height: 16),
                    ] else ...[
                      // Fallback Legacy Rendering (When no blocks are present)
                      _buildLegacyContent(context, isConversational),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegacyContent(BuildContext context, bool isConversational) {
    final showBadge = !isConversational &&
        answer.evidenceBadge.isNotEmpty &&
        answer.evidenceBadge != 'NO VERIFIED SOURCES';
    final showDisclaimer = !isConversational && answer.uncertaintyDisclaimer.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Evidence Badge (Only rendered when genuine verified sources exist)
        if (showBadge) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: NETokens.emerald.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: NETokens.emerald.withValues(alpha: 0.3)),
            ),
            child: Text(
              answer.evidenceBadge,
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: NETokens.emerald,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Synthesized Answer Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(NETokens.radiusMd),
            border: Border.all(color: NETokens.borderDefault),
            boxShadow: NETokens.cardShadow,
          ),
          child: Text(
            answer.answerSummary,
            style: GoogleFonts.manrope(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: NETokens.primary,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Practical Action Steps
        if (!isConversational && answer.practicalSteps.isNotEmpty) ...[
          Text(
            'PRACTICAL NEXT STEPS',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: NETokens.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          for (final step in answer.practicalSteps)
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Icon(Icons.check_circle_rounded, size: 16, color: NETokens.emerald),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      step,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: NETokens.primary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
        ],

        // Retrieved Citations
        if (!isConversational && answer.citations.isNotEmpty) ...[
          Text(
            'RETRIEVED EVIDENCE & CITATIONS',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: NETokens.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          for (final citation in answer.citations)
            Container(
              margin: const EdgeInsets.only(bottom: 8.0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: NETokens.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: NETokens.borderDefault),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          citation.evidenceGrade,
                          style: GoogleFonts.manrope(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: NETokens.emerald,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        citation.year,
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: NETokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    citation.title,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: NETokens.primary,
                    ),
                  ),
                  Text(
                    citation.authorsOrJournal,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: NETokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
        ],

        // Health & Uncertainty Disclaimer
        if (showDisclaimer) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9EC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    answer.uncertaintyDisclaimer,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF92400E),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}

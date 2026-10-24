import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 18: Research Request Review and Submission
/// Authoritative Stitch Design: research_request_review_submission
class ResearchReviewSubmissionScreen extends StatelessWidget {
  final String query;

  const ResearchReviewSubmissionScreen({
    super.key,
    this.query =
        'How does dietary magnesium glycinate bioavailability compare to magnesium oxide for sleep quality?',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NETokens.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Specimen Dossier',
          style: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: NETokens.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: NETokens.space20, vertical: NETokens.space12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Review your question',
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: NETokens.onSurface,
                ),
              ),
              const SizedBox(height: NETokens.space6),
              Text(
                'Verify inquiry parameters and citation indexes before initiating the verification engine.',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: NETokens.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: NETokens.space20),

              // Query Card
              Container(
                padding: const EdgeInsets.all(NETokens.space16),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(NETokens.radiusMd),
                  border: Border.all(color: NETokens.outlineVariant, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PRIMARY QUESTION',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: NETokens.secondary,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => context.go(
                            '/research/composer?q=${Uri.encodeComponent(query)}',
                          ),
                          icon: const Icon(Icons.edit_outlined, size: 14, color: NETokens.secondary),
                          label: Text(
                            'Edit',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: NETokens.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      query,
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: NETokens.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: NETokens.space16),

              // Verified Search Scope
              Container(
                padding: const EdgeInsets.all(NETokens.space16),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainer,
                  borderRadius: BorderRadius.circular(NETokens.radiusMd),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TARGET EVIDENCE REPOSITORIES',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: NETokens.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _SourceBadge(label: 'PubMed (NLM)'),
                        _SourceBadge(label: 'Cochrane Library'),
                        _SourceBadge(label: 'ChEMBL Bioactivity'),
                        _SourceBadge(label: 'USDA FoodData Central'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: NETokens.space16),

              // Attachment card
              Container(
                padding: const EdgeInsets.all(NETokens.space14),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(NETokens.radiusMd),
                  border: Border.all(color: NETokens.outlineVariant.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file, size: 18, color: NETokens.secondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No files attached (Optional)',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          color: NETokens.onSurfaceVariant,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Add reference',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: NETokens.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: NETokens.space32),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NETokens.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NETokens.radiusFull),
                    ),
                  ),
                  onPressed: () => context.go(
                    '/research/investigating?q=${Uri.encodeComponent(query)}',
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Start research',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: NETokens.space8),
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'Cancel and return',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: NETokens.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  final String label;

  const _SourceBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: NETokens.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(NETokens.radiusFull),
        border: Border.all(color: NETokens.outlineVariant.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, size: 13, color: NETokens.secondary),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: NETokens.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

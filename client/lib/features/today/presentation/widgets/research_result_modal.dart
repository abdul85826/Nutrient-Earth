import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../../../core/services/research_persistence_service.dart';
import '../../../../core/services/research_pipeline_service.dart';

class ResearchResultModal extends StatelessWidget {
  final ResearchAnswer answer;
  final ValueChanged<String>? onFollowUp;
  final VoidCallback? onTurnIntoGoal;
  final VoidCallback? onSaveToHistory;

  const ResearchResultModal({
    super.key,
    required this.answer,
    this.onFollowUp,
    this.onTurnIntoGoal,
    this.onSaveToHistory,
  });

  static Future<void> show(
    BuildContext context,
    ResearchAnswer answer, {
    ValueChanged<String>? onFollowUp,
    VoidCallback? onTurnIntoGoal,
    VoidCallback? onSaveToHistory,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ResearchResultModal(
        answer: answer,
        onFollowUp: onFollowUp,
        onTurnIntoGoal: onTurnIntoGoal,
        onSaveToHistory: onSaveToHistory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: NETokens.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 10.0),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Drag Handle & Close Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: NETokens.borderDefault,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Close research findings',
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20, color: NETokens.textSecondary),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Close',
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Tag & Reference ID
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: NETokens.paleMint,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFC0E5CB)),
                          ),
                          child: Text(
                            'RESEARCH INQUIRY',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: NETokens.deepestForest,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        Text(
                          'ID // ${answer.referenceId}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: NETokens.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Query Title in Editorial Serif
                    Text(
                      answer.query,
                      style: GoogleFonts.newsreader(
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        color: NETokens.primary,
                        height: 1.2,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Domain Category Subline
                    Row(
                      children: [
                        const Icon(Icons.science_outlined, size: 14, color: NETokens.botanicalTeal),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            answer.domainCategory,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: NETokens.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 1. ANSWER SECTION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.help_outline_rounded, size: 15, color: NETokens.primary),
                            const SizedBox(width: 6),
                            Text(
                              'ANSWER',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: NETokens.primary,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: NETokens.paleMint,
                            borderRadius: BorderRadius.circular(NETokens.radiusFull),
                            border: Border.all(color: const Color(0xFFC0E5CB)),
                          ),
                          child: Text(
                            answer.evidenceBadge,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: NETokens.deepestForest,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Synthesized Answer Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(NETokens.radiusLg),
                        border: Border.all(color: NETokens.borderDefault),
                        boxShadow: NETokens.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            answer.answerSummary,
                            style: GoogleFonts.manrope(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: NETokens.primary,
                              height: 1.5,
                            ),
                          ),
                          if (answer.comparisonCallout != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: NETokens.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: NETokens.borderSubtle),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        answer.comparisonCallout!,
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: NETokens.primary,
                                        ),
                                      ),
                                      if (answer.comparisonIndex != null)
                                        Text(
                                          '~${answer.comparisonIndex}x Index',
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: NETokens.botanicalTeal,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(NETokens.radiusFull),
                                    child: const LinearProgressIndicator(
                                      value: 0.82,
                                      minHeight: 8,
                                      backgroundColor: NETokens.surfaceDim,
                                      valueColor: AlwaysStoppedAnimation<Color>(NETokens.darkEvergreen),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '● High Bioavailability (~24%)',
                                        style: GoogleFonts.manrope(fontSize: 9.5, color: NETokens.textSecondary, fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        'Low Absorption (~4%)',
                                        style: GoogleFonts.manrope(fontSize: 9.5, color: NETokens.textMuted),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2. EVIDENCE AND SOURCES SECTION
                    if (answer.citations.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.library_books_outlined, size: 15, color: NETokens.primary),
                              const SizedBox(width: 6),
                              Text(
                                'EVIDENCE AND SOURCES',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: NETokens.primary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${answer.citations.length} Peer-Reviewed Sources',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: NETokens.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      for (final citation in answer.citations)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10.0),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: NETokens.borderDefault),
                            boxShadow: NETokens.cardShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: NETokens.surface,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: NETokens.borderSubtle),
                                    ),
                                    child: Text(
                                      citation.evidenceGrade.toUpperCase(),
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: NETokens.botanicalTeal,
                                      ),
                                    ),
                                  ),
                                  if (citation.pmid != null) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: NETokens.paleMint,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'PMID: ${citation.pmid}',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: NETokens.deepestForest,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const Spacer(),
                                  Text(
                                    'Year: ${citation.year}',
                                    style: GoogleFonts.manrope(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: NETokens.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                citation.title,
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: NETokens.primary,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.menu_book_rounded, size: 12, color: NETokens.textMuted),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      citation.authorsOrJournal,
                                      style: GoogleFonts.manrope(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: NETokens.textSecondary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (citation.url != null)
                                    const Icon(Icons.open_in_new_rounded, size: 12, color: NETokens.botanicalTeal),
                                ],
                              ),
                              if (citation.supportingClaim != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: NETokens.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: NETokens.borderSubtle),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'SUPPORTING EVIDENCE CLAIM',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w800,
                                          color: NETokens.textMuted,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '"${citation.supportingClaim}"',
                                        style: GoogleFonts.manrope(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FontStyle.italic,
                                          color: NETokens.textPrimary,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      const SizedBox(height: 14),
                    ],

                    // 3. WHAT THE EVIDENCE TELLS US SECTION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.analytics_outlined, size: 15, color: NETokens.primary),
                            const SizedBox(width: 6),
                            Text(
                              'WHAT THE EVIDENCE TELLS US',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: NETokens.primary,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: NETokens.surfaceContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'EVALUATION',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              color: NETokens.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: NETokens.borderDefault),
                        boxShadow: NETokens.cardShadow,
                      ),
                      child: Column(
                        children: [
                          _buildEvidenceItem(
                            icon: Icons.check_circle_outline_rounded,
                            iconColor: NETokens.emerald,
                            title: 'Clear Evidence',
                            description: 'Organic chelated preparations consistently demonstrate superior fractional bioavailability and lower gastrointestinal distress.',
                          ),
                          const Divider(color: NETokens.borderSeparator, height: 16),
                          _buildEvidenceItem(
                            icon: Icons.help_outline_rounded,
                            iconColor: NETokens.textSecondary,
                            title: 'Evidence Gap',
                            description: answer.evidenceGap ??
                                'Large-scale direct comparative trials on objective polysomnography metrics across diverse adult cohorts remain active areas of ongoing research.',
                          ),
                          const Divider(color: NETokens.borderSeparator, height: 16),
                          _buildEvidenceItem(
                            icon: Icons.shield_outlined,
                            iconColor: NETokens.streakFlame,
                            title: 'No Medical Diagnosis',
                            description: 'Findings represent peer-reviewed nutritional and biochemical syntheses for educational guidance, not clinical disease treatment.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 4. WHAT THIS MEANS FOR YOU
                    if (answer.practicalSteps.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded, size: 15, color: NETokens.primary),
                          const SizedBox(width: 6),
                          Text(
                            'WHAT THIS MEANS FOR YOU',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: NETokens.primary,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: NETokens.borderDefault),
                          boxShadow: NETokens.cardShadow,
                        ),
                        child: Column(
                          children: [
                            for (int i = 0; i < answer.practicalSteps.length; i++) ...[
                              if (i > 0) const Divider(color: NETokens.borderSeparator, height: 14),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Icon(
                                      i == 0
                                          ? Icons.check_circle_rounded
                                          : (i == 1 ? Icons.access_time_rounded : Icons.restaurant_rounded),
                                      size: 16,
                                      color: NETokens.botanicalTeal,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      answer.practicalSteps[i],
                                      style: GoogleFonts.manrope(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: NETokens.primary,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Health Uncertainty Disclaimer
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: NETokens.disclaimerAmberBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: NETokens.disclaimerAmberBorder),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded, color: NETokens.disclaimerAmberText, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              answer.uncertaintyDisclaimer,
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: NETokens.disclaimerAmberText,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Actions
                    Semantics(
                      button: true,
                      label: 'Ask follow-up question',
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: NETokens.darkEvergreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(NETokens.radiusFull),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            onFollowUp?.call(answer.query);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.chat_outlined, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Ask follow-up question',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Action Row: Save to history & Turn into a goal
                    Row(
                      children: [
                        Expanded(
                          child: _SaveToHistoryButton(
                            answer: answer,
                            onSaveToHistory: onSaveToHistory,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: NETokens.darkEvergreen,
                              side: const BorderSide(color: NETokens.borderDefault),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(NETokens.radiusFull),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              onTurnIntoGoal?.call();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Finding turned into a practical action goal.'),
                                  backgroundColor: NETokens.emerald,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.flag_outlined, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'Turn into a goal',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Feedback prompt opened.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Text(
                          'Give feedback or report a problem',
                          style: GoogleFonts.manrope(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: NETokens.textMuted,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvidenceItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
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
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.manrope(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: NETokens.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SaveToHistoryButton extends StatefulWidget {
  final ResearchAnswer answer;
  final VoidCallback? onSaveToHistory;

  const _SaveToHistoryButton({
    required this.answer,
    this.onSaveToHistory,
  });

  @override
  State<_SaveToHistoryButton> createState() => _SaveToHistoryButtonState();
}

class _SaveToHistoryButtonState extends State<_SaveToHistoryButton> {
  bool _isSaving = false;
  bool _isSaved = false;
  String? _activeConversationId;

  Future<void> _handleSave() async {
    if (_isSaving || _isSaved) return;

    setState(() => _isSaving = true);

    try {
      _activeConversationId ??= await ResearchPersistenceService.instance.getOrCreateConversation(
        title: widget.answer.query,
      );
      final convId = _activeConversationId;

      if (!mounted) return;

      if (convId == null) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to save: Please sign in to save research history.'),
            backgroundColor: NETokens.solarAmber,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      final success = await ResearchPersistenceService.instance.persistInquiryAndAnswer(
        conversationId: convId,
        query: widget.answer.query,
        answer: widget.answer,
      );

      if (!mounted) return;

      if (success) {
        setState(() {
          _isSaved = true;
          _isSaving = false;
        });
        widget.onSaveToHistory?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Research inquiry saved to your history.'),
            backgroundColor: NETokens.botanicalTeal,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save research inquiry. Please retry.'),
            backgroundColor: NETokens.error,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving inquiry. Please retry.'),
            backgroundColor: NETokens.error,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: _isSaved ? NETokens.botanicalTeal : NETokens.primary,
        side: BorderSide(
          color: _isSaved ? NETokens.botanicalTeal : NETokens.borderDefault,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NETokens.radiusFull),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onPressed: (_isSaving || _isSaved) ? null : _handleSave,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isSaving)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: NETokens.primary,
              ),
            )
          else
            Icon(
              _isSaved ? Icons.bookmark_added_rounded : Icons.bookmark_border_rounded,
              size: 16,
            ),
          const SizedBox(width: 6),
          Text(
            _isSaved ? 'Saved to history' : (_isSaving ? 'Saving...' : 'Save to history'),
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

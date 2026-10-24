import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 20: Evidence-First Research Answer Dossier
/// Authoritative Stitch Design: evidence_first_research_answer
class EvidenceFirstResearchAnswerScreen extends StatefulWidget {
  final String query;

  const EvidenceFirstResearchAnswerScreen({
    super.key,
    this.query =
        'How does dietary magnesium glycinate bioavailability compare to magnesium oxide for sleep quality?',
  });

  @override
  State<EvidenceFirstResearchAnswerScreen> createState() =>
      _EvidenceFirstResearchAnswerScreenState();
}

class _EvidenceFirstResearchAnswerScreenState
    extends State<EvidenceFirstResearchAnswerScreen> {
  bool _isBookmarked = false;
  bool _isSavedToHistory = false;

  void _toggleBookmark() {
    setState(() => _isBookmarked = !_isBookmarked);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isBookmarked ? 'Saved to bookmarks.' : 'Removed from bookmarks.'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _saveToHistory() {
    setState(() => _isSavedToHistory = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Investigation archived in Research History (REF-2024-884C).'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NETokens.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/research'),
        ),
        title: Text(
          'Research',
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: NETokens.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked ? NETokens.secondary : NETokens.onSurface,
            ),
            onPressed: _toggleBookmark,
            tooltip: 'Bookmark',
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Citation link copied to clipboard.')),
              );
            },
            tooltip: 'Share',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: NETokens.space16, vertical: NETokens.space12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Query Headline
              Text(
                widget.query,
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: NETokens.onSurface,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: NETokens.space16),

              // Synthesis Card
              Container(
                padding: const EdgeInsets.all(NETokens.space16),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(NETokens.radiusLg),
                  border: Border.all(color: NETokens.outlineVariant, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: NETokens.secondaryContainer,
                            borderRadius: BorderRadius.circular(NETokens.radiusFull),
                          ),
                          child: Text(
                            'CONSENSUS (89%)',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: NETokens.onSecondaryContainer,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00251D),
                            borderRadius: BorderRadius.circular(NETokens.radiusFull),
                          ),
                          child: Text(
                            'GRADE A EVIDENCE',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFBBEDDC),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: NETokens.space12),
                    Text(
                      'Magnesium glycinate demonstrates significantly higher intestinal absorption and fractional retention compared to magnesium oxide, with markedly reduced incidence of osmotic gastrointestinal distress.',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: NETokens.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: NETokens.space20),

              // Comparative Physiological Metrics
              Text(
                'BIOCHEMICAL PHARMACOKINETICS',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: NETokens.secondary,
                ),
              ),
              const SizedBox(height: NETokens.space8),

              Row(
                children: [
                  Expanded(
                    child: _CompoundComparisonCard(
                      compound: 'Magnesium Glycinate',
                      badge: 'High Absorption',
                      bioavailability: '~23.5%',
                      transport: 'Amino Acid (PEPT1)',
                      osmoticRisk: 'Negligible',
                      isHighlight: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _CompoundComparisonCard(
                      compound: 'Magnesium Oxide',
                      badge: 'Poor Bioavailability',
                      bioavailability: '~4.0%',
                      transport: 'Passive Paracellular',
                      osmoticRisk: 'High (Laxative)',
                      isHighlight: false,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: NETokens.space20),

              // Peer-Reviewed Sources Section
              Text(
                'PEER-REVIEWED CITATIONS & EVIDENCE',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: NETokens.secondary,
                ),
              ),
              const SizedBox(height: NETokens.space8),

              _CitationCard(
                authors: 'Schuette SA, et al.',
                journal: 'JPEN J Parenter Enteral Nutr. 1994',
                doi: '10.1177/014860719401800543',
                finding:
                    'Demonstrated higher fractional magnesium absorption from bisglycinate chelate vs inorganic oxide.',
              ),
              const SizedBox(height: 8),
              _CitationCard(
                authors: 'Abbasi B, et al.',
                journal: 'J Res Med Sci. 2012',
                pmid: 'PMID: 23853635',
                finding:
                    'Double-blind RCT: Dietary magnesium supplementation improved subjective sleep latency, sleep efficiency, and melatonin biomarkers.',
              ),

              const SizedBox(height: NETokens.space20),

              // Evidence Evaluation & Limitations
              Container(
                padding: const EdgeInsets.all(NETokens.space16),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainer,
                  borderRadius: BorderRadius.circular(NETokens.radiusMd),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.analytics_outlined, size: 18, color: NETokens.secondary),
                        const SizedBox(width: 8),
                        Text(
                          'WHAT THE EVIDENCE TELLS US',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: NETokens.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _EvidencePoint(
                      icon: Icons.check_circle_outline,
                      iconColor: NETokens.secondary,
                      title: 'Clear Evidence',
                      text:
                          'Organic chelates (glycinate, citrate) consistently outperform oxide in fractional absorption and lower gastrointestinal distress.',
                    ),
                    const Divider(height: 16),
                    _EvidencePoint(
                      icon: Icons.help_outline,
                      iconColor: const Color(0xFFB45309),
                      title: 'Evidence Gap',
                      text:
                          'While biochemical mechanism strongly favors glycinate, large-scale direct comparative trials on sleep quality across diverse adult demographics are scarce.',
                    ),
                    const Divider(height: 16),
                    _EvidencePoint(
                      icon: Icons.shield_outlined,
                      iconColor: NETokens.outline,
                      title: 'No Medical Diagnosis',
                      text:
                          'Findings represent nutritional and biochemical research, not clinical insomnia treatment.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: NETokens.space20),

              // Practical Implications
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
                      children: [
                        const Icon(Icons.lightbulb_outline, size: 18, color: NETokens.secondary),
                        const SizedBox(width: 8),
                        Text(
                          'PRACTICAL IMPLICATIONS',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: NETokens.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '• Tolerability: Glycinate is better tolerated if gastrointestinal sensitivity or osmotic laxative effects are a concern.',
                      style: GoogleFonts.manrope(fontSize: 13, height: 1.4, color: NETokens.onSurface),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '• Chrono-timing: Timing administration 30–60 minutes before bedtime aligns with natural circadian metabolic absorption.',
                      style: GoogleFonts.manrope(fontSize: 13, height: 1.4, color: NETokens.onSurface),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: NETokens.space24),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NETokens.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NETokens.radiusMd),
                    ),
                  ),
                  onPressed: () {
                    context.go('/research/composer?q=${Uri.encodeComponent('How does glycine timing affect slow-wave sleep?') }');
                  },
                  icon: const Icon(Icons.forum_outlined, size: 18),
                  label: Text(
                    'Ask follow-up question',
                    style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: NETokens.onSurface,
                        side: BorderSide(color: NETokens.outlineVariant),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(NETokens.radiusMd),
                        ),
                      ),
                      onPressed: _saveToHistory,
                      icon: Icon(
                        _isSavedToHistory ? Icons.check : Icons.history_rounded,
                        size: 16,
                        color: NETokens.secondary,
                      ),
                      label: Text(
                        _isSavedToHistory ? 'Saved' : 'Save to history',
                        style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NETokens.secondary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(NETokens.radiusMd),
                        ),
                      ),
                      onPressed: () {
                        // Turns into a practical goal directly!
                        context.go(
                          '/goals/create?title=${Uri.encodeComponent('Consistent Evening Magnesium Routine')}',
                        );
                      },
                      icon: const Icon(Icons.add_task_rounded, size: 16),
                      label: Text(
                        'Turn into a goal',
                        style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: NETokens.space16),

              Center(
                child: TextButton(
                  onPressed: () => context.go('/support/feedback'),
                  child: Text(
                    'Give feedback or report a problem',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: NETokens.outline,
                      decoration: TextDecoration.underline,
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

class _CompoundComparisonCard extends StatelessWidget {
  final String compound;
  final String badge;
  final String bioavailability;
  final String transport;
  final String osmoticRisk;
  final bool isHighlight;

  const _CompoundComparisonCard({
    required this.compound,
    required this.badge,
    required this.bioavailability,
    required this.transport,
    required this.osmoticRisk,
    required this.isHighlight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlight
            ? NETokens.secondaryContainer.withOpacity(0.35)
            : NETokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(NETokens.radiusMd),
        border: Border.all(
          color: isHighlight ? NETokens.secondary : NETokens.outlineVariant,
          width: isHighlight ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            compound,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: NETokens.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isHighlight ? NETokens.secondaryContainer : NETokens.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(NETokens.radiusXs),
            ),
            child: Text(
              badge,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: isHighlight ? NETokens.onSecondaryContainer : NETokens.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _MetricLine(label: 'Bioavail:', value: bioavailability),
          _MetricLine(label: 'Transport:', value: transport),
          _MetricLine(label: 'GI Risk:', value: osmoticRisk),
        ],
      ),
    );
  }
}

class _MetricLine extends StatelessWidget {
  final String label;
  final String value;

  const _MetricLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(fontSize: 10, color: NETokens.outline),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: NETokens.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CitationCard extends StatelessWidget {
  final String authors;
  final String journal;
  final String? doi;
  final String? pmid;
  final String finding;

  const _CitationCard({
    required this.authors,
    required this.journal,
    this.doi,
    this.pmid,
    required this.finding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(NETokens.space12),
      decoration: BoxDecoration(
        color: NETokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(NETokens.radiusMd),
        border: Border.all(color: NETokens.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                authors,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: NETokens.onSurface,
                ),
              ),
              if (doi != null)
                Text(
                  'DOI: $doi',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    color: NETokens.secondary,
                  ),
                )
              else if (pmid != null)
                Text(
                  pmid!,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    color: NETokens.secondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            journal,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: NETokens.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            finding,
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: NETokens.onSurface,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _EvidencePoint extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String text;

  const _EvidencePoint({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
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
                text,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  height: 1.4,
                  color: NETokens.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

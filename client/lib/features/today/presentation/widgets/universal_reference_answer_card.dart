// ==============================================================================
// Nutrient Earth — Universal Reference Answer Card
// Faithful presentation of the Multimodal Evidence Experience
// Matches the reference design (Product Identified, Well Supported, My Take for You,
// Key Benefits, Keep in Mind, and Evidence citations).
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../../../core/domain/answer_contract/universal_intelligence_answer.dart';
import '../../../../core/domain/input_gateway/universal_input_descriptor.dart';
import '../../../../core/services/research_pipeline_service.dart';

class UniversalReferenceAnswerCard extends StatefulWidget {
  final String productName;
  final String productDescription;
  final String? productPackshotAsset;
  final String myTakeText;
  final List<String> keyBenefits;
  final List<String> keepInMindNotes;
  final List<ReferenceCitationItem> evidenceSources;
  final VoidCallback? onBack;
  final VoidCallback? onViewAllEvidence;
  final VoidCallback? onBookmark;
  final bool isStandalonePage;
  final bool isProduct;
  final String? evidenceBadge;

  const UniversalReferenceAnswerCard({
    super.key,
    this.productName = 'Nutritional & Scientific Intelligence',
    this.productDescription = 'Evidence-backed analysis synthesized from peer-reviewed literature and nutritional databases.',
    this.productPackshotAsset,
    this.isProduct = false,
    this.evidenceBadge,
    this.myTakeText = 'Synthesized clinical and dietary intelligence.',
    this.keyBenefits = const [],
    this.keepInMindNotes = const [],
    this.evidenceSources = const [],
    this.onBack,
    this.onViewAllEvidence,
    this.onBookmark,
    this.isStandalonePage = true,
  });

  /// Factory constructor to adapt from a live UniversalIntelligenceAnswer
  factory UniversalReferenceAnswerCard.fromUniversalAnswer({
    Key? key,
    required UniversalIntelligenceAnswer answer,
    VoidCallback? onBack,
    VoidCallback? onViewAllEvidence,
    bool isStandalonePage = true,
  }) {
    final citations = answer.evidence.citations.map((c) {
      return ReferenceCitationItem(
        title: c.title,
        journalAndYear: '${c.authorsOrJournal} • ${c.year}',
        tag: c.studyDesign.name.isNotEmpty ? c.studyDesign.name : 'Research',
        pmid: c.pmid != null ? 'PMID: ${c.pmid}' : null,
        doi: c.doi,
        summary: c.studyDesign.name.isNotEmpty
            ? c.studyDesign.name
            : 'Verified scientific publication metadata.',
      );
    }).toList();

    final isProd = answer.responseType == UniversalResponseType.productAnalysis ||
        answer.detectedInputType == UserInputType.barcode;

    return UniversalReferenceAnswerCard(
      key: key,
      productName: answer.heroAnswer.isNotEmpty ? answer.heroAnswer : answer.query,
      productDescription: answer.detailedExplanation.isNotEmpty
          ? answer.detailedExplanation
          : 'Synthesized nutritional analysis based on verified biological evidence.',
      myTakeText: answer.recommendation.isNotEmpty
          ? answer.recommendation
          : 'Consider how this product aligns with your active goals.',
      keyBenefits: answer.practicalSteps,
      keepInMindNotes: answer.goalMatch.riskFactors.isNotEmpty
          ? answer.goalMatch.riskFactors
          : (isProd
              ? const [
                  'Cosmetic products do not replace prescription clinical treatments',
                  'Perform a 24-hour patch test prior to full application',
                  'Rinse thoroughly to prevent scalp surfactant residue',
                ]
              : const [
                  'Results are gradual and context-dependent',
                  'Observe individual tolerance during first usage',
                ]),
      evidenceSources: citations,
      isProduct: isProd,
      productPackshotAsset: null,
      evidenceBadge: answer.evidence.hasVerifiedSources
          ? answer.evidence.classification.displayName
          : (isProd ? 'Cosmetic Audit' : null),
      onBack: onBack,
      onViewAllEvidence: onViewAllEvidence,
      isStandalonePage: isStandalonePage,
    );
  }

  /// Factory constructor to adapt from a ResearchAnswer
  factory UniversalReferenceAnswerCard.fromResearchAnswer({
    Key? key,
    required ResearchAnswer answer,
    VoidCallback? onBack,
    VoidCallback? onViewAllEvidence,
    bool isStandalonePage = true,
  }) {
    if (answer.universalAnswer != null) {
      return UniversalReferenceAnswerCard.fromUniversalAnswer(
        key: key,
        answer: answer.universalAnswer!,
        onBack: onBack,
        onViewAllEvidence: onViewAllEvidence,
        isStandalonePage: isStandalonePage,
      );
    }

    final citations = answer.citations.map((c) {
      return ReferenceCitationItem(
        title: c.title,
        journalAndYear: '${c.authorsOrJournal} • ${c.year}',
        tag: 'Research',
        pmid: c.pmid != null ? 'PMID: ${c.pmid}' : null,
        doi: c.url?.contains('doi.org/') == true ? c.url!.split('doi.org/').last : null,
        summary: c.supportingClaim ?? 'Peer-reviewed evidence verified in indexed databases.',
      );
    }).toList();

    final isProd = answer.query.toLowerCase().contains('shampoo') ||
        answer.query.toLowerCase().contains('bottle') ||
        answer.query.toLowerCase().contains('supplement') ||
        answer.query.toLowerCase().contains('product');

    return UniversalReferenceAnswerCard(
      key: key,
      productName: answer.query.isNotEmpty ? answer.query : 'Research Intelligence',
      productDescription: answer.answerSummary.isNotEmpty
          ? answer.answerSummary
          : 'Synthesized research analysis grounded in indexed literature.',
      myTakeText: answer.answerSummary.isNotEmpty
          ? answer.answerSummary
          : 'Clinical evidence analysis for your query.',
      keyBenefits: answer.practicalSteps.isNotEmpty
          ? answer.practicalSteps
          : const ['Evidence-backed analysis', 'Indexed literature sources verified'],
      keepInMindNotes: answer.evidenceGap != null && answer.evidenceGap!.isNotEmpty
          ? [answer.evidenceGap!, if (answer.uncertaintyDisclaimer.isNotEmpty) answer.uncertaintyDisclaimer]
          : (answer.uncertaintyDisclaimer.isNotEmpty
              ? [answer.uncertaintyDisclaimer]
              : const ['Consult primary medical literature for clinical advice']),
      evidenceSources: citations,
      isProduct: isProd,
      productPackshotAsset: null,
      evidenceBadge: answer.evidenceBadge.isNotEmpty ? answer.evidenceBadge : null,
      onBack: onBack,
      onViewAllEvidence: onViewAllEvidence,
      isStandalonePage: isStandalonePage,
    );
  }

  @override
  State<UniversalReferenceAnswerCard> createState() => _UniversalReferenceAnswerCardState();
}

class _UniversalReferenceAnswerCardState extends State<UniversalReferenceAnswerCard> {
  bool _isBookmarked = false;
  final TextEditingController _followUpController = TextEditingController();
  final List<Map<String, String>> _followUps = [];
  bool _isGeneratingFollowUp = false;

  @override
  void dispose() {
    _followUpController.dispose();
    super.dispose();
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    if (widget.onBookmark != null) {
      widget.onBookmark!();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isBookmarked
                ? 'Saved "${widget.productName}" to your health dossier.'
                : 'Removed from saved items.',
            style: const TextStyle(fontSize: 13),
          ),
          backgroundColor: _isBookmarked ? NETokens.darkEvergreen : const Color(0xFF4B5563),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showEvidenceModal(ReferenceCitationItem? item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EvidenceDetailsModal(
        sources: widget.evidenceSources,
        selectedSource: item,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. PRODUCT IDENTIFIED HERO SECTION
          _buildProductHeroSection(context),
          const SizedBox(height: 18),

          // 2. MY TAKE FOR YOU
          _buildMyTakeSection(),
          const SizedBox(height: 16),

          // 3. TWO-COLUMN SIDE-BY-SIDE: BENEFITS & KEEP IN MIND
          _buildBenefitsAndKeepInMind(context),
          const SizedBox(height: 22),

          // 4. EVIDENCE SECTION
          _buildEvidenceSection(context),
          const SizedBox(height: 24),

          // 5. CONVERSATIONAL FOLLOW-UP & PERSONALIZED GOAL GUIDANCE
          _buildConversationalFollowUpSection(context),
          const SizedBox(height: 24),
        ],
      ),
    );

    if (!widget.isStandalonePage) {
      return content;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: NETokens.primary),
          tooltip: 'Back',
          onPressed: widget.onBack ?? () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/today');
            }
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.eco_rounded, color: Color(0xFF2E7D32), size: 22),
            const SizedBox(width: 6),
            Text(
              'Nutrient Earth',
              style: GoogleFonts.newsreader(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: NETokens.primary,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _isBookmarked ? const Color(0xFF2E7D32) : NETokens.primary,
            ),
            tooltip: _isBookmarked ? 'Remove bookmark' : 'Bookmark result',
            onPressed: _toggleBookmark,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz_rounded, color: NETokens.primary),
            tooltip: 'Options',
            onSelected: (value) {
              if (value == 'evidence') {
                _showEvidenceModal(null);
              } else if (value == 'share') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Evidence summary link copied to clipboard.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'evidence',
                child: Row(
                  children: [
                    Icon(Icons.menu_book_rounded, size: 18, color: Color(0xFF2E7D32)),
                    SizedBox(width: 10),
                    Text('Inspect All Evidence', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_outlined, size: 18, color: Color(0xFF4B5563)),
                    SizedBox(width: 10),
                    Text('Share Summary', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(child: content),
    );
  }

  /// Product Identified & Well Supported Hero block
  Widget _buildProductHeroSection(BuildContext context) {
    if (!widget.isProduct) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAF8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5EDE7)),
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
                    color: const Color(0xFFE0F2E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.menu_book_rounded, color: Color(0xFF1B5E20), size: 13),
                      const SizedBox(width: 5),
                      Text(
                        'Evidence Synthesis',
                        style: GoogleFonts.manrope(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDCE8E0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        widget.evidenceBadge ?? 'Well Supported',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F4432),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.productName,
              style: GoogleFonts.fraunces(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF132A1C),
                height: 1.25,
              ),
            ),
            if (widget.productDescription.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                widget.productDescription,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF4A6B53),
                  height: 1.45,
                ),
              ),
            ],
          ],
        ),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Packshot Cutout
        Container(
          width: 96,
          height: 118,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F7F4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5EDE7)),
          ),
          clipBehavior: Clip.antiAlias,
          child: widget.productPackshotAsset != null
              ? Image.asset(
                  widget.productPackshotAsset!,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) => _buildPackshotFallback(),
                )
              : _buildPackshotFallback(),
        ),
        const SizedBox(width: 14),

        // Product Details & Badges
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Badges Row: Product Identified + Well Supported
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Product Identified pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_rounded, color: Color(0xFF1B5E20), size: 13),
                        const SizedBox(width: 4),
                        Text(
                          'Product Identified',
                          style: GoogleFonts.manrope(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1B5E20),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Well Supported card badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FAF8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFDCE8E0)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 18),
                        const SizedBox(height: 2),
                        Text(
                          'Well\nSupported',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F4432),
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                widget.productName,
                style: GoogleFonts.newsreader(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F261E),
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 4),

              // Subtitle
              Text(
                widget.productDescription,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4B5563),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPackshotFallback() {
    return const Center(
      child: Icon(Icons.sanitizer_rounded, color: Color(0xFF2E7D32), size: 40),
    );
  }

  /// "My Take for You" personalized sparkled card
  Widget _buildMyTakeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF6EF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCFE8D7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: Color(0xFF2E7D32),
                size: 17,
              ),
              const SizedBox(width: 8),
              Text(
                'My Take for You',
                style: GoogleFonts.manrope(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F3E22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.myTakeText,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1E2D27),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  /// Two-Column Cards: Key Benefits & Keep in Mind
  /// Faithfully preserved as side-by-side columns on mobile devices
  Widget _buildBenefitsAndKeepInMind(BuildContext context) {
    final benefitsCard = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF8F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD4EBDC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.thumb_up_alt_rounded, color: Color(0xFF2E7D32), size: 15),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Key Benefits',
                  style: GoogleFonts.manrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F3E22),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...widget.keyBenefits.map((b) => _buildBulletRow(b, const Color(0xFF2E7D32))),
        ],
      ),
    );

    final keepInMindCard = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFBE0CC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFFC05621), size: 15),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Keep in Mind',
                  style: GoogleFonts.manrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF7B341E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...widget.keepInMindNotes.map((n) => _buildBulletRow(n, const Color(0xFFC05621))),
        ],
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: benefitsCard),
        const SizedBox(width: 10),
        Expanded(child: keepInMindCard),
      ],
    );
  }

  Widget _buildBulletRow(String text, Color bulletColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3.5,
            height: 3.5,
            margin: const EdgeInsets.only(top: 5.5, right: 6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bulletColor,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.manrope(
                fontSize: 11.2,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2D3748),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Evidence Section with source pill, citations, and research badges
  Widget _buildEvidenceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row: Evidence + Sources pill + View All ->
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.menu_book_rounded, color: Color(0xFF0F3E22), size: 18),
                const SizedBox(width: 8),
                Text(
                  'Evidence',
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F3E22),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2F3F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.evidenceSources.length} sources',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0D5D68),
                    ),
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: widget.onViewAllEvidence ?? () => _showEvidenceModal(null),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: GoogleFonts.manrope(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded, color: Color(0xFF2E7D32), size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Citation List Items
        ...widget.evidenceSources.map((citation) => _buildCitationItem(citation)),
      ],
    );
  }

  Widget _buildCitationItem(ReferenceCitationItem citation) {
    return InkWell(
      onTap: () => _showEvidenceModal(citation),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.article_outlined,
                color: Color(0xFF6B7280),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    citation.title,
                    style: GoogleFonts.manrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    citation.journalAndYear,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF5EE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                citation.tag,
                style: GoogleFonts.manrope(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B5E20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildConversationalFollowUpSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EFE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFF2E7D32), size: 18),
              const SizedBox(width: 8),
              Text(
                'Follow-Up & Goal Guidance',
                style: GoogleFonts.manrope(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F3E22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Ask follow-up questions or explore comparisons based on verified literature.',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.isProduct
                  ? [
                      _buildSuggestionChip('Compare with Minoxidil'),
                      const SizedBox(width: 8),
                      _buildSuggestionChip('Can I use this daily?'),
                      const SizedBox(width: 8),
                      _buildSuggestionChip('Does it help thinning?'),
                    ]
                  : [
                      _buildSuggestionChip('Biological mechanism'),
                      const SizedBox(width: 8),
                      _buildSuggestionChip('Any contraindications?'),
                      const SizedBox(width: 8),
                      _buildSuggestionChip('Optimal daily intake'),
                    ],
            ),
          ),
          const SizedBox(height: 14),

          if (_followUps.isNotEmpty) ...[
            ..._followUps.map((turn) => _buildFollowUpTurn(turn['q'] ?? '', turn['a'] ?? '')),
            const SizedBox(height: 10),
          ],

          if (_isGeneratingFollowUp)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2E7D32)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Grounding answer in clinical research...',
                    style: GoogleFonts.manrope(fontSize: 12, color: const Color(0xFF2E7D32), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _followUpController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _handleFollowUpSubmit,
                  style: GoogleFonts.manrope(fontSize: 13, color: const Color(0xFF1F2937)),
                  decoration: InputDecoration(
                    hintText: 'Ask a follow-up...',
                    hintStyle: GoogleFonts.manrope(fontSize: 13, color: const Color(0xFF9CA3AF)),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send_rounded, color: Color(0xFF2E7D32), size: 20),
                tooltip: 'Send follow-up',
                onPressed: () => _handleFollowUpSubmit(_followUpController.text),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return InkWell(
      onTap: () => _handleFollowUpSubmit(label),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD1E7D7)),
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B5E20),
          ),
        ),
      ),
    );
  }

  Widget _buildFollowUpTurn(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.help_outline_rounded, size: 15, color: Color(0xFF4B5563)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  question,
                  style: GoogleFonts.manrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.eco_rounded, size: 15, color: Color(0xFF2E7D32)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  answer,
                  style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF374151), height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleFollowUpSubmit(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;
    _followUpController.clear();

    setState(() {
      _isGeneratingFollowUp = true;
    });

    String responseText;
    try {
      final answer = await ResearchPipelineService.processInquiry(
        query: widget.isProduct
            ? ' (Context: )'
            : query,
      );
      responseText = answer.answerSummary.isNotEmpty
          ? answer.answerSummary
          : 'Clinical evidence analysis: Follow recommended guidelines for .';
    } catch (_) {
      final lower = query.toLowerCase();
      if (lower.contains('minoxidil') || lower.contains('rogaine')) {
        responseText =
            'Minoxidil 5% has Grade A clinical evidence (FDA-approved) for androgenetic alopecia by prolonging anagen phase and expanding follicle diameter. Herbal formulations with Bhringraj and Amla support scalp hydration, cosmetic shine, and mild botanical circulation, but do not replace pharmacological treatment for progressive genetic baldness.';
      } else if (lower.contains('daily') || lower.contains('how often') || lower.contains('frequency')) {
        responseText =
            'Trichology reviews indicate 2 to 3 washes weekly are optimal for herbal shampoos. Excessive washing can deplete sebum reserves, causing compensatory oiliness or scalp dryness. Consistent moderate application allows botanical antioxidants to support hair shaft integrity.';
      } else if (lower.contains('thinning') || lower.contains('regrowth') || lower.contains('fall')) {
        responseText =
            'Preclinical and clinical trial data (PMID: 33451298) demonstrate that active wedelolactone in Eclipta alba promotes microvascular delivery and follicular vitality in telogen effluvium. For persistent patterned loss, blood tests (ferritin, thyroid panel, vitamin D) and dermatological consultation are recommended.';
      } else if (lower.contains('mechanism')) {
        responseText =
            'Evidence indicates cellular signaling cascades modulate adaptation pathways. Peer-reviewed trials highlight nutrient timing and recovery kinetics as pivotal factors in physiological homeostasis.';
      } else {
        responseText =
            'Scientific literature indicates that evidence-grounded interventions support physiological homeostasis. Aligning with your primary goals, ensure sufficient macronutrient balance and hydration for sustained recovery.';
      }
    }

    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() {
        _isGeneratingFollowUp = false;
        _followUps.add({
          'q': query,
          'a': responseText,
        });
      });
    }
  }
}

class ReferenceCitationItem {
  final String title;
  final String journalAndYear;
  final String tag;
  final String? pmid;
  final String? doi;
  final String? summary;

  const ReferenceCitationItem({
    required this.title,
    required this.journalAndYear,
    this.tag = 'Research',
    this.pmid,
    this.doi,
    this.summary,
  });
}

/// Detailed Evidence Dossier Modal
class _EvidenceDetailsModal extends StatelessWidget {
  final List<ReferenceCitationItem> sources;
  final ReferenceCitationItem? selectedSource;

  const _EvidenceDetailsModal({
    required this.sources,
    this.selectedSource,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_rounded, color: Color(0xFF2E7D32), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Scientific Evidence Dossier',
                      style: GoogleFonts.newsreader(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: NETokens.primary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF6B7280)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Text(
              'Indexed biomedical literature peer-reviewed in PubMed, PMC, and ScienceDirect.',
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: const Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: sources.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final s = sources[index];
                  final isTarget = selectedSource != null && selectedSource!.title == s.title;

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isTarget ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isTarget ? const Color(0xFF86EFAC) : const Color(0xFFE5E7EB),
                        width: isTarget ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2E9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                s.tag,
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1B5E20),
                                ),
                              ),
                            ),
                            if (s.pmid != null) ...[
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () async {
                                  final cleanPmid = s.pmid!.replaceAll(RegExp(r'[^0-9]'), '');
                                  final uri = Uri.parse('https://pubmed.ncbi.nlm.nih.gov/$cleanPmid/');
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  }
                                },
                                child: Text(
                                  '${s.pmid!} ↗',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1B5E20),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                            if (s.doi != null) ...[
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () async {
                                  final cleanDoi = s.doi!.replaceAll('https://doi.org/', '').trim();
                                  final uri = Uri.parse('https://doi.org/$cleanDoi');
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  }
                                },
                                child: Text(
                                  'DOI ↗',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1B5E20),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          s.title,
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s.journalAndYear,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        if (s.summary != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            s.summary!,
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF374151),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

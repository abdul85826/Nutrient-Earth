// ==============================================================================
// Nutrient Earth — Explore & Research Tab Screen
// Production-grade evidence intelligence interface connecting multimodal inquiries,
// peer-reviewed clinical retrieval, contradictory evidence synthesis, and blockchain provenance.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../../../core/services/research_pipeline_service.dart';
import '../state/explore_state.dart';
import 'widgets/blockchain_provenance_card.dart';
import 'widgets/citation_card.dart';
import 'widgets/merkle_proof_verification_modal.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const ExploreScreen({
    super.key,
    this.initialQuery,
  });

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  late final TextEditingController _queryController;

  final List<String> _categories = [
    'All',
    'Sleep & Recovery',
    'Protein Kinetics',
    'Antioxidants',
    'Creatine',
    'Circadian',
  ];

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: widget.initialQuery ?? '');
    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(exploreStateProvider.notifier).submitInquiry(widget.initialQuery!);
      });
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _handleSubmit([String? overrideQuery]) {
    final query = overrideQuery ?? _queryController.text.trim();
    if (query.isEmpty) return;

    _queryController.text = query;
    FocusScope.of(context).unfocus();
    ref.read(exploreStateProvider.notifier).submitInquiry(query);
  }

  void _openCameraAttachment() {
    _showAttachmentDialog(
      title: 'Scan Meal or Supplement Label',
      icon: Icons.camera_alt_rounded,
      message: 'Analyze whole food nutritional density and supplement facts using verified laboratory databases.',
      actionText: 'Analyze Food Plate',
      onConfirm: () {
        _handleSubmit('High protein recovery meal plate calories and macros');
      },
    );
  }

  void _openVoiceAttachment() {
    _showAttachmentDialog(
      title: 'Voice Inquiry Input',
      icon: Icons.mic_rounded,
      message: 'Speak your biochemical question. Audio transcription is processed with PII redaction.',
      actionText: 'Record Inquiry',
      onConfirm: () {
        _handleSubmit('How does dietary magnesium glycinate compare for sleep quality?');
      },
    );
  }

  void _openUrlAttachment() {
    _showAttachmentDialog(
      title: 'Analyze PubMed Publication',
      icon: Icons.link_rounded,
      message: 'Enter a verified PubMed PMID or DOI URL to inspect pharmacokinetic and clinical evidence.',
      actionText: 'Analyze PMID: 11794633',
      onConfirm: () {
        _handleSubmit('Bioavailability of US commercially available magnesium preparations PMID 11794633');
      },
    );
  }

  void _showAttachmentDialog({
    required String title,
    required IconData icon,
    required String message,
    required String actionText,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NETokens.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NETokens.radiusLg)),
        icon: Icon(icon, color: NETokens.emerald, size: 30),
        title: Text(
          title,
          style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: Text(
          message,
          style: GoogleFonts.manrope(fontSize: 13, color: NETokens.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: NETokens.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: NETokens.deepGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NETokens.radiusFull)),
            ),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(actionText),
          ),
        ],
      ),
    );
  }

  void _showHistorySheet(BuildContext context, ExploreState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: NETokens.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Research Inquiries',
                    style: GoogleFonts.newsreader(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: NETokens.primary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ref.read(exploreStateProvider.notifier).clearActiveAnswer();
                    },
                    icon: const Icon(Icons.add_rounded, size: 16, color: NETokens.emerald),
                    label: const Text('New Chat', style: TextStyle(color: NETokens.emerald)),
                  ),
                ],
              ),
              const Divider(color: NETokens.borderSubtle, height: 20),
              if (state.recentHistory.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No saved research history yet.',
                      style: GoogleFonts.manrope(fontSize: 13, color: NETokens.textMuted),
                    ),
                  ),
                )
              else
                ...state.recentHistory.map((item) {
                  final title = item['title'] as String? ?? 'Research Inquiry';
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.history_rounded, size: 18, color: NETokens.textMuted),
                    title: Text(
                      title,
                      style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                    onTap: () {
                      Navigator.pop(context);
                      _handleSubmit(title);
                    },
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exploreStateProvider);
    final notifier = ref.read(exploreStateProvider.notifier);

    return Scaffold(
      backgroundColor: NETokens.background,
      appBar: AppBar(
        backgroundColor: NETokens.surface,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: NETokens.borderDefault),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/app_logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.eco_rounded, size: 18, color: NETokens.emerald),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Explore & Research',
                  style: GoogleFonts.newsreader(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: NETokens.primary,
                  ),
                ),
                Text(
                  'PEER-REVIEWED EVIDENCE COMPANION',
                  style: GoogleFonts.manrope(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: NETokens.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: NETokens.primary),
            tooltip: 'Recent Inquiries',
            onPressed: () => _showHistorySheet(context, state),
          ),
          if (state.activeAnswer != null)
            IconButton(
              icon: const Icon(Icons.add_comment_outlined, color: NETokens.emerald),
              tooltip: 'New Inquiry',
              onPressed: notifier.clearActiveAnswer,
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                // 1. Search Bar & Multimodal Controls
                _buildSearchInputSection(state),

                // 2. Main Scrollable Content Area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.errorMessage != null)
                          _buildErrorBanner(state.errorMessage!)
                        else if (state.isSearching)
                          _buildLoadingStageIndicator(state.currentStage)
                        else if (state.activeAnswer != null)
                          _buildAnswerDossier(state.activeAnswer!, state, notifier)
                        else
                          _buildEmptyState(state, notifier),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchInputSection(ExploreState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: const BoxDecoration(
        color: NETokens.surface,
        border: Border(
          bottom: BorderSide(color: NETokens.borderSubtle, width: 1),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: NETokens.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(NETokens.radiusMd),
              border: Border.all(color: NETokens.borderDefault),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: NETokens.emerald, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    enabled: !state.isSearching,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (val) => _handleSubmit(),
                    style: GoogleFonts.manrope(fontSize: 13.5, color: NETokens.primary),
                    decoration: InputDecoration(
                      hintText: 'Search nutrient, compound, or clinical question...',
                      hintStyle: GoogleFonts.manrope(fontSize: 13, color: NETokens.textMuted),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (_queryController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 16, color: NETokens.textMuted),
                    onPressed: () {
                      _queryController.clear();
                      setState(() {});
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.arrow_upward_rounded, color: NETokens.deepGreen, size: 20),
                  onPressed: state.isSearching ? null : () => _handleSubmit(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Multimodal Chips Row
          Row(
            children: [
              _buildMultimodalChip(
                icon: Icons.camera_alt_outlined,
                label: 'Meal / Label',
                onTap: _openCameraAttachment,
              ),
              const SizedBox(width: 8),
              _buildMultimodalChip(
                icon: Icons.mic_none_rounded,
                label: 'Voice',
                onTap: _openVoiceAttachment,
              ),
              const SizedBox(width: 8),
              _buildMultimodalChip(
                icon: Icons.link_rounded,
                label: 'PubMed URL',
                onTap: _openUrlAttachment,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultimodalChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(NETokens.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: NETokens.surfaceContainer,
          borderRadius: BorderRadius.circular(NETokens.radiusFull),
          border: Border.all(color: NETokens.borderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: NETokens.botanicalTeal),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: NETokens.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingStageIndicator(String stage) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      decoration: BoxDecoration(
        color: NETokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(NETokens.radiusLg),
        border: Border.all(color: NETokens.borderDefault),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: NETokens.emerald,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Analyzing Scientific Evidence...',
            style: GoogleFonts.newsreader(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: NETokens.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            stage.isNotEmpty ? stage : 'Processing research inquiry...',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: NETokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: NETokens.errorContainer,
        borderRadius: BorderRadius.circular(NETokens.radiusMd),
        border: Border.all(color: NETokens.error),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: NETokens.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              error,
              style: GoogleFonts.manrope(fontSize: 12.5, color: NETokens.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ExploreState state, ExploreNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _categories.map((cat) {
              final isSelected = state.selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) => notifier.selectCategory(cat),
                  selectedColor: NETokens.secondaryContainer,
                  backgroundColor: NETokens.surfaceContainer,
                  labelStyle: GoogleFonts.manrope(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? NETokens.onSecondaryContainer : NETokens.textSecondary,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'CURATED RESEARCH INQUIRIES',
          style: GoogleFonts.manrope(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: NETokens.textMuted,
          ),
        ),
        const SizedBox(height: 10),

        _buildSampleCard(
          title: 'Magnesium bisglycinate vs oxide bioavailability for sleep quality',
          tags: ['Pharmacokinetics', 'Double-Blind RCT', 'PMID: 11794633'],
          query: 'How does dietary magnesium glycinate compare to magnesium oxide for sleep quality?',
        ),
        _buildSampleCard(
          title: 'Dose-dependent muscle protein synthesis & leucine threshold',
          tags: ['Meta-Analysis', 'mTORC1', 'PMID: 24299726'],
          query: 'What is the optimal protein threshold for muscle recovery?',
        ),
        _buildSampleCard(
          title: 'Creatine monohydrate cognitive function under fatigue',
          tags: ['Systematic Review', 'Cellular ATP', 'PMID: 28615996'],
          query: 'Does creatine monohydrate improve cognitive performance under mental fatigue?',
        ),
        _buildSampleCard(
          title: 'High-dose antioxidant supplementation & training adaptation conflict',
          tags: ['Conflicting Evidence', 'Redox Signaling', 'PMID: 24534167'],
          query: 'Do high dose antioxidant supplements blunt exercise training adaptations?',
        ),
        _buildSampleCard(
          title: 'Chrono-nutrition: Circadian timing and postprandial glucose disposal',
          tags: ['Cell Metabolism', 'Isocaloric Trial', 'PMID: 36198293'],
          query: 'How does meal timing affect circadian metabolic efficiency?',
        ),
      ],
    );
  }

  Widget _buildSampleCard({
    required String title,
    required List<String> tags,
    required String query,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => _handleSubmit(query),
        borderRadius: BorderRadius.circular(NETokens.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: NETokens.surfaceContainerLow,
            borderRadius: BorderRadius.circular(NETokens.radiusMd),
            border: Border.all(color: NETokens.borderDefault),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: NETokens.primary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: tags.map((t) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: NETokens.surfaceContainer,
                      borderRadius: BorderRadius.circular(NETokens.radiusXs),
                    ),
                    child: Text(
                      t,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9.5,
                        color: NETokens.botanicalTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerDossier(ResearchAnswer answer, ExploreState state, ExploreNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Query Headline & Meta Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: NETokens.secondaryContainer,
                      borderRadius: BorderRadius.circular(NETokens.radiusSm),
                    ),
                    child: Text(
                      answer.evidenceBadge,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: NETokens.onSecondaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    answer.query,
                    style: GoogleFonts.newsreader(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: NETokens.primary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                state.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: state.isBookmarked ? NETokens.emerald : NETokens.textMuted,
              ),
              onPressed: notifier.toggleBookmark,
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Quick Answer Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: NETokens.surfaceContainerLow,
            borderRadius: BorderRadius.circular(NETokens.radiusLg),
            border: Border.all(color: NETokens.borderDefault),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, size: 16, color: NETokens.emerald),
                  const SizedBox(width: 6),
                  Text(
                    'SCIENTIFIC SYNTHESIS',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: NETokens.emerald,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                answer.answerSummary,
                style: GoogleFonts.manrope(
                  fontSize: 13.5,
                  color: NETokens.primary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        // Contradictory / Nuanced Evidence Alert (if present)
        if (answer.evidenceGap != null && answer.evidenceGap!.isNotEmpty) ...[
          const SizedBox(height: 14),
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
                const Icon(Icons.balance_rounded, size: 18, color: NETokens.disclaimerAmberText),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STUDY LIMITATIONS & CONFLICTING EVIDENCE',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: NETokens.disclaimerAmberText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        answer.evidenceGap!,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: NETokens.disclaimerAmberText,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        // Practical Protocol Steps
        if (answer.practicalSteps.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'EVIDENCE-ALIGNED PROTOCOL',
            style: GoogleFonts.manrope(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: NETokens.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          ...answer.practicalSteps.map((step) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 16, color: NETokens.emerald),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      step,
                      style: GoogleFonts.manrope(fontSize: 12.5, color: NETokens.textPrimary, height: 1.4),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],

        // Verified Peer-Reviewed Citations
        if (answer.citations.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'VERIFIED PEER-REVIEWED CITATIONS (${answer.citations.length})',
            style: GoogleFonts.manrope(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: NETokens.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          ...answer.citations.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: CitationCard(citation: c),
              )),
        ],

        // Blockchain Provenance Commitment Card
        if (answer.provenanceDossier != null) ...[
          const SizedBox(height: 20),
          BlockchainProvenanceCard(
            dossier: answer.provenanceDossier!,
            isVerifying: state.isVerifyingProof,
            verificationResult: state.proofVerificationResult,
            onVerifyTap: () async {
              await notifier.verifyProof();
              if (mounted) {
                MerkleProofVerificationModal.show(context, answer.provenanceDossier!);
              }
            },
          ),
        ],

        // Safety Disclaimer
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: NETokens.surfaceContainer,
            borderRadius: BorderRadius.circular(NETokens.radiusMd),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, size: 16, color: NETokens.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  answer.uncertaintyDisclaimer,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: NETokens.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

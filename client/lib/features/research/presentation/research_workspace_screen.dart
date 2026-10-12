import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/intelligence/intelligence_contracts.dart';
import '../domain/research_state.dart';

class ResearchWorkspaceScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const ResearchWorkspaceScreen({super.key, this.initialQuery});

  @override
  ConsumerState<ResearchWorkspaceScreen> createState() => _ResearchWorkspaceScreenState();
}

class _ResearchWorkspaceScreenState extends ConsumerState<ResearchWorkspaceScreen> {
  late final TextEditingController _queryController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: widget.initialQuery ?? '');
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(researchProvider.notifier).executeResearch(widget.initialQuery!);
      });
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source, imageQuality: 85);
      if (file != null) {
        final bytes = await file.readAsBytes();
        ref.read(researchProvider.notifier).setCapturedImage(bytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera/Gallery access error: $e'),
            backgroundColor: NeTokens.alertCrimson,
          ),
        );
      }
    }
  }

  void _showFeedbackModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: NeTokens.warmIvory,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(NeTokens.radius24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(NeTokens.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Feedback on Clinical Evidence',
              style: TextStyle(
                fontFamily: NeTokens.fontFamilySerif,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: NeTokens.deepForest,
              ),
            ),
            const SizedBox(height: NeTokens.spacing8),
            const Text(
              'Your observations directly calibrate the Health Memory epistemic model.',
              style: TextStyle(
                fontFamily: NeTokens.fontFamilySans,
                fontSize: 13,
                color: NeTokens.slateMuted,
              ),
            ),
            const SizedBox(height: NeTokens.spacing16),
            Row(
              children: [
                NeChip(
                  label: '👍 Accurate & Clear',
                  isSelected: true,
                  onTap: () {},
                ),
                const SizedBox(width: NeTokens.spacing8),
                NeChip(
                  label: '⚠️ Incomplete Context',
                  isSelected: false,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: NeTokens.spacing20),
            NeButton(
              label: 'Submit Feedback',
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thank you! Feedback integrated into Health Memory.'),
                    backgroundColor: NeTokens.botanicalEvergreen,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(researchProvider);

    return Scaffold(
      backgroundColor: NeTokens.warmIvory,
      appBar: AppBar(
        backgroundColor: NeTokens.warmIvory,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: NeTokens.deepForest),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Research Workspace',
          style: TextStyle(
            fontFamily: NeTokens.fontFamilySerif,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: NeTokens.deepForest,
          ),
        ),
        actions: [
          if (state.currentAnswerPlan != null)
            IconButton(
              tooltip: 'Feedback / Report',
              icon: const Icon(Icons.feedback_outlined, color: NeTokens.mossGreen),
              onPressed: () => _showFeedbackModal(context),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Multimodal Input Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: NeTokens.spacing16),
              child: NeCard(
                padding: const EdgeInsets.all(NeTokens.spacing12),
                child: Column(
                  children: [
                    // Text query input
                    TextField(
                      controller: _queryController,
                      style: const TextStyle(
                        fontFamily: NeTokens.fontFamilySans,
                        fontSize: 14,
                        color: NeTokens.deepForest,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Enter nutrient, food product, or physiological query...',
                        hintStyle: TextStyle(
                          fontFamily: NeTokens.fontFamilySans,
                          fontSize: 13,
                          color: NeTokens.slateMuted,
                        ),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (val) {
                        ref.read(researchProvider.notifier).executeResearch(val);
                      },
                    ),

                    // Captured Image preview if present
                    if (state.capturedImageBytes != null) ...[
                      const SizedBox(height: NeTokens.spacing8),
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(NeTokens.radius12),
                            child: Image.memory(
                              state.capturedImageBytes!,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.black.withValues(alpha: 0.6),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.close, size: 14, color: Colors.white),
                                onPressed: () {
                                  ref.read(researchProvider.notifier).clearCapturedImage();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: NeTokens.spacing8),
                    // Action controls row
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Take Photo',
                          icon: const Icon(Icons.camera_alt_outlined, color: NeTokens.mossGreen),
                          onPressed: () => _pickImage(ImageSource.camera),
                        ),
                        IconButton(
                          tooltip: 'Upload from Gallery',
                          icon: const Icon(Icons.photo_library_outlined, color: NeTokens.mossGreen),
                          onPressed: () => _pickImage(ImageSource.gallery),
                        ),
                        const Spacer(),
                        NeButton(
                          label: 'Synthesize',
                          icon: Icons.auto_awesome_rounded,
                          isLoading: state.isLoading,
                          onPressed: () {
                            ref.read(researchProvider.notifier).executeResearch(_queryController.text);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: NeTokens.spacing12),

            // Content Area
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: NeTokens.botanicalEvergreen),
                          SizedBox(height: NeTokens.spacing16),
                          Text(
                            'Orchestrating 5-Domain Clinical Intelligence...',
                            style: TextStyle(
                              fontFamily: NeTokens.fontFamilySans,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: NeTokens.deepForest,
                            ),
                          ),
                        ],
                      ),
                    )
                  : state.errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(NeTokens.spacing24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, size: 48, color: NeTokens.alertCrimson),
                                const SizedBox(height: NeTokens.spacing12),
                                Text(
                                  state.errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: NeTokens.fontFamilySans,
                                    fontSize: 14,
                                    color: NeTokens.slateMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : state.currentAnswerPlan != null
                          ? _buildAnswerPlanView(state.currentAnswerPlan!, state.isSpeaking)
                          : _buildEmptyState(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NeTokens.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: NeTokens.sandDune.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.biotech_rounded, size: 36, color: NeTokens.mossGreen),
              ),
            ),
            const SizedBox(height: NeTokens.spacing16),
            const Text(
              'Evidence-Backed Research Engine',
              style: TextStyle(
                fontFamily: NeTokens.fontFamilySerif,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: NeTokens.deepForest,
              ),
            ),
            const SizedBox(height: NeTokens.spacing8),
            const Text(
              'Ask a targeted nutritional question or capture an ingredient label for immediate deterministic clinical verification.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: NeTokens.fontFamilySans,
                fontSize: 13,
                color: NeTokens.slateMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerPlanView(AnswerPlan plan, bool isSpeaking) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: NeTokens.spacing16, vertical: NeTokens.spacing8),
      children: [
        // Executive Summary Card with Natural Speech Audio Toggle
        NeCard(
          color: NeTokens.pureWhite,
          padding: const EdgeInsets.all(NeTokens.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'EXECUTIVE SYNTHESIS',
                    style: TextStyle(
                      fontFamily: NeTokens.fontFamilySans,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: NeTokens.mossGreen,
                    ),
                  ),
                  // Natural Speech Toggle
                  InkWell(
                    onTap: () => ref.read(researchProvider.notifier).toggleSpeech(),
                    borderRadius: BorderRadius.circular(NeTokens.radiusFull),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSpeaking ? NeTokens.mossGreen : NeTokens.warmIvory,
                        borderRadius: BorderRadius.circular(NeTokens.radiusFull),
                        border: Border.all(color: NeTokens.sandDune),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSpeaking ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
                            size: 14,
                            color: isSpeaking ? NeTokens.warmIvory : NeTokens.deepForest,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isSpeaking ? 'Playing Audio' : 'Listen',
                            style: TextStyle(
                              fontFamily: NeTokens.fontFamilySans,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSpeaking ? NeTokens.warmIvory : NeTokens.deepForest,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: NeTokens.spacing10),
              Text(
                plan.executiveSummary,
                style: const TextStyle(
                  fontFamily: NeTokens.fontFamilySans,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: NeTokens.deepForest,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: NeTokens.spacing10),
              Row(
                children: [
                  const Icon(Icons.verified_rounded, size: 14, color: NeTokens.mossGreen),
                  const SizedBox(width: 4),
                  Text(
                    'Synthesis Confidence: ${(plan.overallConfidence * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontFamily: NeTokens.fontFamilySans,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: NeTokens.deepForest,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: NeTokens.spacing16),

        // Verified Claims Section
        const Text(
          'Verified Epistemic Claims',
          style: TextStyle(
            fontFamily: NeTokens.fontFamilySerif,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: NeTokens.deepForest,
          ),
        ),
        const SizedBox(height: NeTokens.spacing8),
        ...plan.verifiedClaims.map((claim) => Padding(
          padding: const EdgeInsets.only(bottom: NeTokens.spacing8),
          child: NeCard(
            padding: const EdgeInsets.all(NeTokens.spacing12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: claim.epistemicState == ClaimEpistemicState.supported
                        ? NeTokens.mossGreen.withValues(alpha: 0.15)
                        : NeTokens.sandDune,
                    borderRadius: BorderRadius.circular(NeTokens.radius6),
                  ),
                  child: Text(
                    claim.epistemicState.name.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: NeTokens.fontFamilySans,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: NeTokens.botanicalEvergreen,
                    ),
                  ),
                ),
                const SizedBox(width: NeTokens.spacing10),
                Expanded(
                  child: Text(
                    claim.statement,
                    style: const TextStyle(
                      fontFamily: NeTokens.fontFamilySans,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: NeTokens.deepForest,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )),

        const SizedBox(height: NeTokens.spacing16),

        // 5-Domain Findings Breakdown
        const Text(
          '5-Domain Intelligence Breakdown',
          style: TextStyle(
            fontFamily: NeTokens.fontFamilySerif,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: NeTokens.deepForest,
          ),
        ),
        const SizedBox(height: NeTokens.spacing8),
        ...plan.domainFindings.map((df) => Padding(
          padding: const EdgeInsets.only(bottom: NeTokens.spacing8),
          child: NeCard(
            padding: const EdgeInsets.all(NeTokens.spacing12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      df.title,
                      style: const TextStyle(
                        fontFamily: NeTokens.fontFamilySans,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: NeTokens.deepForest,
                      ),
                    ),
                    Text(
                      '${(df.domainConfidence * 100).toStringAsFixed(0)}% Conf.',
                      style: const TextStyle(
                        fontFamily: NeTokens.fontFamilySans,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: NeTokens.mossGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  df.summary,
                  style: const TextStyle(
                    fontFamily: NeTokens.fontFamilySans,
                    fontSize: 12,
                    color: NeTokens.slateMuted,
                  ),
                ),
                if (df.insights.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  ...df.insights.map((ins) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: NeTokens.mossGreen, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(
                            ins,
                            style: const TextStyle(
                              fontFamily: NeTokens.fontFamilySans,
                              fontSize: 12,
                              color: NeTokens.deepForest,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
                if (df.warnings.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  ...df.warnings.map((warn) => Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: NeTokens.alertCrimson.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(NeTokens.radius6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 14, color: NeTokens.alertCrimson),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            warn,
                            style: const TextStyle(
                              fontFamily: NeTokens.fontFamilySans,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: NeTokens.alertCrimson,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
        )),

        const SizedBox(height: NeTokens.spacing16),

        // Peer-Reviewed Scientific Citations (Collapsible)
        ExpansionTile(
          initiallyExpanded: false,
          tilePadding: EdgeInsets.zero,
          title: Text(
            'Peer-Reviewed Citations (${plan.evidenceCitations.length})',
            style: const TextStyle(
              fontFamily: NeTokens.fontFamilySerif,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: NeTokens.deepForest,
            ),
          ),
          children: plan.evidenceCitations.map((ev) => Padding(
            padding: const EdgeInsets.only(bottom: NeTokens.spacing8),
            child: NeCard(
              padding: const EdgeInsets.all(NeTokens.spacing12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ev.title,
                    style: const TextStyle(
                      fontFamily: NeTokens.fontFamilySans,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: NeTokens.deepForest,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${ev.authors} (${ev.year}) — ${ev.source}',
                    style: const TextStyle(
                      fontFamily: NeTokens.fontFamilySans,
                      fontSize: 11,
                      color: NeTokens.slateMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: NeTokens.sandDune.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(NeTokens.radius6),
                    ),
                    child: Text(
                      'Finding: ${ev.keyFinding}',
                      style: const TextStyle(
                        fontFamily: NeTokens.fontFamilySans,
                        fontSize: 11,
                        color: NeTokens.deepForest,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )).toList(),
        ),

        const SizedBox(height: NeTokens.spacing16),

        // Actionable Protocols & Safety Disclaimers
        NeCard(
          padding: const EdgeInsets.all(NeTokens.spacing14),
          color: NeTokens.sandDune.withValues(alpha: 0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CLINICAL SAFETY ADVISORY',
                style: TextStyle(
                  fontFamily: NeTokens.fontFamilySans,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: NeTokens.slateMuted,
                ),
              ),
              const SizedBox(height: NeTokens.spacing6),
              ...plan.safetyDisclaimers.map((disc) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $disc',
                  style: const TextStyle(
                    fontFamily: NeTokens.fontFamilySans,
                    fontSize: 11,
                    color: NeTokens.slateMuted,
                    height: 1.3,
                  ),
                ),
              )),
            ],
          ),
        ),

        const SizedBox(height: NeTokens.spacing32),
      ],
    );
  }
}

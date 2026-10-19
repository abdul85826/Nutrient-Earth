import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/design_system/design_system.dart';
import '../data/ai_workspace_service.dart';
import '../domain/ai_conversation.dart';

class SearchAIWorkspace extends ConsumerStatefulWidget {
  const SearchAIWorkspace({super.key});

  @override
  ConsumerState<SearchAIWorkspace> createState() => _SearchAIWorkspaceState();
}

class _SearchAIWorkspaceState extends ConsumerState<SearchAIWorkspace> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  HealthReportAttachment? _stagedAttachment;

  final List<String> _quickPrompts = [
    'How do I improve my fasting glucose?',
    'What factors optimize my deep sleep architecture?',
    'Explain the role of Zone 2 training for longevity',
    'Review my recent bloodwork panel',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend([String? presetText]) async {
    final query = presetText ?? _textController.text.trim();
    if (query.isEmpty && _stagedAttachment == null) return;

    setState(() => _isSending = true);
    _textController.clear();
    final attachment = _stagedAttachment;
    setState(() => _stagedAttachment = null);

    try {
      await ref
          .read(aiWorkspaceProvider.notifier)
          .sendMessage(
            prompt: query.isEmpty
                ? 'Uploaded Health Document for Synthesis'
                : query,
            reportAttachment: attachment,
          );
      _scrollToBottom();
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _pickHealthReport() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        // Enforce sensitive document validation: < 15MB
        if (file.size > 15 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File exceeds sensitive upload limit of 15MB.'),
                backgroundColor: NETokens.error,
              ),
            );
          }
          return;
        }

        setState(() {
          _stagedAttachment = HealthReportAttachment(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            filename: file.name,
            fileType: file.extension ?? 'pdf',
            fileSize: file.size,
            uploadedAt: DateTime.now(),
          );
        });
      }
    } catch (_) {
      // Graceful fallback for non-native platforms
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversation = ref.watch(aiWorkspaceProvider);

    return Column(
      children: [
        // Quick Prompts Tray
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: NETokens.space16,
            vertical: NETokens.space8,
          ),
          child: Row(
            children: _quickPrompts.map((prompt) {
              return Padding(
                padding: const EdgeInsets.only(right: NETokens.space8),
                child: NEChip(
                  label: prompt,
                  icon: Icons.auto_awesome_rounded,
                  type: NEChipType.defaultType,
                  onTap: () => _handleSend(prompt),
                ),
              );
            }).toList(),
          ),
        ),

        const Divider(height: 1),

        // Conversation Messages
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(NETokens.space16),
            itemCount: conversation.messages.length,
            itemBuilder: (context, index) {
              final msg = conversation.messages[index];
              return _MessageBubble(message: msg);
            },
          ),
        ),

        // Staged Attachment Indicator
        if (_stagedAttachment != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: NETokens.space16,
              vertical: NETokens.space8,
            ),
            color: NETokens.surfaceElevated,
            child: Row(
              children: [
                const Icon(
                  Icons.attach_file_rounded,
                  size: 18,
                  color: NETokens.primary,
                ),
                const SizedBox(width: NETokens.space8),
                Expanded(
                  child: Text(
                    '${_stagedAttachment!.filename} (${(_stagedAttachment!.fileSize / 1024).toStringAsFixed(1)} KB)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: NETokens.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => setState(() => _stagedAttachment = null),
                ),
              ],
            ),
          ),

        // Input Bar
        Container(
          padding: const EdgeInsets.all(NETokens.space12),
          decoration: const BoxDecoration(
            color: NETokens.surface,
            border: Border(
              top: BorderSide(color: NETokens.borderSubtle, width: 1),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.upload_file_rounded),
                color: NETokens.textSecondary,
                tooltip: 'Upload Health Report (PDF/Image)',
                onPressed: _pickHealthReport,
              ),
              Expanded(
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(
                    color: NETokens.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask a health question or describe symptoms...',
                    hintStyle: const TextStyle(
                      color: NETokens.textMuted,
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: NETokens.surfaceElevated,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: NETokens.space16,
                      vertical: NETokens.space12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(NETokens.radiusMd),
                      borderSide: const BorderSide(
                        color: NETokens.borderSubtle,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(NETokens.radiusMd),
                      borderSide: const BorderSide(
                        color: NETokens.borderSubtle,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(NETokens.radiusMd),
                      borderSide: const BorderSide(color: NETokens.primary),
                    ),
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
              const SizedBox(width: NETokens.space8),
              NEButton(
                label: 'Send',
                icon: Icons.send_rounded,
                isLoading: _isSending,
                onPressed: _handleSend,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final AIMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: NETokens.space12, left: 40),
          padding: const EdgeInsets.symmetric(
            horizontal: NETokens.space16,
            vertical: NETokens.space12,
          ),
          decoration: BoxDecoration(
            color: NETokens.surfaceElevated,
            borderRadius: BorderRadius.circular(NETokens.radiusMd),
            border: Border.all(color: NETokens.borderDefault, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (message.attachedReport != null) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.picture_as_pdf_rounded,
                      size: 14,
                      color: NETokens.primary,
                    ),
                    const SizedBox(width: NETokens.space4),
                    Text(
                      message.attachedReport!.filename,
                      style: const TextStyle(
                        color: NETokens.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: NETokens.space6),
              ],
              Text(
                message.content,
                style: const TextStyle(
                  color: NETokens.textPrimary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // AI Message
    return Container(
      margin: const EdgeInsets.only(bottom: NETokens.space16, right: 24),
      padding: const EdgeInsets.all(NETokens.space16),
      decoration: BoxDecoration(
        color: NETokens.surface,
        borderRadius: BorderRadius.circular(NETokens.radiusLg),
        border: Border.all(color: NETokens.borderSubtle, width: 1),
        boxShadow: NETokens.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Evidence & Uncertainty Badges
          Row(
            children: [
              const Icon(
                Icons.psychology_rounded,
                size: 18,
                color: NETokens.primary,
              ),
              const SizedBox(width: NETokens.space8),
              const Text(
                'Nutrient Earth AI',
                style: TextStyle(
                  color: NETokens.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (message.evidenceQuality != null)
                NEChip(
                  label: message.evidenceQuality == EvidenceQuality.high
                      ? 'High Rigor'
                      : 'Moderate Rigor',
                  type: NEChipType.measured,
                ),
              if (message.uncertainty != null) ...[
                const SizedBox(width: NETokens.space4),
                NEChip(
                  label: message.uncertainty == UncertaintyLevel.low
                      ? 'Low Uncertainty'
                      : 'Uncertainty: Med',
                  type: NEChipType.outline,
                ),
              ],
            ],
          ),

          const SizedBox(height: NETokens.space12),

          // Content
          Text(
            message.content,
            style: const TextStyle(
              color: NETokens.textPrimary,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          // Practical Next Steps
          if (message.practicalNextSteps.isNotEmpty) ...[
            const SizedBox(height: NETokens.space16),
            const Text(
              'Practical Next Steps',
              style: TextStyle(
                color: NETokens.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: NETokens.space8),
            ...message.practicalNextSteps.map(
              (step) => Padding(
                padding: const EdgeInsets.only(bottom: NETokens.space6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 15,
                      color: NETokens.primary,
                    ),
                    const SizedBox(width: NETokens.space8),
                    Expanded(
                      child: Text(
                        step,
                        style: const TextStyle(
                          color: NETokens.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Missing Information Required
          if (message.missingInformationQuestions.isNotEmpty) ...[
            const SizedBox(height: NETokens.space12),
            Container(
              padding: const EdgeInsets.all(NETokens.space12),
              decoration: BoxDecoration(
                color: NETokens.warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(NETokens.radiusMd),
                border: Border.all(
                  color: NETokens.warning.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.help_outline_rounded,
                        size: 15,
                        color: NETokens.warning,
                      ),
                      SizedBox(width: NETokens.space6),
                      Text(
                        'Missing Information (Material Impact)',
                        style: TextStyle(
                          color: NETokens.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: NETokens.space6),
                  ...message.missingInformationQuestions.map(
                    (q) => Padding(
                      padding: const EdgeInsets.only(bottom: NETokens.space4),
                      child: Text(
                        '• $q',
                        style: const TextStyle(
                          color: NETokens.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Sources / Citations
          if (message.sources.isNotEmpty) ...[
            const SizedBox(height: NETokens.space16),
            const Text(
              'Verifiable Scientific Sources',
              style: TextStyle(
                color: NETokens.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: NETokens.space6),
            ...message.sources.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: NETokens.space6),
                child: Container(
                  padding: const EdgeInsets.all(NETokens.space8),
                  decoration: BoxDecoration(
                    color: NETokens.surfaceElevated,
                    borderRadius: BorderRadius.circular(NETokens.radiusSm),
                    border: Border.all(color: NETokens.borderSubtle, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.title,
                        style: const TextStyle(
                          color: NETokens.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: NETokens.space2),
                      Text(
                        '${s.authors} (${s.year}) — ${s.publication}',
                        style: const TextStyle(
                          color: NETokens.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      if (s.doiOrUrl != null)
                        Text(
                          'DOI/Ref: ${s.doiOrUrl} • ${s.studyType}',
                          style: const TextStyle(
                            color: NETokens.primary,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: NETokens.space12),
          const Text(
            'Disclaimer: Continuous intelligence synthesis is for informational guidance only and does not constitute clinical medical diagnosis.',
            style: TextStyle(
              color: NETokens.textMuted,
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

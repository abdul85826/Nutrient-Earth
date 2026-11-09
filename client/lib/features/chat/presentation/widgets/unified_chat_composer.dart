// ==============================================================================
// Nutrient Earth — Unified Chat Composer Widget
// Docked conversational input bar with multimodal trigger controls
// (Camera/Gallery/PDF/Barcode, Voice/Audio, Link/DOI, Send, and Stop Generation).
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';

class UnifiedChatComposer extends StatefulWidget {
  final ValueChanged<String> onSubmitted;
  final VoidCallback? onCameraTap;
  final VoidCallback? onVoiceTap;
  final VoidCallback? onUrlTap;
  final bool isGenerating;
  final VoidCallback? onStopTap;
  final String? initialText;

  const UnifiedChatComposer({
    super.key,
    required this.onSubmitted,
    this.onCameraTap,
    this.onVoiceTap,
    this.onUrlTap,
    this.isGenerating = false,
    this.onStopTap,
    this.initialText,
  });

  @override
  State<UnifiedChatComposer> createState() => _UnifiedChatComposerState();
}

class _UnifiedChatComposerState extends State<UnifiedChatComposer> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _hasText = _controller.text.trim().isNotEmpty;
    _controller.addListener(_updateTextStatus);
  }

  void _updateTextStatus() {
    final has = _controller.text.trim().isNotEmpty;
    if (has != _hasText) {
      setState(() => _hasText = has);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateTextStatus);
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSubmitted(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NETokens.background,
        border: const Border(
          top: BorderSide(color: NETokens.borderSubtle, width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Multimodal input triggers: Camera & Link
            if (widget.onCameraTap != null)
              Semantics(
                button: true,
                label: 'Add media, take photo, or scan document',
                child: IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, color: NETokens.darkEvergreen, size: 24),
                  tooltip: 'Attach photo, PDF, or barcode',
                  onPressed: widget.onCameraTap,
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                ),
              ),

            if (widget.onUrlTap != null)
              Semantics(
                button: true,
                label: 'Add link or PubMed URL',
                child: IconButton(
                  icon: const Icon(Icons.link_rounded, color: NETokens.textSecondary, size: 22),
                  tooltip: 'Verify scientific URL / PubMed ID',
                  onPressed: widget.onUrlTap,
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                ),
              ),

            // Input Text Field
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(NETokens.radiusFull),
                  border: Border.all(color: NETokens.borderInput, width: 1.2),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _handleSubmit(),
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: NETokens.primary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ask Nutrient Earth or plan goals...',
                          hintStyle: GoogleFonts.manrope(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: NETokens.textMuted,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                        ),
                      ),
                    ),

                    // Voice button inside field if text is empty
                    if (!_hasText && widget.onVoiceTap != null)
                      Semantics(
                        button: true,
                        label: 'Voice search or audio dictation',
                        child: IconButton(
                          icon: const Icon(Icons.mic_none_rounded, color: NETokens.emerald, size: 22),
                          tooltip: 'Speak inquiry',
                          onPressed: widget.onVoiceTap,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Send / Stop Generation Button
            if (widget.isGenerating)
              Semantics(
                button: true,
                label: 'Stop generating response',
                child: InkWell(
                  onTap: widget.onStopTap,
                  borderRadius: BorderRadius.circular(NETokens.radiusFull),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: NETokens.error.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: NETokens.error),
                    ),
                    child: const Center(
                      child: Icon(Icons.stop_rounded, color: NETokens.error, size: 22),
                    ),
                  ),
                ),
              )
            else
              Semantics(
                button: true,
                label: 'Send message to Nutrient Earth',
                child: InkWell(
                  onTap: _hasText ? _handleSubmit : null,
                  borderRadius: BorderRadius.circular(NETokens.radiusFull),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _hasText ? NETokens.darkEvergreen : NETokens.surfaceContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_upward_rounded,
                        color: _hasText ? Colors.white : NETokens.textMuted,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


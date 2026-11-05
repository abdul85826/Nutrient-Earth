import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';

class ResearchSearchBar extends StatefulWidget {
  final ValueChanged<String> onSubmit;
  final VoidCallback? onCameraTap;
  final VoidCallback? onVoiceTap;
  final VoidCallback? onUrlTap;
  final bool isLoading;

  const ResearchSearchBar({
    super.key,
    required this.onSubmit,
    this.onCameraTap,
    this.onVoiceTap,
    this.onUrlTap,
    this.isLoading = false,
  });

  @override
  State<ResearchSearchBar> createState() => _ResearchSearchBarState();
}

class _ResearchSearchBarState extends State<ResearchSearchBar> {
  final TextEditingController _controller = TextEditingController();

  void _handleSubmitted() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSubmit(text);
      _controller.clear();
    }
  }

  void _setSuggestion(String text) {
    _controller.text = text;
    widget.onSubmit(text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading
        Text(
          'Get answers. Know the evidence. Make better choices.',
          style: GoogleFonts.newsreader(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: NETokens.primary,
            height: 1.15,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Understand what works for your goals, what suits you, and why.',
          style: GoogleFonts.manrope(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: NETokens.textSecondary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),

        // Search Input Bar Container
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(NETokens.radiusFull),
            border: Border.all(color: NETokens.borderInput, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: NETokens.darkEvergreen.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
          child: Row(
            children: [
              // Camera button
              IconButton(
                icon: const Icon(Icons.camera_alt_outlined, color: NETokens.primary, size: 22),
                tooltip: 'Scan label or meal photo',
                onPressed: widget.onCameraTap,
              ),

              if (widget.onUrlTap != null)
                IconButton(
                  icon: const Icon(Icons.link_rounded, color: NETokens.textSecondary, size: 21),
                  tooltip: 'Submit research link or DOI',
                  onPressed: widget.onUrlTap,
                ),

              // Search TextField
              Expanded(
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _handleSubmitted(),
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: NETokens.primary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask about food, fitness, biology...',
                    hintStyle: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: NETokens.textMuted,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  ),
                ),
              ),

              // Voice microphone button
              IconButton(
                icon: const Icon(Icons.mic_none_rounded, color: NETokens.emerald, size: 22),
                tooltip: 'Voice research inquiry',
                onPressed: widget.onVoiceTap,
              ),

              // Submit upward arrow button
              Semantics(
                button: true,
                label: 'Submit research inquiry',
                child: InkWell(
                  onTap: widget.isLoading ? null : _handleSubmitted,
                  borderRadius: BorderRadius.circular(NETokens.radiusFull),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                    child: Center(
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: NETokens.deepGreen,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: widget.isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(
                                  Icons.arrow_upward_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Suggested Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildSuggestedChip(
                'Protein timing for recovery',
                onTap: () => _setSuggestion('What is the optimal protein threshold for muscle recovery?'),
              ),
              const SizedBox(width: 8),
              _buildSuggestedChip(
                'Is my diet right for my goal?',
                onTap: () => _setSuggestion('Is my diet right for my goal?'),
              ),
              const SizedBox(width: 8),
              _buildSuggestedChip(
                'How can I improve my routine?',
                onTap: () => _setSuggestion('How can I improve my routine?'),
              ),
              const SizedBox(width: 8),
              _buildSuggestedChip(
                'Magnesium for sleep quality',
                onTap: () => _setSuggestion('How does magnesium glycinate compare for sleep quality?'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedChip(String label, {required VoidCallback onTap}) {
    return Semantics(
      button: true,
      label: 'Suggested inquiry: $label',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(NETokens.radiusFull),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 7.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(NETokens.radiusFull),
            border: Border.all(color: NETokens.borderInput),
            boxShadow: [
              BoxShadow(
                color: NETokens.darkEvergreen.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_rounded, size: 14, color: NETokens.emerald),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: NETokens.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

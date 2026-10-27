import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';

class FeedbackBanner extends StatefulWidget {
  final ValueChanged<String> onSubmit;
  final bool isSubmitted;

  const FeedbackBanner({
    super.key,
    required this.onSubmit,
    this.isSubmitted = false,
  });

  @override
  State<FeedbackBanner> createState() => _FeedbackBannerState();
}

class _FeedbackBannerState extends State<FeedbackBanner> {
  final TextEditingController _controller = TextEditingController();

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSubmit(text);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NETokens.greetingGradientMid,
        borderRadius: BorderRadius.circular(NETokens.radiusMd),
        border: Border.all(color: NETokens.borderDefault),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080B2B26),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      child: Row(
        children: [
          // Left Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: NETokens.borderInput),
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: NETokens.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),

          // Message Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.isSubmitted ? 'Thank you for your feedback!' : 'Share your feedback',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: NETokens.primary,
                  ),
                ),
                Text(
                  widget.isSubmitted
                      ? 'Your note was recorded for the research team.'
                      : 'Tell us what helped or what to research next.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: NETokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Right Input Pill & Submit Button
          if (!widget.isSubmitted)
            Container(
              width: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(NETokens.radiusFull),
                border: Border.all(color: NETokens.borderInput),
              ),
              padding: const EdgeInsets.only(left: 10.0, right: 2.0, top: 2.0, bottom: 2.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _handleSubmit(),
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: NETokens.primary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type here...',
                        hintStyle: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: NETokens.textSecondary,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Submit feedback',
                    child: InkWell(
                      onTap: _handleSubmit,
                      borderRadius: BorderRadius.circular(NETokens.radiusFull),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: NETokens.deepGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

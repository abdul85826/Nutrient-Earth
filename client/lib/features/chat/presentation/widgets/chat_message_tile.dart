// ==============================================================================
// Nutrient Earth — Adaptive Chat Message Tile
// Renders user and assistant turns inline within the ChatGPT-style conversation stream.
// Adapts dynamically: Markdown prose, Atwater tables, PubMed citations, action checklists.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../../summary/presentation/doctor_summary_modal.dart';
import '../../domain/chat_message.dart';

class ChatMessageTile extends StatelessWidget {
  final ChatMessage message;
  final ValueChanged<String>? onActionItemToggled;
  final VoidCallback? onAcceptAllActions;
  final VoidCallback? onRetry;

  const ChatMessageTile({
    super.key,
    required this.message,
    this.onActionItemToggled,
    this.onAcceptAllActions,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return _buildUserBubble(context);
    } else {
      return _buildAssistantBlock(context);
    }
  }

  Widget _buildUserBubble(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 48),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: NETokens.darkEvergreen,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (message.attachments.isNotEmpty) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: message.attachments.map((att) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                att.isPdf
                                    ? Icons.picture_as_pdf_rounded
                                    : att.isAudio
                                        ? Icons.audiotrack_rounded
                                        : Icons.image_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                att.fileName,
                                style: GoogleFonts.manrope(fontSize: 11, color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    message.text,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssistantBlock(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botanical Assistant Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: NETokens.botanicalTeal.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: NETokens.botanicalTeal.withOpacity(0.3)),
            ),
            child: const Icon(
              Icons.eco_rounded,
              color: NETokens.darkEvergreen,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),

          // Message Content Body
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Capability Badge (if not ordinary text)
                if (message.capabilityType != ChatCapabilityType.ordinaryConversation) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: NETokens.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: NETokens.outlineVariant),
                        ),
                        child: Text(
                          message.capabilityType.displayName.toUpperCase(),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: NETokens.botanicalTeal,
                          ),
                        ),
                      ),
                      if (message.evidenceBadge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: NETokens.emerald.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            message.evidenceBadge!,
                            style: GoogleFonts.manrope(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: NETokens.emerald,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                ],

                // Error State Callout
                if (message.isError) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: NETokens.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: NETokens.error.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(message.text, style: GoogleFonts.manrope(fontSize: 13, color: NETokens.error)),
                        if (onRetry != null) ...[
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: onRetry,
                            icon: const Icon(Icons.refresh_rounded, size: 14),
                            label: const Text('Retry Inquiry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NETokens.error,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ] else ...[
                  // Streaming indicator or standard text body
                  Text(
                    message.text,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: NETokens.textPrimary,
                      height: 1.5,
                    ),
                  ),

                  // 1. Scientific Citations Block
                  if (message.citations.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: NETokens.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: NETokens.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.menu_book_rounded, size: 14, color: NETokens.darkEvergreen),
                              const SizedBox(width: 6),
                              Text(
                                'PEER-REVIEWED EVIDENCE & CITATIONS (${message.citations.length})',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: NETokens.darkEvergreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...message.citations.map((c) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (c.pmid != null) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: NETokens.botanicalTeal.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'PMID ${c.pmid}',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          color: NETokens.darkEvergreen,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Expanded(
                                    child: Text(
                                      '${c.title} (${c.authorsOrJournal}, ${c.year})',
                                      style: GoogleFonts.manrope(
                                        fontSize: 11.5,
                                        color: NETokens.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],

                  // 2. Goal Action Protocol Block (Interactive Checklists)
                  if (message.actionItems.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: NETokens.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: NETokens.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ACTIONABLE MILESTONES',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: NETokens.darkEvergreen,
                                ),
                              ),
                              if (onAcceptAllActions != null)
                                InkWell(
                                  onTap: onAcceptAllActions,
                                  child: Text(
                                    '+ Add to Daily Plan',
                                    style: GoogleFonts.manrope(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: NETokens.emerald,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const Divider(height: 16),
                          ...message.actionItems.map((item) {
                            return InkWell(
                              onTap: onActionItemToggled != null ? () => onActionItemToggled!(item.id) : null,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      item.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                      size: 18,
                                      color: item.isCompleted ? NETokens.emerald : NETokens.outline,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            style: GoogleFonts.manrope(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                              decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                                              color: item.isCompleted ? NETokens.textSecondary : NETokens.textPrimary,
                                            ),
                                          ),
                                          if (item.subtitle.isNotEmpty)
                                            Text(
                                              item.subtitle,
                                              style: GoogleFonts.manrope(
                                                fontSize: 11,
                                                color: NETokens.textSecondary,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],

                  // 3. Doctor Consultation Summary Card
                  if (message.doctorSummary != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: NETokens.darkEvergreen.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: NETokens.darkEvergreen.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.medical_services_rounded, color: NETokens.darkEvergreen, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'CLINICAL BRIEFING READY',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: NETokens.darkEvergreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Contains 9 domains: symptoms timeline, active supplements, confirmed conditions, and patient questions.',
                            style: GoogleFonts.manrope(fontSize: 12, color: NETokens.textSecondary),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () => DoctorSummaryModal.show(context, message.doctorSummary!),
                            icon: const Icon(Icons.visibility_rounded, size: 14),
                            label: const Text('Review & Export Dossier'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NETokens.darkEvergreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Copy and Disclaimer Row
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: message.text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied response to clipboard'), duration: Duration(seconds: 1)),
                          );
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.copy_rounded, size: 12, color: NETokens.textSecondary),
                            const SizedBox(width: 4),
                            Text('Copy', style: GoogleFonts.manrope(fontSize: 10.5, color: NETokens.textSecondary)),
                          ],
                        ),
                      ),
                      if (message.disclaimer != null) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            message.disclaimer!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(fontSize: 10, fontStyle: FontStyle.italic, color: NETokens.textSecondary),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}


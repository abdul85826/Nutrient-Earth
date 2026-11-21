import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../../../core/services/learn_repository.dart';

class LearnDetailModal extends StatelessWidget {
  final LearnItem item;

  const LearnDetailModal({
    super.key,
    required this.item,
  });

  static Future<void> show(BuildContext context, LearnItem item) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LearnDetailModal(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = item.type == LearnContentType.video;

    return Container(
      decoration: const BoxDecoration(
        color: NETokens.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 12.0),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
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
            const SizedBox(height: 16),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Media Header Banner
                    Stack(
                      children: [
                        Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: const Color(0xFFEAE5D8),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset(
                            item.thumbnailAsset,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFFEAE5D8),
                              child: const Icon(Icons.menu_book_rounded, size: 40, color: NETokens.primary),
                            ),
                          ),
                        ),
                        if (isVideo)
                          Positioned.fill(
                            child: Center(
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF051F20).withValues(alpha: 0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Badges
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isVideo ? NETokens.emerald : const Color(0xFFC85A32),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isVideo ? 'VIDEO • ${item.duration}' : 'ARTICLE',
                            style: GoogleFonts.manrope(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: NETokens.borderDefault),
                          ),
                          child: Text(
                            item.categoryTag,
                            style: GoogleFonts.manrope(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: isVideo ? NETokens.emerald : const Color(0xFFC85A32),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          item.publishedDate,
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: NETokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Title
                    Text(
                      item.title,
                      style: GoogleFonts.newsreader(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: NETokens.primary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Source Attribution
                    Row(
                      children: [
                        const Icon(Icons.verified_outlined, size: 14, color: NETokens.emerald),
                        const SizedBox(width: 6),
                        Text(
                          item.sourceName,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: NETokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: NETokens.borderDefault),
                      ),
                      child: Text(
                        item.description,
                        style: GoogleFonts.manrope(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: NETokens.primary,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Key Takeaways
                    if (item.keyTakeaways.isNotEmpty) ...[
                      Text(
                        'EVIDENCE-BASED KEY TAKEAWAYS',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: NETokens.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final takeaway in item.keyTakeaways)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 4.0),
                                child: Icon(Icons.check_circle_outline_rounded,
                                    size: 15, color: NETokens.emerald),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  takeaway,
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
                        ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

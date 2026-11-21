import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../../../core/services/learn_repository.dart';

class LearnTodaySection extends StatelessWidget {
  final List<LearnItem> items;
  final ValueChanged<LearnItem> onItemTap;
  final VoidCallback onSeeAllTap;

  const LearnTodaySection({
    super.key,
    required this.items,
    required this.onItemTap,
    required this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayItems = items.take(2).toList();

    return Container(
      decoration: BoxDecoration(
        color: NETokens.surface,
        borderRadius: BorderRadius.circular(NETokens.radiusXl),
        border: Border.all(color: NETokens.borderDefault),
        boxShadow: NETokens.cardShadow,
      ),
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Learn for today',
                      style: GoogleFonts.newsreader(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: NETokens.primary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Three fresh picks to help you understand your health better.',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: NETokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onSeeAllTap,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'See all',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: NETokens.primary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: NETokens.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Two-Column Grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < displayItems.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(
                  child: _buildMediaCard(displayItems[i]),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaCard(LearnItem item) {
    final isVideo = item.type == LearnContentType.video;
    final tagColor = isVideo ? NETokens.emerald : const Color(0xFFC85A32);

    return InkWell(
      onTap: () => onItemTap(item),
      borderRadius: BorderRadius.circular(NETokens.radiusLg),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(NETokens.radiusLg),
          border: Border.all(color: NETokens.borderDefault),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B2B26).withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail container
            Stack(
              children: [
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFEAE5D8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    item.thumbnailAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFEAE5D8),
                      child: Icon(
                        isVideo ? Icons.play_circle_outline_rounded : Icons.article_outlined,
                        size: 36,
                        color: NETokens.textMuted,
                      ),
                    ),
                  ),
                ),

                // Center Play Button for Video
                if (isVideo)
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFF051F20).withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),

                // Video duration badge
                if (isVideo && item.duration != null)
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF051F20).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.duration!,
                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                // Type Badge (VIDEO or ARTICLE)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: isVideo ? NETokens.emerald : const Color(0xFFC85A32),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isVideo ? 'VIDEO' : 'ARTICLE',
                      style: GoogleFonts.manrope(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Category Tag
            Text(
              item.categoryTag,
              style: GoogleFonts.manrope(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: tagColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 3),

            // Title
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.newsreader(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: NETokens.primary,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),

            // Footer note
            Container(
              padding: const EdgeInsets.only(top: 6.0),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF1EBE0))),
              ),
              width: double.infinity,
              child: Text(
                item.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: NETokens.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

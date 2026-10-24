import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/design_system.dart';
import '../data/learn_discover_repository.dart';
import '../domain/learn_discover_models.dart';

class LearnSection extends ConsumerWidget {
  const LearnSection({super.key});

  void _showArticleModal(BuildContext context, ArticleItem article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: NETokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(NETokens.radiusLg),
        ),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(NETokens.space20),
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
            const SizedBox(height: NETokens.space16),
            Row(
              children: [
                NEChip(label: article.category, type: NEChipType.outline),
                const SizedBox(width: NETokens.space8),
                NEChip(
                  label: '${article.evidenceScore}% Evidence Rigor',
                  type: NEChipType.measured,
                ),
                const Spacer(),
                Text(
                  '${article.readingTimeMinutes} min read',
                  style: const TextStyle(
                    fontSize: 12,
                    color: NETokens.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: NETokens.space12),
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: NETokens.textPrimary,
              ),
            ),
            const SizedBox(height: NETokens.space12),
            Text(
              article.content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: NETokens.textSecondary,
              ),
            ),
            const SizedBox(height: NETokens.space20),
            const Text(
              'Key Clinical Takeaways',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: NETokens.primary,
              ),
            ),
            const SizedBox(height: NETokens.space8),
            ...article.keyTakeaways.map(
              (point) => Padding(
                padding: const EdgeInsets.only(bottom: NETokens.space8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: NETokens.primary,
                    ),
                    const SizedBox(width: NETokens.space8),
                    Expanded(
                      child: Text(
                        point,
                        style: const TextStyle(
                          fontSize: 13,
                          color: NETokens.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: NETokens.space16),
            Container(
              padding: const EdgeInsets.all(NETokens.space12),
              decoration: BoxDecoration(
                color: NETokens.surfaceElevated,
                borderRadius: BorderRadius.circular(NETokens.radiusMd),
                border: Border.all(color: NETokens.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Primary Literature Citation:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: NETokens.textMuted,
                    ),
                  ),
                  const SizedBox(height: NETokens.space4),
                  Text(
                    article.primarySourceCitation,
                    style: const TextStyle(
                      fontSize: 11,
                      color: NETokens.primaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsync = ref.watch(articlesProvider);

    return articlesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading articles: $err')),
      data: (articles) => ListView.builder(
        padding: const EdgeInsets.all(NETokens.space16),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: NETokens.space12),
            child: NECard(
              onTap: () => _showArticleModal(context, article),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      NEChip(label: article.category, type: NEChipType.outline),
                      const SizedBox(width: NETokens.space8),
                      NEChip(
                        label: '${article.evidenceScore}% Rigor',
                        type: NEChipType.measured,
                      ),
                      const Spacer(),
                      Text(
                        '${article.readingTimeMinutes} min read',
                        style: const TextStyle(
                          fontSize: 11,
                          color: NETokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: NETokens.space12),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: NETokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: NETokens.space8),
                  Text(
                    article.summary,
                    style: const TextStyle(
                      fontSize: 13,
                      color: NETokens.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

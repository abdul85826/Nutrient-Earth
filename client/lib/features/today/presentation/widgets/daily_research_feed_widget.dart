// ==============================================================================
// Nutrient Earth — Daily Scientific Intelligence Feed Widget
// Renders the 5-article goal-matched daily edition with:
// - English <-> Tamil bilingual toggle
// - Auditable 60-second read dwell time progress & verification state machine
// - Tiered scientific evidence badges & citation provenance
// - Exact Nutrient Earth design: #FAF8F5 canvas, #EAF0EC cards, #00251D text
// ==============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/research/daily_research_models.dart';
import '../../../../core/services/research/daily_research_service.dart';

class DailyResearchFeedWidget extends ConsumerStatefulWidget {
  final String userId;

  const DailyResearchFeedWidget({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<DailyResearchFeedWidget> createState() => _DailyResearchFeedWidgetState();
}

class _DailyResearchFeedWidgetState extends ConsumerState<DailyResearchFeedWidget> {
  bool _isTamil = false;
  String? _expandedArticleId;
  Timer? _dwellTimer;

  @override
  void dispose() {
    _dwellTimer?.cancel();
    super.dispose();
  }

  void _onArticleExpanded(String articleId) {
    setState(() {
      if (_expandedArticleId == articleId) {
        _expandedArticleId = null;
        _dwellTimer?.cancel();
      } else {
        _expandedArticleId = articleId;
        _startDwellTracking(articleId);
      }
    });
  }

  void _startDwellTracking(String articleId) {
    _dwellTimer?.cancel();
    // Pulse a 5-second dwell heartbeat to record verifiable engagement
    _dwellTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!mounted || _expandedArticleId != articleId) {
        timer.cancel();
        return;
      }
      final service = ref.read(dailyResearchServiceProvider);
      await service.recordReadingHeartbeat(
        userId: widget.userId,
        articleId: articleId,
        dwellDeltaSeconds: 5,
      );
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final editionAsync = ref.watch(todayResearchEditionProvider(widget.userId));

    return editionAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(color: Color(0xFF00251D)),
        ),
      ),
      error: (err, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFDE8E8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Error loading daily scientific intelligence: $err',
          style: const TextStyle(color: Color(0xFF9B1C1C), fontSize: 13),
        ),
      ),
      data: (edition) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with bilingual toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isTamil ? 'அறிவியல் நுண்ணறிவு' : 'Daily Scientific Intelligence',
                      style: const TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00251D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isTamil ? 'உங்கள் இலக்குகளுக்கான 5 ஆய்வுக் கட்டுரைகள்' : '5 goal-matched peer-reviewed insights',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4A6B5D),
                      ),
                    ),
                  ],
                ),
                // Language Switcher Pill
                InkWell(
                  onTap: () => setState(() => _isTamil = !_isTamil),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF0EC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFCCD7D0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isTamil ? 'தமிழ்' : 'English',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00251D),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.translate, size: 14, color: Color(0xFF00251D)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Articles List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: edition.articles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final article = edition.articles[index];
                final isExpanded = _expandedArticleId == article.id;

                return _ArticleCard(
                  article: article,
                  userId: widget.userId,
                  isTamil: _isTamil,
                  isExpanded: isExpanded,
                  onToggleExpand: () => _onArticleExpanded(article.id),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _ArticleCard extends ConsumerWidget {
  final DailyResearchArticle article;
  final String userId;
  final bool isTamil;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const _ArticleCard({
    required this.article,
    required this.userId,
    required this.isTamil,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(articleReadingSessionProvider((userId: userId, articleId: article.id)));

    return sessionAsync.maybeWhen(
      data: (session) => _buildCardContent(context, session),
      orElse: () => _buildCardContent(
        context,
        ArticleReadingSession(
          id: '',
          userId: userId,
          articleId: article.id,
          sessionStart: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, ArticleReadingSession session) {
    final title = isTamil && article.titleTa != null ? article.titleTa! : article.title;
    final summary = isTamil && article.summaryTa != null ? article.summaryTa! : article.summaryEn;
    final takeaway = isTamil && article.scientificTakeawayTa != null ? article.scientificTakeawayTa! : article.scientificTakeaway;
    final recommendation = isTamil && article.actionableRecommendationTa != null
        ? article.actionableRecommendationTa!
        : article.actionableRecommendation;

    final isVerified = session.isVerifiedRead;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0EC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVerified ? const Color(0xFF2E7D32) : const Color(0xFFCCD7D0),
          width: isVerified ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header clickable area
          InkWell(
            onTap: onToggleExpand,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order index badge
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isVerified ? const Color(0xFF2E7D32) : const Color(0xFF00251D),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${article.orderIndex}',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title and badges
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4E2D8),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                article.evidenceStrength.label,
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF00251D)),
                              ),
                            ),
                            const Spacer(),
                            if (isVerified)
                              const Row(
                                children: [
                                  Icon(Icons.check_circle, size: 14, color: Color(0xFF2E7D32)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Verified Read',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                                  ),
                                ],
                              )
                            else if (session.dwellTimeSeconds > 0)
                              Text(
                                '${session.remainingSecondsToVerify}s to verify',
                                style: const TextStyle(fontSize: 10, color: Color(0xFF7A6010), fontWeight: FontWeight.w600),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00251D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF00251D),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content with 60-Second Reading Progress
          if (isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFCCD7D0)),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Verification Progress Bar
                  if (!isVerified) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Reading Engagement Verification:',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF4A6B5D)),
                        ),
                        Text(
                          '${session.dwellTimeSeconds}s / 60s',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00251D)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (session.dwellTimeSeconds / 60.0).clamp(0.0, 1.0),
                        backgroundColor: const Color(0xFFCCD7D0),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                        minHeight: 5,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Plain Language Summary
                  Text(
                    summary,
                    style: const TextStyle(fontSize: 13, height: 1.45, color: Color(0xFF1E2923)),
                  ),
                  const SizedBox(height: 12),

                  // Scientific Takeaway Box
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF8F5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFCCD7D0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.biotech, size: 14, color: Color(0xFF00251D)),
                            const SizedBox(width: 6),
                            Text(
                              isTamil ? 'அறிவியல் முடிவு' : 'Scientific Mechanism & Evidence',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00251D)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          takeaway,
                          style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF2E4035)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Actionable Recommendation Box
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4E2D8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFF00251D)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isTamil ? 'செயல்படுத்த வேண்டிய முறை' : 'Actionable Protocol',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00251D)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                recommendation,
                                style: const TextStyle(fontSize: 12, height: 1.35, color: Color(0xFF00251D)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Citation Reference
                  Text(
                    article.citationReference,
                    style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Color(0xFF6B7E73)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

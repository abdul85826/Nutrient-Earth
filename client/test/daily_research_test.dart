// ==============================================================================
// Nutrient Earth — Daily Scientific Intelligence Tests
// Verifies:
// 1. Curated 5-article goal-matched daily edition generation
// 2. Bilingual content (English & Tamil)
// 3. 60-second read dwell time engagement state machine
// 4. Verification gates and progress tracking
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/domain/research/daily_research_models.dart';
import 'package:nutrient_earth_client/core/services/research/daily_research_service.dart';

void main() {
  group('Daily Scientific Intelligence & Engagement Tests', () {
    late SupabaseDailyResearchService researchService;
    const testUserId = 'usr_test_research_feed';

    setUp(() {
      researchService = SupabaseDailyResearchService(supabase: null);
    });

    test('Generates 5 curated goal-matched articles with bilingual translations', () async {
      final edition = await researchService.getTodayEdition(userId: testUserId);

      expect(edition.userId, equals(testUserId));
      expect(edition.articles.length, equals(5));

      for (int i = 0; i < 5; i++) {
        final article = edition.articles[i];
        expect(article.orderIndex, equals(i + 1));
        expect(article.title, isNotEmpty);
        expect(article.summaryEn, isNotEmpty);
        expect(article.scientificTakeaway, isNotEmpty);
        expect(article.actionableRecommendation, isNotEmpty);

        // Tamil bilingual translations must be present
        expect(article.titleTa, isNotNull);
        expect(article.summaryTa, isNotNull);
        expect(article.scientificTakeawayTa, isNotNull);
        expect(article.actionableRecommendationTa, isNotNull);

        // Rigorous citations
        expect(article.citationReference, isNotEmpty);
        expect(article.publicationDoi, isNotNull);
      }
    });

    test('60-second read engagement state machine transitions correctly', () async {
      final edition = await researchService.getTodayEdition(userId: testUserId);
      final firstArticle = edition.articles.first;

      // 1. Initially unread
      final initialSession = await researchService.getArticleReadingSession(
        userId: testUserId,
        articleId: firstArticle.id,
      );
      expect(initialSession.engagementState, equals(ReadEngagementState.unread));
      expect(initialSession.isVerifiedRead, isFalse);
      expect(initialSession.dwellTimeSeconds, equals(0));
      expect(initialSession.remainingSecondsToVerify, equals(60));

      // 2. Pulse 30s dwell -> inProgress
      final midSession = await researchService.recordReadingHeartbeat(
        userId: testUserId,
        articleId: firstArticle.id,
        dwellDeltaSeconds: 30,
      );
      expect(midSession.dwellTimeSeconds, equals(30));
      expect(midSession.engagementState, equals(ReadEngagementState.inProgress));
      expect(midSession.isVerifiedRead, isFalse);
      expect(midSession.remainingSecondsToVerify, equals(30));

      // 3. Pulse additional 30s (total 60s) -> verifiedRead
      final verifiedSession = await researchService.recordReadingHeartbeat(
        userId: testUserId,
        articleId: firstArticle.id,
        dwellDeltaSeconds: 30,
      );
      expect(verifiedSession.dwellTimeSeconds, equals(60));
      expect(verifiedSession.isVerifiedRead, isTrue);
      expect(verifiedSession.verifiedAt, isNotNull);
      expect(verifiedSession.engagementState, equals(ReadEngagementState.verifiedRead));
      expect(verifiedSession.remainingSecondsToVerify, equals(0));
    });

    test('Edition progress correctly computes completion percentage', () async {
      final edition = await researchService.getTodayEdition(userId: testUserId);

      // Initially 0%
      var progress = await researchService.getEditionProgress(
        userId: testUserId,
        editionId: edition.id,
      );
      expect(progress['totalArticles'], equals(5));
      expect(progress['verifiedCount'], equals(0));
      expect(progress['isComplete'], isFalse);

      // Verify 2 articles by providing 60 seconds of dwell time
      await researchService.recordReadingHeartbeat(
        userId: testUserId,
        articleId: edition.articles[0].id,
        dwellDeltaSeconds: 60,
      );
      await researchService.recordReadingHeartbeat(
        userId: testUserId,
        articleId: edition.articles[1].id,
        dwellDeltaSeconds: 60,
      );

      progress = await researchService.getEditionProgress(
        userId: testUserId,
        editionId: edition.id,
      );
      expect(progress['verifiedCount'], equals(2));
      expect(progress['completionPercentage'], equals(40.0));
      expect(progress['isComplete'], isFalse);
    });
  });
}

// ==============================================================================
// Nutrient Earth — Conversational Intelligence & Lifecycle Verification Tests
// Gate C Phase 1 & Phase 2 verification:
// 1. Social Greetings route to pure conversation (zero fake citations, zero evidence badge)
// 2. Botanical/Nutrition knowledge (Isabgol) returns verified digestive guidance
// 3. Ambiguous entity clarification ("apple") returns selectable options
// 4. Clarification selection resolves to fruit nutrition or wearable sync
// 5. Deterministic nutrition calculation (2 eggs) returns Atwater factor breakdown
// 6. Contextual follow-ups ("biological mechanism", "any contraindications?")
// 7. Cosmetic product audit returns formulation limits without medical regrowth claims
// 8. Stale answer persistence elimination (clearActiveAnswer)
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/domain/answer_contract/universal_intelligence_answer.dart';
import 'package:nutrient_earth_client/core/domain/input_gateway/input_classification_gateway.dart';
import 'package:nutrient_earth_client/core/domain/input_gateway/universal_input_descriptor.dart';
import 'package:nutrient_earth_client/core/domain/orchestration/chatbot_intent_router.dart';
import 'package:nutrient_earth_client/core/domain/personalization/goal_alignment_evaluator.dart';
import 'package:nutrient_earth_client/core/domain/personalization/user_profile_context.dart';
import 'package:nutrient_earth_client/core/services/research_pipeline_service.dart';
import 'package:nutrient_earth_client/features/today/state/today_state.dart';

void main() {
  group('Phase 1 — Conversational Intelligence & Intent Routing', () {
    test('Greeting "hii" routes to Conversation without fake papers or evidence badges', () {
      final intent = ChatbotIntentRouter.classifyIntent('hii');
      expect(intent, equals(ChatbotIntent.greetingSocial));

      final answer = ChatbotIntentRouter.handleNonResearchIntent(
        intent: intent,
        rawQuery: 'hii',
        userProfile: UserProfileContext.fromJson(const {'userId': 'user-1', 'displayName': 'Jordan'}),
      );

      expect(answer, isNotNull);
      expect(answer!.responseType, equals(UniversalResponseType.conversation));
      expect(answer.heroAnswer, contains('Jordan'));
      expect(answer.evidence.hasVerifiedSources, isFalse);
      expect(answer.evidence.citations, isEmpty);
      expect(answer.evidence.watermarkLabel, equals('Conversation'));
    });

    test('"What is isabgol" routes to Nutrition Knowledge with verified botanical profile', () {
      final intent = ChatbotIntentRouter.classifyIntent('what is isabgol');
      expect(intent, equals(ChatbotIntent.nutritionKnowledge));

      final answer = ChatbotIntentRouter.handleNonResearchIntent(
        intent: intent,
        rawQuery: 'what is isabgol',
      );

      expect(answer, isNotNull);
      expect(answer!.responseType, equals(UniversalResponseType.nutritionKnowledge));
      expect(answer.heroAnswer, contains('Psyllium Husk'));
      expect(answer.detailedExplanation, contains('Plantago ovata'));
      expect(answer.detailedExplanation, contains('gel-like material'));
      expect(answer.recommendation, contains('250 mL of water'));
      expect(answer.evidence.hasVerifiedSources, isTrue);
      expect(answer.evidence.citations.isNotEmpty, isTrue);
      expect(answer.evidence.citations.first.pmid, equals('28252255'));
    });

    test('Ambiguous "apple" returns Clarification with actionable options', () {
      final intent = ChatbotIntentRouter.classifyIntent('apple');
      expect(intent, equals(ChatbotIntent.clarification));

      final answer = ChatbotIntentRouter.handleNonResearchIntent(
        intent: intent,
        rawQuery: 'apple',
      );

      expect(answer, isNotNull);
      expect(answer!.responseType, equals(UniversalResponseType.clarification));
      expect(answer.heroAnswer, contains('Apple the fruit or Apple the technology company'));
      expect(answer.clarificationOptions, contains('Apple (Fresh Fruit & Nutrition)'));
      expect(answer.clarificationOptions, contains('Apple Inc. (HealthKit & Watch Sync)'));
    });

    test('Selecting "Apple (Fresh Fruit & Nutrition)" yields FoodData Central nutrition breakdown', () {
      final query = 'Apple (Fresh Fruit & Nutrition)';
      final intent = ChatbotIntentRouter.classifyIntent(query);
      expect(intent, equals(ChatbotIntent.nutritionKnowledge));

      final answer = ChatbotIntentRouter.handleNonResearchIntent(
        intent: intent,
        rawQuery: query,
      );

      expect(answer, isNotNull);
      expect(answer!.responseType, equals(UniversalResponseType.nutritionKnowledge));
      expect(answer.heroAnswer, contains('Malus domestica'));
      expect(answer.detailedExplanation, contains('~52 kcal'));
      expect(answer.detailedExplanation, contains('pectin'));
      expect(answer.detailedExplanation, contains('Quercetin'));
      expect(answer.evidence.citations.any((c) => c.title.contains('USDA FoodData Central')), isTrue);
    });

    test('Selecting "Apple Inc. (HealthKit & Watch Sync)" yields Wearable Integration guide', () {
      final query = 'Apple Inc. (HealthKit & Watch Sync)';
      final intent = ChatbotIntentRouter.classifyIntent(query);
      expect(intent, equals(ChatbotIntent.generalHelp));

      final answer = ChatbotIntentRouter.handleNonResearchIntent(
        intent: intent,
        rawQuery: query,
      );

      expect(answer, isNotNull);
      expect(answer!.responseType, equals(UniversalResponseType.conversation));
      expect(answer.heroAnswer, contains('HealthKit'));
      expect(answer.detailedExplanation, contains('biometric data is encrypted'));
    });

    test('"Calories in 2 eggs" routes to Nutrition Calculation with Atwater breakdown', () {
      final intent = ChatbotIntentRouter.classifyIntent('how many calories in 2 eggs');
      expect(intent, equals(ChatbotIntent.nutritionCalculation));

      final answer = ChatbotIntentRouter.handleNonResearchIntent(
        intent: intent,
        rawQuery: 'how many calories in 2 eggs',
      );

      expect(answer, isNotNull);
      expect(answer!.responseType, equals(UniversalResponseType.nutritionCalculation));
      expect(answer.heroAnswer, contains('143 Calories'));
      expect(answer.detailedExplanation, contains('12.6g'));
      expect(answer.detailedExplanation, contains('Choline'));
      expect(answer.detailedExplanation, contains('Atwater Factors'));
    });

    test('Follow-up "biological mechanism" with activeContextTopic="isabgol" resolves mechanism', () {
      final intent = ChatbotIntentRouter.classifyIntent(
        'biological mechanism',
        activeContextTopic: 'isabgol',
      );
      expect(intent, equals(ChatbotIntent.followUpContext));

      final answer = ChatbotIntentRouter.handleNonResearchIntent(
        intent: intent,
        rawQuery: 'biological mechanism',
        activeContextTopic: 'isabgol',
      );

      expect(answer, isNotNull);
      expect(answer!.responseType, equals(UniversalResponseType.nutritionKnowledge));
      expect(answer.heroAnswer, contains('Biological Mechanism'));
      expect(answer.detailedExplanation, contains('arabinoxylan'));
      expect(answer.detailedExplanation, contains('short-chain fatty acids'));
    });

    test('Follow-up "any contraindications?" with activeContextTopic="isabgol" returns safety triage', () {
      final intent = ChatbotIntentRouter.classifyIntent(
        'any contraindications?',
        activeContextTopic: 'isabgol',
      );
      expect(intent, equals(ChatbotIntent.followUpContext));

      final answer = ChatbotIntentRouter.handleNonResearchIntent(
        intent: intent,
        rawQuery: 'any contraindications?',
        activeContextTopic: 'isabgol',
      );

      expect(answer, isNotNull);
      expect(answer!.responseType, equals(UniversalResponseType.safetyResponse));
      expect(answer.heroAnswer, contains('Contraindications'));
      expect(answer.detailedExplanation, contains('Dysphagia'));
      expect(answer.detailedExplanation, contains('2-hour window'));
    });

    test('Cosmetic product inquiry audits formulation and rejects medical regrowth claims', () {
      final intent = ChatbotIntentRouter.classifyIntent('Himalaya hair fall shampoo review');
      expect(intent, equals(ChatbotIntent.productAnalysis));

      final answer = ChatbotIntentRouter.handleNonResearchIntent(
        intent: intent,
        rawQuery: 'Himalaya hair fall shampoo review',
      );

      expect(answer, isNotNull);
      expect(answer!.responseType, equals(UniversalResponseType.productAnalysis));
      expect(answer.heroAnswer, contains('Cosmetic Product Analysis'));
      expect(answer.detailedExplanation, contains('cannot reverse hormonal (androgenetic) alopecia'));
      expect(answer.detailedExplanation, contains('24-hour patch test'));
    });
  });

  group('Phase 2 — Application Lifecycle & Stale Answer Elimination', () {
    test('clearActiveAnswer explicitly purges activeAnswer and universalAnswer', () {
      final notifier = TodayNotifier();

      // Simulate state with an active answer
      final dummyAnswer = UniversalIntelligenceAnswer(
        referenceId: 'TEST-1',
        detectedInputType: UserInputType.text,
        responseType: UniversalResponseType.conversation,
        query: 'test',
        heroAnswer: 'Old Hero',
        recommendation: 'Old Rec',
        detailedExplanation: 'Old Exp',
        goalMatch: const GoalMatchIndicator(
          matchPercentage: null,
          status: GoalAlignmentStatus.insufficientInformation,
          matchLabel: 'Not enough information to assess',
          rationale: 'Test',
        ),
        evidence: const EvidenceProvenanceContainer(
          hasVerifiedSources: false,
          classification: EvidenceClassification.notVerified,
          watermarkLabel: 'Test',
          citations: [],
        ),
        uncertaintyDisclaimer: 'Test disclaimer',
      );

      notifier.state = notifier.state.copyWith(
        activeAnswer: ResearchAnswer.fromUniversalAnswer(dummyAnswer),
        universalAnswer: dummyAnswer,
      );

      expect(notifier.state.activeAnswer, isNotNull);
      expect(notifier.state.universalAnswer, isNotNull);

      // Call clearActiveAnswer()
      notifier.clearActiveAnswer();

      // Must be null!
      expect(notifier.state.activeAnswer, isNull);
      expect(notifier.state.universalAnswer, isNull);
    });

    test('submitUniversalInquiry updates activeContextTopic and retains topic for follow-up', () async {
      final notifier = TodayNotifier();

      final descriptor = InputClassificationGateway.classifyRawInput(
        rawInput: 'Tell me what is isabgol',
        sourceType: InputSourceType.userText,
      );

      await notifier.submitUniversalInquiry(descriptor);

      expect(notifier.state.activeContextTopic, equals('isabgol'));
      expect(notifier.state.universalAnswer, isNotNull);
      expect(notifier.state.universalAnswer!.responseType, equals(UniversalResponseType.nutritionKnowledge));

      // Follow-up query
      final followUpDescriptor = InputClassificationGateway.classifyRawInput(
        rawInput: 'biological mechanism',
        sourceType: InputSourceType.userText,
      );

      await notifier.submitUniversalInquiry(followUpDescriptor);
      expect(notifier.state.universalAnswer!.heroAnswer, contains('Biological Mechanism of Psyllium'));
    });
  });
}

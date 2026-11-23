import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/domain/answer_contract/response_content_block.dart';
import 'package:nutrient_earth_client/core/domain/answer_contract/universal_intelligence_answer.dart';
import 'package:nutrient_earth_client/core/domain/input_gateway/universal_input_descriptor.dart';
import 'package:nutrient_earth_client/core/domain/orchestration/adaptive_execution_planner.dart';
import 'package:nutrient_earth_client/core/domain/orchestration/universal_intelligence_router.dart';
import 'package:nutrient_earth_client/core/domain/personalization/user_profile_context.dart';
import 'package:nutrient_earth_client/core/services/search/universal_intelligence_search_engine.dart';

void main() {
  group('Universal Intent Router — Canonical Intents & Conditional RAG', () {
    test('1. Greeting intent classification with zero RAG', () {
      final greetingQueries = ['hii', 'hi', 'Hello!', 'hey there', 'good morning', 'yo'];
      for (final q in greetingQueries) {
        final routing = UniversalIntelligenceRouter.classify(q);
        expect(routing.intent, equals(UniversalIntent.greeting), reason: 'Failed for query: $q');
        expect(routing.ragDecision, equals(RagRetrievalDecision.none));
        expect(routing.intent.isConversational, isTrue);
        expect(routing.requiresEvidenceCitations, isFalse);
      }
    });

    test('2. Casual conversation classification with zero RAG', () {
      final casualQueries = ['how are you', 'thank you', 'who are you', 'what can you do', 'nice to meet you'];
      for (final q in casualQueries) {
        final routing = UniversalIntelligenceRouter.classify(q);
        expect(routing.intent, equals(UniversalIntent.casualConversation), reason: 'Failed for query: $q');
        expect(routing.ragDecision, equals(RagRetrievalDecision.none));
        expect(routing.intent.isConversational, isTrue);
      }
    });

    test('3. Code generation intent classification', () {
      final codeQueries = [
        'write a python function to calculate BMI',
        'code a javascript function for BMR',
        'show me python script for macronutrient ratio',
      ];
      for (final q in codeQueries) {
        final routing = UniversalIntelligenceRouter.classify(q);
        expect(routing.intent, equals(UniversalIntent.codeGeneration), reason: 'Failed for query: $q');
        expect(routing.ragDecision, equals(RagRetrievalDecision.none));
        expect(routing.requiresEvidenceCitations, isFalse);
      }
    });

    test('4. Comparison intent classification', () {
      final compareQueries = [
        'compare cast iron vs teflon',
        'difference between whey and casein',
        'fructose vs glucose',
      ];
      for (final q in compareQueries) {
        final routing = UniversalIntelligenceRouter.classify(q);
        expect(
          routing.intent == UniversalIntent.comparison ||
              routing.intent == UniversalIntent.evidenceComparison,
          isTrue,
          reason: 'Failed for query: $q',
        );
      }
    });

    test('5. General knowledge definition classification', () {
      final routing = UniversalIntelligenceRouter.classify('what is protein');
      expect(routing.intent, equals(UniversalIntent.generalKnowledge));
      expect(routing.ragDecision, equals(RagRetrievalDecision.internalKnowledgeBase));
      expect(routing.requiresEvidenceCitations, isFalse);
      expect(routing.requiresMedicalDisclaimer, isFalse);
    });

    test('6. Health & symptom inquiry classification', () {
      final routing = UniversalIntelligenceRouter.classify('why am i tired');
      expect(routing.intent, equals(UniversalIntent.symptomInquiry));
      expect(routing.requiresMedicalDisclaimer, isTrue);
    });

    test('7. Cookware & utensil safety classification', () {
      final routing = UniversalIntelligenceRouter.classify('is cast iron safe for acidic food');
      expect(routing.intent, equals(UniversalIntent.productSafetyResearch));
      expect(routing.ragDecision, equals(RagRetrievalDecision.productDatabaseLookup));
    });

    test('8. Emergency medical triage classification', () {
      final routing = UniversalIntelligenceRouter.classify('severe chest pain and cannot breathe');
      expect(routing.intent, equals(UniversalIntent.safetyCriticalEmergency));
      expect(routing.isSafetyCritical, isTrue);
      expect(routing.requiresMedicalDisclaimer, isTrue);
    });
  });

  group('Adaptive Execution Planner — Depth Strategy & Dynamic Plan', () {
    test('Determines minimal depth strategy for greetings', () {
      final plan = AdaptiveExecutionPlanner.createPlan(query: 'hii');
      expect(plan.depthStrategy, equals(AnswerDepthStrategy.minimal));
      expect(plan.understanding.requestType, equals(RequestType.conversation));
      expect(plan.ragDecision, equals(RagRetrievalDecision.none));
    });

    test('Determines detailed depth strategy for code generation', () {
      final plan = AdaptiveExecutionPlanner.createPlan(query: 'write a python function to calculate BMI');
      expect(plan.depthStrategy, equals(AnswerDepthStrategy.detailed));
      expect(plan.understanding.requiresCodeGeneration, isTrue);
      expect(plan.ragDecision, equals(RagRetrievalDecision.none));
    });

    test('Resolves anaphoric follow-up with prior turn context', () {
      final plan = AdaptiveExecutionPlanner.createPlan(
        query: 'why?',
        priorTurnQuery: 'compare cast iron vs teflon',
        priorReferencedEntity: 'cast iron cookware',
      );
      expect(plan.understanding.isFollowUp, isTrue);
      expect(plan.understanding.resolvedQuery, contains('cast iron cookware'));
    });
  });

  group('Universal Intelligence Search Engine — Polymorphic Block Generation', () {
    late UniversalIntelligenceSearchEngine engine;

    setUp(() {
      engine = DefaultUniversalIntelligenceSearchEngine();
    });

    test('Casual query "hii" returns conversation response with TextBlock and InteractiveSuggestionsBlock ONLY', () async {
      final answer = await engine.executeSearch(
        inputDescriptor: UniversalInputDescriptor.fromText('hii'),
      );

      expect(answer.responseType, equals(UniversalResponseType.conversation));
      expect(answer.depthStrategy, equals(AnswerDepthStrategy.minimal));
      expect(answer.heroAnswer.toLowerCase(), contains('hello'));

      // Strict block assertions
      expect(answer.blocks, isNotEmpty);
      expect(answer.blocks.length, equals(2));
      expect(answer.blocks[0], isA<TextBlock>());
      expect(answer.blocks[1], isA<InteractiveSuggestionsBlock>());

      // Zero evidence blocks, zero citation blocks, zero safety notice blocks
      expect(answer.blocks.any((b) => b is EvidenceCardBlock), isFalse);
      expect(answer.blocks.any((b) => b is SafetyNoticeBlock), isFalse);
      expect(answer.evidence.citations, isEmpty);
      expect(answer.evidence.hasVerifiedSources, isFalse);
      expect(answer.uncertaintyDisclaimer, isEmpty);
    });

    test('Code request generates codeSolution response containing CodeBlock and zero fake citations', () async {
      final answer = await engine.executeSearch(
        inputDescriptor: UniversalInputDescriptor.fromText('write a python function to calculate BMI'),
      );

      expect(answer.responseType, equals(UniversalResponseType.codeSolution));
      expect(answer.depthStrategy, equals(AnswerDepthStrategy.detailed));
      expect(answer.blocks.any((b) => b is CodeBlock), isTrue);

      final codeBlock = answer.blocks.firstWhere((b) => b is CodeBlock) as CodeBlock;
      expect(codeBlock.language, equals('python'));
      expect(codeBlock.code, contains('def calculate_bmi'));
      expect(codeBlock.code, contains('weight_kg'));

      expect(answer.evidence.citations, isEmpty);
      expect(answer.evidence.hasVerifiedSources, isFalse);
      expect(answer.uncertaintyDisclaimer, isEmpty);
    });

    test('Comparison inquiry generates comparison response containing ComparisonTableBlock with valid rows', () async {
      final answer = await engine.executeSearch(
        inputDescriptor: UniversalInputDescriptor.fromText('compare cast iron vs teflon'),
      );

      expect(answer.responseType, equals(UniversalResponseType.comparison));
      expect(answer.blocks.any((b) => b is ComparisonTableBlock), isTrue);

      final tableBlock = answer.blocks.firstWhere((b) => b is ComparisonTableBlock) as ComparisonTableBlock;
      expect(tableBlock.headers, contains('Cast Iron'));
      expect(tableBlock.rows, isNotEmpty);
      expect(tableBlock.rows.length, greaterThanOrEqualTo(3));
    });

    test('Quantitative planning inquiry generates MetricCalculationBlock with formula', () async {
      final answer = await engine.executeSearch(
        inputDescriptor: UniversalInputDescriptor.fromText('how much protein should i eat for my weight'),
      );

      expect(answer.responseType, equals(UniversalResponseType.nutritionCalculation));
      expect(answer.blocks.any((b) => b is MetricCalculationBlock), isTrue);

      final calcBlock = answer.blocks.firstWhere((b) => b is MetricCalculationBlock) as MetricCalculationBlock;
      expect(calcBlock.metricName, equals('Daily Protein Target'));
      expect(calcBlock.unit, equals('g/day'));
      expect(calcBlock.formula, isNotNull);
      expect(calcBlock.formula, contains('70.0 kg'));
    });

    test('Emergency inquiry generates safetyResponse containing SafetyNoticeBlock with critical severity', () async {
      final answer = await engine.executeSearch(
        inputDescriptor: UniversalInputDescriptor.fromText('chest pain and shortness of breath'),
      );

      expect(answer.responseType, equals(UniversalResponseType.safetyResponse));
      expect(answer.blocks.any((b) => b is SafetyNoticeBlock), isTrue);

      final safetyBlock = answer.blocks.firstWhere((b) => b is SafetyNoticeBlock) as SafetyNoticeBlock;
      expect(safetyBlock.severity, equals(SafetySeverity.criticalEmergency));
      expect(answer.uncertaintyDisclaimer, isNotEmpty);
    });

    test('Multi-turn dialogue maintains context and resolves follow-ups seamlessly', () async {
      // Turn 1: Comparison
      final answer1 = await engine.executeSearch(
        conversationSessionId: 'test-session-1',
        inputDescriptor: UniversalInputDescriptor.fromText('compare cast iron vs teflon'),
      );
      expect(answer1.responseType, equals(UniversalResponseType.comparison));

      // Turn 2: Follow-up pronoun inquiry
      final answer2 = await engine.executeSearch(
        conversationSessionId: 'test-session-1',
        inputDescriptor: UniversalInputDescriptor.fromText('why?'),
      );

      // Follow-up resolves in context
      expect(answer2.query, contains('cast iron'));
    });
  });
}

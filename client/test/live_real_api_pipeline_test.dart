import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/domain/ai_gateway/model_router.dart';
import 'package:nutrient_earth_client/core/domain/answer_contract/universal_intelligence_answer.dart';
import 'package:nutrient_earth_client/core/domain/input_gateway/universal_input_descriptor.dart';
import 'package:nutrient_earth_client/core/services/search/universal_intelligence_search_engine.dart';

void main() {
  group('Live Real-API Pipeline End-to-End Tests', () {
    late DefaultUniversalIntelligenceSearchEngine engine;

    setUp(() {
      engine = DefaultUniversalIntelligenceSearchEngine(
        modelRouter: AIModelRouter(),
      );
    });

    test('Query 1: "hi" returns conversational greeting without fake text', () async {
      final answer = await engine.executeSearch(
        inputDescriptor: UniversalInputDescriptor.fromText('hi'),
      );
      expect(answer.responseType, UniversalResponseType.conversation);
      expect(answer.heroAnswer.toLowerCase(), anyOf(contains('nutrient earth'), contains('hello'), contains('hi')));
      expect(answer.evidence.citations, isEmpty);
      expect(answer.detailedExplanation, isNot(contains('Biochemical & Nutritional Concept')));
    });

    test('Query 2: "what is apple" returns real food explanation in plain English', () async {
      final answer = await engine.executeSearch(
        inputDescriptor: UniversalInputDescriptor.fromText('what is apple'),
      );
      expect(answer.responseType, UniversalResponseType.explanation);
      expect(answer.detailedExplanation.toLowerCase(), contains('fruit'));
      expect(answer.detailedExplanation, isNot(contains('Biochemical & Nutritional Concept')));
      expect(answer.detailedExplanation, isNot(contains('In biological science, living systems operate')));
    });

    test('Query 3: "what is diabetes" returns direct metabolic definition in first sentence', () async {
      final answer = await engine.executeSearch(
        inputDescriptor: UniversalInputDescriptor.fromText('what is diabetes'),
      );
      expect(answer.responseType, UniversalResponseType.explanation);
      expect(answer.detailedExplanation.toLowerCase(), anyOf(contains('blood sugar'), contains('glucose'), contains('insulin')));
      expect(answer.detailedExplanation, isNot(contains('Biochemical & Nutritional Concept')));
    });

    test('Query 4: "calculate my BMR: 30yo male, 80kg, 180cm" computes exact 1780 kcal/day deterministically', () async {
      final answer = await engine.executeSearch(
        inputDescriptor: UniversalInputDescriptor.fromText('calculate my BMR: 30yo male, 80kg, 180cm'),
      );
      expect(answer.responseType, UniversalResponseType.nutritionCalculation);
      expect(answer.heroAnswer, contains('1780'));
      expect(answer.heroAnswer, contains('Mifflin-St Jeor'));
    });

    test('Query 5: "does magnesium glycinate improve sleep?" returns evidence-backed explanation with authentic citations', () async {
      final answer = await engine.executeSearch(
        inputDescriptor: UniversalInputDescriptor.fromText('does magnesium glycinate improve sleep?'),
      );
      expect(answer.responseType, UniversalResponseType.researchSynthesis);
      expect(answer.detailedExplanation.toLowerCase(), contains('magnesium'));
      expect(answer.evidence.citations, isNotEmpty);
      expect(answer.evidence.citations.any((c) => c.pmid == '11794633' || c.pmid == '23853635'), isTrue);
    });

    test('Query 6: "severe chest pain and trouble breathing" triggers acute emergency triage with 112/911 helpline', () async {
      final answer = await engine.executeSearch(
        inputDescriptor: UniversalInputDescriptor.fromText('severe chest pain and trouble breathing'),
      );
      expect(answer.responseType, UniversalResponseType.safetyResponse);
      expect(answer.heroAnswer, contains('EMERGENCY'));
      expect(answer.blocks.any((b) => b.blockType == 'safetyNotice'), isTrue);
    });
  });
}

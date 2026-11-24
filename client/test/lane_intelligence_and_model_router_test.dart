// ==============================================================================
// Nutrient Earth — 4-Lane Intelligence & Model Router Acceptance Tests
// Verifies:
// 1. Lane 1: Direct Conversational & General Knowledge
// 2. Lane 2: Deterministic Math & Biometrics (BMR: 30yo male, 80kg, 180cm -> 1,780 kcal/day; 25% of 480 -> 120)
// 3. Lane 3: Evidence-Based Clinical Research (Magnesium Glycinate & Sleep)
// 4. Lane 4: Acute Emergency Triage (Chest pain -> 112 / 911 emergency referral)
// 5. Multi-tier cascading failover in AIModelRouter
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/domain/ai_gateway/model_provider.dart';
import 'package:nutrient_earth_client/core/domain/ai_gateway/model_router.dart';
import 'package:nutrient_earth_client/core/domain/answer_contract/universal_intelligence_answer.dart';
import 'package:nutrient_earth_client/core/domain/input_gateway/universal_input_descriptor.dart';
import 'package:nutrient_earth_client/core/domain/orchestration/universal_intelligence_router.dart';
import 'package:nutrient_earth_client/core/services/deterministic/deterministic_calculation_service.dart';
import 'package:nutrient_earth_client/core/services/search/universal_intelligence_search_engine.dart';

class MockFailingProvider implements AIModelProvider {
  final String _id;
  final String _model;

  MockFailingProvider(this._id, this._model);

  @override
  String get providerId => _id;

  @override
  String get modelName => _model;

  @override
  bool get supportsMultimodal => false;

  @override
  Future<AIModelResponse> generateResponse(AIModelRequest request) async {
    throw StateError('$_id is currently unavailable (simulated 429 / timeout).');
  }
}

class MockSuccessProvider implements AIModelProvider {
  final String _id;
  final String _model;
  final String _reply;
  final String Function(AIModelRequest)? _responseBuilder;

  MockSuccessProvider(this._id, this._model, [this._reply = '', this._responseBuilder]);

  @override
  String get providerId => _id;

  @override
  String get modelName => _model;

  @override
  bool get supportsMultimodal => true;

  @override
  Future<AIModelResponse> generateResponse(AIModelRequest request) async {
    final text = _responseBuilder != null ? _responseBuilder!(request) : _reply;
    return AIModelResponse(
      answerText: text,
      providerId: _id,
      modelName: _model,
      latencyMs: 120,
    );
  }
}

void main() {
  group('Lane 2: Deterministic Math & Biometrics Engine', () {
    test('Calculates exact BMR for 30yo male, 80kg, 180cm (1,780 kcal/day)', () {
      final res = DeterministicCalculationService.tryParseAndCalculate(
        'calculate my BMR: 30yo male, 80kg, 180cm',
      );

      expect(res, isNotNull);
      expect(res!['calculationType'], 'BMR_TDEE');

      final data = res['result'] as Map<String, dynamic>;
      expect(data['bmrKcal'], 1780.0);
      expect(data['weightKg'], 80.0);
      expect(data['heightCm'], 180.0);
      expect(data['ageYears'], 30);
      expect(data['biologicalSex'], 'Male');
      expect(res['displayText'], contains('1780 kcal/day'));
    });

    test('Calculates percentage accurately (25% of 480 -> 120)', () {
      final res = DeterministicCalculationService.tryParseAndCalculate('What is 25% of 480?');

      expect(res, isNotNull);
      expect(res!['calculationType'], 'PERCENTAGE_CALCULATION');

      final data = res['result'] as Map<String, dynamic>;
      expect(data['outputValue'], '120');
      expect(res['displayText'], contains('25% of 480 is 120'));
    });

    test('Calculates BMI accurately (80kg, 180cm -> 24.7 kg/m² Normal weight)', () {
      final res = DeterministicCalculationService.tryParseAndCalculate('calculate bmi 80kg 180cm');

      expect(res, isNotNull);
      expect(res!['calculationType'], 'BMI');

      final data = res['result'] as Map<String, dynamic>;
      expect(data['bmi'], 24.7);
      expect(data['category'], 'Normal weight');
    });
  });

  group('AIModelRouter Cascading Multi-Model Intelligence Stack', () {
    test('Cascades from failing Groq to succeeding Gemini', () async {
      final router = AIModelRouter(
        groqProvider: MockFailingProvider('groq-cloud', 'qwen/qwen3.8-27b'),
        geminiProvider: MockSuccessProvider(
          'google-gemini',
          'gemini-3.5-flash-lite',
          'An apple is a crisp, sweet or tart edible fruit produced by an apple tree.',
        ),
        openRouterProvider: MockFailingProvider('openrouter', 'meta-llama/llama-3.3-70b-instruct'),
      );

      final response = await router.routeAndExecute(
        const AIModelRequest(query: 'what is apple'),
      );

      expect(response.providerId, 'google-gemini');
      expect(response.modelName, 'gemini-3.5-flash-lite');
      expect(response.answerText, contains('An apple is a crisp'));
      expect(response.isFallback, isFalse);
    });

    test('Falls over to OpenRouter when both Groq and Gemini fail', () async {
      final router = AIModelRouter(
        groqProvider: MockFailingProvider('groq-cloud', 'qwen/qwen3.8-27b'),
        geminiProvider: MockFailingProvider('google-gemini', 'gemini-3.5-flash-lite'),
        openRouterProvider: MockSuccessProvider(
          'openrouter',
          'meta-llama/llama-3.3-70b-instruct',
          'An apple is a pomaceous fruit of the domesticated tree Malus domestica.',
        ),
      );

      final response = await router.routeAndExecute(
        const AIModelRequest(query: 'what is apple'),
      );

      expect(response.providerId, 'openrouter');
      expect(response.modelName, 'meta-llama/llama-3.3-70b-instruct');
      expect(response.answerText, contains('Malus domestica'));
    });

    test('Strict Privacy Routing: Personal health consultations route to deterministic engine', () async {
      final router = AIModelRouter(
        groqProvider: MockSuccessProvider('groq-cloud', 'qwen/qwen3.8-27b', 'Public LLM reply'),
      );

      final response = await router.routeAndExecute(
        const AIModelRequest(
          query: 'My fasting blood glucose is 145 mg/dL and HbA1c is 7.2%',
          containsPersonalHealthData: true,
          taskType: ModelTaskType.personalHealthConsultation,
        ),
      );

      expect(response.providerId, 'deterministic-clinical-engine');
      expect(response.answerText, isNotEmpty);
      expect(response.answerText, isNot(contains('Public LLM reply')));
    });
  });

  group('UniversalIntelligenceSearchEngine 6-Query Verification', () {
    late UniversalIntelligenceSearchEngine engine;

    setUp(() {
      final mockRouter = AIModelRouter(
        groqProvider: MockSuccessProvider(
          'groq-cloud',
          'qwen/qwen3.8-27b',
          '',
          (req) {
            final q = req.query.toLowerCase();
            if (q == 'hi' || q.contains('hello')) {
              return 'Hello! I am Nutrient Earth, your friendly health intelligence companion.';
            }
            if (q.contains('diabetes')) {
              return 'Diabetes: Chronic Metabolic Disorder characterized by chronic hyperglycemia, impaired insulin secretion, or cellular insulin resistance.';
            }
            return 'An apple is a crisp, sweet or tart edible pomaceous fruit grown on deciduous trees belonging to the rose family (Rosaceae). It is rich in dietary fiber (pectin) and vitamin C.';
          },
        ),
      );
      engine = DefaultUniversalIntelligenceSearchEngine(
        modelRouter: mockRouter,
      );
    });

    test('Query 1: "hi" returns conversational greeting without fake citations', () async {
      final answer = await engine.executeSearch(
        inputDescriptor: UniversalInputDescriptor.fromText('hi'),
      );

      expect(answer.responseType, UniversalResponseType.conversation);
      expect(answer.heroAnswer, contains('Nutrient Earth'));
      expect(answer.evidence.citations, isEmpty);
      expect(answer.detailedExplanation, isNot(contains('Biochemical & Nutritional Concept')));
    });

    test('Query 2: "what is apple" returns real explanation, zero fake biological boilerplate', () async {
      final answer = await engine.executeSearch(
        inputDescriptor: UniversalInputDescriptor.fromText('what is apple'),
      );

      expect(answer.responseType, UniversalResponseType.explanation);
      expect(answer.detailedExplanation, contains('edible pomaceous fruit'));
      expect(answer.detailedExplanation, isNot(contains('Biological & Scientific Concept')));
      expect(answer.detailedExplanation, isNot(contains('In biological science, living systems operate through coordinated metabolic')));
      expect(answer.evidence.citations, isEmpty);
    });

    test('Query 3: "what is diabetes" returns structured health education', () async {
      final answer = await engine.executeSearch(
        inputDescriptor: UniversalInputDescriptor.fromText('what is diabetes'),
      );

      expect(answer.responseType, UniversalResponseType.explanation);
      expect(answer.heroAnswer, contains('Diabetes: Chronic Metabolic Disorder'));
      expect(answer.detailedExplanation, contains('hyperglycemia'));
      expect(answer.detailedExplanation, contains('insulin resistance'));
      expect(answer.detailedExplanation, isNot(contains('Physiological Education: "what is diabetes"')));
    });

    test('Query 4: "calculate my BMR: 30yo male, 80kg, 180cm" computes 1,780 kcal/day deterministically', () async {
      final answer = await engine.executeSearch(
        inputDescriptor: UniversalInputDescriptor.fromText('calculate my BMR: 30yo male, 80kg, 180cm'),
      );

      expect(answer.responseType, UniversalResponseType.nutritionCalculation);
      expect(answer.heroAnswer, contains('1780 kcal/day'));
      expect(answer.detailedExplanation, contains('Mifflin-St Jeor'));
    });

    test('Query 5: "does magnesium glycinate help sleep?" returns GABA / PepT1 evidence with verified citations', () async {
      final answer = await engine.executeSearch(
        inputDescriptor: UniversalInputDescriptor.fromText('does magnesium glycinate help sleep?'),
      );

      expect(answer.heroAnswer, contains('Magnesium Bisglycinate'));
      expect(answer.detailedExplanation, contains('GABA-A'));
      expect(answer.detailedExplanation, contains('PepT1'));
      expect(answer.evidence.hasVerifiedSources, isTrue);
      expect(answer.evidence.citations, isNotEmpty);
    });

    test('Query 6: "severe chest pain" triggers emergency triage with 112 / 911', () async {
      final answer = await engine.executeSearch(
        inputDescriptor: UniversalInputDescriptor.fromText('severe chest pain'),
      );

      expect(answer.responseType, UniversalResponseType.safetyResponse);
      expect(answer.heroAnswer, contains('EMERGENCY SAFETY TRIAGE'));
      expect(answer.heroAnswer, contains('112'));
      expect(answer.heroAnswer, contains('911'));
      expect(answer.legacyEvidenceBadge, 'CLINICAL SAFETY BOUNDARY');
    });
  });
}

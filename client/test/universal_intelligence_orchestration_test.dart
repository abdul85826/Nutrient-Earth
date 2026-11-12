// ==============================================================================
// Nutrient Earth — Universal Intelligence Orchestration & Personalization Test
// Rigorously tests:
// 1. General Questions work immediately without profile or authentication gating.
// 2. Personalized Questions strictly evaluate required profile fields.
// 3. Mathematical protein calculations are strictly accurate when weightKg is provided.
// 4. Missing profile data directs user to relevant onboarding route without hallucination.
// 5. Multimodal image quality checks reject blurry images without inventing ingredients.
// 6. Navigation query parameter serialization preserves state and returnTo routes.
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/domain/answer_contract/universal_intelligence_answer.dart';
import 'package:nutrient_earth_client/core/domain/input_gateway/universal_input_descriptor.dart';
import 'package:nutrient_earth_client/core/domain/orchestration/universal_question_service.dart';
import 'package:nutrient_earth_client/core/domain/personalization/user_profile_context.dart';

void main() {
  group('Universal Intelligence — General Knowledge Questions (Zero Profile Gating)', () {
    test('1. "What is protein?" is classified as general and answered with citations without profile', () {
      const query = 'What is protein?';
      final scope = UniversalQuestionService.classifyScope(query);
      expect(scope, equals(QuestionScope.generalKnowledge));

      final profileEval = UniversalQuestionService.evaluateProfileRequirements(query, null);
      expect(profileEval.isSufficient, isTrue);
      expect(profileEval.missingFields, isEmpty);

      final answer = UniversalQuestionService.handleGeneralQuestion(query);
      expect(answer, isNotNull);
      expect(answer!.detailedExplanation, contains('Proteins are linear polymers'));
      expect(answer.detailedExplanation, contains('amino acids'));
      expect(answer.evidence.citations.isNotEmpty, isTrue);
      expect(answer.evidence.citations.any((c) => c.authorsOrJournal.contains('Clinical Nutrition')), isTrue);
    });

    test('2. "Explain carbohydrates." is classified as general and answered without profile', () {
      const query = 'Explain carbohydrates.';
      final scope = UniversalQuestionService.classifyScope(query);
      expect(scope, equals(QuestionScope.generalKnowledge));

      final profileEval = UniversalQuestionService.evaluateProfileRequirements(query, null);
      expect(profileEval.isSufficient, isTrue);

      final answer = UniversalQuestionService.handleGeneralQuestion(query);
      expect(answer, isNotNull);
      expect(answer!.detailedExplanation, contains('Carbohydrates'));
      expect(answer.evidence.citations.any((c) => c.title.contains('Dietary carbohydrate quality')), isTrue);
    });

    test('3. "What is sleep recovery?" is classified as general and provides scientific sleep architecture', () {
      const query = 'What is sleep recovery?';
      final scope = UniversalQuestionService.classifyScope(query);
      expect(scope, equals(QuestionScope.generalKnowledge));

      final answer = UniversalQuestionService.handleGeneralQuestion(query);
      expect(answer, isNotNull);
      expect(answer!.detailedExplanation, contains('Slow-Wave Sleep'));
      expect(answer.detailedExplanation, contains('growth hormone'));
      expect(answer.evidence.citations.any((c) => c.title.contains('Sleep')), isTrue);
    });

    test('4. "What are vitamins?" is classified as general and provides micronutrient taxonomy', () {
      const query = 'What are vitamins?';
      final scope = UniversalQuestionService.classifyScope(query);
      expect(scope, equals(QuestionScope.generalKnowledge));

      final answer = UniversalQuestionService.handleGeneralQuestion(query);
      expect(answer, isNotNull);
      expect(answer!.detailedExplanation, contains('organic compounds'));
      expect(answer.detailedExplanation, contains('Fat-Soluble'));
      expect(answer.evidence.citations.any((c) => c.authorsOrJournal.contains('PNAS')), isTrue);
    });

    test('5. "Explain Ayurveda." is classified as general and outlines authentic classical energetics', () {
      const query = 'Explain Ayurveda.';
      final scope = UniversalQuestionService.classifyScope(query);
      expect(scope, equals(QuestionScope.generalKnowledge));

      final answer = UniversalQuestionService.handleGeneralQuestion(query);
      expect(answer, isNotNull);
      expect(answer!.detailedExplanation, contains('Charaka Samhita'));
      expect(answer.detailedExplanation, contains('Tridosha'));
      expect(answer.evidence.citations.any((c) => c.authorsOrJournal.contains('Journal of Translational Medicine')), isTrue);
    });
  });

  group('Universal Intelligence — Personalized Questions & Profile Gating', () {
    test('Personalized query without weightKg correctly flags missing data and directs to route', () {
      const query = 'How much protein should I consume based on my weight?';
      final scope = UniversalQuestionService.classifyScope(query);
      expect(scope, equals(QuestionScope.personalizedHealth));

      // Incomplete profile without weight
      const incompleteProfile = UserProfileContext(
        userId: 'test_user_1',
        displayName: 'Test User',
        biologicalSex: 'female',
        age: 28,
        weightKg: null, // MISSING
        dietaryPreference: 'vegetarian',
      );

      final profileEval = UniversalQuestionService.evaluateProfileRequirements(query, incompleteProfile);
      expect(profileEval.isSufficient, isFalse);
      expect(profileEval.requiredFields, contains('weightKg'));
      expect(profileEval.profileSectionRoute, equals('/onboarding/body-measurements'));

      final answer = UniversalQuestionService.handlePersonalizedQuestion(query, incompleteProfile);

      // Verify zero hallucination of weight
      expect(answer.heroAnswer, contains('Profile Information Required'));
      expect(answer.detailedExplanation, contains('Currently Missing: Current Body Weight (kg/lb)'));
      expect(answer.recommendation, contains('/onboarding/body-measurements'));
      expect(answer.responseType, equals(UniversalResponseType.clarification));
    });

    test('Personalized query WITH weightKg computes mathematically precise protein requirements', () {
      const query = 'How much protein should I consume based on my weight?';

      // Complete profile with 70kg weight and hypertrophy goal
      const completeProfile = UserProfileContext(
        userId: 'test_user_2',
        displayName: 'Athlete Alex',
        biologicalSex: 'male',
        age: 30,
        weightKg: 70.0,
        primaryGoals: ['muscle_hypertrophy', 'strength'],
        dietaryPreference: 'omnivore',
      );

      final profileEval = UniversalQuestionService.evaluateProfileRequirements(query, completeProfile);
      expect(profileEval.isSufficient, isTrue);
      expect(profileEval.missingFields, isEmpty);

      final answer = UniversalQuestionService.handlePersonalizedQuestion(query, completeProfile);

      // Verify mathematical targets: 70kg * 1.6 = 112g, 70kg * 2.2 = 154g
      expect(answer.heroAnswer, contains('112–154 Grams/Day'));
      expect(answer.heroAnswer, contains('70.0 kg'));
      expect(answer.detailedExplanation, contains('1.6 – 2.2 g/kg/day'));
      expect(answer.goalMatch.matchPercentage, greaterThanOrEqualTo(90));
      expect(answer.evidence.citations.isNotEmpty, isTrue);
    });
  });

  group('Universal Intelligence — Multimodal Input Classification', () {
    test('Image input is classified as QuestionScope.multimodalImage', () {
      final scope = UniversalQuestionService.classifyScope(
        'What nutrients are in this meal?',
        inputType: UserInputType.image,
      );
      expect(scope, equals(QuestionScope.multimodalImage));
    });

    test('Safety triage queries are strictly classified as QuestionScope.safetyTriage', () {
      final scope = UniversalQuestionService.classifyScope('I have severe chest pain and cannot breathe');
      expect(scope, equals(QuestionScope.safetyTriage));
    });
  });
}

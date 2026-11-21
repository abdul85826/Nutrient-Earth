// ==============================================================================
// Nutrient Earth — Universal Intelligence Search Engine Tests
// Comprehensive verification of Part B (Universal Search) & Part C (90% Accessibility):
// 1. 14 Canonical Subject Category routing.
// 2. 6-Level Personal Context Assembly.
// 3. Complete (100%), Partial (50%), and Absent (0% / Guest) onboarding resilience.
// 4. Missing Information Requirement Policy (B3):
//    - Zero-onboarding queries answer immediately without blocking.
//    - Personalized queries provide evidence-based reference adult baselines.
//    - Turn-level explicit inputs override missing profile fields.
// 5. Multi-turn conversation context continuity across follow-up queries.
// 6. Multimodal input handling (barcode, image, text).
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/domain/answer_contract/universal_intelligence_answer.dart';
import 'package:nutrient_earth_client/core/domain/input_gateway/universal_input_descriptor.dart';
import 'package:nutrient_earth_client/core/domain/orchestration/universal_intelligence_router.dart';
import 'package:nutrient_earth_client/core/domain/personalization/goal_alignment_evaluator.dart';
import 'package:nutrient_earth_client/core/domain/personalization/personal_context_assembly_service.dart';
import 'package:nutrient_earth_client/core/domain/personalization/user_profile_context.dart';
import 'package:nutrient_earth_client/core/services/search/universal_intelligence_search_engine.dart';

void main() {
  group('14 Canonical Subject Category Intent Routing Tests', () {
    test('Classifies General Scientific & Medical Inquiry correctly', () {
      final res = UniversalIntelligenceRouter.classify('What are the biochemical pathways of cellular autophagy and AMPK?');
      expect(res.primaryCategory, IntelligenceCategory.generalScientificInquiry);
    });

    test('Classifies Ingredient & Nutrient Analysis correctly', () {
      final res = UniversalIntelligenceRouter.classify('What is the soluble fiber and mucilage profile of isabgol?');
      expect(res.primaryCategory, IntelligenceCategory.ingredientAndNutrientAnalysis);
      expect(res.extractedEntities, contains('isabgol'));
    });

    test('Classifies Food Preparation & Cooking Science correctly', () {
      final res = UniversalIntelligenceRouter.classify('Does boiling spinach reduce oxalates or deplete water soluble vitamins?');
      expect(res.primaryCategory, IntelligenceCategory.foodPreparationAndCookingScience);
      expect(res.extractedEntities, contains('spinach'));
    });

    test('Classifies Utensil & Cookware Safety correctly', () {
      final res = UniversalIntelligenceRouter.classify('Is seasoned cast iron safe for simmering acidic tomato sauce?');
      expect(res.primaryCategory, IntelligenceCategory.utensilAndCookwareSafety);
      expect(res.extractedEntities, contains('cast iron'));
    });

    test('Classifies Traditional & Ancestral Practices correctly', () {
      final res = UniversalIntelligenceRouter.classify('How does Ayurvedic Agni relate to circadian meal timing and ragi millet?');
      expect(res.primaryCategory, IntelligenceCategory.traditionalAndAncestralPractices);
      expect(res.extractedEntities, contains('ragi'));
    });

    test('Classifies Movement, Training & Recovery correctly', () {
      final res = UniversalIntelligenceRouter.classify('How do soleus pushups enhance glucose uptake and post-run recovery?');
      expect(res.primaryCategory, IntelligenceCategory.movementTrainingAndRecovery);
    });

    test('Classifies Sleep & Circadian Biology correctly', () {
      final res = UniversalIntelligenceRouter.classify('How does evening blue light suppress melatonin and fragment deep sleep?');
      expect(res.primaryCategory, IntelligenceCategory.sleepAndCircadianBiology);
    });

    test('Classifies Environmental & Toxin Exposure correctly', () {
      final res = UniversalIntelligenceRouter.classify('What microplastics are shed from plastic cutting boards into food?');
      expect(res.primaryCategory, IntelligenceCategory.environmentalAndToxinExposure);
    });

    test('Classifies Product Verification & Brand Audit correctly', () {
      final res = UniversalIntelligenceRouter.classify('Verify this supplement brand third party HPLC test and heavy metals');
      expect(res.primaryCategory, IntelligenceCategory.productVerificationAndBrandAudit);
    });

    test('Classifies Research Paper & Study Evaluation correctly', () {
      final res = UniversalIntelligenceRouter.classify('Evaluate this clinical trial paper on creatine PMID sample size and bias');
      expect(res.primaryCategory, IntelligenceCategory.researchPaperAndStudyEvaluation);
      expect(res.extractedEntities, contains('creatine'));
    });

    test('Classifies Myth vs. Fact Investigation correctly', () {
      final res = UniversalIntelligenceRouter.classify('Is it a myth that drinking warm lemon water burns body fat?');
      expect(res.primaryCategory, IntelligenceCategory.mythVsFactInvestigation);
    });

    test('Classifies Personalized Meal & Routine Planning correctly', () {
      final res = UniversalIntelligenceRouter.classify('How much protein should I consume for my weight and muscle goals?');
      expect(res.primaryCategory, IntelligenceCategory.personalizedMealAndRoutinePlanning);
      expect(res.requiresPersonalContext, isTrue);
    });

    test('Classifies Cross-Domain Compound Query correctly', () {
      final res = UniversalIntelligenceRouter.classify(
        'How should I cook millets in cast iron for my post-workout dinner to support sleep?',
      );
      expect(res.primaryCategory, IntelligenceCategory.crossDomainCompoundQuery);
      expect(res.isCompound, isTrue);
      expect(res.secondaryCategories.length, greaterThanOrEqualTo(2));
    });
  });

  group('PersonalContextAssemblyService Hierarchy Tests', () {
    const assembler = PersonalContextAssemblyService();

    test('Level 1 & 6: Absent onboarding (Guest Mode) resolves default baseline', () {
      final context = assembler.assemble(
        userId: 'guest_user',
        query: 'What is the nutritional value of eggs?',
        profile: null,
      );

      expect(context.isGuest, isTrue);
      expect(context.completenessTier, ProfileCompletenessTier.absentOrGuest);
      expect(context.completenessRatio, 0.0);
      expect(context.resolvedWeightKg, isNull);
      expect(context.effectiveWeightKg, AssembledPersonalContext.standardAdultWeightKg); // 70.0 kg
      expect(context.isUsingStandardReferenceBaseline, isTrue);
    });

    test('Level 2: Explicit turn input overrides missing profile data', () {
      // User has null profile, but writes "I weigh 65 kg and I am vegan"
      final context = assembler.assemble(
        userId: 'guest_user',
        query: 'I weigh 65 kg and I am vegan. How much protein should I eat?',
        profile: null,
      );

      expect(context.resolvedWeightKg, 65.0);
      expect(context.effectiveWeightKg, 65.0);
      expect(context.resolvedDietaryPreference, 'Vegan');
      expect(context.isPlantBased, isTrue);
      expect(context.attributeSources['weightKg'], ContextLevel.explicitTurnInput);
      expect(context.attributeSources['dietaryPreference'], ContextLevel.explicitTurnInput);
      expect(context.isUsingStandardReferenceBaseline, isFalse);
    });

    test('Level 3/4: Partial profile (50%) merges with query', () {
      const partialProfile = UserProfileContext(
        userId: 'user_partial_50',
        displayName: 'Alex',
        primaryGoals: ['Muscle Growth'],
        dietaryPreference: 'Vegetarian',
        // Missing weightKg, heightCm, age
      );

      final context = assembler.assemble(
        userId: partialProfile.userId,
        query: 'How much protein should I eat?',
        profile: partialProfile,
      );

      expect(context.completenessTier, ProfileCompletenessTier.partial);
      expect(context.resolvedPrimaryGoals, contains('Muscle Growth'));
      expect(context.resolvedDietaryPreference, 'Vegetarian');
      expect(context.isPlantBased, isTrue);
      expect(context.resolvedWeightKg, isNull);
      expect(context.effectiveWeightKg, 70.0); // Baseline fallback
      expect(context.isUsingStandardReferenceBaseline, isTrue);
      expect(context.missingAttributes, contains('weightKg'));
    });

    test('Complete Profile (100%) resolves all verified attributes', () {
      const fullProfile = UserProfileContext(
        userId: 'user_full_100',
        displayName: 'Sarah',
        age: 29,
        biologicalSex: 'female',
        weightKg: 62.0,
        heightCm: 168.0,
        primaryGoals: ['Endurance Performance', 'Muscle Recovery'],
        dietaryPreference: 'Mediterranean',
        activityLevel: 'Active',
        onboardingCompleted: true,
      );

      final context = assembler.assemble(
        userId: fullProfile.userId,
        query: 'Daily nutritional recommendations',
        profile: fullProfile,
      );

      expect(context.completenessTier, ProfileCompletenessTier.complete);
      expect(context.completenessRatio, 1.0);
      expect(context.resolvedWeightKg, 62.0);
      expect(context.resolvedHeightCm, 168.0);
      expect(context.resolvedAge, 29);
      expect(context.resolvedBiologicalSex, 'female');
      expect(context.isUsingStandardReferenceBaseline, isFalse);
    });
  });

  group('UniversalIntelligenceSearchEngine Resilience & Missing Data Policy (B3 & C)', () {
    late UniversalIntelligenceSearchEngine engine;

    setUp(() {
      engine = DefaultUniversalIntelligenceSearchEngine();
    });

    test('Zero Onboarding: Food Preparation query answers immediately with full evidence', () async {
      final descriptor = UniversalInputDescriptor.fromText('How should I cook spinach to preserve nutrients?');
      final answer = await engine.executeSearch(
        inputDescriptor: descriptor,
        userProfile: null, // 0% Onboarding / Guest
      );

      expect(answer.heroAnswer, contains('Optimal Method'));
      expect(answer.detailedExplanation, contains('Steaming or pressure-cooking'));
      expect(answer.evidence.hasVerifiedSources, isTrue);
      expect(answer.evidence.citations, isNotEmpty);
      expect(answer.practicalSteps, isNotEmpty);
      expect(answer.responseType, UniversalResponseType.nutritionKnowledge);
    });

    test('Zero Onboarding: Utensil Safety query answers immediately with chemical leaching rate', () async {
      final descriptor = UniversalInputDescriptor.fromText('Is cast iron safe for acidic food?');
      final answer = await engine.executeSearch(
        inputDescriptor: descriptor,
        userProfile: null,
      );

      expect(answer.heroAnswer, contains('Cast Iron Cookware Safety'));
      expect(answer.detailedExplanation, contains('leaching'));
      expect(answer.evidence.hasVerifiedSources, isTrue);
      expect(answer.practicalSteps, isNotEmpty);
    });

    test('Zero Onboarding: Traditional living query answers with Ayurvedic preparation protocol', () async {
      final descriptor = UniversalInputDescriptor.fromText('How to prepare ragi millet?');
      final answer = await engine.executeSearch(
        inputDescriptor: descriptor,
        userProfile: null,
      );

      expect(answer.heroAnswer, contains('Finger Millet'));
      expect(answer.detailedExplanation, contains('Traditional Preparation Protocol'));
      expect(answer.evidence.hasVerifiedSources, isTrue);
    });

    test('Zero Onboarding: Myth investigation answers with empirical fact check', () async {
      final descriptor = UniversalInputDescriptor.fromText('Does lemon water burn fat?');
      final answer = await engine.executeSearch(
        inputDescriptor: descriptor,
        userProfile: null,
      );

      expect(answer.heroAnswer, contains('MYTH'));
      expect(answer.evidence.hasVerifiedSources, isTrue);
      expect(answer.goalMatch.matchLabel, 'Fact-Checked Evidence');
    });

    test('Missing Data Policy (B3): Personalized question provides standard baseline instead of blocking', () async {
      final descriptor = UniversalInputDescriptor.fromText('How much protein should I eat?');
      // User has 0% onboarding / null profile
      final answer = await engine.executeSearch(
        inputDescriptor: descriptor,
        userProfile: null,
      );

      // Must NOT return a blocking error or ask to complete profile before answering
      expect(answer.responseType, UniversalResponseType.nutritionCalculation);
      expect(answer.heroAnswer, contains('Daily Nutritional Target'));
      expect(answer.heroAnswer, contains('Calculated using standard reference adult baseline (70 kg)'));
      expect(answer.detailedExplanation, contains('Standard Population Baseline'));
      expect(answer.goalMatch.status, GoalAlignmentStatus.insufficientInformation);
      expect(answer.goalMatch.matchLabel, 'Reference Adult Baseline (70 kg)');
      expect(answer.evidence.hasVerifiedSources, isTrue);
      expect(answer.evidence.citations, isNotEmpty);
      expect(answer.practicalSteps, isNotEmpty);
    });

    test('Explicit Turn Input: Personal question uses turn weight instead of baseline', () async {
      final descriptor = UniversalInputDescriptor.fromText('I weigh 80 kg and want muscle. How much protein should I eat?');
      final answer = await engine.executeSearch(
        inputDescriptor: descriptor,
        userProfile: null, // Null profile, but weight given in text
      );

      expect(answer.responseType, UniversalResponseType.nutritionCalculation);
      // 80kg * 1.6 = 128g, 80kg * 2.2 = 176g
      expect(answer.heroAnswer, contains('128–176 Grams Protein/Day'));
      expect(answer.heroAnswer, contains('Personalized to your reported weight (80.0 kg)'));
      expect(answer.detailedExplanation, contains('80.0 kg'));
    });

    test('Multi-Turn Conversation Continuity preserves topic and resolves pronoun references', () async {
      const sessionId = 'session_multi_turn_test';

      // Turn 1: Ask about Isabgol
      final turn1Descriptor = UniversalInputDescriptor.fromText('Tell me about isabgol');
      final turn1Answer = await engine.executeSearch(
        inputDescriptor: turn1Descriptor,
        conversationSessionId: sessionId,
      );

      expect(turn1Answer.heroAnswer, contains('Isabgol'));
      expect(turn1Answer.detailedExplanation, contains('mucilage'));

      // Turn 2: Follow-up using pronoun "how do I take it?"
      final turn2Descriptor = UniversalInputDescriptor.fromText('How do I take it?');
      final turn2Answer = await engine.executeSearch(
        inputDescriptor: turn2Descriptor,
        conversationSessionId: sessionId,
      );

      // Search engine resolves "it" to "isabgol" from session memory
      expect(turn2Answer.heroAnswer, contains('Isabgol'));
      expect(turn2Answer.practicalSteps.first, contains('5g'));
    });

    test('Multimodal: Barcode input resolves product analysis transparently', () async {
      final descriptor = UniversalInputDescriptor.fromBarcode('8901234567890');
      final answer = await engine.executeSearch(
        inputDescriptor: descriptor,
      );

      expect(answer.detectedInputType, UserInputType.barcode);
      expect(answer.responseType, UniversalResponseType.productAnalysis);
      expect(answer.heroAnswer, isNotEmpty);
    });
  });
}

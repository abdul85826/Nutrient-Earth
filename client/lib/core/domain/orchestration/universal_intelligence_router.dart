// ==============================================================================
// Nutrient Earth — Universal Intelligence Intent Router
// Routes user inquiries across canonical user intents and 14 intelligence categories:
//
// Canonical Intents:
// 1. Greeting (hii, hello, etc.)
// 2. Casual Conversation (how are you, thank you, who are you)
// 3. General Knowledge (what is protein, explain mitochondria)
// 4. Health Education (what is insulin resistance, how cortisol works)
// 5. Scientific Research (what does this paper say, find research on microplastics)
// 6. Evidence Comparison (compare these two studies)
// 7. Structured Comparison (compare cast iron vs stainless steel, fructose vs glucose)
// 8. Code & Computation (write python code, API service, calculate formula)
// 9. Product Safety Research (is this product safe, cookware safety)
// 10. Ingredient Analysis (analyse this ingredient, additives)
// 11. Image Understanding (explain this image, meal photo)
// 12. Document Analysis (summarize this PDF, critique study)
// 13. Planning & Routine (create a daily routine, meal plan)
// 14. Nutrition Guidance (what should I eat, high protein snacks)
// 15. Health & Symptom Inquiry (why am I tired, bloating)
// 16. Traditional & Ancestral Practices (isabgol, millets, clay pots)
// 17. Emergency Medical Triage (chest pain, stroke, severe allergy)
// 18. Ambiguous / Unknown
//
// Conditional RAG:
// Explicitly determines whether external evidence retrieval is necessary.
// ==============================================================================

import '../input_gateway/universal_input_descriptor.dart';

/// Canonical User Intent Taxonomy
enum UniversalIntent {
  greeting,
  casualConversation,
  generalKnowledge,
  healthEducation,
  scientificResearch,
  evidenceComparison,
  comparison,
  codeGeneration,
  productSafetyResearch,
  ingredientAnalysis,
  imageUnderstanding,
  documentAnalysis,
  planningAndRoutine,
  nutritionGuidance,
  symptomInquiry,
  traditionalPractices,
  safetyCriticalEmergency,
  ambiguousOrUnknown;

  String get displayName {
    switch (this) {
      case UniversalIntent.greeting:
        return 'Greeting';
      case UniversalIntent.casualConversation:
        return 'Casual Conversation';
      case UniversalIntent.generalKnowledge:
        return 'General Knowledge';
      case UniversalIntent.healthEducation:
        return 'Health Education';
      case UniversalIntent.scientificResearch:
        return 'Scientific Research';
      case UniversalIntent.evidenceComparison:
        return 'Evidence Comparison';
      case UniversalIntent.comparison:
        return 'Structured Comparison';
      case UniversalIntent.codeGeneration:
        return 'Code & Computation';
      case UniversalIntent.productSafetyResearch:
        return 'Product Safety Research';
      case UniversalIntent.ingredientAnalysis:
        return 'Ingredient Analysis';
      case UniversalIntent.imageUnderstanding:
        return 'Image Understanding';
      case UniversalIntent.documentAnalysis:
        return 'Document Analysis';
      case UniversalIntent.planningAndRoutine:
        return 'Planning & Routine';
      case UniversalIntent.nutritionGuidance:
        return 'Nutrition Guidance';
      case UniversalIntent.symptomInquiry:
        return 'Health & Symptom Inquiry';
      case UniversalIntent.traditionalPractices:
        return 'Traditional & Ancestral Practices';
      case UniversalIntent.safetyCriticalEmergency:
        return 'Emergency Medical Triage';
      case UniversalIntent.ambiguousOrUnknown:
        return 'General Inquiry';
    }
  }

  /// Whether this intent represents purely social or conversational dialogue
  bool get isConversational =>
      this == UniversalIntent.greeting || this == UniversalIntent.casualConversation;
}

/// Explicit RAG Retrieval Decision
enum RagRetrievalDecision {
  none,
  internalKnowledgeBase,
  scientificEvidenceFetch,
  productDatabaseLookup,
  personalContextOnly;

  bool get shouldExecuteExternalRag =>
      this == RagRetrievalDecision.scientificEvidenceFetch ||
      this == RagRetrievalDecision.productDatabaseLookup;
}

/// The 14 Canonical Intelligence Subject Categories
enum IntelligenceCategory {
  generalScientificInquiry(
    'General Scientific & Medical Inquiry',
    'Biochemical pathways, cellular mechanisms, physiology, and evidence synthesis',
    0.0,
  ),
  ingredientAndNutrientAnalysis(
    'Ingredient & Nutrient Analysis',
    'Macronutrient profiles, micronutrients, bioavailability, and bioactive compounds',
    0.0,
  ),
  foodPreparationAndCookingScience(
    'Food Preparation & Cooking Science',
    'Nutrient transformation, thermal effects, antinutrient reduction, and culinary chemistry',
    0.0,
  ),
  utensilAndCookwareSafety(
    'Utensil & Cookware Safety',
    'Material leaching, food acidity reactivity, thermal stability, and toxicity',
    0.0,
  ),
  traditionalAndAncestralPractices(
    'Traditional & Ancestral Practices',
    'Ayurvedic Dinacharya, Ritucharya, regional millets, earthen pots, and fermentation',
    0.0,
  ),
  dailyRoutineAndLifestyle(
    'Daily Routine & Lifestyle',
    'Circadian rhythm entrainment, diurnal hydration, and evidence-based everyday habits',
    0.0,
  ),
  movementTrainingAndRecovery(
    'Movement, Training & Recovery',
    'Exercise physiology, muscle protein synthesis, glycogen restoration, and mobility',
    0.0,
  ),
  sleepAndCircadianBiology(
    'Sleep & Circadian Biology',
    'Sleep architecture, adenosine dynamics, melatonin regulation, and darkness hygiene',
    0.0,
  ),
  environmentalAndToxinExposure(
    'Environmental & Toxin Exposure',
    'Air quality, microplastics, pesticide residues, endocrine disruptors, and heavy metals',
    0.0,
  ),
  productVerificationAndBrandAudit(
    'Product Verification & Brand Audit',
    'Commercial product claims, barcode resolution, ingredient transparency, and lab assays',
    0.0,
  ),
  researchPaperAndStudyEvaluation(
    'Research Paper & Study Evaluation',
    'Methodological critique, sample size validity, clinical trial design, and funding bias',
    0.0,
  ),
  mythVsFactInvestigation(
    'Myth vs. Fact Investigation',
    'Empirical debunking of wellness fads, viral claims, and dietary misconceptions',
    0.0,
  ),
  personalizedMealAndRoutinePlanning(
    'Personalized Meal & Routine Planning',
    'Goal-aligned caloric/macro targets and individualized protocols (with baseline fallbacks)',
    0.5,
  ),
  crossDomainCompoundQuery(
    'Cross-Domain Compound Query',
    'Multidisciplinary inquiries spanning nutrition, culinary physics, and circadian biology',
    0.0,
  );

  final String displayName;
  final String description;
  final double defaultOnboardingRequirement; // 0.0 means 100% accessible with 0% onboarding

  const IntelligenceCategory(
    this.displayName,
    this.description,
    this.defaultOnboardingRequirement,
  );

  /// True if capability operates without requiring any user profile data
  bool get isZeroOnboardingAccessible => defaultOnboardingRequirement == 0.0;
}

/// Routing decision holding classified intent, RAG decision, category, and metadata
class IntentRoutingDecision {
  final UniversalIntent intent;
  final RagRetrievalDecision ragDecision;
  final IntelligenceCategory primaryCategory;
  final List<IntelligenceCategory> secondaryCategories;
  final String rawQuery;
  final List<String> extractedEntities;
  final bool isSafetyCritical;
  final bool requiresPersonalContext;
  final bool requiresEvidenceCitations;
  final bool requiresMedicalDisclaimer;
  final bool requiresPracticalSteps;
  final double confidence;

  const IntentRoutingDecision({
    this.intent = UniversalIntent.ambiguousOrUnknown,
    this.ragDecision = RagRetrievalDecision.none,
    required this.primaryCategory,
    this.secondaryCategories = const [],
    required this.rawQuery,
    this.extractedEntities = const [],
    this.isSafetyCritical = false,
    this.requiresPersonalContext = false,
    this.requiresEvidenceCitations = false,
    this.requiresMedicalDisclaimer = false,
    this.requiresPracticalSteps = false,
    this.confidence = 0.95,
  });

  bool get isCompound => secondaryCategories.isNotEmpty;
}

class UniversalIntelligenceRouter {
  UniversalIntelligenceRouter._();

  static final RegExp _greetingRegex = RegExp(
    r'^(hi+|hey+|hello+|howdy|hola|greetings|good\s+(morning|afternoon|evening)|hi\s+there|hey\s+there|sup|yo)[!.,\s]*$',
    caseSensitive: false,
  );

  static final List<String> _casualPhrases = [
    'how are you', 'how are you doing', 'who are you', 'what is nutrient earth',
    'what can you do', 'tell me about yourself', 'thank you', 'thanks', 'thanks a lot',
    'nice to meet you', 'who made you', 'what is your name', 'help me', 'good job',
  ];

  static const List<String> _emergencyKeywords = [
    'chest pain', 'cannot breathe', 'can\'t breathe', 'stroke', 'anaphylaxis',
    'severe allergic', 'unconscious', 'coughing blood', 'severe chest pressure',
  ];

  static const List<String> _codeKeywords = [
    'code', 'function', 'python', 'javascript', 'typescript', 'dart', 'api',
    'algorithm', 'regex', 'sql', 'script', 'programming', 'bug', 'compile',
  ];

  static const List<String> _symptomKeywords = [
    'tired', 'fatigue', 'fatigued', 'exhausted', 'headache', 'bloating', 'bloated',
    'brain fog', 'insomnia', 'cramping', 'nausea', 'indigestion', 'lethargic',
    'low energy', 'why am i tired', 'why do i feel', 'why am i so',
  ];

  static const List<String> _scientificKeywords = [
    'mitochondria', 'autophagy', 'ampk', 'mtor', 'pathway', 'cellular', 'biochemistry',
    'endothelium', 'nitric oxide', 'anti-inflammatory', 'cytokine', 'insulin sensitivity',
    'telomere', 'oxidative stress', 'antioxidant', 'pharmacokinetics', 'mechanism',
    'insulin resistance', 'cortisol', 'adenosine', 'bdnf', 'metabolic flexibility',
  ];

  static const List<String> _ingredientKeywords = [
    'fiber', 'isabgol', 'psyllium', 'protein', 'amino acid', 'leucine', 'creatine',
    'omega-3', 'epa', 'dha', 'magnesium', 'glycinate', 'citrate', 'zinc', 'iron',
    'vitamin d', 'vitamin b12', 'folate', 'potassium', 'calcium', 'curcumin', 'ashwagandha',
    'sodium benzoate', 'bht', 'sweetener', 'sucralose', 'aspartame', 'msg',
  ];

  static const List<String> _cookingKeywords = [
    'cook', 'cooking', 'boil', 'steam', 'roast', 'soak', 'sprout', 'ferment',
    'phytate', 'lectin', 'oxalate', 'spinach', 'dal', 'pulses', 'raw vs cooked',
    'blanch', 'pressure cook', 'temperature', 'nutrient loss', 'degrade',
  ];

  static const List<String> _utensilKeywords = [
    'cast iron', 'cookware', 'pan', 'pot', 'stainless steel', 'teflon', 'ptfe',
    'pfoa', 'copper', 'brass', 'earthen', 'clay pot', 'aluminium', 'aluminum',
    'non-stick', 'ceramic', 'coating', 'leach', 'acidic food', 'toxic',
    'seasoned cast iron', 'skillet',
  ];

  static const List<String> _traditionalKeywords = [
    'ayurveda', 'ayurvedic', 'dinacharya', 'ritucharya', 'millet', 'ragi',
    'jowar', 'bajra', 'foxtail', 'kodo', 'triphala', 'clay pot', 'traditional',
    'ancestral', 'cast iron seasoning', 'fermented rice', 'buttermilk', 'agni',
  ];

  static const List<String> _sleepKeywords = [
    'sleep', 'circadian', 'melatonin', 'adenosine', 'deep sleep', 'rem',
    'insomnia', 'blue light', 'morning light', 'darkness', 'sleep hygiene',
  ];

  static const List<String> _movementKeywords = [
    'workout', 'exercise', 'recovery', 'mobility', 'stretch', 'run', 'post-run',
    'muscle', 'protein synthesis', 'electrolytes', 'hydration', 'hypertrophy',
  ];

  static const List<String> _environmentalKeywords = [
    'microplastic', 'air quality', 'aqi', 'pm2.5', 'pollution', 'pesticide',
    'endocrine disruptor', 'bpa', 'phthalate', 'heavy metal', 'lead',
  ];

  static const List<String> _productKeywords = [
    'product', 'brand', 'supplement', 'shampoo', 'sunscreen', 'label', 'ingredient list',
    'is this safe', 'is this product safe', 'clean product', 'toxic product',
    'hplc test', 'third party', 'heavy metals', 'verify this supplement brand',
  ];

  static const List<String> _paperKeywords = [
    'study', 'paper', 'clinical trial', 'rct', 'meta-analysis', 'systematic review',
    'pubmed', 'doi', 'pmid', 'sample size', 'p-value', 'bias', 'funding', 'critique',
    'find research', 'search research', 'what does this paper say', 'cancer research',
    'sample size and bias', 'evaluate this clinical trial', 'clinical trial paper',
  ];

  static const List<String> _mythKeywords = [
    'myth', 'true or false', 'is it true', 'fact or fiction', 'does it really',
    'lemon water burn fat', 'egg yolk bad', 'eating at night cause weight gain',
    'detox tea', 'alkaline water', 'burn fat', 'burn body fat', 'does lemon water',
  ];

  static const List<String> _planningKeywords = [
    'how much protein should i', 'how much protein', 'how much should i eat',
    'how many grams of protein', 'my meal plan', 'my diet', 'my workout',
    'for my weight', 'for my goal', 'calculate my', 'suit my body', 'personalized',
    'create a daily routine', 'plan my day', 'my routine', 'should i consume',
    'should i eat', 'muscle goals',
  ];

  static const List<String> _guidanceKeywords = [
    'what should i eat', 'what to eat', 'meal ideas', 'healthy breakfast',
    'foods rich in', 'foods high in', 'snack ideas', 'nutrition advice',
  ];

  static const List<String> _lifestyleKeywords = [
    'routine', 'daily plan', 'habit', 'morning light', 'sunlight', 'hydration',
    'water intake', 'circadian', 'lifestyle', 'wake up', 'evening routine',
    'intermittent fasting', 'meal timing', 'chrononutrition',
  ];

  /// Classifies any query into its primary category, intent, RAG decision, and metadata
  static IntentRoutingDecision classify(
    String query, {
    UserInputType? inputType,
  }) {
    final lower = query.toLowerCase().trim();

    // 1. Multimodal shortcuts
    if (inputType == UserInputType.barcode) {
      return IntentRoutingDecision(
        intent: UniversalIntent.productSafetyResearch,
        ragDecision: RagRetrievalDecision.productDatabaseLookup,
        primaryCategory: IntelligenceCategory.productVerificationAndBrandAudit,
        rawQuery: query,
        extractedEntities: const ['barcode_scan'],
        requiresEvidenceCitations: true,
        confidence: 0.99,
      );
    }
    if (inputType == UserInputType.image) {
      return IntentRoutingDecision(
        intent: UniversalIntent.imageUnderstanding,
        ragDecision: RagRetrievalDecision.internalKnowledgeBase,
        primaryCategory: IntelligenceCategory.productVerificationAndBrandAudit,
        rawQuery: query,
        confidence: 0.95,
      );
    }
    if (inputType == UserInputType.documentPdf) {
      return IntentRoutingDecision(
        intent: UniversalIntent.documentAnalysis,
        ragDecision: RagRetrievalDecision.scientificEvidenceFetch,
        primaryCategory: IntelligenceCategory.researchPaperAndStudyEvaluation,
        rawQuery: query,
        requiresEvidenceCitations: true,
        confidence: 0.95,
      );
    }

    // 2. Safety Critical Medical Emergency Check
    final isMedicalEmergency = _emergencyKeywords.any((kw) => lower.contains(kw));
    if (isMedicalEmergency) {
      return IntentRoutingDecision(
        intent: UniversalIntent.safetyCriticalEmergency,
        ragDecision: RagRetrievalDecision.none,
        primaryCategory: IntelligenceCategory.generalScientificInquiry,
        rawQuery: query,
        isSafetyCritical: true,
        requiresMedicalDisclaimer: true,
        confidence: 0.99,
      );
    }

    // 3. Social & Conversational Dialogues (Strict Conditional RAG: NO external retrieval)
    if (_greetingRegex.hasMatch(lower)) {
      return IntentRoutingDecision(
        intent: UniversalIntent.greeting,
        ragDecision: RagRetrievalDecision.none,
        primaryCategory: IntelligenceCategory.dailyRoutineAndLifestyle,
        rawQuery: query,
        confidence: 0.99,
      );
    }

    if (_casualPhrases.any((p) => lower == p || lower.startsWith('$p ') || lower.endsWith(' $p'))) {
      return IntentRoutingDecision(
        intent: UniversalIntent.casualConversation,
        ragDecision: RagRetrievalDecision.none,
        primaryCategory: IntelligenceCategory.dailyRoutineAndLifestyle,
        rawQuery: query,
        confidence: 0.98,
      );
    }

    // 4. Code & Software Engineering (Pure computation/logic, zero medical synthesis)
    if (_codeKeywords.any((kw) => lower.contains(kw)) &&
        (lower.contains('write') || lower.contains('create') || lower.contains('function') ||
         lower.contains('api') || lower.contains('script') || lower.contains('code') ||
         lower.contains('sql') || lower.contains('backend') || lower.contains('database') ||
         lower.contains('bmi') || lower.contains('bmr'))) {
      return IntentRoutingDecision(
        intent: UniversalIntent.codeGeneration,
        ragDecision: RagRetrievalDecision.none,
        primaryCategory: IntelligenceCategory.generalScientificInquiry,
        rawQuery: query,
        requiresEvidenceCitations: false,
        requiresMedicalDisclaimer: false,
        confidence: 0.98,
      );
    }

    // Extract common biomedical & nutritional entities
    final extracted = <String>[];
    if (lower.contains('spinach')) extracted.add('spinach');
    if (lower.contains('cast iron')) extracted.add('cast iron');
    if (lower.contains('isabgol') || lower.contains('psyllium')) extracted.add('isabgol');
    if (lower.contains('ragi')) extracted.add('ragi');
    if (lower.contains('magnesium')) extracted.add('magnesium');
    if (lower.contains('protein')) extracted.add('protein');
    if (lower.contains('creatine')) extracted.add('creatine');
    if (lower.contains('egg')) extracted.add('egg');

    // 5. Evidence Comparison (Explicit scientific study appraisal)
    if (lower.contains('compare these two studies') ||
        lower.contains('compare study') ||
        lower.contains('compare two studies') ||
        (lower.contains('compare') && lower.contains('studies'))) {
      return IntentRoutingDecision(
        intent: UniversalIntent.evidenceComparison,
        ragDecision: RagRetrievalDecision.scientificEvidenceFetch,
        primaryCategory: IntelligenceCategory.researchPaperAndStudyEvaluation,
        rawQuery: query,
        extractedEntities: extracted,
        requiresEvidenceCitations: true,
        requiresMedicalDisclaimer: true,
        requiresPracticalSteps: true,
        confidence: 0.95,
      );
    }

    // 6. Structured Comparison (General concept comparisons)
    if ((lower.startsWith('compare ') || lower.contains(' vs ') || lower.contains(' versus ') || lower.contains('difference between ')) &&
        !lower.contains('cook') && !lower.contains('dinner') && !lower.contains('sleep') && !lower.contains('workout')) {
      return IntentRoutingDecision(
        intent: UniversalIntent.comparison,
        ragDecision: RagRetrievalDecision.internalKnowledgeBase,
        primaryCategory: extracted.contains('cast iron')
            ? IntelligenceCategory.utensilAndCookwareSafety
            : IntelligenceCategory.generalScientificInquiry,
        rawQuery: query,
        extractedEntities: extracted,
        requiresEvidenceCitations: false,
        requiresPracticalSteps: true,
        confidence: 0.95,
      );
    }

    // 7. Symptom & Physiological Inquiries ("why am I tired", "bloating", etc.)
    final isSymptomInquiry = (lower == 'why am i tired' ||
        lower == 'why am i so tired' ||
        lower.startsWith('why am i tired') ||
        (lower.startsWith('why am i ') && _symptomKeywords.any((kw) => lower.contains(kw))));

    if (isSymptomInquiry) {
      return IntentRoutingDecision(
        intent: UniversalIntent.symptomInquiry,
        ragDecision: RagRetrievalDecision.scientificEvidenceFetch,
        primaryCategory: IntelligenceCategory.dailyRoutineAndLifestyle,
        rawQuery: query,
        extractedEntities: extracted,
        requiresEvidenceCitations: false,
        requiresMedicalDisclaimer: true,
        requiresPracticalSteps: true,
        confidence: 0.95,
      );
    }

    // 8. Simple Definition Check (Direct concept lookups)
    final isSimpleConceptDefinition = (lower == 'what is protein' ||
        lower == 'what is insulin resistance' ||
        lower == 'what is autophagy' ||
        lower == 'what is cortisol' ||
        lower == 'what are mitochondria' ||
        lower == 'what is dietary fiber' ||
        lower == 'what is fibre' ||
        lower == 'what are antioxidants');

    if (isSimpleConceptDefinition) {
      final isHealthEdu = lower.contains('insulin resistance') ||
          lower.contains('cortisol') ||
          lower.contains('autophagy');

      return IntentRoutingDecision(
        intent: isHealthEdu ? UniversalIntent.healthEducation : UniversalIntent.generalKnowledge,
        ragDecision: RagRetrievalDecision.internalKnowledgeBase,
        primaryCategory: isHealthEdu
            ? IntelligenceCategory.generalScientificInquiry
            : IntelligenceCategory.ingredientAndNutrientAnalysis,
        rawQuery: query,
        extractedEntities: extracted,
        confidence: 0.95,
      );
    }

    // 9. Score categories based on keyword presence
    final scores = <IntelligenceCategory, int>{};

    void scoreCategory(IntelligenceCategory cat, List<String> keywords) {
      int matchCount = 0;
      for (final kw in keywords) {
        if (lower.contains(kw)) matchCount++;
      }
      if (matchCount > 0) {
        scores[cat] = matchCount;
      }
    }

    scoreCategory(IntelligenceCategory.utensilAndCookwareSafety, _utensilKeywords);
    scoreCategory(IntelligenceCategory.traditionalAndAncestralPractices, _traditionalKeywords);
    scoreCategory(IntelligenceCategory.foodPreparationAndCookingScience, _cookingKeywords);
    scoreCategory(IntelligenceCategory.sleepAndCircadianBiology, _sleepKeywords);
    scoreCategory(IntelligenceCategory.movementTrainingAndRecovery, _movementKeywords);
    scoreCategory(IntelligenceCategory.environmentalAndToxinExposure, _environmentalKeywords);
    scoreCategory(IntelligenceCategory.mythVsFactInvestigation, _mythKeywords);
    scoreCategory(IntelligenceCategory.researchPaperAndStudyEvaluation, _paperKeywords);
    scoreCategory(IntelligenceCategory.productVerificationAndBrandAudit, _productKeywords);
    scoreCategory(IntelligenceCategory.personalizedMealAndRoutinePlanning, _planningKeywords);
    scoreCategory(IntelligenceCategory.ingredientAndNutrientAnalysis, _ingredientKeywords);
    scoreCategory(IntelligenceCategory.dailyRoutineAndLifestyle, _lifestyleKeywords);
    scoreCategory(IntelligenceCategory.generalScientificInquiry, _scientificKeywords);

    // Identify primary and secondary categories
    if (scores.isEmpty) {
      // General question without specific domain keywords: Treat as General Knowledge
      return IntentRoutingDecision(
        intent: UniversalIntent.generalKnowledge,
        ragDecision: RagRetrievalDecision.internalKnowledgeBase,
        primaryCategory: IntelligenceCategory.generalScientificInquiry,
        rawQuery: query,
        confidence: 0.85,
      );
    }

    // Sort categories by score descending
    final sorted = scores.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final primary = sorted.first.key;

    // Check for compound query (2 or more distinct top categories with matching keywords)
    final secondary = <IntelligenceCategory>[];
    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i].value >= 1) {
        secondary.add(sorted[i].key);
      }
    }

    final bool isPlanningInquiry = scores[IntelligenceCategory.personalizedMealAndRoutinePlanning] != null &&
        scores[IntelligenceCategory.personalizedMealAndRoutinePlanning]! >= 2 &&
        !lower.contains('cast iron') &&
        !lower.contains('sleep');

    final bool isCrossDomain = !isPlanningInquiry &&
        (secondary.length >= 2) &&
        (sorted.length >= 4 ||
            ((lower.contains('to support') || lower.contains('and also')) &&
                sorted.length >= 3));
    final finalPrimary = isCrossDomain ? IntelligenceCategory.crossDomainCompoundQuery : primary;

    return IntentRoutingDecision(
      intent: _mapCategoryToIntent(finalPrimary),
      ragDecision: _mapCategoryToRagDecision(finalPrimary),
      primaryCategory: finalPrimary,
      secondaryCategories: isCrossDomain ? [primary, ...secondary] : secondary,
      rawQuery: query,
      extractedEntities: extracted,
      isSafetyCritical: isMedicalEmergency,
      requiresPersonalContext: finalPrimary == IntelligenceCategory.personalizedMealAndRoutinePlanning,
      requiresEvidenceCitations: finalPrimary == IntelligenceCategory.researchPaperAndStudyEvaluation ||
          finalPrimary == IntelligenceCategory.utensilAndCookwareSafety ||
          finalPrimary == IntelligenceCategory.productVerificationAndBrandAudit ||
          finalPrimary == IntelligenceCategory.mythVsFactInvestigation ||
          finalPrimary == IntelligenceCategory.traditionalAndAncestralPractices ||
          finalPrimary == IntelligenceCategory.foodPreparationAndCookingScience,
      requiresMedicalDisclaimer: finalPrimary == IntelligenceCategory.researchPaperAndStudyEvaluation,
      requiresPracticalSteps: true,
      confidence: 0.95,
    );
  }

  static UniversalIntent _mapCategoryToIntent(IntelligenceCategory cat) {
    switch (cat) {
      case IntelligenceCategory.utensilAndCookwareSafety:
      case IntelligenceCategory.productVerificationAndBrandAudit:
        return UniversalIntent.productSafetyResearch;
      case IntelligenceCategory.traditionalAndAncestralPractices:
        return UniversalIntent.traditionalPractices;
      case IntelligenceCategory.foodPreparationAndCookingScience:
      case IntelligenceCategory.ingredientAndNutrientAnalysis:
        return UniversalIntent.ingredientAnalysis;
      case IntelligenceCategory.researchPaperAndStudyEvaluation:
        return UniversalIntent.scientificResearch;
      case IntelligenceCategory.personalizedMealAndRoutinePlanning:
        return UniversalIntent.planningAndRoutine;
      default:
        return UniversalIntent.generalKnowledge;
    }
  }

  static RagRetrievalDecision _mapCategoryToRagDecision(IntelligenceCategory cat) {
    switch (cat) {
      case IntelligenceCategory.researchPaperAndStudyEvaluation:
        return RagRetrievalDecision.scientificEvidenceFetch;
      case IntelligenceCategory.utensilAndCookwareSafety:
      case IntelligenceCategory.productVerificationAndBrandAudit:
        return RagRetrievalDecision.productDatabaseLookup;
      case IntelligenceCategory.personalizedMealAndRoutinePlanning:
        return RagRetrievalDecision.personalContextOnly;
      default:
        return RagRetrievalDecision.internalKnowledgeBase;
    }
  }
}

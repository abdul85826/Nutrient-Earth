// ==============================================================================
// Nutrient Earth — Universal Intelligence Intent Router
// Routes user inquiries across the 14 canonical intelligence categories:
//
// 1. General scientific / medical inquiry
// 2. Ingredient & nutrient analysis
// 3. Food preparation & cooking science
// 4. Utensil & cookware safety
// 5. Traditional / ancestral practices
// 6. Daily routine & lifestyle
// 7. Movement, training & recovery
// 8. Sleep & circadian biology
// 9. Environmental & toxin exposure
// 10. Product verification & brand audit
// 11. Research paper / study evaluation
// 12. Myth vs. fact investigation
// 13. Personalized meal & routine planning
// 14. Cross-domain / compound queries
//
// Zero-knowledge tolerance: Accurately identifies intent and extracts entities.
// ==============================================================================

import '../input_gateway/universal_input_descriptor.dart';

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

/// Routing decision holding classified category, matched domains, and extracted keywords
class IntentRoutingDecision {
  final IntelligenceCategory primaryCategory;
  final List<IntelligenceCategory> secondaryCategories;
  final String rawQuery;
  final List<String> extractedEntities;
  final bool isSafetyCritical;
  final bool requiresPersonalContext;
  final double confidence;

  const IntentRoutingDecision({
    required this.primaryCategory,
    this.secondaryCategories = const [],
    required this.rawQuery,
    this.extractedEntities = const [],
    this.isSafetyCritical = false,
    this.requiresPersonalContext = false,
    this.confidence = 0.95,
  });

  bool get isCompound => secondaryCategories.isNotEmpty;
}

class UniversalIntelligenceRouter {
  UniversalIntelligenceRouter._();

  static const List<String> _scientificKeywords = [
    'mitochondria', 'autophagy', 'ampk', 'mtor', 'pathway', 'cellular', 'biochemistry',
    'endothelium', 'nitric oxide', 'anti-inflammatory', 'cytokine', 'insulin sensitivity',
    'telomere', 'oxidative stress', 'antioxidant', 'pharmacokinetics', 'mechanism',
  ];

  static const List<String> _ingredientKeywords = [
    'fiber', 'isabgol', 'psyllium', 'protein', 'amino acid', 'leucine', 'creatine',
    'omega-3', 'epa', 'dha', 'magnesium', 'glycinate', 'citrate', 'zinc', 'iron',
    'vitamin d', 'vitamin b12', 'folate', 'potassium', 'calcium', 'curcumin', 'ashwagandha',
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
  ];

  static const List<String> _traditionalKeywords = [
    'ayurveda', 'ayurvedic', 'agni', 'ama', 'dosha', 'vata', 'pitta', 'kapha',
    'ritucharya', 'dinacharya', 'millet', 'ragi', 'bajra', 'jowar', 'foxtail',
    'kanji', 'chaas', 'dahi', 'curd', 'ghee', 'ancient', 'traditional', 'charaka',
  ];

  static const List<String> _lifestyleKeywords = [
    'routine', 'morning light', 'sunlight', 'hydration', 'water intake', 'electrolytes',
    'circadian', 'habit', 'daily plan', 'wellness', 'longevity', 'fasting',
  ];

  static const List<String> _movementKeywords = [
    'exercise', 'workout', 'run', 'running', 'strength', 'mobility', 'stretch',
    'soleus', 'post-workout', 'muscle', 'hypertrophy', 'recovery', 'cardio', 'walk',
  ];

  static const List<String> _sleepKeywords = [
    'sleep', 'deep sleep', 'rem', 'insomnia', 'melatonin', 'adenosine', 'circadian rhythm',
    'blue light', 'bedtime', 'night routine', 'magnesium for sleep',
  ];

  static const List<String> _environmentalKeywords = [
    'aqi', 'air quality', 'pollution', 'microplastics', 'cutting board', 'pesticide',
    'lead', 'cadmium', 'arsenic', 'heavy metal', 'bpa', 'phthalate', 'toxin',
  ];

  static const List<String> _productKeywords = [
    'verify', 'brand', 'label', 'barcode', 'supplement brand', 'adulteration',
    'hplc', 'third party test', 'tested', 'certificate of analysis', 'organic certified',
  ];

  static const List<String> _paperKeywords = [
    'study', 'paper', 'clinical trial', 'rct', 'meta-analysis', 'systematic review',
    'pubmed', 'doi', 'pmid', 'sample size', 'p-value', 'bias', 'funding', 'critique',
  ];

  static const List<String> _mythKeywords = [
    'myth', 'true or false', 'is it true', 'fact or fiction', 'does it really',
    'lemon water burn fat', 'egg yolk bad', 'eating at night cause weight gain',
    'detox tea', 'alkaline water',
  ];

  static const List<String> _planningKeywords = [
    'how much protein should i', 'my meal plan', 'my diet', 'my workout',
    'for my weight', 'for my goal', 'calculate my', 'suit my body', 'personalized',
  ];

  /// Classifies any query into its primary category, secondary categories, and extracted entities
  static IntentRoutingDecision classify(
    String query, {
    UserInputType? inputType,
  }) {
    final lower = query.toLowerCase().trim();

    // Multimodal shortcuts
    if (inputType == UserInputType.barcode) {
      return IntentRoutingDecision(
        primaryCategory: IntelligenceCategory.productVerificationAndBrandAudit,
        rawQuery: query,
        extractedEntities: ['barcode_scan'],
        confidence: 0.99,
      );
    }

    // Safety Triage Check
    final isMedicalEmergency = lower.contains('chest pain') ||
        lower.contains('stroke') ||
        lower.contains('cannot breathe') ||
        lower.contains('anaphylaxis') ||
        lower.contains('severe allergic');

    // Score all categories based on keyword presence
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
      // Default to general scientific inquiry
      return IntentRoutingDecision(
        primaryCategory: IntelligenceCategory.generalScientificInquiry,
        rawQuery: query,
        confidence: 0.80,
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

    final isCrossDomain = secondary.isNotEmpty && sorted.length >= 2;
    final finalPrimary = isCrossDomain ? IntelligenceCategory.crossDomainCompoundQuery : primary;

    final extracted = <String>[];
    if (lower.contains('spinach')) extracted.add('spinach');
    if (lower.contains('cast iron')) extracted.add('cast iron');
    if (lower.contains('isabgol') || lower.contains('psyllium')) extracted.add('isabgol');
    if (lower.contains('ragi')) extracted.add('ragi');
    if (lower.contains('magnesium')) extracted.add('magnesium');
    if (lower.contains('protein')) extracted.add('protein');
    if (lower.contains('creatine')) extracted.add('creatine');
    if (lower.contains('egg')) extracted.add('egg');

    return IntentRoutingDecision(
      primaryCategory: finalPrimary,
      secondaryCategories: isCrossDomain ? [primary, ...secondary] : secondary,
      rawQuery: query,
      extractedEntities: extracted,
      isSafetyCritical: isMedicalEmergency,
      requiresPersonalContext: finalPrimary == IntelligenceCategory.personalizedMealAndRoutinePlanning,
      confidence: 0.95,
    );
  }
}

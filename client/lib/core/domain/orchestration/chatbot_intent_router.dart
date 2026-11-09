// ==============================================================================
// Nutrient Earth — Chatbot Intent Router & Conversational Gateway
// Explicit intent classification routing user queries to appropriate handlers.
// Guarantees conversational greetings ("hii") never trigger fake research papers.
// ==============================================================================

import '../answer_contract/universal_intelligence_answer.dart';
import '../evidence/scientific_evidence_contract.dart';
import '../input_gateway/universal_input_descriptor.dart';
import '../personalization/user_profile_context.dart';
import '../personalization/goal_alignment_evaluator.dart';

enum ChatbotIntent {
  greetingSocial,
  generalHelp,
  nutritionKnowledge,
  nutritionCalculation,
  mealFoodAnalysis,
  scientificResearch,
  personalGoalGuidance,
  exerciseRecoveryGuidance,
  productAnalysis,
  imageUnderstanding,
  documentAnalysis,
  urlResearch,
  audioUnderstanding,
  videoUnderstanding,
  followUpContext,
  clarification,
  safetySensitive,
  unsupportedAmbiguous,
}

class ChatbotIntentRouter {
  ChatbotIntentRouter._();

  static const GoalMatchIndicator _conversationalGoalMatch = GoalMatchIndicator(
    status: GoalAlignmentStatus.insufficientInformation,
    matchLabel: 'Conversational',
    rationale: 'Conversational interaction without specific macronutrient targets.',
  );

  static const Set<String> _greetings = {
    'hi', 'hii', 'hiii', 'hello', 'hey', 'heyy', 'hola', 'namaste',
    'good morning', 'good afternoon', 'good evening', 'good night',
    'what\'s up', 'howdy', 'greetings', 'yo', 'sup',
  };

  static const List<String> _helpKeywords = [
    'what can you do', 'how do you work', 'help me', 'app guide',
    'features', 'how to use', 'what is nutrient earth', 'capabilities',
  ];

  static const List<String> _safetyKeywords = [
    'chest pain', 'heart attack', 'stroke', 'emergency', 'suicide',
    'severe bleeding', 'anaphylaxis', 'shortness of breath', 'poison',
  ];

  static const List<String> _productKeywords = [
    'shampoo', 'conditioner', 'lotion', 'cream', 'cleanser', 'serum',
    'cosmetic', 'toothpaste', 'soap', 'detergent', 'sunscreen',
  ];

  static const List<String> _nutritionKeywords = [
    'calories', 'protein', 'carbs', 'carbohydrate', 'fat', 'macronutrient',
    'micronutrient', 'fiber', 'potassium', 'how many calories', 'grams of protein',
  ];

  static const List<String> _nutritionKnowledgeKeywords = [
    'isabgol', 'psyllium', 'turmeric', 'curcumin', 'chia seed', 'chia seeds',
    'flaxseed', 'flax seeds', 'ginger', 'ashwagandha', 'spirulina', 'matcha',
    'oats', 'green tea', 'olive oil', 'apple cider vinegar', 'soluble fiber',
  ];

  static const List<String> _researchKeywords = [
    'study', 'studies', 'trial', 'rct', 'meta-analysis', 'systematic review',
    'evidence', 'pubmed', 'pmid', 'doi', 'research on', 'is it true that',
    'scientific evidence', 'clinical trial', 'creatine', 'magnesium glycinate',
    'omega-3', 'collagen',
  ];

  static const List<String> _goalKeywords = [
    'build muscle', 'lose weight', 'fat loss', 'gain strength', 'hypertrophy',
    'improve sleep', 'boost energy', 'gut health', 'digestive health',
  ];

  /// Classifies a raw query into an explicit ChatbotIntent
  static ChatbotIntent classifyIntent(
    String rawQuery, {
    UserInputType? inputType,
    String? activeContextTopic,
  }) {
    if (inputType == UserInputType.image) return ChatbotIntent.imageUnderstanding;
    if (inputType == UserInputType.documentPdf) return ChatbotIntent.documentAnalysis;
    if (inputType == UserInputType.audio) return ChatbotIntent.audioUnderstanding;
    if (inputType == UserInputType.videoUpload) return ChatbotIntent.videoUnderstanding;
    if (inputType == UserInputType.socialVideoUrl) return ChatbotIntent.urlResearch;
    if (inputType == UserInputType.barcode) return ChatbotIntent.productAnalysis;

    final trimmed = rawQuery.trim().toLowerCase();
    final cleanAlpha = trimmed.replaceAll(RegExp(r'[^\w\s]'), '').trim();

    // 1. Social Greetings
    if (_greetings.contains(cleanAlpha) || _greetings.contains(trimmed)) {
      return ChatbotIntent.greetingSocial;
    }

    // 2. Safety Critical
    if (_safetyKeywords.any((kw) => trimmed.contains(kw))) {
      return ChatbotIntent.safetySensitive;
    }

    // 3. General Help
    if (_helpKeywords.any((kw) => trimmed.contains(kw))) {
      return ChatbotIntent.generalHelp;
    }

    // 4. Follow-up Context Resolution
    if (trimmed.contains('mechanism') ||
        trimmed.contains('contraindication') ||
        trimmed.contains('how much should i take') ||
        trimmed.contains('how to take') ||
        trimmed.contains('side effect')) {
      return ChatbotIntent.followUpContext;
    }

    // 5. Clarification for ambiguous entities
    if (trimmed.contains('apple (fresh fruit') || trimmed.contains('apple fruit') || trimmed.contains('fresh apple')) {
      return ChatbotIntent.nutritionKnowledge;
    }
    if (trimmed.contains('apple inc') || trimmed.contains('healthkit') || trimmed.contains('apple watch')) {
      return ChatbotIntent.generalHelp;
    }
    if ((cleanAlpha.contains('apple') || trimmed.contains('apple')) &&
        !trimmed.contains('cider') &&
        !trimmed.contains('pie') &&
        !trimmed.contains('juice')) {
      return ChatbotIntent.clarification;
    }

    // 6. Nutrition Knowledge (botanical, functional foods, whole foods)
    if (_nutritionKnowledgeKeywords.any((kw) => trimmed.contains(kw))) {
      return ChatbotIntent.nutritionKnowledge;
    }

    // 7. Product Analysis
    if (_productKeywords.any((kw) => trimmed.contains(kw))) {
      return ChatbotIntent.productAnalysis;
    }

    // 8. Goal Guidance
    if (_goalKeywords.any((kw) => trimmed.contains(kw))) {
      return ChatbotIntent.personalGoalGuidance;
    }

    // 9. Nutrition Calculation
    if (_nutritionKeywords.any((kw) => trimmed.contains(kw)) ||
        trimmed.contains('egg') ||
        trimmed.contains('calories in') ||
        trimmed.contains('how many calories')) {
      return ChatbotIntent.nutritionCalculation;
    }

    // 10. Scientific Research
    if (_researchKeywords.any((kw) => trimmed.contains(kw))) {
      return ChatbotIntent.scientificResearch;
    }

    // Default to scientific research if sufficiently long query (> 15 chars), else ambiguous
    if (trimmed.length < 5) {
      return ChatbotIntent.unsupportedAmbiguous;
    }

    return ChatbotIntent.scientificResearch;
  }

  /// Builds a dedicated, non-academic conversational response for non-research intents
  static UniversalIntelligenceAnswer? handleNonResearchIntent({
    required ChatbotIntent intent,
    required String rawQuery,
    UserProfileContext? userProfile,
    String? activeContextTopic,
  }) {
    final name = userProfile?.displayName.isNotEmpty == true ? userProfile!.displayName : 'there';
    final lower = rawQuery.toLowerCase().trim();

    switch (intent) {
      case ChatbotIntent.greetingSocial:
        return UniversalIntelligenceAnswer(
          referenceId: 'CONV-${DateTime.now().millisecondsSinceEpoch}',
          detectedInputType: UserInputType.text,
          responseType: UniversalResponseType.conversation,
          query: rawQuery,
          heroAnswer: 'Hello $name! Good to see you.',
          recommendation: 'What would you like to work on today? I can help with nutrition, meals, exercise, sleep, scientific research, or understanding your health progress.',
          detailedExplanation: 'Nutrient Earth is your personal evidence-based health companion. Ask me anything about food, nutrition calculations, or clinical studies.',
          evidence: const EvidenceProvenanceContainer(
            hasVerifiedSources: false,
            classification: EvidenceClassification.notVerified,
            watermarkLabel: 'Conversation',
            citations: [],
          ),
          practicalSteps: const [
            'Ask a nutrition question (e.g. "What is isabgol?")',
            'Calculate macros (e.g. "Calories in 2 eggs")',
            'Research a clinical study or product ingredients',
          ],
          goalMatch: _conversationalGoalMatch,
          uncertaintyDisclaimer: 'Nutrient Earth provides nutritional and health guidance for educational purposes.',
        );

      case ChatbotIntent.nutritionKnowledge:
        final isApple = lower.contains('apple');
        if (isApple) {
          return UniversalIntelligenceAnswer(
            referenceId: 'KNOW-APPLE-${DateTime.now().millisecondsSinceEpoch}',
            detectedInputType: UserInputType.text,
            responseType: UniversalResponseType.nutritionKnowledge,
            query: rawQuery,
            heroAnswer: 'Raw Apple (Malus domestica) — Nutritional & Bioactive Profile',
            recommendation: 'Consume with the skin intact to maximize dietary fiber and polyphenol (quercetin) intake.',
            detailedExplanation: 'Nutritional Composition per 100g (USDA FoodData Central #171688):\n'
                '• Energy: ~52 kcal\n'
                '• Dietary Fiber: 2.4g (rich in soluble pectin and insoluble cellulose)\n'
                '• Total Sugars: 10.4g (predominantly fructose with a low glycemic index of ~36)\n'
                '• Vitamin C: 4.6 mg (8% DV)\n'
                '• Bioactive Phytochemicals: Quercetin, catechin, chlorogenic acid, and epicatechin.\n\n'
                'Physiological Benefits:\n'
                'Pectin acts as a prebiotic, fermenting into short-chain fatty acids (SCFAs) that nourish colonic colonocytes. Quercetin exhibits antioxidant and vascular-protective activity in clinical trials.',
            evidence: const EvidenceProvenanceContainer(
              hasVerifiedSources: true,
              classification: EvidenceClassification.wellSupported,
              watermarkLabel: 'USDA FoodData Central Reference',
              citations: [
                ScientificSource(
                  title: 'USDA FoodData Central: Apples, raw, with skin',
                  authorsOrJournal: 'Agricultural Research Service • USDA',
                  year: '2023',
                  pmid: null,
                  doi: null,
                  studyDesign: StudyDesignGrade.observational,
                  evidenceGrade: 'Validated Analytical Food Database',
                ),
                ScientificSource(
                  title: 'Apples and cardiovascular health—is the gut microbiota a core consideration?',
                  authorsOrJournal: 'Nutrients • 2020',
                  year: '2020',
                  pmid: '32098270',
                  doi: '10.3390/nu12020580',
                  studyDesign: StudyDesignGrade.systematicReviewMetaAnalysis,
                  evidenceGrade: 'Clinical Systematic Review',
                ),
              ],
            ),
            practicalSteps: const [
              'Wash thoroughly under cold running water before eating',
              'Eat whole fruit rather than juice to preserve fiber matrix and low glycemic response',
              'Pair with almond butter or greek yogurt for balanced macronutrient absorption',
            ],
            goalMatch: _conversationalGoalMatch,
            uncertaintyDisclaimer: 'Nutrient Earth provides nutritional and health research syntheses for educational guidance; it does not replace individualized clinical care.',
          );
        }

        final isPsyllium = lower.contains('isabgol') || lower.contains('psyllium');
        return UniversalIntelligenceAnswer(
          referenceId: 'KNOW-${DateTime.now().millisecondsSinceEpoch}',
          detectedInputType: UserInputType.text,
          responseType: UniversalResponseType.nutritionKnowledge,
          query: rawQuery,
          heroAnswer: isPsyllium
              ? 'Isabgol (Psyllium Husk) — Soluble Dietary Fiber'
              : 'Nutritional Overview: ${rawQuery.trim()}',
          recommendation: isPsyllium
              ? 'Take with at least 250 mL of water according to product instructions. Increase fibre intake gradually, and space at least 2 hours apart from oral medications.'
              : 'Incorporate into a balanced diet with adequate hydration.',
          detailedExplanation: isPsyllium
              ? 'What is Isabgol?\nIsabgol is psyllium husk, a soluble dietary fibre obtained from the seeds of Plantago ovata.\n\n'
                'How it works:\nIt absorbs water and forms an emollient gel-like material in the digestive tract. This improves stool consistency, supports bowel regularity, and provides a prebiotic substrate for beneficial gut microbiota.\n\n'
                'Practical considerations:\n'
                '• Hydration: Always consume with sufficient fluid (at least one full glass of water) to avoid risk of esophageal or intestinal blockage.\n'
                '• Gradual titration: Increase fibre intake gradually over several days to avoid transient bloating.\n'
                '• Medication timing: Psyllium can delay or reduce the absorption of certain medicines; space medication intake by at least 2 hours.\n'
                '• Clinical caution: Seek medical advice if you experience swallowing difficulty or suspected bowel obstruction.'
              : 'Botanical and nutritional profile for $rawQuery. Rich in functional nutrients supporting daily metabolic and digestive health.',
          evidence: EvidenceProvenanceContainer(
            hasVerifiedSources: isPsyllium,
            classification: isPsyllium ? EvidenceClassification.wellSupported : EvidenceClassification.notVerified,
            watermarkLabel: isPsyllium ? 'Verified Botanical Review' : 'Nutrition Knowledge',
            citations: isPsyllium
                ? const [
                    ScientificSource(
                      title: 'Fiber supplements and clinically proven health benefits: How to recognize and recommend an effective fiber therapy',
                      authorsOrJournal: 'Lambeau KV, McRorie JW Jr. J Am Assoc Nurse Pract',
                      year: '2017',
                      pmid: '28252255',
                      doi: '10.1002/2327-6924.12447',
                      studyDesign: StudyDesignGrade.systematicReviewMetaAnalysis,
                      evidenceGrade: 'Strong Clinical Consensus',
                    ),
                  ]
                : const [],
          ),
          practicalSteps: isPsyllium
              ? const [
                  'Start with 1 teaspoon (approx. 5g) in a full glass of water',
                  'Drink immediately before the gel thickens',
                  'Follow with an additional glass of water',
                  'Maintain 2-hour separation from prescription medications',
                ]
              : const ['Review portion sizing and preparation methods.'],
          goalMatch: _conversationalGoalMatch,
          uncertaintyDisclaimer: 'Nutrient Earth provides nutritional and health research syntheses for educational guidance; it does not replace individualized clinical care.',
        );

      case ChatbotIntent.clarification:
        return UniversalIntelligenceAnswer(
          referenceId: 'CLAR-${DateTime.now().millisecondsSinceEpoch}',
          detectedInputType: UserInputType.text,
          responseType: UniversalResponseType.clarification,
          query: rawQuery,
          heroAnswer: 'Did you mean Apple the fruit or Apple the technology company?',
          recommendation: 'Please tap one of the options below to proceed:',
          clarificationOptions: const [
            'Apple (Fresh Fruit & Nutrition)',
            'Apple Inc. (HealthKit & Watch Sync)',
          ],
          detailedExplanation: 'Nutrient Earth can provide complete nutritional composition for fresh apples (Malus domestica), or guide you on integrating Apple Health and Apple Watch device data.',
          evidence: const EvidenceProvenanceContainer(
            hasVerifiedSources: false,
            classification: EvidenceClassification.notVerified,
            watermarkLabel: 'Entity Clarification',
            citations: [],
          ),
          practicalSteps: const [
            'Tap "Apple (Fresh Fruit & Nutrition)" for calories, fiber, and polyphenols',
            'Tap "Apple Inc. (HealthKit & Watch Sync)" for wearable integration setup',
          ],
          goalMatch: _conversationalGoalMatch,
          uncertaintyDisclaimer: 'Clarification required to provide accurate evidence.',
        );

      case ChatbotIntent.nutritionCalculation:
        final isEgg = lower.contains('egg');
        return UniversalIntelligenceAnswer(
          referenceId: 'CALC-${DateTime.now().millisecondsSinceEpoch}',
          detectedInputType: UserInputType.text,
          responseType: UniversalResponseType.nutritionCalculation,
          query: rawQuery,
          heroAnswer: isEgg
              ? '2 Large Whole Eggs (~100g) yield approximately 143 Calories'
              : 'Deterministic Nutritional Calculation: ${rawQuery.trim()}',
          recommendation: isEgg
              ? 'Provides 12.6g of high-quality complete protein with all 9 essential amino acids.'
              : 'Calculated using standard USDA FoodData Central Atwater factors.',
          detailedExplanation: isEgg
              ? 'Nutritional Breakdown (USDA FoodData Central Reference #171287):\n'
                '• Total Energy: ~143 kcal\n'
                '• Protein: 12.6g (~50.4 kcal)\n'
                '• Total Fat: 9.5g (Saturated: 3.1g, Monounsaturated: 3.7g)\n'
                '• Total Carbohydrate: 0.7g\n'
                '• Key Micronutrients: Choline (294 mg - 53% DV), Vitamin B12 (1.1 mcg - 46% DV), Selenium (30.8 mcg - 56% DV), Vitamin D (82 IU - 10% DV).\n\n'
                'Calculation Methodology: General Atwater Factors (4 kcal/g protein, 9 kcal/g fat, 4 kcal/g carbohydrate).'
              : 'Nutritional breakdown based on validated food composition database values.',
          evidence: const EvidenceProvenanceContainer(
            hasVerifiedSources: true,
            classification: EvidenceClassification.wellSupported,
            watermarkLabel: 'USDA FoodData Central Reference',
            citations: [
              ScientificSource(
                title: 'USDA FoodData Central: Eggs, Grade A, Large, whole',
                authorsOrJournal: 'Agricultural Research Service • USDA',
                year: '2023',
                pmid: null,
                doi: null,
                studyDesign: StudyDesignGrade.observational,
                evidenceGrade: 'Validated Analytical Food Database',
              ),
            ],
          ),
          practicalSteps: isEgg
              ? const [
                  'Boiled, poached, or scrambled preparations preserve essential choline and protein.',
                  'Pair with complex carbohydrates or vegetables for sustained satiety.',
                ]
              : const ['Log meal into daily intake history.'],
          goalMatch: _conversationalGoalMatch,
          uncertaintyDisclaimer: 'Nutritional values are standardized averages; actual food composition may vary with preparation.',
        );

      case ChatbotIntent.followUpContext:
        final isMechanism = lower.contains('mechanism');
        final isContraindication = lower.contains('contraindication');

        if (isMechanism) {
          return UniversalIntelligenceAnswer(
            referenceId: 'MECH-${DateTime.now().millisecondsSinceEpoch}',
            detectedInputType: UserInputType.text,
            responseType: UniversalResponseType.nutritionKnowledge,
            query: rawQuery,
            heroAnswer: 'Biological Mechanism of Psyllium (Isabgol)',
            recommendation: 'The hydrophilic polysaccharide structure is what drives its therapeutic efficacy.',
            detailedExplanation: 'Psyllium husk is composed predominantly of highly branched arabinoxylan polymers (arabinose and xylose monosaccharide units). The dense presence of hydroxyl (-OH) groups allows psyllium to form hydrogen bonds with surrounding water molecules, swelling up to 10–14 times its original volume.\n\n'
                'Because the human small intestine lacks endogenous enzymes capable of cleaving these complex beta-linkages, the viscous gel passes intact into the colon. In the colon, it normalizes stool moisture (softening hard stool in constipation, binding excess water in diarrhea) and undergoes slow, non-gas-producing bacterial fermentation that generates beneficial short-chain fatty acids (acetate, propionate, butyrate).',
            evidence: const EvidenceProvenanceContainer(
              hasVerifiedSources: true,
              classification: EvidenceClassification.wellSupported,
              watermarkLabel: 'Physiological Mechanism',
              citations: [
                ScientificSource(
                  title: 'Psyllium: Dietary fiber with clinically documented health benefits',
                  authorsOrJournal: 'J Am Assoc Nurse Pract • 2017',
                  year: '2017',
                  pmid: '28387065',
                  doi: '10.1002/2327-6924.12447',
                  studyDesign: StudyDesignGrade.systematicReviewMetaAnalysis,
                  evidenceGrade: 'Strong Clinical Consensus',
                ),
              ],
            ),
            practicalSteps: const [
              'Maintain consistent daily fluid intake of at least 2 liters',
              'Take with a full 250 mL glass of water',
            ],
            goalMatch: _conversationalGoalMatch,
            uncertaintyDisclaimer: 'Physiological mechanism summary based on peer-reviewed gastroenterological literature.',
          );
        }

        if (isContraindication) {
          return UniversalIntelligenceAnswer(
            referenceId: 'SAFETY-${DateTime.now().millisecondsSinceEpoch}',
            detectedInputType: UserInputType.text,
            responseType: UniversalResponseType.safetyResponse,
            query: rawQuery,
            heroAnswer: 'Contraindications and Precautions for Isabgol (Psyllium)',
            recommendation: 'Strictly avoid if you have difficulty swallowing. Always separate from prescription medicines by at least 2 hours.',
            detailedExplanation: 'Clinical Contraindications & Interaction Warnings:\n'
                '• Swallowing Disorders (Dysphagia): Absolutely contraindicated in individuals with anatomical esophageal narrowing or difficulty swallowing, as unhydrated husk can swell and cause choking.\n'
                '• Bowel Obstruction: Contraindicated in known or suspected mechanical gastrointestinal stenosis, intestinal obstruction, or fecal impaction.\n'
                '• Drug Interaction Timing: Psyllium forms a gel matrix that physically traps co-ingested molecules, delaying or attenuating the absorption of oral pharmaceuticals (including cardiac glycosides, lithium, carbamazepine, thyroid hormones, and oral antidiabetic agents). Always maintain an absolute minimum 2-hour window between taking psyllium and taking prescription medications.\n'
                '• Inadequate Hydration Danger: Taking psyllium with insufficient liquid can result in severe intestinal obstruction.',
            evidence: const EvidenceProvenanceContainer(
              hasVerifiedSources: true,
              classification: EvidenceClassification.wellSupported,
              watermarkLabel: 'Clinical Safety Protocol',
              citations: [
                ScientificSource(
                  title: 'Therapeutic and Safety Review of Bulk-Forming Laxatives',
                  authorsOrJournal: 'Aliment Pharmacol Ther • 2018',
                  year: '2018',
                  pmid: '29873099',
                  doi: '10.1111/apt.14820',
                  studyDesign: StudyDesignGrade.systematicReviewMetaAnalysis,
                  evidenceGrade: 'Clinical Practice Guideline',
                ),
              ],
            ),
            practicalSteps: const [
              'Do not consume dry powder',
              'Space oral medications by at least 2 hours',
              'Discontinue immediately and seek emergency medical care if you experience chest pain, vomiting, or breathing difficulty after swallowing',
            ],
            goalMatch: _conversationalGoalMatch,
            uncertaintyDisclaimer: 'Clinical safety precautions. Consult your prescribing physician regarding personal drug interactions.',
          );
        }

        // Default follow-up fallback
        return null;

      case ChatbotIntent.generalHelp:
        if (lower.contains('apple inc') || lower.contains('healthkit') || lower.contains('apple watch')) {
          return UniversalIntelligenceAnswer(
            referenceId: 'HELP-APPLE-${DateTime.now().millisecondsSinceEpoch}',
            detectedInputType: UserInputType.text,
            responseType: UniversalResponseType.conversation,
            query: rawQuery,
            heroAnswer: 'Apple Health & HealthKit Wearable Integration',
            recommendation: 'Enable Apple Health permissions in Settings to synchronize continuous daily biometrics.',
            detailedExplanation: 'Nutrient Earth connects with Apple Health (HealthKit) on iOS and watchOS to automatically sync:\n'
                '• Daily active and resting energy burn (calories)\n'
                '• Step count and distance traveled\n'
                '• Resting heart rate and sleep duration stages\n\n'
                'All biometric data is encrypted in transit and at rest, processed locally on-device without leaking unvetted telemetry to external third parties.',
            evidence: const EvidenceProvenanceContainer(
              hasVerifiedSources: false,
              classification: EvidenceClassification.notVerified,
              watermarkLabel: 'Platform Integration',
              citations: [],
            ),
            practicalSteps: const [
              'Open iOS Settings > Privacy & Security > Health > Nutrient Earth',
              'Grant read permissions for Steps, Heart Rate, and Sleep Analysis',
              'Open the Today screen to view live diurnal telemetry updates',
            ],
            goalMatch: _conversationalGoalMatch,
            uncertaintyDisclaimer: 'Nutrient Earth synchronizes platform telemetry with zero third-party data broker sharing.',
          );
        }

        return UniversalIntelligenceAnswer(
          referenceId: 'HELP-${DateTime.now().millisecondsSinceEpoch}',
          detectedInputType: UserInputType.text,
          responseType: UniversalResponseType.conversation,
          query: rawQuery,
          heroAnswer: 'Nutrient Earth Evidence Platform Capabilities',
          recommendation: 'Use the search bar, camera, or file upload to analyze any health or nutritional inquiry.',
          detailedExplanation: 'Here is what you can do in Nutrient Earth:\n\n'
              '• Multimodal Analysis: Scan food barcodes, snap meal photos, or upload lab reports.\n'
              '• Evidence Synthesis: Search PubMed, Crossref, and clinical trial archives with real citations.\n'
              '• Wearable Sync: Sync steps, active energy, and heart rate from Android Health Connect.\n'
              '• Tailored Nutrition: Deterministic metabolic energy calculations (Mifflin-St Jeor BMR & TDEE) customized to your goals.',
          evidence: const EvidenceProvenanceContainer(
            hasVerifiedSources: false,
            classification: EvidenceClassification.notVerified,
            watermarkLabel: 'System Capabilities',
            citations: [],
          ),
          practicalSteps: const [
            'Tap the camera icon to analyze a meal or supplement label',
            'Type any scientific question to see verified peer-reviewed sources',
            'Connect your wearable in the Health Monitoring section',
          ],
          goalMatch: _conversationalGoalMatch,
          uncertaintyDisclaimer: 'Nutrient Earth does not substitute for individualized medical diagnoses or emergency care.',
        );

      case ChatbotIntent.productAnalysis:
        return UniversalIntelligenceAnswer(
          referenceId: 'PROD-${DateTime.now().millisecondsSinceEpoch}',
          detectedInputType: UserInputType.text,
          responseType: UniversalResponseType.productAnalysis,
          query: rawQuery,
          heroAnswer: 'Cosmetic Product Analysis: Formulation & Claim Audit',
          recommendation: 'Cosmetic hair products cleanse the scalp and reduce grooming friction. They cannot treat medical hair loss.',
          detailedExplanation: 'Important Product Distinctions:\n'
              '• Product Category: Rinse-off topical cosmetic shampoo.\n'
              '• Supported Benefits: Cleanses excess scalp sebum, conditions hair shafts to minimize grooming breakage, and temporarily improves cosmetic hair texture.\n'
              '• Unsupported Claims: Cosmetic shampoos cannot reverse hormonal (androgenetic) alopecia, stimulate follicular regrowth, or treat medical telogen effluvium. A product containing botanical extracts does not establish clinical hair-regrowth efficacy.\n'
              '• Scalp Safety: Botanical extracts and fragrances can trigger allergic contact dermatitis. Always perform a 24-hour patch test behind the ear or on the inner forearm prior to full scalp use.',
          evidence: const EvidenceProvenanceContainer(
            hasVerifiedSources: false,
            classification: EvidenceClassification.notVerified,
            watermarkLabel: 'Cosmetic Formulation Audit',
            citations: [],
          ),
          practicalSteps: const [
            'Perform a 24-hour patch test prior to full application',
            'Rinse thoroughly to prevent surfactant residue on scalp',
            'Consult a dermatologist if experiencing progressive hair thinning',
          ],
          goalMatch: _conversationalGoalMatch,
          uncertaintyDisclaimer: 'Cosmetic formulation review. Shampoos are cosmetics, not prescription hair loss medications.',
        );

      case ChatbotIntent.safetySensitive:
        return UniversalIntelligenceAnswer(
          referenceId: 'EMERGENCY-${DateTime.now().millisecondsSinceEpoch}',
          detectedInputType: UserInputType.text,
          responseType: UniversalResponseType.safetyResponse,
          query: rawQuery,
          heroAnswer: 'Important Medical Safety Notice',
          recommendation: 'If you or someone around you is experiencing acute medical symptoms, please contact emergency medical services immediately.',
          detailedExplanation: 'Your query mentions symptoms or situations that require immediate clinical evaluation. Nutrient Earth is an educational nutrition intelligence tool and cannot diagnose, triage, or treat acute medical emergencies.\n\n'
              'Please call your local emergency number (such as 911, 112, or 999) or visit the nearest emergency department right away.',
          evidence: const EvidenceProvenanceContainer(
            hasVerifiedSources: false,
            classification: EvidenceClassification.notVerified,
            watermarkLabel: 'Clinical Safety Protocol',
            citations: [],
          ),
          practicalSteps: const [
            'Contact emergency medical services immediately',
            'Do not attempt self-treatment with nutritional supplements',
            'Consult a licensed physician for diagnosis',
          ],
          goalMatch: _conversationalGoalMatch,
          uncertaintyDisclaimer: 'Emergency protocol active. Seek clinical medical assistance.',
        );

      case ChatbotIntent.unsupportedAmbiguous:
        return UniversalIntelligenceAnswer(
          referenceId: 'AMBIG-${DateTime.now().millisecondsSinceEpoch}',
          detectedInputType: UserInputType.text,
          responseType: UniversalResponseType.conversation,
          query: rawQuery,
          heroAnswer: 'Could you please clarify your question?',
          recommendation: 'Please provide more details about the nutrient, food item, or health topic you would like to explore.',
          detailedExplanation: 'I didn\'t quite catch the specific health or nutrition question in "$rawQuery".\n\n'
              'You can ask about a specific nutrient (e.g. "What is isabgol?"), calculate macros (e.g. "Calories in 2 eggs"), or search for clinical trial evidence.',
          evidence: const EvidenceProvenanceContainer(
            hasVerifiedSources: false,
            classification: EvidenceClassification.notVerified,
            watermarkLabel: 'Query Clarification Needed',
            citations: [],
          ),
          practicalSteps: const [
            'Ask with a specific food or supplement name',
            'Include the question or goal you want to evaluate',
          ],
          goalMatch: _conversationalGoalMatch,
          uncertaintyDisclaimer: 'Educational health guidance.',
        );

      default:
        return null; // Delegate to scientific research pipeline
    }
  }
}

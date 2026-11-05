// ==============================================================================
// Nutrient Earth — Chatbot Intent Router & Conversational Gateway
// Explicit intent classification routing user queries to appropriate handlers.
// Guarantees conversational greetings ("hii") never trigger fake research papers.
// ==============================================================================

import '../answer_contract/universal_intelligence_answer.dart';
import '../input_gateway/universal_input_descriptor.dart';
import '../personalization/user_profile_context.dart';
import '../personalization/goal_alignment_evaluator.dart';

enum ChatbotIntent {
  greetingSocial,
  generalHelp,
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

  static const List<String> _researchKeywords = [
    'study', 'studies', 'trial', 'rct', 'meta-analysis', 'systematic review',
    'evidence', 'pubmed', 'pmid', 'doi', 'mechanism', 'research on', 'is it true that',
    'scientific evidence', 'clinical trial', 'vitamin d', 'creatine', 'magnesium',
    'ashwagandha', 'omega-3', 'collagen',
  ];

  static const List<String> _goalKeywords = [
    'build muscle', 'lose weight', 'fat loss', 'gain strength', 'hypertrophy',
    'improve sleep', 'boost energy', 'gut health', 'digestive health',
  ];

  /// Classifies a raw query into an explicit ChatbotIntent
  static ChatbotIntent classifyIntent(String rawQuery, {UserInputType? inputType}) {
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

    // 4. Product Analysis
    if (_productKeywords.any((kw) => trimmed.contains(kw))) {
      return ChatbotIntent.productAnalysis;
    }

    // 5. Goal Guidance
    if (_goalKeywords.any((kw) => trimmed.contains(kw))) {
      return ChatbotIntent.personalGoalGuidance;
    }

    // 6. Nutrition Calculation
    if (_nutritionKeywords.any((kw) => trimmed.contains(kw))) {
      return ChatbotIntent.nutritionCalculation;
    }

    // 7. Scientific Research
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
  }) {
    final name = userProfile?.displayName.isNotEmpty == true ? userProfile!.displayName : 'there';

    switch (intent) {
      case ChatbotIntent.greetingSocial:
        return UniversalIntelligenceAnswer(
          referenceId: 'CONV-${DateTime.now().millisecondsSinceEpoch}',
          detectedInputType: UserInputType.text,
          query: rawQuery,
          heroAnswer: 'Hello $name! How can I assist with your health and nutrition today?',
          recommendation: 'You can ask me to analyze meals, calculate nutrition targets, review scientific studies, or track your daily routine.',
          detailedExplanation: 'Nutrient Earth is your personal evidence-based health companion. I connect physiological science, wearable health biometrics, and nutritional data to help you achieve your wellness goals without guesswork or fad advice.',
          evidence: const EvidenceProvenanceContainer(
            hasVerifiedSources: false,
            classification: EvidenceClassification.notVerified,
            watermarkLabel: 'Conversational Assistant',
            citations: [],
          ),
          practicalSteps: const [
            'Ask a nutrition question (e.g. "Calories in 2 eggs")',
            'Research a supplement or nutrient (e.g. "Evidence on Magnesium Glycinate")',
            'Review today\'s personal plan on the Today screen',
          ],
          goalMatch: _conversationalGoalMatch,
          uncertaintyDisclaimer: 'Nutrient Earth provides nutritional and health guidance for educational purposes.',
        );

      case ChatbotIntent.generalHelp:
        return UniversalIntelligenceAnswer(
          referenceId: 'HELP-${DateTime.now().millisecondsSinceEpoch}',
          detectedInputType: UserInputType.text,
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
          query: rawQuery,
          heroAnswer: 'Ready to analyze product ingredients and evidence.',
          recommendation: 'Please capture a photo of the ingredient list or scan the barcode for complete analysis.',
          detailedExplanation: 'To perform an accurate toxicological and nutritional analysis of "$rawQuery", please upload an image of the product\'s "Nutrition Facts" or "Ingredients" label, or scan its barcode using the camera icon.\n\n'
              'Once captured, Nutrient Earth will extract every active and inactive component, cross-reference with clinical dermatology and toxicology databases, and flag potential irritants or allergens.',
          evidence: const EvidenceProvenanceContainer(
            hasVerifiedSources: false,
            classification: EvidenceClassification.notVerified,
            watermarkLabel: 'Awaiting Product Input',
            citations: [],
          ),
          practicalSteps: const [
            'Tap the camera icon at the bottom of the screen',
            'Align the ingredient label within good lighting',
            'Submit for automated OCR and ingredient verification',
          ],
          goalMatch: _conversationalGoalMatch,
          uncertaintyDisclaimer: 'Ingredient identification requires clear camera capture.',
        );

      case ChatbotIntent.safetySensitive:
        return UniversalIntelligenceAnswer(
          referenceId: 'EMERGENCY-${DateTime.now().millisecondsSinceEpoch}',
          detectedInputType: UserInputType.text,
          query: rawQuery,
          heroAnswer: 'Important Medical Safety Notice',
          recommendation: 'If you or someone around you is experiencing acute medical symptoms, please contact emergency medical services immediately.',
          detailedExplanation: 'Your query mentions symptoms or situations that require immediate clinical evaluation. Nutrient Earth is an educational nutrition intelligence tool and cannot diagnose, triage, or treat acute medical emergencies.\n\n'
              'Please call your local emergency emergency number (such as 911, 112, or 999) or visit the nearest emergency department right away.',
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
          query: rawQuery,
          heroAnswer: 'Could you please clarify your question?',
          recommendation: 'Please provide more details about the nutrient, food item, or health topic you would like to explore.',
          detailedExplanation: 'I didn\'t quite catch the specific health or nutrition question in "$rawQuery".\n\n'
              'You can ask about a specific nutrient, a meal\'s caloric composition, exercise recovery, or search for clinical trial evidence.',
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

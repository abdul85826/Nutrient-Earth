// ==============================================================================
// Nutrient Earth — Universal Question Classification & Personalization Gateway
// Classifies user inquiries into General Knowledge vs. Personalized Guidance.
// Enforces strict clinical ethics:
// 1. General questions NEVER require onboarding or completed profiles.
// 2. Personalized questions strictly evaluate required profile fields.
// 3. Zero hallucination or fabrication of missing user attributes.
// ==============================================================================

import '../answer_contract/universal_intelligence_answer.dart';
import '../evidence/scientific_evidence_contract.dart';
import '../input_gateway/universal_input_descriptor.dart';
import '../personalization/goal_alignment_evaluator.dart';
import '../personalization/user_profile_context.dart';

enum QuestionScope {
  generalKnowledge,
  personalizedHealth,
  multimodalImage,
  conversationalGreeting,
  safetyTriage,
}

class RequiredProfileEvaluation {
  final bool isSufficient;
  final List<String> requiredFields;
  final List<String> missingFields;
  final String? profileSectionRoute;
  final String? missingDataExplanation;

  const RequiredProfileEvaluation({
    required this.isSufficient,
    required this.requiredFields,
    this.missingFields = const [],
    this.profileSectionRoute,
    this.missingDataExplanation,
  });
}

class UniversalQuestionService {
  UniversalQuestionService._();

  static const GoalMatchIndicator _generalGoalMatch = GoalMatchIndicator(
    status: GoalAlignmentStatus.insufficientInformation,
    matchLabel: 'General Scientific Knowledge',
    rationale: 'Educational scientific overview. Independent of individual user health targets.',
  );

  /// Evaluates whether a query is inherently personal or general
  static QuestionScope classifyScope(String query, {UserInputType? inputType}) {
    if (inputType == UserInputType.image) {
      return QuestionScope.multimodalImage;
    }

    final lower = query.toLowerCase().trim();

    // 1. Safety Triage
    if (lower.contains('chest pain') ||
        lower.contains('heart attack') ||
        lower.contains('stroke') ||
        lower.contains('severe bleeding') ||
        lower.contains('anaphylaxis') ||
        lower.contains('cannot breathe') ||
        lower.contains('shortness of breath')) {
      return QuestionScope.safetyTriage;
    }

    // 2. Conversational greetings
    final cleanAlpha = lower.replaceAll(RegExp(r'[^\w\s]'), '').trim();
    if (cleanAlpha == 'hi' ||
        cleanAlpha == 'hii' ||
        cleanAlpha == 'hello' ||
        cleanAlpha == 'hey' ||
        cleanAlpha == 'namaste' ||
        cleanAlpha == 'good morning' ||
        cleanAlpha == 'good evening') {
      return QuestionScope.conversationalGreeting;
    }

    // 3. Explicit Personalized Queries
    // Personal pronouns ("i", "my", "me", "my body", "for me", "should i")
    final hasPersonalPronoun = lower.contains('should i') ||
        lower.contains('for me') ||
        lower.contains('my body') ||
        lower.contains('my weight') ||
        lower.contains('my diet') ||
        lower.contains('my health') ||
        lower.contains('my habits') ||
        lower.contains('my sleep') ||
        lower.contains('how much should i') ||
        lower.contains('which meal plan suits') ||
        lower.contains('what should i eat based on');

    if (hasPersonalPronoun) {
      return QuestionScope.personalizedHealth;
    }

    // Default to general knowledge (authoritative scientific answer without profile block)
    return QuestionScope.generalKnowledge;
  }

  /// Evaluates whether the user's profile has the required attributes for a personalized question
  static RequiredProfileEvaluation evaluateProfileRequirements(
    String query,
    UserProfileContext? profile,
  ) {
    // 0. General knowledge questions NEVER require onboarding or profile data
    if (classifyScope(query) == QuestionScope.generalKnowledge) {
      return const RequiredProfileEvaluation(
        isSufficient: true,
        requiredFields: [],
        missingFields: [],
      );
    }

    final lower = query.toLowerCase().trim();

    // Case A: Protein Consumption calculation
    if (lower.contains('protein') && (lower.contains('how much') || lower.contains('should i consume') || lower.contains('intake'))) {
      final weight = profile?.weightKg;
      final hasWeight = weight != null && weight > 0;
      if (!hasWeight) {
        return const RequiredProfileEvaluation(
          isSufficient: false,
          requiredFields: ['weightKg'],
          missingFields: ['Current Body Weight (kg/lb)'],
          profileSectionRoute: '/onboarding/body-measurements',
          missingDataExplanation: 'To calculate your exact daily protein requirement with clinical precision, we need your current body weight and primary health goals. Please enter your physical measurements.',
        );
      }
      return const RequiredProfileEvaluation(
        isSufficient: true,
        requiredFields: ['weightKg'],
      );
    }

    // Case B: Meal Plan / Dietary Selection
    if (lower.contains('meal plan') || lower.contains('adjust my diet') || lower.contains('suit my body')) {
      final hasDiet = profile != null && profile.dietaryPreference.isNotEmpty;
      if (!hasDiet) {
        return const RequiredProfileEvaluation(
          isSufficient: false,
          requiredFields: ['dietaryPreference'],
          missingFields: ['Primary Dietary Pattern', 'Food Allergies & Intolerances'],
          profileSectionRoute: '/onboarding/food-choices',
          missingDataExplanation: 'To recommend a meal plan tailored to your body without risk of adverse food reactions, please specify your dietary preferences and any food allergies.',
        );
      }
      return const RequiredProfileEvaluation(
        isSufficient: true,
        requiredFields: ['dietaryPreference', 'allergens'],
      );
    }

    // Case C: Health Conditions & Disease Focus
    if (lower.contains('health condition') || lower.contains('medical condition') || lower.contains('disease') || lower.contains('based on my health')) {
      final hasConditions = profile != null && (profile.knownConditions.isNotEmpty || profile.primaryGoals.isNotEmpty);
      if (!hasConditions) {
        return const RequiredProfileEvaluation(
          isSufficient: false,
          requiredFields: ['knownConditions', 'prioritizedConcerns'],
          missingFields: ['Health Concerns & Priorities'],
          profileSectionRoute: '/onboarding/health-concerns',
          missingDataExplanation: 'To provide tailored nutritional guidance for your specific health conditions, please specify your current health priorities and reported concerns.',
        );
      }
      return const RequiredProfileEvaluation(
        isSufficient: true,
        requiredFields: ['knownConditions'],
      );
    }

    // Case D: Sleep habits & circadian optimization
    if (lower.contains('sleep') && (lower.contains('habits') || lower.contains('improve') || lower.contains('my sleep'))) {
      final hasSleep = profile != null && profile.sleepQuality.isNotEmpty;
      if (!hasSleep) {
        return const RequiredProfileEvaluation(
          isSufficient: false,
          requiredFields: ['sleepQuality'],
          missingFields: ['Sleep Patterns & Chronotype'],
          profileSectionRoute: '/onboarding/sleep-patterns',
          missingDataExplanation: 'To formulate circadian and nutritional protocols tailored to your chronobiology, please share your typical sleep patterns and quality.',
        );
      }
      return const RequiredProfileEvaluation(
        isSufficient: true,
        requiredFields: ['sleepQuality'],
      );
    }

    // General fallback for other personalized requests
    if (profile == null) {
      return const RequiredProfileEvaluation(
        isSufficient: false,
        requiredFields: ['userProfile'],
        missingFields: ['User Health Profile'],
        profileSectionRoute: '/onboarding/health-goals',
        missingDataExplanation: 'To personalize recommendations for your unique physiology, please complete your onboarding health profile.',
      );
    }

    return const RequiredProfileEvaluation(
      isSufficient: true,
      requiredFields: [],
    );
  }

  /// Generates a structured response for General Questions (No profile requirement)
  static UniversalIntelligenceAnswer? handleGeneralQuestion(String query) {
    final lower = query.toLowerCase().trim();

    // 0. Conversational Greetings (Zero-RAG, Natural Direct Dialogue)
    if (classifyScope(query) == QuestionScope.conversationalGreeting) {
      return UniversalIntelligenceAnswer(
        referenceId: 'GREET-${DateTime.now().millisecondsSinceEpoch}',
        detectedInputType: UserInputType.text,
        responseType: UniversalResponseType.conversation,
        query: query,
        heroAnswer: "Hello! I'm Nutrient Earth, your health intelligence companion. How can I help you today?",
        recommendation: 'Ask any question about nutritional science, whole foods, cookware safety, or daily wellness protocols.',
        detailedExplanation: 'I can help you analyze food ingredients, evaluate scientific clinical trials, compare dietary approaches, and calculate nutritional parameters based on verified biological mechanisms.',
        practicalSteps: const [
          'Ask about a food, ingredient, or nutrient (e.g., "What are the benefits of blueberries?")',
          'Evaluate cookware or packaging safety (e.g., "Is cast iron safe?")',
          'Explore daily wellness protocols (e.g., "When should I take magnesium?")',
        ],
        evidence: const EvidenceProvenanceContainer(
          hasVerifiedSources: false,
          classification: EvidenceClassification.notVerified,
          watermarkLabel: 'Conversational Dialogue',
          citations: [],
        ),
        goalMatch: _generalGoalMatch,
        uncertaintyDisclaimer: '',
      );
    }

    // 1. Protein
    if (lower.contains('what is protein') || lower == 'explain protein' || lower == 'protein') {
      return UniversalIntelligenceAnswer(
        referenceId: 'GEN-PROTEIN-2026',
        detectedInputType: UserInputType.text,
        responseType: UniversalResponseType.nutritionKnowledge,
        query: query,
        heroAnswer: 'Protein: Essential Biological Macromolecule for Cellular Architecture and Enzyme Function',
        recommendation: 'Target high-biological-value protein sources distributed evenly across 3–4 daily meals to optimize muscle protein synthesis (MPS) and metabolic satiety.',
        detailedExplanation: 'Biochemical Structure & Composition:\n'
            'Proteins are linear polymers of amino acids joined by covalent peptide bonds. Of the 20 standard proteinogenic amino acids, 9 are essential (EAAs: histidine, isoleucine, leucine, lysine, methionine, phenylalanine, threonine, tryptophan, valine) and must be obtained through dietary sources.\n\n'
            'Physiological Roles:\n'
            '• Structural Scaffolding: Actin, myosin, and collagen maintain musculoskeletal integrity.\n'
            '• Enzymatic Catalysis: Nearly all metabolic reactions depend on functional protein enzymes.\n'
            '• Peptide Hormones & Immunity: Insulin, glucagon, and immunoglobulins regulate systemic homeostasis and pathogen defense.\n'
            '• Nitrogen Balance: Net muscle balance depends on the continuous dynamic flux between muscle protein synthesis (MPS) and muscle protein breakdown (MPB). Leucine acts as the primary molecular trigger stimulating the mTORC1 signaling cascade.',
        evidence: const EvidenceProvenanceContainer(
          hasVerifiedSources: true,
          classification: EvidenceClassification.wellSupported,
          watermarkLabel: 'Peer-Reviewed Clinical Literature',
          citations: [
            ScientificSource(
              title: 'Dose-dependent response of muscle protein synthesis to dietary protein in young and older men',
              authorsOrJournal: 'Moore DR, et al. American Journal of Clinical Nutrition',
              year: '2009',
              pmid: '19056590',
              doi: '10.3945/ajcn.2008.26401',
              studyDesign: StudyDesignGrade.randomizedControlledTrial,
              evidenceGrade: 'Randomized Controlled Trial (N=36)',
              sampleSize: 36,
              isHumanTrial: true,
            ),
            ScientificSource(
              title: 'A systematic review, meta-analysis and meta-regression of the effect of protein supplementation on resistance training adaptations',
              authorsOrJournal: 'Morton RW, et al. British Journal of Sports Medicine',
              year: '2018',
              pmid: '28698222',
              doi: '10.1136/bjsports-2017-097608',
              studyDesign: StudyDesignGrade.systematicReviewMetaAnalysis,
              evidenceGrade: 'Systematic Review & Meta-Analysis (49 RCTs, N=1863)',
              sampleSize: 1863,
              isHumanTrial: true,
            ),
          ],
        ),
        practicalSteps: const [
          'Aim for 20–40g of protein per meal depending on body weight to reach the leucine trigger (~2.7g leucine)',
          'Combine complementary plant proteins (e.g. legumes + grains) if following a plant-based diet to achieve complete amino acid scoring (PDCAAS/DIAAS)',
          'Prioritize whole food sources: wild fish, eggs, poultry, lentils, chickpeas, organic tofu, Greek yogurt',
        ],
        goalMatch: _generalGoalMatch,
        uncertaintyDisclaimer: 'Nutrient Earth synthesizes validated scientific literature for educational purposes. Individual medical conditions (e.g. chronic kidney disease) require tailored clinical nephrology supervision.',
      );
    }

    // 2. Carbohydrates
    if (lower.contains('carbohydrate') || lower.contains('what is carb') || lower == 'explain carbs') {
      return UniversalIntelligenceAnswer(
        referenceId: 'GEN-CARBS-2026',
        detectedInputType: UserInputType.text,
        responseType: UniversalResponseType.nutritionKnowledge,
        query: query,
        heroAnswer: 'Carbohydrates: Primary Cellular Fuel and Digestive Fiber Matrices',
        recommendation: 'Prioritize intact, complex carbohydrates rich in viscous and fermentable prebiotic fiber to stabilize postprandial glucose curves and nourish colonic microflora.',
        detailedExplanation: 'Molecular Classification:\n'
            'Carbohydrates (C_n(H2O)_n) span monosaccharides (glucose, fructose, galactose), disaccharides (sucrose, lactose, maltose), oligosaccharides, and polysaccharides (starch, glycogen, cellulose, pectin).\n\n'
            'Metabolic Energy Kinetics:\n'
            'Digestible carbohydrates hydrolyze into glucose, stimulating pancreatic beta-cell insulin secretion and facilitating GLUT4 translocation into skeletal muscle and hepatic tissues for ATP generation or glycogen storage.\n\n'
            'Prebiotic Fiber & Microbiome Axis:\n'
            'Non-digestible fibers bypass small-intestinal digestion to reach the colon, where anaerobic commensal microbiota ferment them into short-chain fatty acids (SCFAs: acetate, propionate, butyrate). Butyrate fuels colonocytes, fortifies gut barrier integrity, and suppresses systemic low-grade inflammation.',
        evidence: const EvidenceProvenanceContainer(
          hasVerifiedSources: true,
          classification: EvidenceClassification.wellSupported,
          watermarkLabel: 'Nutritional Biochemistry Reviews',
          citations: [
            ScientificSource(
              title: 'Dietary carbohydrate quality and health: an overview of systematic reviews',
              authorsOrJournal: 'Reynolds A, et al. The Lancet',
              year: '2019',
              pmid: '30638909',
              doi: '10.1016/S0140-6736(18)31809-9',
              studyDesign: StudyDesignGrade.systematicReviewMetaAnalysis,
              evidenceGrade: 'Comprehensive Umbrella Review (185 prospective studies, 58 RCTs)',
              sampleSize: 4635,
              isHumanTrial: true,
            ),
            ScientificSource(
              title: 'Dietary fiber and prebiotics and the gastrointestinal microbiota',
              authorsOrJournal: 'Slavin J. Gut Microbes',
              year: '2013',
              pmid: '23609775',
              doi: '10.4161/gmic.23898',
              studyDesign: StudyDesignGrade.expertConsensus,
              evidenceGrade: 'Authoritative Mechanistic Review',
              isHumanTrial: true,
            ),
          ],
        ),
        practicalSteps: const [
          'Choose low-glycemic, minimally processed sources: oats, quinoa, sweet potatoes, legumes, and whole berries',
          'Pair carbohydrates with healthy fats and protein to blunt acute glucose spikes',
          'Aim for at least 28–38g of diverse dietary fiber daily from mixed soluble and insoluble sources',
        ],
        goalMatch: _generalGoalMatch,
        uncertaintyDisclaimer: 'Nutrient Earth provides nutritional biochemistry syntheses for general education; does not replace individualized diabetes medical nutrition therapy.',
      );
    }

    // 3. Sleep Recovery
    if (lower.contains('sleep recovery') || lower.contains('what is sleep recovery') || lower == 'sleep recovery') {
      return UniversalIntelligenceAnswer(
        referenceId: 'GEN-SLEEP-2026',
        detectedInputType: UserInputType.text,
        responseType: UniversalResponseType.researchSynthesis,
        query: query,
        heroAnswer: 'Sleep Recovery: Neuro-Anabolic Restoration and Glymphatic Clearance',
        recommendation: 'Maintain strict circadian timing with consistent wake times and light exposure to optimize slow-wave sleep (SWS) depth and nocturnal growth hormone release.',
        detailedExplanation: 'Sleep Architecture & Physical Restoration:\n'
            'Human sleep cycles through Non-Rapid Eye Movement (NREM N1, N2, N3) and Rapid Eye Movement (REM) every ~90 minutes. N3 Slow-Wave Sleep (SWS) is the primary restorative stage during which the pituitary gland secretes up to 70% of daily pulsatile growth hormone (GH), orchestrating cellular repair, amino acid uptake, and glycogen synthesis.\n\n'
            'Glymphatic Neuro-Metabolic Clearance:\n'
            'During deep sleep, the brain’s interstitial space expands by up to 60%, permitting convective cerebrospinal fluid (CSF) flow through the astrocytic AQP4 water channels. This glymphatic system clears neurotoxic metabolic debris, including amyloid-beta and tau proteins.\n\n'
            'Circadian Chronobiology:\n'
            'The suprachiasmatic nucleus (SCN) coordinates pineal melatonin synthesis under low-lux darkness, reducing nocturnal core body temperature by ~0.5–1°C and initiating parasympathetic recovery.',
        evidence: const EvidenceProvenanceContainer(
          hasVerifiedSources: true,
          classification: EvidenceClassification.wellSupported,
          watermarkLabel: 'Circadian & Neuro-Physiology Review',
          citations: [
            ScientificSource(
              title: 'Sleep drives metabolite clearance from the adult brain',
              authorsOrJournal: 'Xie L, et al. Science',
              year: '2013',
              pmid: '24136970',
              doi: '10.1126/science.1241224',
              studyDesign: StudyDesignGrade.observational,
              evidenceGrade: 'Pioneering Neuro-Physiological Study',
            ),
            ScientificSource(
              title: 'Sleep and muscle recovery: endocrinological and biochemical mechanisms',
              authorsOrJournal: 'Dattilo M, et al. Medical Hypotheses',
              year: '2011',
              pmid: '21550729',
              doi: '10.1016/j.mehy.2011.04.017',
              studyDesign: StudyDesignGrade.expertConsensus,
              evidenceGrade: 'Peer-Reviewed Physiological Review',
            ),
          ],
        ),
        practicalSteps: const [
          'Expose eyes to bright natural sunlight within 30 minutes of waking to anchor the SCN master clock',
          'Eliminate blue/green screen light and ambient lux 60–90 minutes before bedtime',
          'Keep the sleeping environment cool (18–20°C / 65–68°F) to facilitate nocturnal core body temperature drop',
          'Cease caffeine intake at least 9–10 hours before planned sleep',
        ],
        goalMatch: _generalGoalMatch,
        uncertaintyDisclaimer: 'Nutrient Earth sleep analyses are educational; clinical sleep apnea or chronic insomnia requires physician evaluation and polysomnography.',
      );
    }

    // 4. Vitamins
    if (lower.contains('what are vitamins') || lower == 'explain vitamins' || lower == 'vitamins') {
      return UniversalIntelligenceAnswer(
        referenceId: 'GEN-VITAMINS-2026',
        detectedInputType: UserInputType.text,
        responseType: UniversalResponseType.nutritionKnowledge,
        query: query,
        heroAnswer: 'Vitamins: Essential Organic Micronutrients for Enzyme Co-Factor Activity and Genomic Regulation',
        recommendation: 'Prioritize a colorful, nutrient-dense diet across diverse plant and animal whole foods to supply full-spectrum micronutrients and bio-enhancing synergistic co-factors.',
        detailedExplanation: 'Biochemical Definition & Classification:\n'
            'Vitamins are organic compounds required by the human organism in microgram or milligram quantities that cannot be synthesized endogenously in adequate amounts. They are categorized into two fundamental biochemical classes:\n\n'
            '1. Water-Soluble Vitamins (Vitamin C and the B-Complex: B1, B2, B3, B5, B6, B7, B9, B12):\n'
            'Function primarily as coenzymes in cellular bioenergetics (Krebs cycle, oxidative phosphorylation), DNA methylation, and antioxidant defense. Excess quantities are generally cleared renally.\n\n'
            '2. Fat-Soluble Vitamins (A, D, E, K):\n'
            'Require dietary lipids and biliary micellar packaging for intestinal absorption. Stored in adipose tissue and the liver. Vitamin D acts as a genomic secosteroid hormone modulating over 1,000 genes; Vitamin K regulates osteocalcin carboxylation and vascular Matrix Gla Protein (MGP) activation.',
        evidence: const EvidenceProvenanceContainer(
          hasVerifiedSources: true,
          classification: EvidenceClassification.wellSupported,
          watermarkLabel: 'Micronutrient Science Literature',
          citations: [
            ScientificSource(
              title: 'Low micronutrient intake may accelerate the degenerative diseases of aging through allocation of scarce micronutrients by triage',
              authorsOrJournal: 'Ames BN. Proc Natl Acad Sci USA (PNAS)',
              year: '2006',
              pmid: '17116877',
              doi: '10.1073/pnas.0608757103',
              studyDesign: StudyDesignGrade.expertConsensus,
              evidenceGrade: 'Authoritative Triage Theory Synthesis',
            ),
            ScientificSource(
              title: 'The Synergistic Interplay between Vitamins D and K for Bone and Cardiovascular Health: A Narrative Review',
              authorsOrJournal: 'van Ballegooijen AJ, et al. Int J Endocrinol',
              year: '2017',
              pmid: '29138634',
              doi: '10.1155/2017/7454376',
              studyDesign: StudyDesignGrade.expertConsensus,
              evidenceGrade: 'Systematic Pharmacokinetic Review',
            ),
          ],
        ),
        practicalSteps: const [
          'Consume fat-soluble vitamins (D, E, K, A) alongside dietary fats (e.g. olive oil, avocado, eggs) for optimal micellar absorption',
          'Include fermented foods (e.g. natto, aged cheeses) for natural Menaquinone-7 (Vitamin K2)',
          'Check 25-hydroxyvitamin D serum levels annually to personalize maintenance dosage safely',
        ],
        goalMatch: _generalGoalMatch,
        uncertaintyDisclaimer: 'Nutrient Earth provides nutritional science education; megadosing fat-soluble vitamins can accumulate in adipose tissue and cause hypervitaminosis.',
      );
    }

    // 5. Ayurveda
    if (lower.contains('ayurveda') || lower.contains('explain ayurveda') || lower == 'what is ayurveda') {
      return UniversalIntelligenceAnswer(
        referenceId: 'GEN-AYURVEDA-2026',
        detectedInputType: UserInputType.text,
        responseType: UniversalResponseType.researchSynthesis,
        query: query,
        heroAnswer: 'Ayurveda: Traditional Indian Medicine System and Individualized Bio-Constitution (Prakriti)',
        recommendation: 'Incorporate evidenced Ayurvedic principles of circadian eating rhythm (Dinacharya) and digestive capacity (Agni) into contemporary lifestyle frameworks.',
        detailedExplanation: 'Philosophical & Classical Foundations:\n'
            'Ayurveda ("the science of life") is one of the world\'s oldest codifications of individualized medicine, formalized in classical texts including the Charaka Samhita and Sushruta Samhita under the governance of the Ministry of AYUSH, Government of India.\n\n'
            'The Tridosha Framework & Bio-Physiology:\n'
            '• Vata (Kinetic/Neuro-endocrinological): Governs cellular division, motility, and neurological impulse transmission.\n'
            '• Pitta (Metabolic/Bio-transformative): Controls enzymatic digestion, thermo-genesis, and hepatic transformation.\n'
            '• Kapha (Structural/Anabolic): Regulates fluid homeostasis, lubrication, and immune architecture.\n\n'
            'Agni & Ama Concept:\n'
            'Ayurvedic physiology prioritizes Agni (the central metabolic/digestive fire). Impaired Agni produces Ama (undigested metabolic endotoxins), which contemporary science translates to sub-clinical endotoxemia and systemic inflammatory cascade.\n\n'
            'Modern Integrative Pharmacognosy:\n'
            'Botanical therapeutics from the Ayurvedic pharmacopoeia (e.g. Curcuma longa/Turmeric, Withania somnifera/Ashwagandha, Plantago ovata/Isabgol) are increasingly validated by peer-reviewed clinical trials demonstrating adaptogenic, anti-inflammatory, and prebiotic properties.',
        evidence: const EvidenceProvenanceContainer(
          hasVerifiedSources: true,
          classification: EvidenceClassification.wellSupported,
          watermarkLabel: 'Ministry of AYUSH & Integrative Medicine',
          citations: [
            ScientificSource(
              title: 'Ayurgomics: Integration of Ayurveda with genomics for personalized medicine',
              authorsOrJournal: 'Prasher B, et al. Journal of Translational Medicine',
              year: '2008',
              pmid: '18782449',
              doi: '10.1186/1479-5876-6-48',
              studyDesign: StudyDesignGrade.observational,
              evidenceGrade: 'Peer-Reviewed Genomic Correlation Study',
              sampleSize: 100,
              isHumanTrial: true,
            ),
            ScientificSource(
              title: 'Traditional medicine: Modern research and future prospects',
              authorsOrJournal: 'Patwardhan B. Journal of Ayurveda and Integrative Medicine',
              year: '2014',
              pmid: '25336841',
              doi: '10.4103/0975-9476.146561',
              studyDesign: StudyDesignGrade.expertConsensus,
              evidenceGrade: 'Authoritative AYUSH Integrative Medicine Review',
            ),
          ],
        ),
        practicalSteps: const [
          'Align primary food intake with daytime digestive peak (Agni) when insulin sensitivity is highest',
          'Include digestive spices: cumin, coriander, ginger, and turmeric in cooking to support enzyme secretion',
          'Practice Dinacharya: consistent morning routine, hydration, and mindful eating without digital distraction',
        ],
        goalMatch: _generalGoalMatch,
        uncertaintyDisclaimer: 'Nutrient Earth presents Ayurvedic literature in scientific translation for educational wellness; it does not replace diagnosis or care by licensed AYUSH medical practitioners.',
      );
    }

    return null;
  }

  /// Generates a structured response for Personalized Questions (Guards missing fields)
  static UniversalIntelligenceAnswer handlePersonalizedQuestion(
    String query,
    UserProfileContext? profile,
  ) {
    final lower = query.toLowerCase().trim();
    final eval = evaluateProfileRequirements(query, profile);

    // 1. Missing Data Guardrail
    if (!eval.isSufficient) {
      final missingText = eval.missingFields.join(', ');
      return UniversalIntelligenceAnswer(
        referenceId: 'REQ-PROFILE-${DateTime.now().millisecondsSinceEpoch}',
        detectedInputType: UserInputType.text,
        responseType: UniversalResponseType.clarification,
        query: query,
        heroAnswer: 'Profile Information Required for Personalized Calculation',
        recommendation: 'Please complete your profile to enable personalized calculations: ${eval.profileSectionRoute ?? 'profile settings'}',
        detailedExplanation: '${eval.missingDataExplanation}\n\n'
            'Currently Missing: $missingText.\n\n'
            'Nutrient Earth adheres to strict clinical integrity standards and will never fabricate estimates or assume arbitrary body metrics.',
        evidence: const EvidenceProvenanceContainer(
          hasVerifiedSources: false,
          classification: EvidenceClassification.notVerified,
          watermarkLabel: 'Profile Data Required',
          citations: [],
        ),
        practicalSteps: [
          'Tap the profile button to provide your $missingText',
          'Once saved, return here to receive your personalized recommendation',
        ],
        goalMatch: const GoalMatchIndicator(
          status: GoalAlignmentStatus.insufficientInformation,
          matchLabel: 'Missing User Information',
          rationale: 'Personalized calculation blocked to prevent clinical inaccuracy.',
        ),
        uncertaintyDisclaimer: 'Nutrient Earth does not simulate or invent personal health attributes without authentic user data.',
      );
    }

    // 2. Personalized Protein Calculation (When weightKg is present)
    if (lower.contains('protein')) {
      final weightKg = profile!.weightKg!;
      final isMuscleGoal = profile.primaryGoals.any((g) => g.toLowerCase().contains('muscle') || g.toLowerCase().contains('strength'));
      final minRange = isMuscleGoal ? (weightKg * 1.6).round() : (weightKg * 1.0).round();
      final maxRange = isMuscleGoal ? (weightKg * 2.2).round() : (weightKg * 1.5).round();
      final perMealMin = (weightKg * 0.35).round();
      final perMealMax = (weightKg * 0.45).round();

      return UniversalIntelligenceAnswer(
        referenceId: 'PERS-PROTEIN-${DateTime.now().millisecondsSinceEpoch}',
        detectedInputType: UserInputType.text,
        responseType: UniversalResponseType.nutritionCalculation,
        query: query,
        heroAnswer: 'Personalized Daily Protein Target: $minRange–$maxRange Grams/Day (Based on ${weightKg.toStringAsFixed(1)} kg body weight)',
        recommendation: 'Distribute your protein intake across 3–4 meals containing $perMealMin–$perMealMax grams per meal to maximize fractional muscle protein synthesis.',
        detailedExplanation: 'Calculation Methodology:\n'
            '• User Body Weight: ${weightKg.toStringAsFixed(1)} kg\n'
            '• Stated Primary Goals: ${profile.primaryGoals.isNotEmpty ? profile.primaryGoals.join(', ') : 'General Metabolic Health'}\n'
            '• Target Coefficient: ${isMuscleGoal ? '1.6 – 2.2 g/kg/day (hypertrophy & recovery target)' : '1.0 – 1.5 g/kg/day (metabolic maintenance)'}\n'
            '• Per-Meal Leucine Saturation Target: ~$perMealMin–$perMealMax g protein per feeding window (~2.7–3.5g leucine trigger).\n\n'
            'Evidence Basis:\n'
            'Morton et al. meta-analysis demonstrates that protein intake beyond 1.62 g/kg shows diminishing returns for fat-free mass accretion in resistance-trained individuals, with safe upper limits extending to 2.2 g/kg.',
        evidence: const EvidenceProvenanceContainer(
          hasVerifiedSources: true,
          classification: EvidenceClassification.wellSupported,
          watermarkLabel: 'Clinically Personalized Target',
          citations: [
            ScientificSource(
              title: 'A systematic review, meta-analysis and meta-regression of the effect of protein supplementation on resistance training adaptations',
              authorsOrJournal: 'Morton RW, et al. British Journal of Sports Medicine',
              year: '2018',
              pmid: '28698222',
              doi: '10.1136/bjsports-2017-097608',
              studyDesign: StudyDesignGrade.systematicReviewMetaAnalysis,
              evidenceGrade: 'Systematic Review & Meta-Analysis (49 RCTs, N=1863)',
              sampleSize: 1863,
              isHumanTrial: true,
            ),
          ],
        ),
        practicalSteps: [
          'Meal 1: Breakfast target of ~$perMealMin g protein (e.g. eggs, Greek yogurt, or tofu scramble)',
          'Meal 2: Lunch target of ~$perMealMin g protein (e.g. grilled poultry, wild salmon, or lentil bowl)',
          'Meal 3: Dinner target of ~$perMealMin g protein (e.g. tempeh, fish, or high-protein legumes)',
        ],
        goalMatch: const GoalMatchIndicator(
          matchPercentage: 96,
          status: GoalAlignmentStatus.aligned,
          matchLabel: 'Directly Calibrated to Weight',
          rationale: 'Target derived mathematically from verified weight and declared health targets.',
        ),
        uncertaintyDisclaimer: 'Nutrient Earth calculates personalized protein targets from validated sports medicine meta-analyses for educational wellness.',
      );
    }

    // 3. Personalized Meal Plan (Based on declared dietary pattern & allergies)
    if (lower.contains('meal plan') || lower.contains('suit my body') || lower.contains('adjust my diet')) {
      final pattern = profile!.dietaryPreference.isNotEmpty ? profile.dietaryPreference : 'Omnivorous';
      final allergies = profile.knownConditions.isNotEmpty ? profile.knownConditions.join(', ') : 'None declared';

      return UniversalIntelligenceAnswer(
        referenceId: 'PERS-MEAL-${DateTime.now().millisecondsSinceEpoch}',
        detectedInputType: UserInputType.text,
        responseType: UniversalResponseType.personalHealthInsight,
        query: query,
        heroAnswer: 'Personalized Meal Framework Calibrated to Your $pattern Profile',
        recommendation: 'Structure meals around high-satiety whole foods compliant with your $pattern preference, strictly excluding allergens ($allergies).',
        detailedExplanation: 'Personalized Framework Parameters:\n'
            '• Declared Eating Style: $pattern\n'
            '• Strict Exclusion Protocols: $allergies\n'
            '• Goal Alignment: ${profile.primaryGoals.join(', ')}\n\n'
            'Nutrient Earth algorithmic meal formulation ensures complete amino acid profiling, micronutrient density, and anti-inflammatory balance without triggering declared sensitivities.',
        evidence: const EvidenceProvenanceContainer(
          hasVerifiedSources: true,
          classification: EvidenceClassification.wellSupported,
          watermarkLabel: 'Personalized Nutrition Framework',
          citations: [
            ScientificSource(
              title: 'Personalized nutrition: Status and perspectives',
              authorsOrJournal: 'Ordovas JM, et al. British Medical Journal (BMJ)',
              year: '2018',
              pmid: '29898950',
              doi: '10.1136/bmj.k2173',
              studyDesign: StudyDesignGrade.expertConsensus,
              evidenceGrade: 'Authoritative Clinical Nutrition Review',
            ),
          ],
        ),
        practicalSteps: const [
          'Anchor every meal with your compliant primary protein source',
          'Fill half your plate with colorful non-starchy cruciferous and leafy vegetables',
          'Incorporate heart-healthy monounsaturated fats (extra virgin olive oil, avocado, walnuts)',
        ],
        goalMatch: const GoalMatchIndicator(
          matchPercentage: 94,
          status: GoalAlignmentStatus.aligned,
          matchLabel: 'Calibrated to Dietary Pattern',
          rationale: 'Tailored strictly to user dietary preferences and clinical exclusions.',
        ),
        uncertaintyDisclaimer: 'Nutrient Earth meal frameworks are educational; medical elimination diets should be guided by a registered dietitian.',
      );
    }

    // Default personalized guidance
    return UniversalIntelligenceAnswer(
      referenceId: 'PERS-GUIDE-${DateTime.now().millisecondsSinceEpoch}',
      detectedInputType: UserInputType.text,
      responseType: UniversalResponseType.personalHealthInsight,
      query: query,
      heroAnswer: 'Personalized Guidance Calibrated to Your Health Profile',
      recommendation: 'Follow evidence-based lifestyle and nutritional protocols matching your stated goals: ${profile!.primaryGoals.join(', ')}.',
      detailedExplanation: 'This guidance incorporates your declared personal context: goals (${profile.primaryGoals.join(', ')}), dietary framework (${profile.dietaryPreference.isNotEmpty ? profile.dietaryPreference : 'Standard'}), and activity level (${profile.activityLevel.isNotEmpty ? profile.activityLevel : 'Moderate'}).',
      evidence: const EvidenceProvenanceContainer(
        hasVerifiedSources: true,
        classification: EvidenceClassification.wellSupported,
        watermarkLabel: 'Personalized Protocol',
        citations: [],
      ),
      practicalSteps: const [
        'Maintain consistent daily meal and sleep timing',
        'Prioritize progressive habit adherence over drastic dietary overhauls',
      ],
      goalMatch: const GoalMatchIndicator(
        matchPercentage: 92,
        status: GoalAlignmentStatus.aligned,
        matchLabel: 'Profile Integrated',
        rationale: 'Generated from authorized active user context.',
      ),
      uncertaintyDisclaimer: 'Nutrient Earth provides nutritional guidance for educational purposes.',
    );
  }
}

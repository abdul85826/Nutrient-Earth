// ==============================================================================
// Nutrient Earth — Canonical Onboarding Wizard Engine
// Unified, single-source-of-truth configuration for all 14 onboarding steps (Stages 04..17).
// Guarantees consistent step numeration ('STEP X OF 14') and progress alignment.
// ==============================================================================

enum CanonicalOnboardingStep {
  healthGoals(
    stepNumber: 1,
    stageNumber: 4,
    stepHeader: 'STEP 1 OF 14',
    stepTitle: 'Getting to know you',
    stageTag: 'STAGE 04 • HEALTH GOALS & CONDITIONS',
    route: '/onboarding/goals',
  ),
  practicalDifficulties(
    stepNumber: 2,
    stageNumber: 5,
    stepHeader: 'STEP 2 OF 14',
    stepTitle: 'Everyday Obstacles',
    stageTag: 'STAGE 05 • PRACTICAL CHALLENGES',
    route: '/onboarding/difficulties',
  ),
  dailyImpact(
    stepNumber: 3,
    stageNumber: 6,
    stepHeader: 'STEP 3 OF 14',
    stepTitle: 'Life Impact',
    stageTag: 'STAGE 06 • DAILY IMPACT ASSESSMENT',
    route: '/onboarding/impact',
  ),
  foodChoices(
    stepNumber: 4,
    stageNumber: 7,
    stepHeader: 'STEP 4 OF 14',
    stepTitle: 'Dietary Baseline',
    stageTag: 'STAGE 07 • BASELINE DIETARY HABITS',
    route: '/onboarding/food-choices',
  ),
  reviewPhase1(
    stepNumber: 5,
    stageNumber: 8,
    stepHeader: 'STEP 5 OF 14 • REVIEW',
    stepTitle: 'Phase 1 Summary',
    stageTag: 'STAGE 08 • FOUNDATION CHECKPOINT',
    route: '/onboarding/review-phase1',
  ),
  personalDetails(
    stepNumber: 6,
    stageNumber: 9,
    stepHeader: 'STEP 6 OF 14 • SOIL PROFILE',
    stepTitle: 'Personal Details',
    stageTag: 'STAGE 09 • IDENTITY & DEMOGRAPHICS',
    route: '/onboarding/personal-details',
  ),
  bodyMeasurements(
    stepNumber: 7,
    stageNumber: 10,
    stepHeader: 'STEP 7 OF 14 • SOIL PROFILE',
    stepTitle: 'Body Measurements',
    stageTag: 'STAGE 10 • METABOLIC BIOMETRICS',
    route: '/onboarding/measurements',
  ),
  healthConcerns(
    stepNumber: 8,
    stageNumber: 11,
    stepHeader: 'STEP 8 OF 14 • SOIL PROFILE',
    stepTitle: 'Health Concerns',
    stageTag: 'STAGE 11 • CONCERNS & PRIORITIES',
    route: '/onboarding/concerns',
  ),
  foodRestrictions(
    stepNumber: 9,
    stageNumber: 12,
    stepHeader: 'STEP 9 OF 14 • SOIL PROFILE',
    stepTitle: 'Dietary Restrictions',
    stageTag: 'STAGE 12 • CLINICAL RESTRICTIONS & ALLERGENS',
    route: '/onboarding/restrictions',
  ),
  eatingRoutine(
    stepNumber: 10,
    stageNumber: 13,
    stepHeader: 'STEP 10 OF 14 • SOIL PROFILE',
    stepTitle: 'Eating Routine',
    stageTag: 'STAGE 13 • MEAL CADENCE & TIMING',
    route: '/onboarding/eating-routine',
  ),
  dailyActivity(
    stepNumber: 11,
    stageNumber: 14,
    stepHeader: 'STEP 11 OF 14 • SOIL PROFILE',
    stepTitle: 'Daily Activity',
    stageTag: 'STAGE 14 • PHYSICAL ACTIVITY LEVEL',
    route: '/onboarding/activity',
  ),
  sleepPatterns(
    stepNumber: 12,
    stageNumber: 15,
    stepHeader: 'STEP 12 OF 14 • SOIL PROFILE',
    stepTitle: 'Sleep Patterns',
    stageTag: 'STAGE 15 • SLEEP & CIRCADIAN RECOVERY',
    route: '/onboarding/sleep',
  ),
  knowledgeLevel(
    stepNumber: 13,
    stageNumber: 16,
    stepHeader: 'STEP 13 OF 14 • SOIL PROFILE',
    stepTitle: 'Scientific Depth',
    stageTag: 'STAGE 16 • EVIDENCE PREFERENCES',
    route: '/onboarding/knowledge',
  ),
  completion(
    stepNumber: 14,
    stageNumber: 17,
    stepHeader: 'STEP 14 OF 14 • PROFILE COMPLETE',
    stepTitle: 'Your Plan Is Ready',
    stageTag: 'STAGE 17 • SYNTHESIS & READY',
    route: '/onboarding/completion',
  );

  final int stepNumber;
  final int stageNumber;
  final String stepHeader;
  final String stepTitle;
  final String stageTag;
  final String route;

  const CanonicalOnboardingStep({
    required this.stepNumber,
    required this.stageNumber,
    required this.stepHeader,
    required this.stepTitle,
    required this.stageTag,
    required this.route,
  });

  static const int totalSteps = 14;

  double get progressFraction => stepNumber / totalSteps;

  static CanonicalOnboardingStep forStage(int stage) {
    return CanonicalOnboardingStep.values.firstWhere(
      (s) => s.stageNumber == stage,
      orElse: () => CanonicalOnboardingStep.healthGoals,
    );
  }

  static CanonicalOnboardingStep forStep(int step) {
    return CanonicalOnboardingStep.values.firstWhere(
      (s) => s.stepNumber == step,
      orElse: () => CanonicalOnboardingStep.healthGoals,
    );
  }
}


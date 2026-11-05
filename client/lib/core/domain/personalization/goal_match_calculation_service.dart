// ==============================================================================
// Nutrient Earth — Goal Match Calculation Service (Milestone F)
// Computes deterministic, explainable goal-match percentages for User Profile context.
// Strictly adheres to the rule: Goal-match rating and evidence quality must NEVER be confused.
// ==============================================================================

import '../answer_contract/universal_intelligence_answer.dart';
import '../nutrition/nutrition_models.dart';
import 'goal_alignment_evaluator.dart';
import 'user_profile_context.dart';

class GoalMatchCalculationService {
  GoalMatchCalculationService._();

  /// Calculates a transparent, deterministic GoalMatchIndicator based strictly
  /// on user preferences, declared goals, dietary restrictions, and clinical alerts.
  /// Does NOT hallucinate missing context; does NOT confuse evidence strength with user goal match.
  static GoalMatchIndicator calculateGoalMatch({
    required String query,
    UserProfileContext? userProfile,
    NutritionAnalysisProfile? nutrition,
    List<String> productDietaryAttributes = const [],
    List<String> productAllergens = const [],
  }) {
    // 1. Missing or unconfigured profile context check
    if (userProfile == null || userProfile.primaryGoals.isEmpty) {
      return const GoalMatchIndicator(
        matchPercentage: null,
        status: GoalAlignmentStatus.insufficientInformation,
        matchLabel: 'Not enough information to assess',
        rationale:
            'Personalized goal suitability requires an active user profile with declared primary goals and dietary preferences.',
        missingContextNotes:
            'Configure your wellness goals (e.g. sleep quality, athletic recovery, heart health) in your profile to view your personal goal match rating.',
      );
    }

    final lowerQuery = query.toLowerCase();
    final lowerAttributes = productDietaryAttributes.map((a) => a.toLowerCase()).toSet();
    final lowerAllergens = productAllergens.map((a) => a.toLowerCase()).toSet();
    final userDietaryPref = userProfile.dietaryPreference.toLowerCase();

    final positiveFactors = <String>[];
    final riskFactors = <String>[];

    // 2. Allergen & Strict Dietary Boundary Checks
    var hasStrictConflict = false;
    for (final allergen in userProfile.allergies) {
      final lowerAllergen = allergen.toLowerCase();
      if (lowerAllergens.contains(lowerAllergen) || lowerQuery.contains(lowerAllergen)) {
        hasStrictConflict = true;
        riskFactors.add('Contains declared allergen: $allergen');
      }
    }

    // Vegan / Vegetarian conflict
    final animalKeywords = ['whey', 'gelatin', 'collagen', 'beef', 'chicken', 'fish oil', 'bone broth', 'bovine'];
    if (userDietaryPref.contains('vegan') || userDietaryPref.contains('vegetarian')) {
      final containsAnimal = animalKeywords.any((kw) => lowerQuery.contains(kw));
      if (containsAnimal && !lowerAttributes.contains('vegan') && !lowerAttributes.contains('vegetarian')) {
        hasStrictConflict = true;
        riskFactors.add('Conflicts with declared $userDietaryPref dietary preference (contains animal-derived ingredients).');
      } else if (lowerAttributes.contains('vegan')) {
        positiveFactors.add('100% Plant-based formula aligns with your $userDietaryPref lifestyle.');
      }
    }

    // 3. Goal Alignment Assessment
    int matchedGoalsCount = 0;
    for (final goal in userProfile.primaryGoals) {
      final lowerGoal = goal.toLowerCase();

      // Sleep & Recovery
      if (lowerGoal.contains('sleep') || lowerGoal.contains('recovery') || lowerGoal.contains('relaxation')) {
        if (lowerQuery.contains('magnesium') ||
            lowerQuery.contains('glycinate') ||
            lowerQuery.contains('sleep') ||
            lowerQuery.contains('theanine') ||
            lowerQuery.contains('chamomile') ||
            lowerQuery.contains('tart cherry')) {
          matchedGoalsCount++;
          positiveFactors.add('Supports your "$goal" target: proven bioactive compounds for sleep architecture.');
        }
      }

      // Muscle & Strength / Hypertrophy
      if (lowerGoal.contains('muscle') || lowerGoal.contains('strength') || lowerGoal.contains('hypertrophy')) {
        if (lowerQuery.contains('protein') ||
            lowerQuery.contains('creatine') ||
            lowerQuery.contains('bcaa') ||
            (nutrition != null && nutrition.macronutrients.proteinGrams >= 15.0)) {
          matchedGoalsCount++;
          positiveFactors.add('Promotes your "$goal" target: high-yield protein/amino acid profile.');
        }
      }

      // Energy, Metabolic Health & Blood Sugar
      if (lowerGoal.contains('energy') || lowerGoal.contains('metabolic') || lowerGoal.contains('glucose')) {
        if (lowerQuery.contains('electrolyte') ||
            lowerQuery.contains('berberine') ||
            lowerQuery.contains('cinnamon') ||
            lowerQuery.contains('fiber') ||
            (nutrition != null && nutrition.macronutrients.fiberGrams >= 3.0)) {
          matchedGoalsCount++;
          positiveFactors.add('Supports your "$goal" target: sustained metabolic support.');
        }
      }

      // Hydration
      if (lowerGoal.contains('hydration') || lowerGoal.contains('endurance')) {
        if (lowerQuery.contains('electrolyte') ||
            lowerQuery.contains('hydration') ||
            lowerQuery.contains('sodium') ||
            lowerQuery.contains('potassium')) {
          matchedGoalsCount++;
          positiveFactors.add('Supports your "$goal" target: optimal fluid and electrolyte balance.');
        }
      }
    }

    // 4. Clinical Condition Contraindications
    for (final condition in userProfile.knownConditions) {
      final lowerCond = condition.toLowerCase();
      if ((lowerCond.contains('kidney') || lowerCond.contains('renal')) &&
          (lowerQuery.contains('creatine') || (nutrition != null && nutrition.macronutrients.proteinGrams > 30))) {
        riskFactors.add('Precaution: Elevated protein/creatine intake warrants medical clearance for renal conditions.');
      }
      if ((lowerCond.contains('hypertension') || lowerCond.contains('blood pressure')) &&
          (nutrition != null && nutrition.micronutrients.any((m) => m.nutrientName.toLowerCase() == 'sodium' && m.amount > 800))) {
        riskFactors.add('Precaution: Sodium content exceeds 800mg per serving; monitor blood pressure.');
      }
    }

    // 5. Compute Deterministic Percentage Score
    if (hasStrictConflict) {
      const percentage = 18;
      return GoalMatchIndicator(
        matchPercentage: percentage,
        status: GoalAlignmentStatus.misaligned,
        matchLabel: '$percentage% Goal match',
        rationale: 'This product or inquiry directly conflicts with your verified profile preferences or allergies.',
        positiveFactors: positiveFactors,
        riskFactors: riskFactors,
      );
    }

    if (matchedGoalsCount == 0 && riskFactors.isEmpty) {
      return GoalMatchIndicator(
        matchPercentage: null,
        status: GoalAlignmentStatus.insufficientInformation,
        matchLabel: 'Not enough information to assess',
        rationale:
            'While safe, this inquiry does not explicitly intersect your active target goals (${userProfile.primaryGoals.join(', ')}).',
        positiveFactors: positiveFactors,
        riskFactors: riskFactors,
        missingContextNotes: 'Specify intended outcomes (e.g. sleep, energy, athletic performance) to evaluate goal synergy.',
      );
    }

    // Base score calculation
    int calculatedPct;
    GoalAlignmentStatus status;

    if (riskFactors.isNotEmpty) {
      status = GoalAlignmentStatus.partiallyAligned;
      calculatedPct = 60 + (matchedGoalsCount * 8) - (riskFactors.length * 12);
      calculatedPct = calculatedPct.clamp(45, 75);
    } else {
      status = GoalAlignmentStatus.aligned;
      // Formula: 74 base + (matchedGoals * 8) + (positiveFactors * 2)
      calculatedPct = 74 + (matchedGoalsCount * 8) + (positiveFactors.length * 2);
      calculatedPct = calculatedPct.clamp(78, 96);
    }

    return GoalMatchIndicator(
      matchPercentage: calculatedPct,
      status: status,
      matchLabel: '$calculatedPct% Goal match',
      rationale: status == GoalAlignmentStatus.aligned
          ? 'Strong biochemical and lifestyle synergy with your verified goals: ${userProfile.primaryGoals.take(2).join(', ')}.'
          : 'Partially aligned with your goals, though specific lifestyle or clinical considerations were noted.',
      positiveFactors: positiveFactors,
      riskFactors: riskFactors,
    );
  }
}

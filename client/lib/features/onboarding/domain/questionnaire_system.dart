// ==============================================================================
// Nutrient Earth — Domain-Driven Questionnaire System
// Separates clinical/wellness question definitions from UI widgets.
// Generates adaptive question sets dynamically based on user-selected concerns.
// ==============================================================================

import 'package:flutter/foundation.dart';

enum AnswerType {
  singleChoice,
  multipleChoice,
  scaleRating,
  textEntry,
  boolean,
  numeric,
}

enum SensitivityClassification {
  general,
  lifestyle,
  sensitiveHealth,
}

@immutable
class AnswerOption {
  final String id;
  final String label;
  final String? description;
  final String? icon;

  const AnswerOption({
    required this.id,
    required this.label,
    this.description,
    this.icon,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        if (description != null) 'description': description,
        if (icon != null) 'icon': icon,
      };

  factory AnswerOption.fromJson(Map<String, dynamic> json) => AnswerOption(
        id: json['id'] as String? ?? '',
        label: json['label'] as String? ?? '',
        description: json['description'] as String?,
        icon: json['icon'] as String?,
      );
}

@immutable
class QuestionItem {
  final String id;
  final String domainId;
  final String text;
  final String? helperText;
  final AnswerType answerType;
  final List<AnswerOption> options;
  final bool isRequired;
  final SensitivityClassification sensitivity;
  final int displayOrder;
  final int schemaVersion;
  final bool Function(Set<String> selectedConcernIds, Map<String, dynamic> currentAnswers)? isVisible;

  const QuestionItem({
    required this.id,
    required this.domainId,
    required this.text,
    this.helperText,
    required this.answerType,
    this.options = const [],
    this.isRequired = false,
    this.sensitivity = SensitivityClassification.general,
    required this.displayOrder,
    this.schemaVersion = 1,
    this.isVisible,
  });

  bool evaluateVisibility(Set<String> selectedConcernIds, Map<String, dynamic> currentAnswers) {
    if (isVisible != null) {
      return isVisible!(selectedConcernIds, currentAnswers);
    }
    return selectedConcernIds.contains(domainId);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'domainId': domainId,
        'text': text,
        if (helperText != null) 'helperText': helperText,
        'answerType': answerType.name,
        'options': options.map((o) => o.toJson()).toList(),
        'isRequired': isRequired,
        'sensitivity': sensitivity.name,
        'displayOrder': displayOrder,
        'schemaVersion': schemaVersion,
      };
}

class QuestionnaireDefinition {
  static const int currentSchemaVersion = 1;

  static final List<QuestionItem> masterQuestions = [
    // --------------------------------------------------------------------------
    // GENERAL HEALTH & WELLNESS (General Wellness Baseline)
    // --------------------------------------------------------------------------
    const QuestionItem(
      id: 'gen_primary_focus',
      domainId: 'general_wellness',
      text: 'What is your primary wellness aspiration?',
      helperText: 'Your answers help us tailor balanced evidence-based guidance.',
      answerType: AnswerType.singleChoice,
      isRequired: true,
      displayOrder: 10,
      options: [
        AnswerOption(id: 'vitality_longevity', label: 'Daily vitality & healthy longevity'),
        AnswerOption(id: 'clean_eating', label: 'Clean, balanced daily nutrition'),
        AnswerOption(id: 'habit_consistency', label: 'Building sustainable wellness micro-habits'),
        AnswerOption(id: 'stress_energy_balance', label: 'Balanced energy and stress management'),
      ],
    ),
    const QuestionItem(
      id: 'gen_daily_water',
      domainId: 'general_wellness',
      text: 'How much water or hydration do you typically drink daily?',
      answerType: AnswerType.singleChoice,
      isRequired: false,
      displayOrder: 11,
      options: [
        AnswerOption(id: 'under_1l', label: 'Less than 1 liter (< 4 glasses)'),
        AnswerOption(id: '1_to_2l', label: '1 to 2 liters (4-8 glasses)'),
        AnswerOption(id: '2_to_3l', label: '2 to 3 liters (8-12 glasses)'),
        AnswerOption(id: 'over_3l', label: 'More than 3 liters (> 12 glasses)'),
      ],
    ),

    // --------------------------------------------------------------------------
    // WEIGHT MANAGEMENT
    // --------------------------------------------------------------------------
    const QuestionItem(
      id: 'wm_primary_objective',
      domainId: 'weight_management',
      text: 'What is your main weight management objective?',
      answerType: AnswerType.singleChoice,
      isRequired: true,
      displayOrder: 20,
      options: [
        AnswerOption(id: 'gradual_fat_loss', label: 'Gradual, sustainable fat reduction'),
        AnswerOption(id: 'body_recomposition', label: 'Body recomposition (lower fat, maintain muscle)'),
        AnswerOption(id: 'post_weight_loss_maintenance', label: 'Maintaining current healthy weight'),
        AnswerOption(id: 'metabolic_rate_support', label: 'Supporting healthy basal metabolic rate'),
      ],
    ),
    const QuestionItem(
      id: 'wm_biggest_challenge',
      domainId: 'weight_management',
      text: 'What feels like your biggest challenge with food?',
      answerType: AnswerType.multipleChoice,
      isRequired: false,
      displayOrder: 21,
      options: [
        AnswerOption(id: 'evening_cravings', label: 'Late evening sugar or snack cravings'),
        AnswerOption(id: 'portion_control', label: 'Portion sizing and feeling full'),
        AnswerOption(id: 'busy_schedule', label: 'Cooking healthy meals while busy'),
        AnswerOption(id: 'emotional_eating', label: 'Eating when stressed or bored'),
      ],
    ),

    // --------------------------------------------------------------------------
    // WEIGHT GAIN
    // --------------------------------------------------------------------------
    const QuestionItem(
      id: 'wg_target_goal',
      domainId: 'weight_gain',
      text: 'What type of weight gain are you looking to achieve?',
      answerType: AnswerType.singleChoice,
      isRequired: true,
      displayOrder: 25,
      options: [
        AnswerOption(id: 'lean_mass_bulk', label: 'Lean mass and strength increase'),
        AnswerOption(id: 'general_healthy_weight', label: 'Reaching a healthy BMI from underweight'),
        AnswerOption(id: 'appetite_stimulation', label: 'Overcoming poor appetite or early satiety'),
      ],
    ),

    // --------------------------------------------------------------------------
    // MUSCLE BUILDING & HYPERTROPHY
    // --------------------------------------------------------------------------
    const QuestionItem(
      id: 'mb_training_frequency',
      domainId: 'muscle_building',
      text: 'How frequently do you perform resistance or strength training?',
      answerType: AnswerType.singleChoice,
      isRequired: true,
      displayOrder: 30,
      options: [
        AnswerOption(id: 'none_yet', label: 'Not currently training, planning to start'),
        AnswerOption(id: '1_2_days', label: '1 to 2 sessions per week'),
        AnswerOption(id: '3_4_days', label: '3 to 4 sessions per week'),
        AnswerOption(id: '5_plus_days', label: '5 or more sessions per week'),
      ],
    ),
    const QuestionItem(
      id: 'mb_protein_focus',
      domainId: 'muscle_building',
      text: 'Do you currently track or prioritize daily protein intake?',
      answerType: AnswerType.singleChoice,
      isRequired: false,
      displayOrder: 31,
      options: [
        AnswerOption(id: 'yes_tracking', label: 'Yes, actively tracking daily grams'),
        AnswerOption(id: 'informal', label: 'I try to include protein in every meal'),
        AnswerOption(id: 'not_sure', label: 'Not sure how much protein I need'),
      ],
    ),

    // --------------------------------------------------------------------------
    // DIGESTIVE & GUT HEALTH
    // --------------------------------------------------------------------------
    const QuestionItem(
      id: 'dh_main_symptom',
      domainId: 'digestive_health',
      text: 'Which digestive sensations do you experience most often?',
      answerType: AnswerType.multipleChoice,
      isRequired: true,
      displayOrder: 40,
      options: [
        AnswerOption(id: 'bloating_post_meal', label: 'Post-meal bloating or abdominal distension'),
        AnswerOption(id: 'acid_reflux', label: 'Heartburn, reflux, or sour taste'),
        AnswerOption(id: 'sluggish_motility', label: 'Infrequent bowel movements or constipation'),
        AnswerOption(id: 'irregular_stools', label: 'Loose or fluctuating bowel habits'),
      ],
    ),
    const QuestionItem(
      id: 'dh_fermented_foods',
      domainId: 'digestive_health',
      text: 'How frequently do you consume fermented or probiotic-rich foods?',
      answerType: AnswerType.singleChoice,
      isRequired: false,
      displayOrder: 41,
      options: [
        AnswerOption(id: 'daily', label: 'Daily (yogurt, kefir, kimchi, idli)'),
        AnswerOption(id: 'occasional', label: '1-3 times a week'),
        AnswerOption(id: 'rarely', label: 'Rarely or never'),
      ],
    ),

    // --------------------------------------------------------------------------
    // DIABETES & BLOOD GLUCOSE (Appears ONLY when diabetes is selected!)
    // --------------------------------------------------------------------------
    const QuestionItem(
      id: 'dia_diagnosed_status',
      domainId: 'diabetes_blood_glucose',
      text: 'What best describes your blood glucose context?',
      helperText: 'Optional. We use this strictly to match research on glycemic stability.',
      answerType: AnswerType.singleChoice,
      isRequired: false,
      sensitivity: SensitivityClassification.sensitiveHealth,
      displayOrder: 50,
      options: [
        AnswerOption(id: 'type2_diabetes', label: 'Diagnosed Type 2 Diabetes'),
        AnswerOption(id: 'prediabetes', label: 'Prediabetes or elevated fasting glucose'),
        AnswerOption(id: 'type1_diabetes', label: 'Diagnosed Type 1 Diabetes'),
        AnswerOption(id: 'gestational_diabetes', label: 'Gestational Diabetes'),
        AnswerOption(id: 'prevention_focus', label: 'No diagnosis, focus on blood sugar prevention'),
        AnswerOption(id: 'prefer_not_to_say', label: 'Prefer not to say'),
      ],
    ),
    const QuestionItem(
      id: 'dia_glucose_monitoring',
      domainId: 'diabetes_blood_glucose',
      text: 'Do you currently monitor your blood glucose?',
      answerType: AnswerType.singleChoice,
      isRequired: false,
      sensitivity: SensitivityClassification.sensitiveHealth,
      displayOrder: 51,
      options: [
        AnswerOption(id: 'cgm', label: 'Continuous Glucose Monitor (CGM)'),
        AnswerOption(id: 'fingerstick', label: 'Periodic fingerstick glucometer'),
        AnswerOption(id: 'lab_hba1c_only', label: 'Occasional lab HbA1c tests only'),
        AnswerOption(id: 'no_monitoring', label: 'Not currently monitoring'),
      ],
    ),

    // --------------------------------------------------------------------------
    // SLEEP & RECOVERY
    // --------------------------------------------------------------------------
    const QuestionItem(
      id: 'slp_routine_quality',
      domainId: 'sleep_recovery',
      text: 'What most accurately reflects your sleep pattern?',
      answerType: AnswerType.singleChoice,
      isRequired: true,
      displayOrder: 60,
      options: [
        AnswerOption(id: 'falling_asleep', label: 'Difficulty falling asleep (racing mind / restlessness)'),
        AnswerOption(id: 'staying_asleep', label: 'Waking up during the night and struggling to return to sleep'),
        AnswerOption(id: 'unrefreshing', label: 'Sleeping 7-8 hours but waking up unrefreshed'),
        AnswerOption(id: 'erratic_schedule', label: 'Shift work or unpredictable bedtimes'),
      ],
    ),

    // --------------------------------------------------------------------------
    // ENERGY & FATIGUE
    // --------------------------------------------------------------------------
    const QuestionItem(
      id: 'nrg_pattern',
      domainId: 'energy_fatigue',
      text: 'When do you feel your energy dip most acutely?',
      answerType: AnswerType.singleChoice,
      isRequired: false,
      displayOrder: 70,
      options: [
        AnswerOption(id: 'morning_inertia', label: 'First waking up / takes hours to get going'),
        AnswerOption(id: 'post_lunch_slump', label: 'Mid-afternoon post-lunch crash (2 PM - 4 PM)'),
        AnswerOption(id: 'constant_low', label: 'Persistent, flat low energy all day'),
        AnswerOption(id: 'exertion_exhaustion', label: 'Sudden depletion after mild physical activity'),
      ],
    ),

    // --------------------------------------------------------------------------
    // MENTAL WELLBEING & STRESS
    // --------------------------------------------------------------------------
    const QuestionItem(
      id: 'str_coping_style',
      domainId: 'mental_wellbeing_stress',
      text: 'How does daily stress typically manifest physically for you?',
      answerType: AnswerType.multipleChoice,
      isRequired: false,
      displayOrder: 80,
      options: [
        AnswerOption(id: 'muscle_tension', label: 'Neck, shoulder, or jaw tension'),
        AnswerOption(id: 'digestive_knot', label: 'Stomach butterflies, cramping, or appetite drop'),
        AnswerOption(id: 'restlessness', label: 'Restless mind, rapid breathing, or sleep disruption'),
        AnswerOption(id: 'sugar_cravings', label: 'Immediate desire for quick carbohydrates or sweets'),
      ],
    ),
  ];

  /// Resolves the deduplicated, ordered list of questions relevant to the user's selected concerns.
  static List<QuestionItem> resolveQuestionsForConcerns(
    Set<String> selectedConcernIds, {
    Map<String, dynamic> currentAnswers = const {},
  }) {
    if (selectedConcernIds.isEmpty) {
      // For completely new users with no concerns selected, return empty list
      return const [];
    }

    final matched = <QuestionItem>[];
    final seenIds = <String>{};

    for (final q in masterQuestions) {
      if (seenIds.contains(q.id)) continue;
      if (q.evaluateVisibility(selectedConcernIds, currentAnswers)) {
        matched.add(q);
        seenIds.add(q.id);
      }
    }

    matched.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return matched;
  }
}


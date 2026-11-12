// ==============================================================================
// Nutrient Earth — Universal Health Concern Domain Model
// Defines the 18 independent health and wellness domains.
// Guarantees onboarding is user-driven and general-wellness-first,
// without assuming diabetes or any specific pathology.
// ==============================================================================

import 'package:flutter/foundation.dart';

enum ConcernCategory {
  lifestyle,
  physicalFitness,
  metabolic,
  digestive,
  preventive,
  traditional,
  other,
}

@immutable
class HealthConcernDomain {
  final String id;
  final String name;
  final String description;
  final ConcernCategory category;
  final String iconName;
  final List<String> searchTags;
  final bool isPathology;
  final List<String> defaultDifficultyCodes;

  const HealthConcernDomain({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.iconName,
    required this.searchTags,
    this.isPathology = false,
    this.defaultDifficultyCodes = const [],
  });

  static const List<HealthConcernDomain> allDomains = [
    // 1. General health and wellness
    HealthConcernDomain(
      id: 'general_wellness',
      name: 'General Health & Wellness',
      description: 'Overall vitality, balanced nutrition, daily energy, and healthy living habits.',
      category: ConcernCategory.lifestyle,
      iconName: 'eco',
      searchTags: ['wellness', 'energy', 'vitality', 'health', 'lifestyle', 'balance', 'nutrition'],
      isPathology: false,
      defaultDifficultyCodes: ['NRG-01', 'NRG-02', 'SLP-01'],
    ),

    // 2. Weight management
    HealthConcernDomain(
      id: 'weight_management',
      name: 'Weight Management',
      description: 'Sustainable weight loss, healthy fat reduction, and appetite regulation.',
      category: ConcernCategory.physicalFitness,
      iconName: 'scale',
      searchTags: ['weight', 'weight loss', 'fat loss', 'slimming', 'calorie deficit', 'metabolism'],
      isPathology: false,
      defaultDifficultyCodes: ['WGT-01', 'NRG-02', 'DIG-02'],
    ),

    // 3. Weight gain
    HealthConcernDomain(
      id: 'weight_gain',
      name: 'Weight Gain',
      description: 'Healthy caloric surplus, nutrient-dense nutrition, and lean body mass accumulation.',
      category: ConcernCategory.physicalFitness,
      iconName: 'trending_up',
      searchTags: ['weight gain', 'underweight', 'bulk', 'surplus', 'appetite', 'nutrition'],
      isPathology: false,
      defaultDifficultyCodes: ['WGT-02', 'DIG-01'],
    ),

    // 4. Muscle building
    HealthConcernDomain(
      id: 'muscle_building',
      name: 'Muscle Building & Hypertrophy',
      description: 'Strength development, muscle protein synthesis, and muscular adaptations.',
      category: ConcernCategory.physicalFitness,
      iconName: 'fitness_center',
      searchTags: ['muscle', 'strength', 'hypertrophy', 'gym', 'protein', 'gains', 'resistance'],
      isPathology: false,
      defaultDifficultyCodes: ['MSK-04', 'NRG-04'],
    ),

    // 5. Fitness and physical performance
    HealthConcernDomain(
      id: 'fitness_performance',
      name: 'Fitness & Physical Performance',
      description: 'Aerobic endurance, cardiovascular fitness, athletic conditioning, and stamina.',
      category: ConcernCategory.physicalFitness,
      iconName: 'sprint',
      searchTags: ['fitness', 'cardio', 'stamina', 'running', 'endurance', 'athletic', 'performance'],
      isPathology: false,
      defaultDifficultyCodes: ['NRG-04', 'MSK-02'],
    ),

    // 6. Energy and fatigue
    HealthConcernDomain(
      id: 'energy_fatigue',
      name: 'Energy & Fatigue',
      description: 'Overcoming daily sluggishness, mental fog, daytime fatigue, and low vitality.',
      category: ConcernCategory.lifestyle,
      iconName: 'bolt',
      searchTags: ['energy', 'tired', 'fatigue', 'exhausted', 'sluggish', 'brain fog', 'vitality'],
      isPathology: false,
      defaultDifficultyCodes: ['NRG-01', 'NRG-03', 'NRG-02'],
    ),

    // 7. Sleep and recovery
    HealthConcernDomain(
      id: 'sleep_recovery',
      name: 'Sleep & Recovery',
      description: 'Restful night sleep, consistent circadian rhythm, waking refreshed, and biological recovery.',
      category: ConcernCategory.lifestyle,
      iconName: 'bedtime',
      searchTags: ['sleep', 'insomnia', 'waking up', 'deep sleep', 'rem', 'rest', 'circadian', 'recovery'],
      isPathology: false,
      defaultDifficultyCodes: ['SLP-01', 'SLP-02', 'NRG-03'],
    ),

    // 8. Digestive health
    HealthConcernDomain(
      id: 'digestive_health',
      name: 'Digestive & Gut Health',
      description: 'Relief from bloating, acidity, irregular bowel motility, and supporting gut microbiome.',
      category: ConcernCategory.digestive,
      iconName: 'digest',
      searchTags: ['gut', 'bloating', 'digestion', 'acid reflux', 'ibs', 'gas', 'constipation', 'stomach'],
      isPathology: false,
      defaultDifficultyCodes: ['DIG-01', 'DIG-02', 'DIG-03'],
    ),

    // 9. Diabetes and blood glucose
    HealthConcernDomain(
      id: 'diabetes_blood_glucose',
      name: 'Diabetes & Blood Glucose',
      description: 'Glycemic control, steady insulin response, HbA1c optimization, and glucose stability.',
      category: ConcernCategory.metabolic,
      iconName: 'bloodtype',
      searchTags: ['diabetes', 'prediabetes', 'sugar', 'blood sugar', 'glucose', 'insulin', 'a1c', 'type 1', 'type 2'],
      isPathology: true,
      defaultDifficultyCodes: ['GLU-01', 'REN-02', 'NRV-01'],
    ),

    // 10. Cardiovascular health
    HealthConcernDomain(
      id: 'cardiovascular_health',
      name: 'Cardiovascular Health',
      description: 'Heart health, blood pressure balance, cholesterol (LDL/HDL) management, and circulation.',
      category: ConcernCategory.metabolic,
      iconName: 'favorite',
      searchTags: ['heart', 'cardiovascular', 'blood pressure', 'hypertension', 'cholesterol', 'artery'],
      isPathology: true,
      defaultDifficultyCodes: ['MSK-02', 'NRG-04'],
    ),

    // 11. Hormonal and metabolic health
    HealthConcernDomain(
      id: 'hormonal_metabolic',
      name: 'Hormonal & Metabolic Health',
      description: 'Thyroid function, PCOS hormonal balance, cortisol resilience, and metabolic rate.',
      category: ConcernCategory.metabolic,
      iconName: 'vital_signs',
      searchTags: ['hormones', 'pcos', 'thyroid', 'cortisol', 'metabolism', 'endocrine', 'estrogen'],
      isPathology: true,
      defaultDifficultyCodes: ['NRG-01', 'WGT-01', 'SLP-01'],
    ),

    // 12. Nutrition deficiencies
    HealthConcernDomain(
      id: 'nutrition_deficiencies',
      name: 'Nutrition Deficiencies',
      description: 'Addressing low iron, vitamin D, B12, magnesium, and optimizing micronutrient absorption.',
      category: ConcernCategory.lifestyle,
      iconName: 'vaccines',
      searchTags: ['deficiency', 'vitamin d', 'b12', 'iron', 'anemia', 'magnesium', 'minerals', 'nutrients'],
      isPathology: false,
      defaultDifficultyCodes: ['NRG-01', 'MSK-03'],
    ),

    // 13. Food allergies and intolerances
    HealthConcernDomain(
      id: 'food_allergies_intolerances',
      name: 'Food Allergies & Intolerances',
      description: 'Managing lactose intolerance, gluten sensitivity, histamine triggers, and food sensitivities.',
      category: ConcernCategory.digestive,
      iconName: 'no_food',
      searchTags: ['allergy', 'allergies', 'intolerance', 'gluten', 'dairy', 'lactose', 'nuts', 'sensitivity'],
      isPathology: false,
      defaultDifficultyCodes: ['DIG-02', 'DIG-03'],
    ),

    // 14. Mental wellbeing and stress
    HealthConcernDomain(
      id: 'mental_wellbeing_stress',
      name: 'Mental Wellbeing & Stress',
      description: 'Stress resilience, anxiety relief, mood stability, mental clarity, and focus.',
      category: ConcernCategory.lifestyle,
      iconName: 'psychology',
      searchTags: ['stress', 'cortisol', 'anxiety', 'mental health', 'mood', 'burnout', 'focus', 'clarity'],
      isPathology: false,
      defaultDifficultyCodes: ['STR-01', 'SLP-01', 'NRG-02'],
    ),

    // 15. Skin and hair wellness
    HealthConcernDomain(
      id: 'skin_hair_wellness',
      name: 'Skin & Hair Wellness',
      description: 'Clear radiant skin, collagen synthesis, hair strength, and reducing shedding/thinning.',
      category: ConcernCategory.lifestyle,
      iconName: 'spa',
      searchTags: ['skin', 'hair', 'hair loss', 'acne', 'glow', 'collagen', 'dermatology', 'thinning'],
      isPathology: false,
      defaultDifficultyCodes: ['SKN-01', 'DIG-02'],
    ),

    // 16. Healthy ageing
    HealthConcernDomain(
      id: 'healthy_ageing',
      name: 'Healthy Ageing & Longevity',
      description: 'Joint preservation, cellular longevity, cognitive sharpness, and bone mineral density.',
      category: ConcernCategory.preventive,
      iconName: 'elderly',
      searchTags: ['aging', 'ageing', 'longevity', 'joints', 'bone density', 'lifespan', 'mobility'],
      isPathology: false,
      defaultDifficultyCodes: ['MSK-01', 'MSK-02', 'NRG-04'],
    ),

    // 17. Ayurveda and traditional wellness
    HealthConcernDomain(
      id: 'ayurveda_traditional',
      name: 'Ayurveda & Traditional Wellness',
      description: 'Dosha harmony (Vata, Pitta, Kapha), herbal adaptogens, and traditional lifestyle balance.',
      category: ConcernCategory.traditional,
      iconName: 'self_improvement',
      searchTags: ['ayurveda', 'dosha', 'herbs', 'traditional', 'holistic', 'ashwagandha', 'natural'],
      isPathology: false,
      defaultDifficultyCodes: ['DIG-02', 'SLP-01'],
    ),

    // 18. Other concerns
    HealthConcernDomain(
      id: 'other_concerns',
      name: 'Other Specific Questions',
      description: 'Personal nutrition questions, scientific hypotheses, or unique health goals.',
      category: ConcernCategory.other,
      iconName: 'help_outline',
      searchTags: ['other', 'question', 'research', 'hypothesis', 'custom', 'inquiry'],
      isPathology: false,
      defaultDifficultyCodes: ['OTH-01'],
    ),
  ];

  static HealthConcernDomain? findById(String id) {
    try {
      return allDomains.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<HealthConcernDomain> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return allDomains;
    return allDomains.where((d) {
      return d.name.toLowerCase().contains(q) ||
          d.description.toLowerCase().contains(q) ||
          d.searchTags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }
}


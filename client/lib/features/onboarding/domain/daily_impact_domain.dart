// ==============================================================================
// Nutrient Earth — Universal Daily Impact Domain Model
// Resolves functional difficulties dynamically based on the user's selected concerns.
// Eradicates the hardcoded diabetes/neuropathy fallback.
// ==============================================================================

import 'package:flutter/foundation.dart';

@immutable
class DailyImpactSpecimen {
  final String id;
  final String code;
  final String title;
  final String domain;
  final String concernId;
  final String description;

  const DailyImpactSpecimen({
    required this.id,
    required this.code,
    required this.title,
    required this.domain,
    required this.concernId,
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'title': title,
        'domain': domain,
        'concernId': concernId,
        'description': description,
      };

  factory DailyImpactSpecimen.fromJson(Map<String, dynamic> json) => DailyImpactSpecimen(
        id: json['id'] as String? ?? '',
        code: json['code'] as String? ?? '',
        title: json['title'] as String? ?? '',
        domain: json['domain'] as String? ?? '',
        concernId: json['concernId'] as String? ?? '',
        description: json['description'] as String? ?? '',
      );
}

class UniversalDailyImpactCatalog {
  static const Map<String, DailyImpactSpecimen> allSpecimens = {
    // General Wellness & Vitality
    'NRG-01': DailyImpactSpecimen(
      id: 'nrg-01',
      code: 'NRG-01',
      title: 'Difficulty maintaining steady daytime energy',
      domain: 'Vitality & Stamina',
      concernId: 'general_wellness',
      description: 'Struggling with mid-day energy slumps or low stamina during routine activities.',
    ),
    'NRG-02': DailyImpactSpecimen(
      id: 'nrg-02',
      code: 'NRG-02',
      title: 'Difficulty completing everyday productive tasks',
      domain: 'Executive Energy',
      concernId: 'energy_fatigue',
      description: 'Feeling held back from checking off daily personal or work tasks due to fatigue.',
    ),

    // Sleep & Recovery
    'SLP-01': DailyImpactSpecimen(
      id: 'slp-01',
      code: 'SLP-01',
      title: 'Difficulty falling asleep within 30 minutes',
      domain: 'Circadian Sleep Onset',
      concernId: 'sleep_recovery',
      description: 'Tossing and turning, racing thoughts, or restless bedtime state.',
    ),
    'SLP-02': DailyImpactSpecimen(
      id: 'slp-02',
      code: 'SLP-02',
      title: 'Waking unrefreshed despite regular bedtimes',
      domain: 'Restorative Sleep Depth',
      concernId: 'sleep_recovery',
      description: 'Feeling groggy and unenergized upon waking in the morning.',
    ),

    // Digestive & Gut Health
    'DIG-01': DailyImpactSpecimen(
      id: 'dig-01',
      code: 'DIG-01',
      title: 'Sluggish digestive transit or constipation',
      domain: 'Bowel Motility',
      concernId: 'digestive_health',
      description: 'Straining or irregular frequency affecting physical comfort.',
    ),
    'DIG-02': DailyImpactSpecimen(
      id: 'dig-02',
      code: 'DIG-02',
      title: 'Abdominal bloating or post-meal fullness',
      domain: 'Digestive Comfort',
      concernId: 'digestive_health',
      description: 'Discomfort, tight waistband, or heaviness after eating.',
    ),

    // Physical Movement & Fitness
    'MSK-01': DailyImpactSpecimen(
      id: 'msk-01',
      code: 'MSK-01',
      title: 'Joint stiffness or reduced mobility',
      domain: 'Joint Mobility',
      concernId: 'fitness_performance',
      description: 'Stiffness in knees, hips, or shoulders when starting to move.',
    ),
    'MSK-02': DailyImpactSpecimen(
      id: 'msk-02',
      code: 'MSK-02',
      title: 'Difficulty standing or walking for extended periods',
      domain: 'Postural Endurance',
      concernId: 'fitness_performance',
      description: 'Lower back or leg strain during prolonged standing.',
    ),
    'NRG-04': DailyImpactSpecimen(
      id: 'nrg-04',
      code: 'NRG-04',
      title: 'Prolonged soreness or slow physical recovery',
      domain: 'Muscular Recovery',
      concernId: 'muscle_building',
      description: 'Taking days to recover from workouts or brisk physical activity.',
    ),

    // Weight & Appetite
    'WGT-01': DailyImpactSpecimen(
      id: 'wgt-01',
      code: 'WGT-01',
      title: 'Unpredictable cravings or hunger spikes',
      domain: 'Appetite Regulation',
      concernId: 'weight_management',
      description: 'Urges to snack between meals or late in the evening.',
    ),

    // Stress & Mental Focus
    'STR-01': DailyImpactSpecimen(
      id: 'str-01',
      code: 'STR-01',
      title: 'Brain fog or difficulty sustaining concentration',
      domain: 'Cognitive Focus',
      concernId: 'mental_wellbeing_stress',
      description: 'Trouble maintaining deep work attention or finding words.',
    ),

    // Diabetes & Blood Glucose (Appears ONLY if diabetes/glucose is selected)
    'GLU-01': DailyImpactSpecimen(
      id: 'glu-01',
      code: 'GLU-01',
      title: 'Post-meal glucose spikes or energy crashes',
      domain: 'Glycemic Regulation',
      concernId: 'diabetes_blood_glucose',
      description: 'Pronounced lethargy, shakiness, or thirst after high-carb meals.',
    ),
    'REN-02': DailyImpactSpecimen(
      id: 'ren-02',
      code: 'REN-02',
      title: 'Excessive thirst or dry mouth',
      domain: 'Electrolyte Hydration',
      concernId: 'diabetes_blood_glucose',
      description: 'Constantly needing water or waking up thirsty.',
    ),
    'NRV-01': DailyImpactSpecimen(
      id: 'nrv-01',
      code: 'NRV-01',
      title: 'Tingling or numbness in feet or hands',
      domain: 'Peripheral Signaling',
      concernId: 'diabetes_blood_glucose',
      description: 'Pins-and-needles sensation in fingers or toes.',
    ),
  };

  /// Resolves relevant specimens based on the user's selected concerns.
  /// If the user did NOT select diabetes, diabetes questions (GLU-01, REN-02, NRV-01) NEVER appear.
  static List<DailyImpactSpecimen> resolveSpecimensForUser({
    required Set<String> selectedConcernIds,
    Set<String> explicitlySelectedDifficulties = const {},
  }) {
    final result = <DailyImpactSpecimen>[];
    final seenCodes = <String>{};

    // 1. If user explicitly selected difficulties in Step 2, map them first
    for (final code in explicitlySelectedDifficulties) {
      final upper = code.toUpperCase();
      if (allSpecimens.containsKey(upper) && !seenCodes.contains(upper)) {
        result.add(allSpecimens[upper]!);
        seenCodes.add(upper);
      }
    }

    // 2. Map relevant specimens based on selected health concerns
    for (final concernId in selectedConcernIds) {
      for (final specimen in allSpecimens.values) {
        if (specimen.concernId == concernId && !seenCodes.contains(specimen.code)) {
          // Guard: Diabetes specimens appear ONLY if diabetes concern was selected
          if (specimen.concernId == 'diabetes_blood_glucose' && !selectedConcernIds.contains('diabetes_blood_glucose')) {
            continue;
          }
          result.add(specimen);
          seenCodes.add(specimen.code);
        }
      }
    }

    // 3. Adaptive Universal Fallback (if user skipped Step 2 or selected no difficulties)
    if (result.isEmpty) {
      if (selectedConcernIds.contains('diabetes_blood_glucose')) {
        // Only if user selected diabetes, show glycemic & energy focus
        return [
          allSpecimens['GLU-01']!,
          allSpecimens['NRG-01']!,
          allSpecimens['REN-02']!,
          allSpecimens['SLP-01']!,
        ];
      } else if (selectedConcernIds.contains('weight_management')) {
        return [
          allSpecimens['WGT-01']!,
          allSpecimens['NRG-01']!,
          allSpecimens['DIG-02']!,
          allSpecimens['SLP-01']!,
        ];
      } else if (selectedConcernIds.contains('digestive_health')) {
        return [
          allSpecimens['DIG-01']!,
          allSpecimens['DIG-02']!,
          allSpecimens['NRG-01']!,
          allSpecimens['SLP-01']!,
        ];
      } else if (selectedConcernIds.contains('muscle_building') || selectedConcernIds.contains('fitness_performance')) {
        return [
          allSpecimens['NRG-04']!,
          allSpecimens['MSK-02']!,
          allSpecimens['SLP-02']!,
          allSpecimens['NRG-01']!,
        ];
      } else if (selectedConcernIds.contains('sleep_recovery')) {
        return [
          allSpecimens['SLP-01']!,
          allSpecimens['SLP-02']!,
          allSpecimens['NRG-01']!,
          allSpecimens['STR-01']!,
        ];
      } else {
        // General Wellness Universal Default: Vitality, Sleep, Digestion, Recovery (Zero disease assumptions!)
        return [
          allSpecimens['NRG-01']!,
          allSpecimens['SLP-01']!,
          allSpecimens['DIG-02']!,
          allSpecimens['NRG-04']!,
        ];
      }
    }

    // Limit to 4-5 high-relevance specimens to avoid overwhelming the user
    return result.take(5).toList();
  }
}


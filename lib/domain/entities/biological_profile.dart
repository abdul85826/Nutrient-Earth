
/// Clinical history object representing medical and physical conditions.
class ClinicalHistory {
  final List<String> currentSymptoms;
  final List<String> currentMedications;
  final List<String> documentedAllergies;
  final List<String> hereditaryRisks;

  const ClinicalHistory({
    required this.currentSymptoms,
    required this.currentMedications,
    required this.documentedAllergies,
    required this.hereditaryRisks,
  });

  Map<String, dynamic> toMap() => {
        'current_symptoms': currentSymptoms,
        'current_medications': currentMedications,
        'documented_allergies': documentedAllergies,
        'hereditary_risks': hereditaryRisks,
      };

  factory ClinicalHistory.fromMap(Map<String, dynamic> map) {
    return ClinicalHistory(
      currentSymptoms: List<String>.from(map['current_symptoms'] ?? []),
      currentMedications: List<String>.from(map['current_medications'] ?? []),
      documentedAllergies: List<String>.from(map['documented_allergies'] ?? []),
      hereditaryRisks: List<String>.from(map['hereditary_risks'] ?? []),
    );
  }
}

/// Dynamic behavioral indicators that represent psychological and metabolic traits.
class BehavioralDynamics {
  final List<String> foodPatterns;
  final bool hasEmotionalEating;
  final double anxietyIndex; // 0.0 to 10.0
  final double burnoutTendency; // 0.0 to 10.0
  final double behavioralConsistency; // 0.0 to 1.0

  const BehavioralDynamics({
    required this.foodPatterns,
    required this.hasEmotionalEating,
    required this.anxietyIndex,
    required this.burnoutTendency,
    required this.behavioralConsistency,
  });

  Map<String, dynamic> toMap() => {
        'food_patterns': foodPatterns,
        'has_emotional_eating': hasEmotionalEating,
        'anxiety_index': anxietyIndex,
        'burnout_tendency': burnoutTendency,
        'behavioral_consistency': behavioralConsistency,
      };

  factory BehavioralDynamics.fromMap(Map<String, dynamic> map) {
    return BehavioralDynamics(
      foodPatterns: List<String>.from(map['food_patterns'] ?? []),
      hasEmotionalEating: map['has_emotional_eating'] ?? false,
      anxietyIndex: (map['anxiety_index'] ?? 0.0).toDouble(),
      burnoutTendency: (map['burnout_tendency'] ?? 0.0).toDouble(),
      behavioralConsistency: (map['behavioral_consistency'] ?? 1.0).toDouble(),
    );
  }
}

/// Physical bio-dimensions tracking day-to-day dynamic load.
class PhysicalBiometrics {
  final double hydrationLiters;
  final double sleepHours;
  final double stressLevel; // 0.0 to 10.0
  final double stepCount;
  final double sunlightExposureMinutes;
  final double screenTimeMinutes;
  final double energyLevel; // 1.0 to 5.0

  const PhysicalBiometrics({
    required this.hydrationLiters,
    required this.sleepHours,
    required this.stressLevel,
    required this.stepCount,
    required this.sunlightExposureMinutes,
    required this.screenTimeMinutes,
    required this.energyLevel,
  });

  Map<String, dynamic> toMap() => {
        'hydration_liters': hydrationLiters,
        'sleep_hours': sleepHours,
        'stress_level': stressLevel,
        'step_count': stepCount,
        'sunlight_exposure_minutes': sunlightExposureMinutes,
        'screen_time_minutes': screenTimeMinutes,
        'energy_level': energyLevel,
      };

  factory PhysicalBiometrics.fromMap(Map<String, dynamic> map) {
    return PhysicalBiometrics(
      hydrationLiters: (map['hydration_liters'] ?? 0.0).toDouble(),
      sleepHours: (map['sleep_hours'] ?? 0.0).toDouble(),
      stressLevel: (map['stress_level'] ?? 0.0).toDouble(),
      stepCount: (map['step_count'] ?? 0.0).toDouble(),
      sunlightExposureMinutes: (map['sunlight_exposure_minutes'] ?? 0.0).toDouble(),
      screenTimeMinutes: (map['screen_time_minutes'] ?? 0.0).toDouble(),
      energyLevel: (map['energy_level'] ?? 3.0).toDouble(),
    );
  }
}

/// The absolute core entity of Nutrient Earth: The Human Biological Profile.
class BiologicalProfile {
  final String userId;
  final int age;
  final String gender;
  final double weightKg;
  final double heightCm;
  
  // Advanced biological segments
  final ClinicalHistory clinicalHistory;
  final PhysicalBiometrics biometrics;
  final BehavioralDynamics behavioral;

  // Metabolic/Environmental metrics
  final String digestionRating; // good, fair, poor
  final String bowelPattern; // normal, irregular
  final String hormonalProfile; // normal, fluctuating
  final double occupationalStress; // 0.0 to 10.0
  final bool isClimateAdapted;

  const BiologicalProfile({
    required this.userId,
    required this.age,
    required this.gender,
    required this.weightKg,
    required this.heightCm,
    required this.clinicalHistory,
    required this.biometrics,
    required this.behavioral,
    required this.digestionRating,
    required this.bowelPattern,
    required this.hormonalProfile,
    required this.occupationalStress,
    required this.isClimateAdapted,
  });

  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));

  bool get isHealthyWeight => bmi >= 18.5 && bmi < 25.0;

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'age': age,
        'gender': gender,
        'weight_kg': weightKg,
        'height_cm': heightCm,
        'clinical_history': clinicalHistory.toMap(),
        'biometrics': biometrics.toMap(),
        'behavioral': behavioral.toMap(),
        'digestion_rating': digestionRating,
        'bowel_pattern': bowelPattern,
        'hormonal_profile': hormonalProfile,
        'occupational_stress': occupationalStress,
        'is_climate_adapted': isClimateAdapted,
        'computed_bmi': bmi,
      };

  factory BiologicalProfile.fromMap(Map<String, dynamic> map) {
    return BiologicalProfile(
      userId: map['user_id'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? 'male',
      weightKg: (map['weight_kg'] ?? 0.0).toDouble(),
      heightCm: (map['height_cm'] ?? 0.0).toDouble(),
      clinicalHistory: ClinicalHistory.fromMap(map['clinical_history'] ?? {}),
      biometrics: PhysicalBiometrics.fromMap(map['biometrics'] ?? {}),
      behavioral: BehavioralDynamics.fromMap(map['behavioral'] ?? {}),
      digestionRating: map['digestion_rating'] ?? 'good',
      bowelPattern: map['bowel_pattern'] ?? 'normal',
      hormonalProfile: map['hormonal_profile'] ?? 'normal',
      occupationalStress: (map['occupational_stress'] ?? 0.0).toDouble(),
      isClimateAdapted: map['is_climate_adapted'] ?? true,
    );
  }
}

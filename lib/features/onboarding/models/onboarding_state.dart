class OnboardingState {
  final String name;
  final int age;
  final String sex;
  final double height;
  final double weight;
  final String country;
  final String city;
  final String occupation;
  final String primaryGoal;

  // Lifestyle
  final String sleepTime;
  final String wakeTime;
  final String activityLevel;
  final String exercise;
  final String smoking;
  final String alcohol;
  final int stressLevel;

  // Food
  final String dietPreference; // Veg / Non-Veg
  final double waterIntake;
  final String mealTiming;
  final List<String> supplements;

  // Family Risk
  final bool hasDiabetesRisk;
  final bool hasHeartDiseaseRisk;
  final bool hasCancerRisk;
  final bool hasThyroidRisk;
  final bool hasBloodPressureRisk;

  final int currentStep;
  final bool isLoading;

  OnboardingState({
    this.name = '',
    this.age = 25,
    this.sex = 'Male',
    this.height = 175.0,
    this.weight = 70.0,
    this.country = '',
    this.city = '',
    this.occupation = '',
    this.primaryGoal = 'General Health',
    this.sleepTime = '22:00',
    this.wakeTime = '06:00',
    this.activityLevel = 'Moderate',
    this.exercise = 'Moderate',
    this.smoking = 'No',
    this.alcohol = 'No',
    this.stressLevel = 3,
    this.dietPreference = 'Veg',
    this.waterIntake = 2.0,
    this.mealTiming = 'Consistent',
    this.supplements = const [],
    this.hasDiabetesRisk = false,
    this.hasHeartDiseaseRisk = false,
    this.hasCancerRisk = false,
    this.hasThyroidRisk = false,
    this.hasBloodPressureRisk = false,
    this.currentStep = 0,
    this.isLoading = false,
  });

  OnboardingState copyWith({
    String? name,
    int? age,
    String? sex,
    double? height,
    double? weight,
    String? country,
    String? city,
    String? occupation,
    String? primaryGoal,
    String? sleepTime,
    String? wakeTime,
    String? activityLevel,
    String? exercise,
    String? smoking,
    String? alcohol,
    int? stressLevel,
    String? dietPreference,
    double? waterIntake,
    String? mealTiming,
    List<String>? supplements,
    bool? hasDiabetesRisk,
    bool? hasHeartDiseaseRisk,
    bool? hasCancerRisk,
    bool? hasThyroidRisk,
    bool? hasBloodPressureRisk,
    int? currentStep,
    bool? isLoading,
  }) {
    return OnboardingState(
      name: name ?? this.name,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      country: country ?? this.country,
      city: city ?? this.city,
      occupation: occupation ?? this.occupation,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      sleepTime: sleepTime ?? this.sleepTime,
      wakeTime: wakeTime ?? this.wakeTime,
      activityLevel: activityLevel ?? this.activityLevel,
      exercise: exercise ?? this.exercise,
      smoking: smoking ?? this.smoking,
      alcohol: alcohol ?? this.alcohol,
      stressLevel: stressLevel ?? this.stressLevel,
      dietPreference: dietPreference ?? this.dietPreference,
      waterIntake: waterIntake ?? this.waterIntake,
      mealTiming: mealTiming ?? this.mealTiming,
      supplements: supplements ?? this.supplements,
      hasDiabetesRisk: hasDiabetesRisk ?? this.hasDiabetesRisk,
      hasHeartDiseaseRisk: hasHeartDiseaseRisk ?? this.hasHeartDiseaseRisk,
      hasCancerRisk: hasCancerRisk ?? this.hasCancerRisk,
      hasThyroidRisk: hasThyroidRisk ?? this.hasThyroidRisk,
      hasBloodPressureRisk: hasBloodPressureRisk ?? this.hasBloodPressureRisk,
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'sex': sex,
      'height': height,
      'weight': weight,
      'country': country,
      'city': city,
      'occupation': occupation,
      'primary_goal': primaryGoal,
      'sleep_time': sleepTime,
      'wake_time': wakeTime,
      'activity_level': activityLevel,
      'exercise': exercise,
      'smoking': smoking,
      'alcohol': alcohol,
      'stress_level': stressLevel,
      'diet_preference': dietPreference,
      'water_intake': waterIntake,
      'meal_timing': mealTiming,
      'supplements': supplements,
      'has_diabetes_risk': hasDiabetesRisk,
      'has_heart_disease_risk': hasHeartDiseaseRisk,
      'has_cancer_risk': hasCancerRisk,
      'has_thyroid_risk': hasThyroidRisk,
      'has_blood_pressure_risk': hasBloodPressureRisk,
      'current_step': currentStep,
    };
  }

  factory OnboardingState.fromJson(Map<String, dynamic> json) {
    return OnboardingState(
      name: json['name'] ?? '',
      age: json['age'] ?? 25,
      sex: json['sex'] ?? 'Male',
      height: (json['height'] as num?)?.toDouble() ?? 175.0,
      weight: (json['weight'] as num?)?.toDouble() ?? 70.0,
      country: json['country'] ?? '',
      city: json['city'] ?? '',
      occupation: json['occupation'] ?? '',
      primaryGoal: json['primary_goal'] ?? json['goal'] ?? 'General Health',
      sleepTime: json['sleep_time'] ?? '22:00',
      wakeTime: json['wake_time'] ?? '06:00',
      activityLevel: json['activity_level'] ?? 'Moderate',
      exercise: json['exercise'] ?? 'Moderate',
      smoking: json['smoking'] ?? 'No',
      alcohol: json['alcohol'] ?? 'No',
      stressLevel: json['stress_level'] ?? 3,
      dietPreference: json['diet_preference'] ?? 'Veg',
      waterIntake: (json['water_intake'] as num?)?.toDouble() ?? 2.0,
      mealTiming: json['meal_timing'] ?? 'Consistent',
      supplements: List<String>.from(json['supplements'] ?? []),
      hasDiabetesRisk: json['has_diabetes_risk'] ?? false,
      hasHeartDiseaseRisk: json['has_heart_disease_risk'] ?? false,
      hasCancerRisk: json['has_cancer_risk'] ?? false,
      hasThyroidRisk: json['has_thyroid_risk'] ?? false,
      hasBloodPressureRisk: json['has_blood_pressure_risk'] ?? false,
      currentStep: json['current_step'] ?? 0,
    );
  }
}

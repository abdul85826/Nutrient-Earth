enum ProblemArea { none, sugar, energy, weight, stress, bp }

class ActionStep {
  final String id;
  final String title;
  final String instruction;
  final String benefit;
  final String? timing; // e.g., '7:30 AM', 'Morning'
  final bool isCompleted;
  final bool isLocked;

  ActionStep({
    required this.id,
    required this.title,
    required this.instruction,
    required this.benefit,
    this.timing,
    this.isCompleted = false,
    this.isLocked = true,
  });

  ActionStep copyWith({bool? isCompleted, bool? isLocked, String? timing}) {
    return ActionStep(
      id: id,
      title: title,
      instruction: instruction,
      benefit: benefit,
      timing: timing ?? this.timing,
      isCompleted: isCompleted ?? this.isCompleted,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'instruction': instruction,
      'benefit': benefit,
      'timing': timing,
      'is_completed': isCompleted,
      'is_locked': isLocked,
    };
  }

  factory ActionStep.fromMap(Map<String, dynamic> map) {
    return ActionStep(
      id: map['id'],
      title: map['title'],
      instruction: map['instruction'],
      benefit: map['benefit'],
      timing: map['timing'],
      isCompleted: map['is_completed'] ?? false,
      isLocked: map['is_locked'] ?? true,
    );
  }
}

class AppUser {
  final String id;
  final String email;
  final String? fullName;
  final String? profilePhotoUrl;
  final bool profileCompleted;
  final DateTime createdAt;
  final DateTime trialStartDate;
  final UserProfile? profile;
  final HealthIdentity? healthIdentity;
  final UserPlan? plan;
  final int onboardingStep;
  final String subscriptionTier; // 'free', 'premium'

  AppUser({
    required this.id,
    required this.email,
    this.fullName,
    this.profilePhotoUrl,
    this.profileCompleted = false,
    this.onboardingStep = 0,
    DateTime? createdAt,
    DateTime? trialStartDate,
    this.profile,
    this.healthIdentity,
    this.plan,
    this.subscriptionTier = 'free',
  }) : createdAt = createdAt ?? DateTime.now(),
       trialStartDate = trialStartDate ?? createdAt ?? DateTime.now();

  factory AppUser.fromMap(Map<String, dynamic> map) {
    final created = map['created_at'] != null
        ? DateTime.parse(map['created_at'])
        : DateTime.now();
    return AppUser(
      id: map['id'],
      email: map['email'] ?? '',
      fullName: map['full_name'],
      profilePhotoUrl: map['profile_photo_url'],
      profileCompleted: map['profile_completed'] ?? false,
      onboardingStep: map['onboarding_step'] ?? 0,
      createdAt: created,
      trialStartDate: map['trial_start_date'] != null
          ? DateTime.parse(map['trial_start_date'])
          : created,
      profile: (map['user_profiles'] != null)
          ? UserProfile.fromMap({
              ...?map['user_profiles'],
              // Temporary mapping from new schema to old fields for compatibility
              if (map['user_profiles']?['date_of_birth'] != null)
                'age': DateTime.now().year - DateTime.parse(map['user_profiles']['date_of_birth']).year,
            })
          : null,
      healthIdentity: (map['user_profiles'] != null)
          ? HealthIdentity.fromMap({
              'user_id': map['id'] ?? '',
              ...?map['user_profiles'],
              if (map['user_profiles']?['date_of_birth'] != null)
                'age': DateTime.now().year - DateTime.parse(map['user_profiles']['date_of_birth']).year,
            })
          : null,
      plan: null,
      subscriptionTier: map['subscription_tier'] ?? 'free',
    );
  }

  bool get isTrialActive {
    final now = DateTime.now();
    return now.difference(trialStartDate).inDays < 21;
  }

  bool get hasPremiumAccess => subscriptionTier == 'premium' || isTrialActive;
}

class UserProfile {
  final String id;
  final String userId;
  final int age;
  final String gender;
  final double weight;
  final double height;
  final String primaryGoal;
  final List<String> concerns;
  final String diabetesStatus;
  final String activityLevel;
  final double sleepHours;
  final String dietPreference;
  final List<String> lifestyleStressors;

  UserProfile({
    String? id,
    required this.userId,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.primaryGoal,
    this.concerns = const [],
    this.diabetesStatus = 'none',
    this.activityLevel = 'moderate',
    this.sleepHours = 7.0,
    this.dietPreference = 'any',
    this.lifestyleStressors = const [],
  }) : id = id ?? '';
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    try {
      return UserProfile(
        id: map['id']?.toString() ?? '',
        userId: map['user_id']?.toString() ?? '',
        age: (map['age'] ?? map['age_years'] ?? 0).toInt().clamp(0, 100),
        gender: map['gender']?.toString() ?? 'Other',
        weight: ((map['weight_kg'] ?? map['weight'] ?? 0.0) as num).toDouble().clamp(0, 250),
        height: ((map['height_cm'] ?? map['height'] ?? 0.0) as num).toDouble().clamp(0, 250),
        primaryGoal: map['primary_goal']?.toString() ?? '',
        concerns: List<String>.from(map['concerns'] ?? []),
        diabetesStatus: map['diabetes_status']?.toString() ?? 'none',
        activityLevel: map['activity_level']?.toString() ?? 'moderate',
        sleepHours: ((map['sleep_hours'] ?? 7.0) as num).toDouble().clamp(0, 24),
        dietPreference: map['diet_preference']?.toString() ?? 'any',
        lifestyleStressors: List<String>.from(map['lifestyle_stressors'] ?? []),
      );
    } catch (e) {
      print('UserProfile.fromMap error: $e. Using partial defaults.');
      return UserProfile(
        userId: map['user_id']?.toString() ?? '',
        age: 0,
        gender: 'Other',
        weight: 0,
        height: 0,
        primaryGoal: '',
      );
    }
  }

  bool get isComplete {
    return age > 0 && weight > 0 && height > 0 && primaryGoal.isNotEmpty;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'age': age,
      'gender': gender,
      'weight_kg': weight,
      'height_cm': height,
      'primary_goal': primaryGoal,
      'concerns': concerns,
      'diabetes_status': diabetesStatus,
      'activity_level': activityLevel,
      'sleep_hours': sleepHours,
      'diet_preference': dietPreference,
      'lifestyle_stressors': lifestyleStressors,
    };
  }

  /// Validates the profile data against biological safety constraints.
  void validate() {
    if (age < 10 || age > 100) {
      throw Exception(
        'Age must be between 10 and 100 years for accurate calibration.',
      );
    }
    if (weight < 30 || weight > 150) {
      throw Exception(
        'Weight must be between 30 and 150 kg for biological safety.',
      );
    }
    if (height < 100 || height > 220) {
      throw Exception(
        'Height must be between 100 and 220 cm for profile accuracy.',
      );
    }
    if (sleepHours < 0 || sleepHours > 12) {
      throw Exception('Sleep duration must be between 0 and 12 hours.');
    }
  }

  Map<String, dynamic> toJson() => toMap();
}

class UserPlan {
  final String id;
  final String userId;
  final String conditionCategory;
  final String? detectedCause;
  final int timelineDays;
  final String? timelineMessage;
  final Map<String, dynamic> planData; // Contains 'minimalPlan' and 'fullPlan'
  final int planVersion;
  final bool isActive;
  final DateTime createdAt;

  UserPlan({
    String? id,
    required this.userId,
    required this.conditionCategory,
    this.detectedCause,
    required this.timelineDays,
    this.timelineMessage,
    required this.planData,
    this.planVersion = 1,
    this.isActive = true,
    DateTime? createdAt,
  }) : id = id ?? '',
       createdAt = createdAt ?? DateTime.now();

  factory UserPlan.fromMap(Map<String, dynamic> map) {
    return UserPlan(
      id: map['id'],
      userId: map['user_id'],
      conditionCategory: map['condition_category'],
      detectedCause: map['detected_cause'],
      timelineDays: map['timeline_days'] ?? 0,
      timelineMessage: map['timeline_message'],
      planData: map['plan_data'] ?? {},
      planVersion: map['plan_version'] ?? 1,
      isActive: map['is_active'] ?? true,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }
}

class DailyProgress {
  final String id;
  final String userId;
  final String date;
  final int tasksCompleted;
  final int totalTasks;
  final double adherencePercentage;
  final int energyLevel;
  final double waterIntake;
  final double sleepHours;
  final int steps;
  final List<String> symptomsTracked;
  final bool planCompleted;
  final String dailyState; // 'low_energy', 'normal', 'high_energy'

  DailyProgress({
    required this.id,
    required this.userId,
    required this.date,
    required this.tasksCompleted,
    required this.totalTasks,
    required this.adherencePercentage,
    required this.energyLevel,
    required this.waterIntake,
    required this.sleepHours,
    this.steps = 0,
    this.symptomsTracked = const [],
    this.planCompleted = false,
    this.dailyState = 'normal',
  });

  factory DailyProgress.fromMap(Map<String, dynamic> map) {
    return DailyProgress(
      id: map['id'],
      userId: map['user_id'],
      date: map['date'],
      tasksCompleted: map['tasks_completed'] ?? 0,
      totalTasks: map['total_tasks'] ?? 0,
      adherencePercentage:
          (map['adherence_percentage'] as num?)?.toDouble() ?? 0.0,
      energyLevel: map['energy_level'] ?? 0,
      waterIntake: (map['water_intake_liters'] as num?)?.toDouble() ?? 0.0,
      sleepHours: (map['sleep_hours'] as num?)?.toDouble() ?? 0.0,
      steps: map['steps'] ?? 0,
      symptomsTracked: List<String>.from(map['symptoms_tracked'] ?? []),
      planCompleted: map['plan_completed'] ?? false,
      dailyState: map['daily_state'] ?? 'normal',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date,
      'tasks_completed': tasksCompleted,
      'total_tasks': totalTasks,
      'adherence_percentage': adherencePercentage,
      'energy_level': energyLevel,
      'water_intake_liters': waterIntake,
      'sleep_hours': sleepHours,
      'steps': steps,
      'symptoms_tracked': symptomsTracked,
      'plan_completed': planCompleted,
      'daily_state': dailyState,
    };
  }
}

class ChatMessage {
  final String id;
  final String userId;
  final String message;
  final bool isUser;
  final String? imageUrl;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.message,
    required this.isUser,
    this.imageUrl,
    required this.createdAt,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      userId: map['user_id'],
      message: map['message'],
      isUser: map['is_user'],
      imageUrl: map['image_url'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class EnvironmentData {
  final String city;
  final double temp;
  final double humidity;
  final int aqi;
  final double uvi;
  final String description;

  EnvironmentData({
    required this.city,
    required this.temp,
    required this.humidity,
    required this.aqi,
    required this.uvi,
    required this.description,
  });

  String get tempDisplay => '${temp.round()}°C';
  String get aqiDisplay => 'AQI $aqi';

  factory EnvironmentData.placeholder() => EnvironmentData(
    city: 'Detecting...',
    temp: 22.0,
    humidity: 50.0,
    aqi: 45,
    uvi: 2.0,
    description: 'Clear Sky',
  );

  Map<String, dynamic> toMap() {
    return {
      'city': city,
      'temp': temp,
      'humidity': humidity,
      'aqi': aqi,
      'uvi': uvi,
      'description': description,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  String get biologicalInterpretation {
    if (aqi > 150) return 'Critical air quality; high respiratory stress detected.';
    if (temp > 35) return 'Extreme heat; high dehydration risk.';
    if (uvi > 8) return 'Extreme UV radiation; immediate skin protection required.';
    if (aqi > 100) return 'Moderate air quality; sensitive individuals may experience fatigue.';
    return 'Environmental conditions are optimal for biological recovery.';
  }

  Map<String, double> get biologicalStressorWeights {
    return {
      'respiratory': (aqi / 300).clamp(0.0, 1.0),
      'hydration_need': ((temp - 20) / 20).clamp(0.0, 1.0) + (uvi / 10).clamp(0.0, 1.0),
      'energy_drain': (aqi > 100 ? 0.2 : 0.0) + (humidity > 70 ? 0.1 : 0.0),
    };
  }
}

class DailyAction {
  final String title;
  final String type;
  final String instruction;
  final String benefit;
  final String icon;

  DailyAction({
    required this.title,
    required this.type,
    required this.instruction,
    required this.benefit,
    required this.icon,
  });

  factory DailyAction.fromMap(Map<String, dynamic> map) {
    return DailyAction(
      title: map['title'] ?? '',
      type: map['type'] ?? '',
      instruction: map['instruction'] ?? '',
      benefit: map['benefit'] ?? '',
      icon: map['icon'] ?? '⚡',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type,
      'instruction': instruction,
      'benefit': benefit,
      'icon': icon,
    };
  }
}

class BodyState {
  final double energyScore; // 0-100
  final double recoveryScore; // 0-100
  final double stressLoad; // 0-100
  final double hydrationStatus; // 0-100
  final String primaryMessage;
  final String status; // GREEN, YELLOW, RED

  // UI Fields
  final String emoji;
  final String headline;
  final String subtext;
  final List<DailyAction> actions;

  BodyState({
    required this.energyScore,
    required this.recoveryScore,
    required this.stressLoad,
    required this.hydrationStatus,
    required this.primaryMessage,
    required this.status,
    required this.emoji,
    required this.headline,
    required this.subtext,
    required this.actions,
  });
}

class Product {
  final String id;
  final String name;
  final double price;
  final String benefit;
  final List<String> primaryHerbs;
  final String imagePath;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.benefit,
    required this.primaryHerbs,
    required this.imagePath,
  });
}

class UserOutcome {
  final String id;
  final String userId;
  final String remedyId;
  final DateTime timestamp;
  final int effectivenessScore; // 1-10
  final int reliefTimeMinutes;
  final bool wouldUseAgain;
  final int? contextAqi;
  final double? contextSleep;
  final double? contextHydration;

  UserOutcome({
    required this.id,
    required this.userId,
    required this.remedyId,
    required this.timestamp,
    required this.effectivenessScore,
    required this.reliefTimeMinutes,
    required this.wouldUseAgain,
    this.contextAqi,
    this.contextSleep,
    this.contextHydration,
  });

  factory UserOutcome.fromMap(Map<String, dynamic> map) {
    return UserOutcome(
      id: map['id'],
      userId: map['user_id'],
      remedyId: map['remedy_id'],
      timestamp: DateTime.parse(map['timestamp']),
      effectivenessScore: map['effectiveness_score'],
      reliefTimeMinutes: map['relief_time_minutes'],
      wouldUseAgain: map['would_use_again'],
      contextAqi: map['context_aqi'],
      contextSleep: (map['context_sleep'] as num?)?.toDouble(),
      contextHydration: (map['context_hydration'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'remedy_id': remedyId,
      'timestamp': timestamp.toIso8601String(),
      'effectiveness_score': effectivenessScore,
      'relief_time_minutes': reliefTimeMinutes,
      'would_use_again': wouldUseAgain,
      'context_aqi': contextAqi,
      'context_sleep': contextSleep,
      'context_hydration': contextHydration,
    };
  }
}

class DiscoveredPattern {
  final String id;
  final String userId;
  final String patternDescription;
  final double support;
  final double confidence;
  final String actionableInsight;
  final DateTime createdAt;

  DiscoveredPattern({
    required this.id,
    required this.userId,
    required this.patternDescription,
    required this.support,
    required this.confidence,
    required this.actionableInsight,
    required this.createdAt,
  });

  factory DiscoveredPattern.fromMap(Map<String, dynamic> map) {
    return DiscoveredPattern(
      id: map['id'],
      userId: map['user_id'],
      patternDescription: map['pattern_description'],
      support: (map['support'] as num).toDouble(),
      confidence: (map['confidence'] as num).toDouble(),
      actionableInsight: map['actionable_insight'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'pattern_description': patternDescription,
      'support': support,
      'confidence': confidence,
      'actionable_insight': actionableInsight,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class HealthIdentity {
  final String userId;
  final String name;
  final int age;
  final String gender;
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

  final DateTime updatedAt;

  HealthIdentity({
    required this.userId,
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.country,
    required this.city,
    required this.occupation,
    required this.primaryGoal,
    required this.sleepTime,
    required this.wakeTime,
    required this.activityLevel,
    required this.exercise,
    required this.smoking,
    required this.alcohol,
    required this.stressLevel,
    required this.dietPreference,
    required this.waterIntake,
    required this.mealTiming,
    required this.supplements,
    required this.hasDiabetesRisk,
    required this.hasHeartDiseaseRisk,
    required this.hasCancerRisk,
    required this.hasThyroidRisk,
    required this.hasBloodPressureRisk,
    required this.updatedAt,
  });

  factory HealthIdentity.fromMap(Map<String, dynamic> map) {
    return HealthIdentity(
      userId: map['user_id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      age: (map['age'] ?? 0).toInt(),
      gender: map['gender']?.toString() ?? '',
      height: (map['height'] ?? 0.0).toDouble(),
      weight: (map['weight'] ?? 0.0).toDouble(),
      country: map['country']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      occupation: map['occupation']?.toString() ?? '',
      primaryGoal: map['primary_goal'] ?? map['goal']?.toString() ?? '',
      sleepTime: map['sleep_time']?.toString() ?? '',
      wakeTime: map['wake_time']?.toString() ?? '',
      activityLevel: map['activity_level']?.toString() ?? '',
      exercise: map['exercise']?.toString() ?? '',
      smoking: map['smoking']?.toString() ?? '',
      alcohol: map['alcohol']?.toString() ?? '',
      stressLevel: (map['stress_level'] ?? 0).toInt(),
      dietPreference: map['diet_preference'] ?? map['nutrition_diet']?.toString() ?? '',
      waterIntake: (map['water_intake'] ?? 0.0).toDouble(),
      mealTiming: map['meal_timing']?.toString() ?? '',
      supplements: List<String>.from(map['supplements'] ?? []),
      hasDiabetesRisk: map['has_diabetes_risk'] ?? map['family_diabetes'] ?? false,
      hasHeartDiseaseRisk: map['has_heart_disease_risk'] ?? map['family_heart'] ?? false,
      hasCancerRisk: map['has_cancer_risk'] ?? map['family_cancer'] ?? false,
      hasThyroidRisk: map['has_thyroid_risk'] ?? map['family_thyroid'] ?? false,
      hasBloodPressureRisk: map['has_blood_pressure_risk'] ?? map['family_bp'] ?? false,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'age': age,
      'gender': gender,
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
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory HealthIdentity.empty(String userId) {
    return HealthIdentity(
      userId: userId,
      name: '',
      age: 0,
      gender: '',
      height: 0.0,
      weight: 0.0,
      country: '',
      city: '',
      occupation: '',
      primaryGoal: '',
      sleepTime: '',
      wakeTime: '',
      activityLevel: '',
      exercise: '',
      smoking: '',
      alcohol: '',
      stressLevel: 0,
      dietPreference: '',
      waterIntake: 0.0,
      mealTiming: '',
      supplements: [],
      hasDiabetesRisk: false,
      hasHeartDiseaseRisk: false,
      hasCancerRisk: false,
      hasThyroidRisk: false,
      hasBloodPressureRisk: false,
      updatedAt: DateTime.now(),
    );
  }

  bool get isComplete {
    return age > 0 && weight > 0 && height > 0 && primaryGoal.isNotEmpty;
  }
}

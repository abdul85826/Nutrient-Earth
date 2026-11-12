// ==============================================================================
// Nutrient Earth — User Profile Context
// Strongly-typed representation of verified user profile attributes and explicit goals.
// Maps directly to public.profiles table schema.
// ==============================================================================

class UserProfileContext {
  final String userId;
  final String displayName;
  final int age;
  final String biologicalSex;
  final List<String> primaryGoals;
  final String activityLevel;
  final String dietaryPreference;
  final String budgetConstraint;
  final String willingnessToChange;
  final List<String> knownConditions;
  final List<String> activeSupplements;
  final List<String> allergies;
  final double? heightCm;
  final double? weightKg;
  final String eatingRoutine;
  final String sleepQuality;
  final String knowledgeLevel;
  final List<String> difficulties;
  final String difficultiesNote;
  final Map<String, dynamic> dailyImpacts;
  final bool onboardingCompleted;

  const UserProfileContext({
    required this.userId,
    required this.displayName,
    this.age = 0,
    this.biologicalSex = 'unspecified',
    this.primaryGoals = const [],
    this.activityLevel = '',
    this.dietaryPreference = '',
    this.budgetConstraint = '',
    this.willingnessToChange = '',
    this.knownConditions = const [],
    this.activeSupplements = const [],
    this.allergies = const [],
    this.heightCm,
    this.weightKg,
    this.eatingRoutine = '',
    this.sleepQuality = '',
    this.knowledgeLevel = '',
    this.difficulties = const [],
    this.difficultiesNote = '',
    this.dailyImpacts = const {},
    this.onboardingCompleted = false,
  });

  factory UserProfileContext.fromJson(Map<String, dynamic> json) {
    return UserProfileContext(
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
      displayName: json['display_name'] as String? ?? json['displayName'] as String? ?? 'User',
      age: (json['age'] as num?)?.toInt() ?? 0,
      biologicalSex: json['biological_sex'] as String? ?? json['biologicalSex'] as String? ?? 'unspecified',
      primaryGoals: (json['primary_goals'] as List<dynamic>? ?? json['primaryGoals'] as List<dynamic>?)
              ?.map((g) => g.toString())
              .toList() ??
          const [],
      activityLevel: json['activity_level'] as String? ?? json['activityLevel'] as String? ?? '',
      dietaryPreference: json['dietary_preference'] as String? ?? json['dietaryPreference'] as String? ?? '',
      budgetConstraint: json['budget_constraint'] as String? ?? json['budgetConstraint'] as String? ?? '',
      willingnessToChange: json['willingness_to_change'] as String? ?? json['willingnessToChange'] as String? ?? '',
      knownConditions: (json['known_conditions'] as List<dynamic>? ?? json['knownConditions'] as List<dynamic>?)
              ?.map((c) => c.toString())
              .toList() ??
          const [],
      activeSupplements: (json['active_supplements'] as List<dynamic>? ?? json['activeSupplements'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          const [],
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((a) => a.toString())
              .toList() ??
          const [],
      heightCm: (json['height_cm'] as num?)?.toDouble() ?? (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? (json['weightKg'] as num?)?.toDouble(),
      eatingRoutine: json['eating_routine'] as String? ?? json['eatingRoutine'] as String? ?? '',
      sleepQuality: json['sleep_quality'] as String? ?? json['sleepQuality'] as String? ?? '',
      knowledgeLevel: json['knowledge_level'] as String? ?? json['knowledgeLevel'] as String? ?? '',
      difficulties: (json['difficulties'] as List<dynamic>?)
              ?.map((d) => d.toString())
              .toList() ??
          const [],
      difficultiesNote: json['difficulties_note'] as String? ?? json['difficultiesNote'] as String? ?? '',
      dailyImpacts: json['daily_impacts'] as Map<String, dynamic>? ?? json['dailyImpacts'] as Map<String, dynamic>? ?? const {},
      onboardingCompleted: json['onboarding_completed'] as bool? ?? json['onboardingCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'display_name': displayName,
        'age': age,
        'biological_sex': biologicalSex,
        'primary_goals': primaryGoals,
        'activity_level': activityLevel,
        'dietary_preference': dietaryPreference,
        'budget_constraint': budgetConstraint,
        'willingness_to_change': willingnessToChange,
        'known_conditions': knownConditions,
        'active_supplements': activeSupplements,
        'allergies': allergies,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'eating_routine': eatingRoutine,
        'sleep_quality': sleepQuality,
        'knowledge_level': knowledgeLevel,
        'difficulties': difficulties,
        'difficulties_note': difficultiesNote,
        'daily_impacts': dailyImpacts,
        'onboarding_completed': onboardingCompleted,
      };

  /// Returns a privacy-safe, anonymized context map stripped of direct PII (name, userId)
  /// for server-side evaluation where only physiological parameters are required.
  Map<String, dynamic> toAnonymizedEvaluationMap() => {
        'age': age,
        'biological_sex': biologicalSex,
        'primary_goals': primaryGoals,
        'activity_level': activityLevel,
        'dietary_preference': dietaryPreference,
        'known_conditions': knownConditions,
        'active_supplements': activeSupplements,
        'allergies': allergies,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'eating_routine': eatingRoutine,
        'sleep_quality': sleepQuality,
      };
}

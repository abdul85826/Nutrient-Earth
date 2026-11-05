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

  const UserProfileContext({
    required this.userId,
    required this.displayName,
    required this.age,
    required this.biologicalSex,
    required this.primaryGoals,
    required this.activityLevel,
    required this.dietaryPreference,
    required this.budgetConstraint,
    required this.willingnessToChange,
    this.knownConditions = const [],
    this.activeSupplements = const [],
    this.allergies = const [],
  });

  factory UserProfileContext.fromJson(Map<String, dynamic> json) {
    return UserProfileContext(
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
      displayName: json['display_name'] as String? ?? json['displayName'] as String? ?? 'User',
      age: (json['age'] as num?)?.toInt() ?? 30,
      biologicalSex: json['biological_sex'] as String? ?? json['biologicalSex'] as String? ?? 'unspecified',
      primaryGoals: (json['primary_goals'] as List<dynamic>? ?? json['primaryGoals'] as List<dynamic>?)
              ?.map((g) => g.toString())
              .toList() ??
          const [],
      activityLevel: json['activity_level'] as String? ?? json['activityLevel'] as String? ?? 'moderate',
      dietaryPreference: json['dietary_preference'] as String? ?? json['dietaryPreference'] as String? ?? 'omnivorous',
      budgetConstraint: json['budget_constraint'] as String? ?? json['budgetConstraint'] as String? ?? 'moderate',
      willingnessToChange: json['willingness_to_change'] as String? ?? json['willingnessToChange'] as String? ?? 'high',
      knownConditions: (json['known_conditions'] as List<dynamic>? ?? json['knownConditions'] as List<dynamic>?)
              ?.map((c) => c.toString())
              .toList() ??
          const [],
      activeSupplements: (json['active_supplements'] as List<dynamic>? ?? json['activeSupplements'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          const [],
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
      };
}

enum WillingnessToChange { low, moderate, high, aggressive }

class HealthProfile {
  final String userId;
  final String displayName;
  final int age;
  final String biologicalSex;
  final List<String>
  primaryGoals; // e.g. 'Insulin Sensitivity', 'Sleep Deep Phase', 'Endurance'
  final String activityLevel; // 'Sedentary', 'Lightly Active', 'Moderately Active', 'Athletic'
  final String
  dietaryPreference; // 'Omnivore', 'Plant-based', 'Ketogenic', 'Mediterranean'
  final String budgetConstraint; // 'Economy', 'Moderate', 'Unrestricted'
  final WillingnessToChange willingnessToChange;
  final List<String> knownConditions;
  final List<String> activeSupplements;

  const HealthProfile({
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
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'display_name': displayName,
    'age': age,
    'biological_sex': biologicalSex,
    'primary_goals': primaryGoals,
    'activity_level': activityLevel,
    'dietary_preference': dietaryPreference,
    'budget_constraint': budgetConstraint,
    'willingness_to_change': willingnessToChange.name,
    'known_conditions': knownConditions,
    'active_supplements': activeSupplements,
  };

  factory HealthProfile.fromJson(Map<String, dynamic> json) => HealthProfile(
    userId: json['user_id'] as String,
    displayName: json['display_name'] as String? ?? 'User',
    age: (json['age'] as num?)?.toInt() ?? 30,
    biologicalSex: json['biological_sex'] as String? ?? 'Not Specified',
    primaryGoals:
        (json['primary_goals'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        ['Cardiovascular Health', 'Longevity'],
    activityLevel: json['activity_level'] as String? ?? 'Moderately Active',
    dietaryPreference: json['dietary_preference'] as String? ?? 'Mediterranean',
    budgetConstraint: json['budget_constraint'] as String? ?? 'Moderate',
    willingnessToChange: WillingnessToChange.values.firstWhere(
      (e) => e.name == json['willingness_to_change'],
      orElse: () => WillingnessToChange.moderate,
    ),
    knownConditions:
        (json['known_conditions'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    activeSupplements:
        (json['active_supplements'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
  );
}

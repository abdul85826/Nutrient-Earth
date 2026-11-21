// ==============================================================================
// Nutrient Earth — Personal Context Assembly Service
// Master Context Assembly Hierarchy (Levels 1 through 6)
//
// 1. Authenticated user identity and authorization.
// 2. Explicitly provided information in the current query/turn.
// 3. Available, verified onboarding information (OnboardingProfileData / UserProfileContext).
// 4. Current saved profile information from Supabase (public.profiles).
// 5. Relevant historical personal context (memory service / activity history).
// 6. Shared scientific knowledge base (USDA, PubMed, FSSAI, AYUSH).
//
// Policy: Evaluates whether missing information is strictly required.
// For general knowledge, food science, cooking, utensils, and paper reviews:
//   Zero onboarding requirement.
// For personalized queries with partial/missing profile data:
//   Provides evidence-based reference adult baselines, explains requirements,
//   and invites optional completion without blocking.
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../memory/bitemporal_memory_models.dart';
import 'user_profile_context.dart';

/// Context resolution source tier
enum ContextLevel {
  authenticatedIdentity(1, 'Level 1: Authenticated Identity & Authorization'),
  explicitTurnInput(2, 'Level 2: Explicit Information in Current Turn'),
  onboardingData(3, 'Level 3: Verified Onboarding Profile Information'),
  persistedProfile(4, 'Level 4: Current Saved Database Profile'),
  historicalMemory(5, 'Level 5: Historical Personal Context & Memory Ledger'),
  sharedScientificBase(6, 'Level 6: Shared Scientific Knowledge Base');

  final int rank;
  final String description;
  const ContextLevel(this.rank, this.description);
}

/// Degree of profile completeness
enum ProfileCompletenessTier {
  absentOrGuest(0.0, '0% Onboarding / Absent (Guest Mode)'),
  partial(0.5, '50% Onboarding / Partial Profile'),
  complete(1.0, '100% Onboarding / Verified Profile');

  final double score;
  final String label;
  const ProfileCompletenessTier(this.score, this.label);

  static ProfileCompletenessTier fromScore(double score) {
    if (score >= 0.85) return ProfileCompletenessTier.complete;
    if (score >= 0.35) return ProfileCompletenessTier.partial;
    return ProfileCompletenessTier.absentOrGuest;
  }
}

/// Assembled personal context resulting from hierarchical merging
class AssembledPersonalContext {
  final String userId;
  final bool isAuthenticated;
  final bool isGuest;
  final ProfileCompletenessTier completenessTier;
  final double completenessRatio;

  // Resolved physiological attributes (Hierarchy: Turn > Profile > Baseline)
  final double? resolvedWeightKg;
  final double? resolvedHeightCm;
  final int? resolvedAge;
  final String resolvedBiologicalSex;
  final List<String> resolvedPrimaryGoals;
  final String resolvedDietaryPreference;
  final List<String> resolvedAllergies;
  final List<String> resolvedConditions;
  final String resolvedActivityLevel;
  final String resolvedSleepQuality;

  // Metadata describing context origin
  final Map<String, ContextLevel> attributeSources;
  final List<String> missingAttributes;
  final bool isUsingStandardReferenceBaseline;
  final String? baselineExplanation;
  final List<BitemporalPersonalFact> appliedMemoryFacts;

  const AssembledPersonalContext({
    required this.userId,
    required this.isAuthenticated,
    required this.isGuest,
    required this.completenessTier,
    required this.completenessRatio,
    this.resolvedWeightKg,
    this.resolvedHeightCm,
    this.resolvedAge,
    this.resolvedBiologicalSex = 'unspecified',
    this.resolvedPrimaryGoals = const [],
    this.resolvedDietaryPreference = '',
    this.resolvedAllergies = const [],
    this.resolvedConditions = const [],
    this.resolvedActivityLevel = '',
    this.resolvedSleepQuality = '',
    this.attributeSources = const {},
    this.missingAttributes = const [],
    this.isUsingStandardReferenceBaseline = false,
    this.baselineExplanation,
    this.appliedMemoryFacts = const [],
  });

  /// Reference standard adult body weight when missing from user profile (70.0 kg)
  static const double standardAdultWeightKg = 70.0;

  /// Effective weight: user's weight or standard reference adult weight
  double get effectiveWeightKg => resolvedWeightKg ?? standardAdultWeightKg;

  /// True if user explicitly declared or profile contains vegetarian/vegan
  bool get isPlantBased =>
      resolvedDietaryPreference.toLowerCase().contains('veg') ||
      resolvedDietaryPreference.toLowerCase().contains('plant');
}

/// Extracted physiological signals from current turn text
class ExplicitTurnAttributes {
  final double? weightKg;
  final double? heightCm;
  final int? age;
  final String? dietaryPreference;
  final List<String> allergies;
  final List<String> goals;

  const ExplicitTurnAttributes({
    this.weightKg,
    this.heightCm,
    this.age,
    this.dietaryPreference,
    this.allergies = const [],
    this.goals = const [],
  });

  bool get hasAnyAttribute =>
      weightKg != null ||
      heightCm != null ||
      age != null ||
      dietaryPreference != null ||
      allergies.isNotEmpty ||
      goals.isNotEmpty;
}

class PersonalContextAssemblyService {
  const PersonalContextAssemblyService();

  /// Parse explicit personal attributes directly from user query text (Level 2)
  ExplicitTurnAttributes parseExplicitTurnSignals(String query) {
    final lower = query.toLowerCase();
    double? weight;
    double? height;
    int? age;
    String? diet;
    final allergies = <String>[];
    final goals = <String>[];

    // 1. Weight pattern: "68 kg", "70kg", "150 lbs", "160 pounds"
    final kgMatch = RegExp(r'\b(\d{2,3}(?:\.\d)?)\s*(?:kg|kilos|kilograms)\b').firstMatch(lower);
    if (kgMatch != null) {
      weight = double.tryParse(kgMatch.group(1)!);
    } else {
      final lbMatch = RegExp(r'\b(\d{2,3}(?:\.\d)?)\s*(?:lbs|lb|pounds)\b').firstMatch(lower);
      if (lbMatch != null) {
        final lbs = double.tryParse(lbMatch.group(1)!);
        if (lbs != null) weight = lbs * 0.45359237;
      }
    }

    // 2. Height pattern: "175 cm", "180cm", "5 feet 10 inches", "5ft 10in"
    final cmMatch = RegExp(r'\b(\d{2,3}(?:\.\d)?)\s*cm\b').firstMatch(lower);
    if (cmMatch != null) {
      height = double.tryParse(cmMatch.group(1)!);
    }

    // 3. Age pattern: "32 years old", "age 32", "i am 28"
    final ageMatch = RegExp(r'\b(?:age\s*(\d{2})|i\s*am\s*(\d{2})\s*(?:years|yo)?|(\d{2})\s*years?\s*old)\b').firstMatch(lower);
    if (ageMatch != null) {
      final captured = ageMatch.group(1) ?? ageMatch.group(2) ?? ageMatch.group(3);
      if (captured != null) age = int.tryParse(captured);
    }

    // 4. Dietary preferences
    if (lower.contains('vegan')) {
      diet = 'Vegan';
    } else if (lower.contains('vegetarian') || lower.contains('lacto-veg')) {
      diet = 'Vegetarian';
    } else if (lower.contains('pescatarian')) {
      diet = 'Pescatarian';
    } else if (lower.contains('keto') || lower.contains('ketogenic')) {
      diet = 'Ketogenic';
    } else if (lower.contains('gluten-free') || lower.contains('gluten free')) {
      diet = 'Gluten-Free';
    }

    // 5. Allergies
    if (lower.contains('peanut') || lower.contains('tree nut')) allergies.add('Peanuts');
    if (lower.contains('dairy') || lower.contains('lactose')) allergies.add('Dairy/Lactose');
    if (lower.contains('shellfish') || lower.contains('crustacean')) allergies.add('Shellfish');
    if (lower.contains('egg allergy')) allergies.add('Eggs');
    if (lower.contains('soy allergy')) allergies.add('Soy');

    // 6. Goals
    if (lower.contains('muscle') || lower.contains('hypertrophy') || lower.contains('strength')) {
      goals.add('Muscle Growth');
    }
    if (lower.contains('fat loss') || lower.contains('weight loss') || lower.contains('cut')) {
      goals.add('Fat Loss');
    }
    if (lower.contains('endurance') || lower.contains('marathon') || lower.contains('running')) {
      goals.add('Endurance Performance');
    }
    if (lower.contains('longevity') || lower.contains('healthspan')) {
      goals.add('Longevity');
    }

    return ExplicitTurnAttributes(
      weightKg: weight,
      heightCm: height,
      age: age,
      dietaryPreference: diet,
      allergies: allergies,
      goals: goals,
    );
  }

  /// Calculates profile completeness score (0.0 to 1.0)
  double calculateCompletenessRatio(UserProfileContext? profile) {
    if (profile == null) return 0.0;
    int points = 0;
    const totalPoints = 8;

    if (profile.displayName.isNotEmpty && profile.displayName != 'User') points++;
    if (profile.age > 0) points++;
    if (profile.biologicalSex.isNotEmpty && profile.biologicalSex != 'unspecified') points++;
    if (profile.weightKg != null && profile.weightKg! > 0) points++;
    if (profile.heightCm != null && profile.heightCm! > 0) points++;
    if (profile.primaryGoals.isNotEmpty) points++;
    if (profile.dietaryPreference.isNotEmpty) points++;
    if (profile.activityLevel.isNotEmpty || profile.sleepQuality.isNotEmpty) points++;

    return (points / totalPoints).clamp(0.0, 1.0);
  }

  /// Master Assembly: Evaluates all 6 levels and merges into a unified context
  AssembledPersonalContext assemble({
    String? userId,
    String query = '',
    UserProfileContext? profile,
    List<BitemporalPersonalFact> memoryFacts = const [],
  }) {
    final effectiveUserId = userId ?? profile?.userId ?? 'guest_user';
    final isAuthenticated = effectiveUserId != 'guest_user' && effectiveUserId.isNotEmpty;
    final isGuest = !isAuthenticated;

    // Level 2: Parse explicit attributes in the current turn
    final turnAttrs = parseExplicitTurnSignals(query);

    // Track which level sourced each attribute
    final sources = <String, ContextLevel>{};
    final missing = <String>[];

    // Resolved Attributes
    double? resolvedWeight;
    double? resolvedHeight;
    int? resolvedAge;
    String resolvedSex = 'unspecified';
    List<String> resolvedGoals = [];
    String resolvedDiet = '';
    List<String> resolvedAllergies = [];
    List<String> resolvedConditions = [];
    String resolvedActivity = '';
    String resolvedSleep = '';

    // Level 1: Identity
    sources['identity'] = isGuest ? ContextLevel.sharedScientificBase : ContextLevel.authenticatedIdentity;

    // Weight Resolution: Level 2 (Turn) > Level 3/4 (Profile) > None
    if (turnAttrs.weightKg != null) {
      resolvedWeight = turnAttrs.weightKg;
      sources['weightKg'] = ContextLevel.explicitTurnInput;
    } else if (profile?.weightKg != null && profile!.weightKg! > 0) {
      resolvedWeight = profile.weightKg;
      sources['weightKg'] = ContextLevel.persistedProfile;
    } else {
      missing.add('weightKg');
    }

    // Height Resolution
    if (turnAttrs.heightCm != null) {
      resolvedHeight = turnAttrs.heightCm;
      sources['heightCm'] = ContextLevel.explicitTurnInput;
    } else if (profile?.heightCm != null && profile!.heightCm! > 0) {
      resolvedHeight = profile.heightCm;
      sources['heightCm'] = ContextLevel.persistedProfile;
    } else {
      missing.add('heightCm');
    }

    // Age Resolution
    if (turnAttrs.age != null) {
      resolvedAge = turnAttrs.age;
      sources['age'] = ContextLevel.explicitTurnInput;
    } else if (profile != null && profile.age > 0) {
      resolvedAge = profile.age;
      sources['age'] = ContextLevel.persistedProfile;
    } else {
      missing.add('age');
    }

    // Sex Resolution
    if (profile != null && profile.biologicalSex.isNotEmpty && profile.biologicalSex != 'unspecified') {
      resolvedSex = profile.biologicalSex;
      sources['biologicalSex'] = ContextLevel.persistedProfile;
    } else {
      missing.add('biologicalSex');
    }

    // Primary Goals Resolution: Turn Goals > Profile Goals > Memory Facts
    if (turnAttrs.goals.isNotEmpty) {
      resolvedGoals = turnAttrs.goals;
      sources['primaryGoals'] = ContextLevel.explicitTurnInput;
    } else if (profile != null && profile.primaryGoals.isNotEmpty) {
      resolvedGoals = List<String>.from(profile.primaryGoals);
      sources['primaryGoals'] = ContextLevel.persistedProfile;
    } else {
      missing.add('primaryGoals');
    }

    // Dietary Preference Resolution
    if (turnAttrs.dietaryPreference != null) {
      resolvedDiet = turnAttrs.dietaryPreference!;
      sources['dietaryPreference'] = ContextLevel.explicitTurnInput;
    } else if (profile != null && profile.dietaryPreference.isNotEmpty) {
      resolvedDiet = profile.dietaryPreference;
      sources['dietaryPreference'] = ContextLevel.persistedProfile;
    } else {
      missing.add('dietaryPreference');
    }

    // Allergies Resolution: Combine Turn + Profile
    final combinedAllergies = <String>{};
    if (turnAttrs.allergies.isNotEmpty) {
      combinedAllergies.addAll(turnAttrs.allergies);
      sources['allergies'] = ContextLevel.explicitTurnInput;
    }
    if (profile != null && profile.allergies.isNotEmpty) {
      combinedAllergies.addAll(profile.allergies);
      sources['allergies'] = ContextLevel.persistedProfile;
    }
    resolvedAllergies = combinedAllergies.toList();

    // Conditions Resolution
    if (profile != null && profile.knownConditions.isNotEmpty) {
      resolvedConditions = List<String>.from(profile.knownConditions);
      sources['knownConditions'] = ContextLevel.persistedProfile;
    }

    // Activity & Sleep
    if (profile != null && profile.activityLevel.isNotEmpty) {
      resolvedActivity = profile.activityLevel;
      sources['activityLevel'] = ContextLevel.persistedProfile;
    }
    if (profile != null && profile.sleepQuality.isNotEmpty) {
      resolvedSleep = profile.sleepQuality;
      sources['sleepQuality'] = ContextLevel.persistedProfile;
    }

    // Level 5: Relevant Memory facts integration
    final appliedFacts = <BitemporalPersonalFact>[];
    for (final fact in memoryFacts) {
      if (fact.status == FactValidityStatus.active) {
        appliedFacts.add(fact);
      }
    }

    final ratio = calculateCompletenessRatio(profile);
    final tier = ProfileCompletenessTier.fromScore(ratio);

    final isUsingBaseline = resolvedWeight == null;
    final baselineNotes = isUsingBaseline
        ? 'Calculated using standard reference adult baseline (${AssembledPersonalContext.standardAdultWeightKg} kg). To customize for your exact physiology, enter your weight in your message or profile.'
        : null;

    return AssembledPersonalContext(
      userId: effectiveUserId,
      isAuthenticated: isAuthenticated,
      isGuest: isGuest,
      completenessTier: tier,
      completenessRatio: ratio,
      resolvedWeightKg: resolvedWeight,
      resolvedHeightCm: resolvedHeight,
      resolvedAge: resolvedAge,
      resolvedBiologicalSex: resolvedSex,
      resolvedPrimaryGoals: resolvedGoals,
      resolvedDietaryPreference: resolvedDiet,
      resolvedAllergies: resolvedAllergies,
      resolvedConditions: resolvedConditions,
      resolvedActivityLevel: resolvedActivity,
      resolvedSleepQuality: resolvedSleep,
      attributeSources: sources,
      missingAttributes: missing,
      isUsingStandardReferenceBaseline: isUsingBaseline,
      baselineExplanation: baselineNotes,
      appliedMemoryFacts: appliedFacts,
    );
  }
}

final personalContextAssemblyServiceProvider = Provider<PersonalContextAssemblyService>((ref) {
  return const PersonalContextAssemblyService();
});

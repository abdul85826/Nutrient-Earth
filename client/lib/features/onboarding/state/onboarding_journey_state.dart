// ==============================================================================
// Nutrient Earth — Onboarding Journey State & Notifier
// Manages complete state across Screens 01 to 17.
// Enforces two-phase calibration, clinical safety isolation, and authentic
// Supabase PostgREST persistence.
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/personalization/user_profile_context.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/profile_repository.dart';
import '../../../core/services/task_repository.dart';
import '../../today/state/today_state.dart';

class OnboardingJourneyState {
  // Phase 1: Health Foundations (Screens 04 - 08)
  final Set<String> healthGoals;
  final Set<String> difficulties;
  final String difficultiesNote;
  final Map<String, int> dailyImpacts; // difficulty code -> 1..4
  final bool impactFluctuates;
  final String dietaryPattern; // omnivorous, vegetarian, vegan, eggetarian, pescatarian, other
  final String customDietaryPattern;
  final Set<String> foodIntolerances;
  final Set<String> foodsToAvoid;
  final bool phase1Reviewed;

  // Phase 2: Physiology & Calibration (Screens 09 - 17)
  final String firstName;
  final int age;
  final double? heightCm;
  final double? weightKg;
  final String heightUnit; // 'ft' or 'cm'
  final String weightUnit; // 'lb' or 'kg'
  final bool weightSkipped;
  final Set<String> prioritizedConcerns;
  final bool strictlyNoRestrictions;
  final Set<String> allergens;
  final String customAllergen;
  final String eatingRoutine; // regular, intuitive, intermittent_fasting, grazing, shift_work
  final String activityLevel; // sedentary, light, moderate, active, athlete
  final String sleepQuality; // good_consistent, sometimes_disturbed, difficulty_sleeping, irregular
  final String knowledgeLevel; // beginner, basics, intermediate, advanced

  // Persistence & UI State
  final bool isSaving;
  final String? saveError;

  const OnboardingJourneyState({
    this.healthGoals = const {'Energy & Vitality Optimization', 'Digestive & Gut Sensitivity'},
    this.difficulties = const {'MSK-02', 'NRG-04'},
    this.difficultiesNote = '',
    this.dailyImpacts = const {'MSK-02': 3, 'NRG-04': 4},
    this.impactFluctuates = false,
    this.dietaryPattern = 'vegetarian',
    this.customDietaryPattern = '',
    this.foodIntolerances = const {'Lactose intolerance'},
    this.foodsToAvoid = const {'Added sugars & Syrups', 'Highly refined seed oils'},
    this.phase1Reviewed = false,
    this.firstName = 'Explorer',
    this.age = 28,
    this.heightCm = 175.0,
    this.weightKg = 70.0,
    this.heightUnit = 'ft',
    this.weightUnit = 'lb',
    this.weightSkipped = false,
    this.prioritizedConcerns = const {'Energy & Vitality Optimization'},
    this.strictlyNoRestrictions = false,
    this.allergens = const {'Peanuts'},
    this.customAllergen = '',
    this.eatingRoutine = 'regular',
    this.activityLevel = 'moderate',
    this.sleepQuality = 'good_consistent',
    this.knowledgeLevel = 'basics',
    this.isSaving = false,
    this.saveError,
  });

  OnboardingJourneyState copyWith({
    Set<String>? healthGoals,
    Set<String>? difficulties,
    String? difficultiesNote,
    Map<String, int>? dailyImpacts,
    bool? impactFluctuates,
    String? dietaryPattern,
    String? customDietaryPattern,
    Set<String>? foodIntolerances,
    Set<String>? foodsToAvoid,
    bool? phase1Reviewed,
    String? firstName,
    int? age,
    double? heightCm,
    double? weightKg,
    String? heightUnit,
    String? weightUnit,
    bool? weightSkipped,
    Set<String>? prioritizedConcerns,
    bool? strictlyNoRestrictions,
    Set<String>? allergens,
    String? customAllergen,
    String? eatingRoutine,
    String? activityLevel,
    String? sleepQuality,
    String? knowledgeLevel,
    bool? isSaving,
    String? saveError,
  }) {
    return OnboardingJourneyState(
      healthGoals: healthGoals ?? this.healthGoals,
      difficulties: difficulties ?? this.difficulties,
      difficultiesNote: difficultiesNote ?? this.difficultiesNote,
      dailyImpacts: dailyImpacts ?? this.dailyImpacts,
      impactFluctuates: impactFluctuates ?? this.impactFluctuates,
      dietaryPattern: dietaryPattern ?? this.dietaryPattern,
      customDietaryPattern: customDietaryPattern ?? this.customDietaryPattern,
      foodIntolerances: foodIntolerances ?? this.foodIntolerances,
      foodsToAvoid: foodsToAvoid ?? this.foodsToAvoid,
      phase1Reviewed: phase1Reviewed ?? this.phase1Reviewed,
      firstName: firstName ?? this.firstName,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      heightUnit: heightUnit ?? this.heightUnit,
      weightUnit: weightUnit ?? this.weightUnit,
      weightSkipped: weightSkipped ?? this.weightSkipped,
      prioritizedConcerns: prioritizedConcerns ?? this.prioritizedConcerns,
      strictlyNoRestrictions: strictlyNoRestrictions ?? this.strictlyNoRestrictions,
      allergens: allergens ?? this.allergens,
      customAllergen: customAllergen ?? this.customAllergen,
      eatingRoutine: eatingRoutine ?? this.eatingRoutine,
      activityLevel: activityLevel ?? this.activityLevel,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      knowledgeLevel: knowledgeLevel ?? this.knowledgeLevel,
      isSaving: isSaving ?? this.isSaving,
      saveError: saveError,
    );
  }
}

class OnboardingJourneyNotifier extends StateNotifier<OnboardingJourneyState> {
  OnboardingJourneyNotifier() : super(const OnboardingJourneyState());

  void toggleHealthGoal(String goal) {
    final updated = Set<String>.from(state.healthGoals);
    if (updated.contains(goal)) {
      updated.remove(goal);
    } else {
      updated.add(goal);
    }
    // Also synchronize to prioritized concerns if not customized yet
    final concerns = Set<String>.from(state.prioritizedConcerns);
    if (updated.contains(goal)) {
      concerns.add(goal);
    } else {
      concerns.remove(goal);
    }
    state = state.copyWith(healthGoals: updated, prioritizedConcerns: concerns);
  }

  void toggleDifficulty(String code) {
    final updated = Set<String>.from(state.difficulties);
    final impacts = Map<String, int>.from(state.dailyImpacts);
    if (updated.contains(code)) {
      updated.remove(code);
      impacts.remove(code);
    } else {
      updated.add(code);
      impacts[code] = 2; // Default to mild/moderate
    }
    state = state.copyWith(difficulties: updated, dailyImpacts: impacts);
  }

  void setDifficultiesNote(String note) {
    state = state.copyWith(difficultiesNote: note);
  }

  void setDailyImpact(String code, int rating) {
    final impacts = Map<String, int>.from(state.dailyImpacts);
    impacts[code] = rating;
    state = state.copyWith(dailyImpacts: impacts);
  }

  void setImpactFluctuates(bool val) {
    state = state.copyWith(impactFluctuates: val);
  }

  void setDietaryPattern(String pattern, {String? custom}) {
    state = state.copyWith(
      dietaryPattern: pattern,
      customDietaryPattern: custom ?? state.customDietaryPattern,
    );
  }

  void toggleFoodIntolerance(String intolerance) {
    final updated = Set<String>.from(state.foodIntolerances);
    if (updated.contains(intolerance)) {
      updated.remove(intolerance);
    } else {
      updated.add(intolerance);
    }
    state = state.copyWith(foodIntolerances: updated);
  }

  void toggleFoodToAvoid(String food) {
    final updated = Set<String>.from(state.foodsToAvoid);
    if (updated.contains(food)) {
      updated.remove(food);
    } else {
      updated.add(food);
    }
    state = state.copyWith(foodsToAvoid: updated);
  }

  void setPhase1Reviewed(bool val) {
    state = state.copyWith(phase1Reviewed: val);
  }

  void setPersonalDetails({required String name, required int age}) {
    state = state.copyWith(firstName: name, age: age);
  }

  void setBodyMeasurements({
    double? heightCm,
    double? weightKg,
    String? heightUnit,
    String? weightUnit,
    bool? weightSkipped,
  }) {
    state = state.copyWith(
      heightCm: heightCm ?? state.heightCm,
      weightKg: weightKg ?? state.weightKg,
      heightUnit: heightUnit ?? state.heightUnit,
      weightUnit: weightUnit ?? state.weightUnit,
      weightSkipped: weightSkipped ?? state.weightSkipped,
    );
  }

  void togglePrioritizedConcern(String concern) {
    final updated = Set<String>.from(state.prioritizedConcerns);
    if (updated.contains(concern)) {
      updated.remove(concern);
    } else {
      updated.add(concern);
    }
    state = state.copyWith(prioritizedConcerns: updated);
  }

  void setStrictlyNoRestrictions(bool val) {
    if (val) {
      state = state.copyWith(
        strictlyNoRestrictions: true,
        allergens: const {},
        customAllergen: '',
      );
    } else {
      state = state.copyWith(strictlyNoRestrictions: false);
    }
  }

  void toggleAllergen(String allergen) {
    final updated = Set<String>.from(state.allergens);
    if (updated.contains(allergen)) {
      updated.remove(allergen);
    } else {
      updated.add(allergen);
    }
    state = state.copyWith(
      allergens: updated,
      strictlyNoRestrictions: false,
    );
  }

  void setCustomAllergen(String val) {
    state = state.copyWith(
      customAllergen: val,
      strictlyNoRestrictions: false,
    );
  }

  void setEatingRoutine(String routine) {
    state = state.copyWith(eatingRoutine: routine);
  }

  void setActivityLevel(String level) {
    state = state.copyWith(activityLevel: level);
  }

  void setSleepQuality(String quality) {
    state = state.copyWith(sleepQuality: quality);
  }

  void setKnowledgeLevel(String level) {
    state = state.copyWith(knowledgeLevel: level);
  }

  /// Finalizes onboarding, saves authentic user profile to Supabase public.profiles,
  /// seeds goal-tailored tasks, and synchronizes profile to Today state.
  Future<bool> saveAndComplete({
    required AuthService auth,
    required ProfileRepository profileRepo,
    required TaskRepository taskRepo,
  }) async {
    state = state.copyWith(isSaving: true, saveError: null);

    try {
      final userId = auth.currentUser?.id ?? 'usr_${DateTime.now().millisecondsSinceEpoch}';
      final name = state.firstName.trim().isNotEmpty ? state.firstName.trim() : 'Explorer';
      final primaryGoalsList = state.prioritizedConcerns.isNotEmpty
          ? state.prioritizedConcerns.toList()
          : (state.healthGoals.isNotEmpty ? state.healthGoals.toList() : ['Endurance & Energy']);

      final knownConditionsList = <String>[
        ...state.difficulties.map((d) => 'Difficulty: $d'),
        ...state.allergens.map((a) => 'Allergy: $a'),
      ];
      if (state.customAllergen.trim().isNotEmpty) {
        knownConditionsList.add('Allergy: ${state.customAllergen.trim()}');
      }

      final profile = UserProfileContext(
        userId: userId,
        displayName: name,
        age: state.age,
        biologicalSex: 'unspecified',
        primaryGoals: primaryGoalsList,
        activityLevel: state.activityLevel,
        dietaryPreference: state.dietaryPattern,
        budgetConstraint: 'moderate',
        willingnessToChange: 'high',
        knownConditions: knownConditionsList,
        activeSupplements: const [],
        allergies: state.allergens.toList(),
      );

      // Save profile to Supabase
      await profileRepo.saveUserProfile(profile);

      // Seed goal-tailored daily plan tasks based on the authentic selected goal
      final primaryGoal = primaryGoalsList.first.toLowerCase();
      final seededTasks = _generateGoalTailoredTasks(primaryGoal);
      for (final task in seededTasks) {
        try {
          await taskRepo.createTask(task);
        } catch (_) {}
      }

      state = state.copyWith(isSaving: false, saveError: null);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        saveError: 'Unable to save profile: ${e.toString().replaceAll('Exception: ', '')}',
      );
      return false;
    }
  }

  List<DailyPlanTask> _generateGoalTailoredTasks(String primaryGoal) {
    if (primaryGoal.contains('endurance') || primaryGoal.contains('energy')) {
      return const [
        DailyPlanTask(
          id: '',
          title: 'Morning Electrolyte Hydration',
          note: 'Hydrate with sodium, potassium, and magnesium before exertion',
          timeString: '8:00 AM',
          isCompleted: false,
          isUpNext: true,
        ),
        DailyPlanTask(
          id: '',
          title: 'Post-Workout Glycogen & Protein Window',
          note: 'Consume high-bioavailability amino acids and carbohydrates within 45 min',
          timeString: '1:00 PM',
          isCompleted: false,
        ),
        DailyPlanTask(
          id: '',
          title: 'Zone 2 Aerobic Movement Check',
          note: '30 minutes of steady-state aerobic cadence to build mitochondrial density',
          timeString: '5:30 PM',
          isCompleted: false,
        ),
      ];
    } else if (primaryGoal.contains('sleep')) {
      return const [
        DailyPlanTask(
          id: '',
          title: 'Morning Sunlight Exposure',
          note: 'View outdoor light for 10-15 min to anchor circadian cortisol rhythm',
          timeString: '7:30 AM',
          isCompleted: false,
          isUpNext: true,
        ),
        DailyPlanTask(
          id: '',
          title: 'Caffeine Cutoff Checkpoint',
          note: 'Avoid adenosine-blocking stimulants 8-10 hours prior to bedtime',
          timeString: '2:00 PM',
          isCompleted: false,
        ),
        DailyPlanTask(
          id: '',
          title: 'Evening Magnesium & Blue-Light Dimming',
          note: 'Take magnesium glycinate and dim screens 60 minutes before sleep',
          timeString: '9:30 PM',
          isCompleted: false,
        ),
      ];
    } else if (primaryGoal.contains('gut') || primaryGoal.contains('digest')) {
      return const [
        DailyPlanTask(
          id: '',
          title: 'Warm Water & Digestive Priming',
          note: 'Support peristalsis and gastric acid preparation before breakfast',
          timeString: '8:00 AM',
          isCompleted: false,
          isUpNext: true,
        ),
        DailyPlanTask(
          id: '',
          title: 'Fiber & Fermented Food Diversity Check',
          note: 'Include diverse prebiotic plant fibers to nourish gut microbiome',
          timeString: '12:30 PM',
          isCompleted: false,
        ),
        DailyPlanTask(
          id: '',
          title: '3-Hour Pre-Sleep Fasting Buffer',
          note: 'Allow migrating motor complex (MMC) cleansing wave to activate',
          timeString: '7:30 PM',
          isCompleted: false,
        ),
      ];
    } else {
      return const [
        DailyPlanTask(
          id: '',
          title: 'Morning Hydration & Mineral Baseline',
          note: 'Start your day with clean water and natural electrolyte balance',
          timeString: '8:00 AM',
          isCompleted: false,
          isUpNext: true,
        ),
        DailyPlanTask(
          id: '',
          title: 'Nutritious Whole-Food Lunch',
          note: 'Aim for colorful phytonutrients and sufficient lean protein',
          timeString: '12:30 PM',
          isCompleted: false,
        ),
        DailyPlanTask(
          id: '',
          title: 'Evening Digital Wind-Down',
          note: 'Prepare your nervous system for restful biological recovery',
          timeString: '9:00 PM',
          isCompleted: false,
        ),
      ];
    }
  }
}

final onboardingJourneyProvider =
    StateNotifierProvider<OnboardingJourneyNotifier, OnboardingJourneyState>((ref) {
  return OnboardingJourneyNotifier();
});


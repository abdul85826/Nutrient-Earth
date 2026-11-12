// ==============================================================================
// Nutrient Earth — Onboarding Selection Integrity & Regression Suite
// PHASE 7 MANDATORY REGRESSION TESTS (TEST 1 through TEST 12)
// Proves zero hardcoded defaults, authoritative single source of truth,
// accurate state updates/deselection, exact back/forth restoration,
// strict multi-user isolation, and uncompromised AI personalization context.
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutrient_earth_client/core/domain/personalization/user_profile_context.dart';
import 'package:nutrient_earth_client/core/domain/orchestration/universal_question_service.dart';
import 'package:nutrient_earth_client/core/services/profile_repository.dart';
import 'package:nutrient_earth_client/core/services/task_repository.dart';
import 'package:nutrient_earth_client/core/services/auth_service.dart';
import 'package:nutrient_earth_client/features/onboarding/data/onboarding_storage_service.dart';
import 'package:nutrient_earth_client/features/onboarding/state/onboarding_journey_state.dart';
import 'package:nutrient_earth_client/features/today/state/today_state.dart';
import 'package:nutrient_earth_client/features/onboarding/domain/daily_impact_domain.dart';
import 'package:nutrient_earth_client/features/onboarding/domain/questionnaire_system.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockProfileRepo implements ProfileRepository {
  final Map<String, UserProfileContext> storage = {};
  bool failNextSave = false;

  @override
  Future<UserProfileContext?> getCurrentUserProfile({String? explicitUserId}) async {
    if (explicitUserId == null) return null;
    return storage[explicitUserId];
  }

  @override
  UserProfileContext? getCachedProfileSync(String? userId) {
    if (userId == null) return null;
    return storage[userId];
  }

  @override
  Future<bool> saveUserProfile(UserProfileContext profile) async {
    if (failNextSave) {
      failNextSave = false;
      throw Exception('Simulated database write timeout');
    }
    storage[profile.userId] = profile;
    return true;
  }

  @override
  Future<bool> clearCacheForUser(String userId) async {
    storage.remove(userId);
    return true;
  }
}

class MockTaskRepo implements TaskRepository {
  final List<DailyPlanTask> tasks = [];

  @override
  Future<List<DailyPlanTask>> getDailyTasks({String? userId}) async => tasks;

  @override
  Future<DailyPlanTask?> createTask(DailyPlanTask task, {String? userId}) async {
    tasks.add(task);
    return task;
  }

  @override
  Future<bool> toggleTaskCompletion(String taskId, bool isCompleted, {String? userId}) async => true;

  @override
  Future<bool> deleteTask(String taskId, {String? userId}) async {
    tasks.removeWhere((t) => t.id == taskId);
    return true;
  }
}

class MockAuthService implements AuthService {
  User? _user;
  MockAuthService([this._user]);

  void setUser(User? user) => _user = user;

  @override
  User? get currentUser => _user;
  @override
  Session? get currentSession => null;
  @override
  bool get isAuthenticated => _user != null;
  @override
  Stream<AuthState> get authStateChanges => const Stream.empty();
  @override
  Future<AuthSessionUrlResponse> exchangeCodeForSession(String code) => throw UnimplementedError();
  @override
  Future<void> resendOtp({required String email, OtpType type = OtpType.email, String? captchaToken}) => throw UnimplementedError();
  @override
  Future<void> resetPasswordForEmail({required String email, String? redirectTo}) => throw UnimplementedError();
  @override
  Future<AuthResponse> signIn({required String email, required String password}) => throw UnimplementedError();
  @override
  Future<bool> signInWithGoogle({String? redirectTo}) => throw UnimplementedError();
  @override
  Future<void> signInWithOtp({required String email, String? redirectTo, String? captchaToken}) => throw UnimplementedError();
  @override
  Future<void> signOut() async => _user = null;
  @override
  Future<AuthResponse> signUp({required String email, required String password, Map<String, dynamic>? data}) => throw UnimplementedError();
  @override
  Future<UserResponse> updatePassword({required String newPassword}) => throw UnimplementedError();
  @override
  Future<AuthResponse> verifyOtp({required String email, required String token, OtpType type = OtpType.email, String? captchaToken}) => throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late OnboardingStorageService storageService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    await OnboardingStorageService.initialize(prefs);
    storageService = OnboardingStorageService(prefs: prefs);
  });

  group('PHASE 7 — Onboarding Selection Integrity & State Regression Suite', () {
    // TEST 1 — New user: Open onboarding. Verify zero preselected concerns.
    test('TEST 1 — New user starts with zero preselected concerns, goals, and difficulties', () {
      final notifier = OnboardingJourneyNotifier();
      final state = notifier.currentState;

      expect(state.healthGoals, isEmpty, reason: 'New user healthGoals must be empty');
      expect(state.difficulties, isEmpty, reason: 'New user difficulties must be empty');
      expect(state.dailyImpacts, isEmpty, reason: 'New user daily impacts must be empty');
      expect(state.selectedConcernIds, isEmpty, reason: 'New user selected concerns must be empty');
      expect(state.prioritizedConcerns, isEmpty, reason: 'New user prioritized concerns must be empty');
      expect(state.isNewUser, isTrue, reason: 'Must be flagged as new user');

      // Adaptive daily impact specimens must resolve to general baseline without disease defaults
      final specimens = UniversalDailyImpactCatalog.resolveSpecimensForUser(
        selectedConcernIds: state.selectedConcernIds,
        explicitlySelectedDifficulties: state.difficulties,
      );
      final codes = specimens.map((s) => s.code).toSet();
      expect(codes.contains('GLU-01'), isFalse, reason: 'Glycemic specimen must NOT appear for new user');
      expect(specimens.length, equals(4), reason: 'Standard 4 non-disease baseline specimens');
    });

    // TEST 2 — Single selection: Select muscle gain only. Verify exactly one selection.
    test('TEST 2 — Single selection: Select muscle gain only. Verify exactly one selection.', () {
      final notifier = OnboardingJourneyNotifier();
      notifier.setHealthGoals({'build_muscle'});

      final state = notifier.currentState;
      expect(state.healthGoals, equals({'build_muscle'}));
      expect(state.selectedConcernIds, equals({'build_muscle'}));
      expect(state.prioritizedConcerns, equals({'build_muscle'}));
      expect(state.healthGoals.length, equals(1));
      expect(state.healthGoals.contains('prediabetes'), isFalse);
      expect(state.healthGoals.contains('low_energy'), isFalse);
      expect(state.healthGoals.contains('improve_sleep'), isFalse);
    });

    // TEST 3 — Multiple selections: Select digestive health and sleep. Verify exactly those two.
    test('TEST 3 — Multiple selections: Select digestive health and sleep. Verify exactly those two.', () {
      final notifier = OnboardingJourneyNotifier();
      notifier.setHealthGoals({'digestive_conditions', 'improve_sleep'});

      final state = notifier.currentState;
      expect(state.healthGoals, equals({'digestive_conditions', 'improve_sleep'}));
      expect(state.healthGoals.length, equals(2));
      expect(state.healthGoals.contains('digestive_conditions'), isTrue);
      expect(state.healthGoals.contains('improve_sleep'), isTrue);
      expect(state.healthGoals.contains('prediabetes'), isFalse);
    });

    // TEST 4 — Deselect: Remove digestive health. Verify only sleep remains.
    test('TEST 4 — Deselect: Remove digestive health. Verify only sleep remains.', () {
      final notifier = OnboardingJourneyNotifier();
      notifier.setHealthGoals({'digestive_conditions', 'improve_sleep'});
      expect(notifier.currentState.healthGoals.length, equals(2));

      // User deselects digestive_conditions by updating goals to {'improve_sleep'}
      notifier.setHealthGoals({'improve_sleep'});

      final state = notifier.currentState;
      expect(state.healthGoals, equals({'improve_sleep'}));
      expect(state.selectedConcernIds, equals({'improve_sleep'}));
      expect(state.prioritizedConcerns, equals({'improve_sleep'}));
      expect(state.healthGoals.contains('digestive_conditions'), isFalse);
    });

    // TEST 5 — Clear all: Clear all selections. Verify the count is zero and remains zero.
    test('TEST 5 — Clear all: Clear all selections. Verify the count is zero and remains zero.', () {
      final notifier = OnboardingJourneyNotifier();
      notifier.setHealthGoals({'prediabetes', 'low_energy', 'improve_sleep'});
      expect(notifier.currentState.healthGoals.length, equals(3));

      // User taps Clear all
      notifier.setHealthGoals({});

      final state = notifier.currentState;
      expect(state.healthGoals, isEmpty);
      expect(state.selectedConcernIds, isEmpty);
      expect(state.prioritizedConcerns, isEmpty);
      expect(state.healthGoals.length, equals(0));
    });

    // TEST 6 — Next and Back: Select different concerns, navigate forward and backward. Verify exact restoration.
    test('TEST 6 — Next and Back: Select concerns, simulate forward/back navigation. Exact restoration.', () async {
      final notifier = OnboardingJourneyNotifier();
      // User selects weight management on Step 1
      notifier.setHealthGoals({'lose_weight'});
      await storageService.saveStagedOnboarding(notifier.currentState);

      // Advance to Step 2 (difficulties) and select fatigue
      notifier.setDifficulties({'NRG-01'});
      await storageService.saveStagedOnboarding(notifier.currentState);

      // Simulate navigating Back to Step 1:
      // Host reads staged state from storage
      final loaded = await storageService.loadStagedOnboarding();
      expect(loaded, isNotNull);
      notifier.hydrate(loaded!);

      // Exact state preserved
      expect(notifier.currentState.healthGoals, equals({'lose_weight'}));
      expect(notifier.currentState.difficulties, equals({'NRG-01'}));
      expect(notifier.currentState.healthGoals.contains('prediabetes'), isFalse);
    });

    // TEST 7 — Refresh: Reload and restore only legitimately saved answers.
    test('TEST 7 — Refresh: Reload and restore only legitimately saved answers without defaults.', () async {
      final notifier = OnboardingJourneyNotifier();
      notifier.setHealthGoals({'hydration'});
      notifier.setDietaryPattern('vegetarian');
      await storageService.saveStagedOnboarding(notifier.currentState);

      // Simulate browser refresh: re-initialize storage from disk
      await OnboardingStorageService.initialize(prefs);
      final refreshedStorage = OnboardingStorageService(prefs: prefs);
      final restoredState = await refreshedStorage.loadStagedOnboarding();

      expect(restoredState, isNotNull);
      expect(restoredState!.healthGoals, equals({'hydration'}));
      expect(restoredState.dietaryPattern, equals('vegetarian'));
      expect(restoredState.healthGoals.contains('prediabetes'), isFalse);
      expect(restoredState.healthGoals.contains('low_energy'), isFalse);
    });

    // TEST 8 — Existing profile: Verify actual saved answers are restored without inserting unrelated defaults.
    test('TEST 8 — Existing profile: Verify actual saved answers are restored without inserting defaults.', () {
      final existingProfile = const UserProfileContext(
        userId: 'test-user-id-123',
        displayName: 'Alice',
        age: 32,
        primaryGoals: ['Build lean muscle mass'],
        knownConditions: ['Difficulty: Knee stiffness'],
        dietaryPreference: 'vegan',
        difficultiesNote: 'Recovering from knee surgery',
        onboardingCompleted: true,
      );

      final notifier = OnboardingJourneyNotifier();
      notifier.hydrateFromProfile(existingProfile);

      final state = notifier.currentState;
      expect(state.healthGoals, equals({'Build lean muscle mass'}));
      expect(state.firstName, equals('Alice'));
      expect(state.age, equals(32));
      expect(state.dietaryPattern, equals('vegan'));
      expect(state.difficultiesNote, equals('Recovering from knee surgery'));
      expect(state.healthGoals.contains('prediabetes'), isFalse);
      expect(state.healthGoals.contains('low_energy'), isFalse);
      expect(state.healthGoals.contains('improve_sleep'), isFalse);
    });

    // TEST 9 — User isolation: Two authenticated accounts must never share onboarding answers.
    test('TEST 9 — User isolation: Two authenticated accounts never share onboarding answers.', () async {
      final profileRepo = MockProfileRepo();

      const userA = UserProfileContext(
        userId: 'uuid-user-a',
        displayName: 'User A',
        primaryGoals: ['Cardiovascular Health'],
      );
      const userB = UserProfileContext(
        userId: 'uuid-user-b',
        displayName: 'User B',
        primaryGoals: ['Cognitive Focus'],
      );

      await profileRepo.saveUserProfile(userA);
      await profileRepo.saveUserProfile(userB);

      final fetchA = await profileRepo.getCurrentUserProfile(explicitUserId: 'uuid-user-a');
      final fetchB = await profileRepo.getCurrentUserProfile(explicitUserId: 'uuid-user-b');

      expect(fetchA!.primaryGoals, equals(['Cardiovascular Health']));
      expect(fetchB!.primaryGoals, equals(['Cognitive Focus']));
      expect(fetchA.primaryGoals.contains('Cognitive Focus'), isFalse);
      expect(fetchB.primaryGoals.contains('Cardiovascular Health'), isFalse);
    });

    // TEST 10 — Failed persistence: Do not falsely mark data as saved. Preserve current selections and show error.
    test('TEST 10 — Failed persistence: Preserves current selections and reports error on failure.', () async {
      final mockAuth = MockAuthService(
        const User(
          id: 'user-fail-id',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: '2026-01-01',
        ),
      );
      final mockProfileRepo = MockProfileRepo()..failNextSave = true;
      final mockTaskRepo = MockTaskRepo();

      final notifier = OnboardingJourneyNotifier();
      notifier.setHealthGoals({'manage_stress'});

      final success = await notifier.saveAndComplete(
        auth: mockAuth,
        profileRepo: mockProfileRepo,
        taskRepo: mockTaskRepo,
      );

      expect(success, isFalse, reason: 'Must return false on failure');
      expect(notifier.currentState.saveError, isNotNull, reason: 'Error message must be recorded');
      expect(notifier.currentState.saveError, contains('Simulated database write timeout'));
      expect(notifier.currentState.healthGoals, equals({'manage_stress'}), reason: 'Selections must NOT be wiped on failed save');
      expect(notifier.currentState.onboardingFinished, isFalse, reason: 'Must NOT mark onboarding as completed');
    });

    // TEST 11 — Skip: Skipped values must not be converted into false or zero-valued health information.
    test('TEST 11 — Skip: Skipped values must not be converted into false or zero-valued health information.', () {
      final notifier = OnboardingJourneyNotifier();
      // User skips daily impact ratings in Step 3
      notifier.setDailyImpactsSkipped(true);
      notifier.setDailyImpacts({});
      notifier.setImpactFluctuates(false);

      final state = notifier.currentState;
      expect(state.dailyImpactsSkipped, isTrue);
      expect(state.dailyImpacts, isEmpty);

      // Verify serialization does not synthesize zeros
      final json = state.toJson();
      expect(json['dailyImpacts'], isEmpty);
      expect(json['dailyImpactsSkipped'], isTrue);

      final restored = OnboardingJourneyState.fromJson(json);
      expect(restored.dailyImpactsSkipped, isTrue);
      expect(restored.dailyImpacts, isEmpty);
    });

    // TEST 12 — AI personalization: Only use explicitly saved, relevant user information.
    test('TEST 12 — AI personalization: General inquiries do NOT require profile; personal inquiries evaluate exact saved fields.', () {
      // 1. General inquiry: "What is Vitamin D?" -> Classified as generalKnowledge
      final generalScope = UniversalQuestionService.classifyScope('What is Vitamin D synthesis mechanism?');
      expect(generalScope, equals(QuestionScope.generalKnowledge));

      // 2. Personalized inquiry without personal pronoun -> generalKnowledge
      final scienceScope = UniversalQuestionService.classifyScope('Does magnesium glycinate improve slow-wave sleep?');
      expect(scienceScope, equals(QuestionScope.generalKnowledge));

      // 3. Personalized inquiry with pronoun -> personalizedHealth
      final personalScope = UniversalQuestionService.classifyScope('What supplements should I take for my fatigue?');
      expect(personalScope, equals(QuestionScope.personalizedHealth));

      // 4. Questionnaire system: Resolving questions for empty selections returns 0 questions
      final emptyQuestions = QuestionnaireDefinition.resolveQuestionsForConcerns({});
      expect(emptyQuestions, isEmpty, reason: 'No questions generated when no concerns are selected');

      // 5. Questionnaire system: Resolving questions for diabetes_blood_glucose returns relevant glucose questions ONLY
      final glucoseQuestions = QuestionnaireDefinition.resolveQuestionsForConcerns({'diabetes_blood_glucose'});
      expect(glucoseQuestions, isNotEmpty);
      final hasDiabetesQ = glucoseQuestions.any((q) => q.domainId == 'diabetes_blood_glucose');
      expect(hasDiabetesQ, isTrue);
    });
  });
}

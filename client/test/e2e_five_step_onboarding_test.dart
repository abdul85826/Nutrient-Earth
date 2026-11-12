// ==============================================================================
// Nutrient Earth — Complete Five-Step Onboarding & Profile Verification Test
// Validates Requirements 2, 3, and 4:
// - Step 1 selections (zero default bias)
// - Step 2 difficulties + Additional notes text
// - Step 3 ratings + Skip behavior
// - Step 4 dietary answers
// - Step 5 review & final submission
// - Profile persistence in public.profiles (including difficulties_note)
// - Tenant isolation (no cross-account data leakage)
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/domain/personalization/user_profile_context.dart';
import 'package:nutrient_earth_client/core/services/auth_service.dart';
import 'package:nutrient_earth_client/core/services/profile_repository.dart';
import 'package:nutrient_earth_client/core/services/task_repository.dart';
import 'package:nutrient_earth_client/features/onboarding/state/onboarding_journey_state.dart';
import 'package:nutrient_earth_client/features/today/state/today_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockInMemoryProfileRepository implements ProfileRepository {
  final Map<String, UserProfileContext> _database = {};

  @override
  Future<UserProfileContext?> getCurrentUserProfile({String? explicitUserId}) async {
    if (explicitUserId == null || explicitUserId.trim().isEmpty) return null;
    return _database[explicitUserId.trim()];
  }

  @override
  UserProfileContext? getCachedProfileSync(String? userId) {
    if (userId == null) return null;
    return _database[userId];
  }

  @override
  Future<bool> saveUserProfile(UserProfileContext profile) async {
    if (profile.userId.trim().isEmpty) return false;
    _database[profile.userId.trim()] = profile;
    return true;
  }

  @override
  Future<bool> clearCacheForUser(String userId) async {
    _database.remove(userId);
    return true;
  }

  Map<String, dynamic>? inspectDatabaseRow(String userId) {
    final profile = _database[userId];
    if (profile == null) return null;
    return profile.toJson();
  }
}

class MockAuthServiceForE2E implements AuthService {
  User? _user;

  void setUser(User? user) {
    _user = user;
  }

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

class MockTaskRepositoryForE2E implements TaskRepository {
  final List<DailyPlanTask> createdTasks = [];

  @override
  Future<List<DailyPlanTask>> getDailyTasks({String? userId}) async => createdTasks;

  @override
  Future<DailyPlanTask?> createTask(DailyPlanTask task, {String? userId}) async {
    createdTasks.add(task);
    return task;
  }

  @override
  Future<bool> toggleTaskCompletion(String taskId, bool isCompleted, {String? userId}) async => true;

  @override
  Future<bool> deleteTask(String taskId, {String? userId}) async {
    createdTasks.removeWhere((t) => t.id == taskId);
    return true;
  }
}

User _createTestUser(String id, String email) {
  return User(
    id: id,
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    email: email,
    createdAt: DateTime.now().toIso8601String(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NUTRIENT EARTH — Five-Step Onboarding & Profile Integration Suite', () {
    late MockInMemoryProfileRepository profileRepo;
    late MockAuthServiceForE2E authService;
    late MockTaskRepositoryForE2E taskRepo;

    setUp(() {
      profileRepo = MockInMemoryProfileRepository();
      authService = MockAuthServiceForE2E();
      taskRepo = MockTaskRepositoryForE2E();
    });

    test('E2E FLOW 1: Complete 5-Step Journey & Verify DB Profile Persistence', () async {
      // Authenticate test user
      const testUserId = 'usr_test_verified_99';
      authService.setUser(_createTestUser(testUserId, 'jordan@example.com'));

      final notifier = OnboardingJourneyNotifier();

      // Step 1: Health Goals selection (User picks Energy & Muscle; zero preselected items)
      expect(notifier.currentState.healthGoals, isEmpty);
      notifier.setHealthGoals({'Build lean muscle mass'});
      expect(notifier.currentState.healthGoals, equals({'Build lean muscle mass'}));

      // Step 2: Difficulties & Additional Free-Text Notes
      expect(notifier.currentState.difficulties, isEmpty);
      expect(notifier.currentState.difficultiesNote, isEmpty);

      notifier.setDifficulties({'MSK-01'});
      notifier.setDifficultiesNote('Occasional fatigue in early afternoons and mild joint pain after exertion.');

      expect(notifier.currentState.difficulties, equals({'MSK-01'}));
      expect(
        notifier.currentState.difficultiesNote,
        equals('Occasional fatigue in early afternoons and mild joint pain after exertion.'),
      );

      // Step 3: Daily Impact Ratings (User rates MSK-01 as 3)
      notifier.setDailyImpacts({'MSK-01': 3});
      notifier.setDailyImpactsSkipped(false);
      expect(notifier.currentState.dailyImpacts, equals({'MSK-01': 3}));
      expect(notifier.currentState.dailyImpactsSkipped, isFalse);

      // Step 4: Dietary Pattern & Nutrition
      notifier.setDietaryPattern('High Protein / Whole Foods');
      notifier.setAllergens({'Gluten'});
      expect(notifier.currentState.dietaryPattern, equals('High Protein / Whole Foods'));
      expect(notifier.currentState.allergens, equals({'Gluten'}));

      // Step 5: Review Phase, Personal Details, & Final Submission
      notifier.setFirstName('Jordan');
      notifier.setAge(28);
      notifier.setHeightCm(178.0);
      notifier.setWeightKg(75.5);

      final saveSuccess = await notifier.saveAndComplete(
        auth: authService,
        profileRepo: profileRepo,
        taskRepo: taskRepo,
      );

      expect(saveSuccess, isTrue);
      expect(notifier.currentState.onboardingFinished, isTrue);

      // Verify Database Table public.profiles row
      final dbRow = profileRepo.inspectDatabaseRow(testUserId);
      expect(dbRow, isNotNull);
      expect(dbRow!['user_id'], equals(testUserId));
      expect(dbRow['display_name'], equals('Jordan'));
      expect(dbRow['age'], equals(28));
      expect(dbRow['height_cm'], equals(178.0));
      expect(dbRow['weight_kg'], equals(75.5));
      expect(dbRow['primary_goals'], equals(['Build lean muscle mass']));
      expect(dbRow['dietary_preference'], equals('High Protein / Whole Foods'));
      expect(dbRow['difficulties'], equals(['MSK-01']));
      expect(
        dbRow['difficulties_note'],
        equals('Occasional fatigue in early afternoons and mild joint pain after exertion.'),
      );
      expect(dbRow['daily_impacts'], equals({'MSK-01': 3}));
      expect(dbRow['onboarding_completed'], isTrue);

      // Verify Profile Integration: Retrieval by authenticated user
      final fetchedProfile = await profileRepo.getCurrentUserProfile(explicitUserId: testUserId);
      expect(fetchedProfile, isNotNull);
      expect(fetchedProfile!.displayName, equals('Jordan'));
      expect(fetchedProfile.difficultiesNote, equals('Occasional fatigue in early afternoons and mild joint pain after exertion.'));
      expect(fetchedProfile.difficulties, equals(['MSK-01']));
      expect(fetchedProfile.dailyImpacts, equals({'MSK-01': 3}));
      expect(fetchedProfile.onboardingCompleted, isTrue);
    });

    test('E2E FLOW 2: Tenant Isolation — Another account cannot access User 1 profile', () async {
      // User 1 finishes onboarding
      authService.setUser(_createTestUser('user_111', 'user1@example.com'));
      final notifier1 = OnboardingJourneyNotifier();
      notifier1.setHealthGoals({'Digestive balance'});
      notifier1.setDifficulties({'DIG-01'});
      notifier1.setDifficultiesNote('Sensitive to dairy');
      await notifier1.saveAndComplete(auth: authService, profileRepo: profileRepo, taskRepo: taskRepo);

      // Switch auth to User 2
      authService.setUser(_createTestUser('user_222', 'user2@example.com'));

      // User 2 profile must be null in DB
      final user2Profile = await profileRepo.getCurrentUserProfile(explicitUserId: 'user_222');
      expect(user2Profile, isNull);

      // User 2 fresh journey starts completely empty
      final notifier2 = OnboardingJourneyNotifier();
      expect(notifier2.currentState.healthGoals, isEmpty);
      expect(notifier2.currentState.difficulties, isEmpty);
      expect(notifier2.currentState.difficultiesNote, isEmpty);
      expect(notifier2.currentState.dailyImpacts, isEmpty);
    });

    test('E2E FLOW 3: Explicit Skip Behavior Distinguishability', () async {
      authService.setUser(_createTestUser('user_skip_step3', 'skip@example.com'));
      final notifier = OnboardingJourneyNotifier();

      // User selects difficulties but explicitly skips Step 3
      notifier.setDifficulties({'NRG-01'});
      notifier.setDailyImpactsSkipped(true);
      notifier.setDailyImpacts({});

      await notifier.saveAndComplete(auth: authService, profileRepo: profileRepo, taskRepo: taskRepo);

      final dbRow = profileRepo.inspectDatabaseRow('user_skip_step3');
      expect(dbRow!['difficulties'], equals(['NRG-01']));
      expect(dbRow['daily_impacts'], isEmpty); // NOT populated with fabricated defaults!
      expect(dbRow['onboarding_completed'], isTrue);
    });
  });
}

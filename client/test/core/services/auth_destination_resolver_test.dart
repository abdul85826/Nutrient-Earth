// ==============================================================================
// Nutrient Earth — Auth Destination Resolver Unit Test Suite
// Verifies post-authentication navigation routing across all user profile states:
// 1. New account -> /onboarding/health-goals (Screen 04)
// 2. Completed account -> /today (Screen 18)
// 3. Incomplete onboarding -> Sequentially resolves first incomplete step (Screens 04-12)
// 4. Safe returnTo parameter handling & URL decoding
// 5. Exception & failure resilience
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/domain/personalization/user_profile_context.dart';
import 'package:nutrient_earth_client/core/services/auth_destination_resolver.dart';
import 'package:nutrient_earth_client/core/services/profile_repository.dart';

class MockProfileRepoForResolver implements ProfileRepository {
  UserProfileContext? profileToReturn;
  bool shouldThrow = false;
  String? queriedUserId;

  @override
  Future<UserProfileContext?> getCurrentUserProfile({String? explicitUserId}) async {
    queriedUserId = explicitUserId;
    if (shouldThrow) {
      throw Exception('Database query timeout or network failure');
    }
    return profileToReturn;
  }

  @override
  UserProfileContext? getCachedProfileSync(String? userId) => profileToReturn;

  @override
  Future<bool> saveUserProfile(UserProfileContext profile) async {
    profileToReturn = profile;
    return true;
  }

  @override
  Future<bool> updateAvatar({
    required String skinTone,
    Map<String, dynamic>? avatarConfig,
  }) async => true;

  @override
  Future<bool> clearCacheForUser(String userId) async {
    profileToReturn = null;
    return true;
  }
}

UserProfileContext _createTestProfile({
  String userId = 'usr_test_123',
  String displayName = 'Elena Rostova',
  int age = 34,
  String biologicalSex = 'female',
  List<String> primaryGoals = const ['Cognitive Clarity', 'Energy & Vitality'],
  String activityLevel = 'moderate',
  String dietaryPreference = 'mediterranean',
  String budgetConstraint = 'moderate',
  String willingnessToChange = 'high',
  List<String> knownConditions = const ['none'],
  List<String> activeSupplements = const ['Vitamin D3', 'Magnesium Glycinate'],
  List<String> allergies = const ['none'],
  double? heightCm = 172.0,
  double? weightKg = 64.0,
  String eatingRoutine = 'intermittent_fasting_16_8',
  String sleepQuality = 'deep_restful',
  String knowledgeLevel = 'intermediate',
  List<String> difficulties = const ['Afternoon energy dip'],
  Map<String, dynamic> dailyImpacts = const {'fatigue': 'moderate'},
  bool onboardingCompleted = false,
}) {
  return UserProfileContext(
    userId: userId,
    displayName: displayName,
    age: age,
    biologicalSex: biologicalSex,
    primaryGoals: primaryGoals,
    activityLevel: activityLevel,
    dietaryPreference: dietaryPreference,
    budgetConstraint: budgetConstraint,
    willingnessToChange: willingnessToChange,
    knownConditions: knownConditions,
    activeSupplements: activeSupplements,
    allergies: allergies,
    heightCm: heightCm,
    weightKg: weightKg,
    eatingRoutine: eatingRoutine,
    sleepQuality: sleepQuality,
    knowledgeLevel: knowledgeLevel,
    difficulties: difficulties,
    dailyImpacts: dailyImpacts,
    onboardingCompleted: onboardingCompleted,
  );
}

void main() {
  late MockProfileRepoForResolver mockRepo;

  setUp(() {
    mockRepo = MockProfileRepoForResolver();
  });

  group('AuthDestinationResolver - resolveDestination', () {
    test('routes new user (profile is null) to /onboarding/health-goals', () async {
      mockRepo.profileToReturn = null;
      final destination = await AuthDestinationResolver.resolveDestination(
        profileRepository: mockRepo,
        userId: 'usr_new_google_user',
      );

      expect(destination, equals('/onboarding/health-goals'));
      expect(mockRepo.queriedUserId, equals('usr_new_google_user'));
    });

    test('routes completed user (onboardingCompleted == true) to /today', () async {
      mockRepo.profileToReturn = _createTestProfile(onboardingCompleted: true);
      final destination = await AuthDestinationResolver.resolveDestination(
        profileRepository: mockRepo,
        userId: 'usr_returning_user',
      );

      expect(destination, equals('/today'));
    });

    test('routes incomplete user to first incomplete step', () async {
      mockRepo.profileToReturn = _createTestProfile(
        onboardingCompleted: false,
        primaryGoals: [], // Missing goals
      );
      final destination = await AuthDestinationResolver.resolveDestination(
        profileRepository: mockRepo,
        userId: 'usr_incomplete_user',
      );

      expect(destination, equals('/onboarding/health-goals'));
    });

    test('honors valid safe returnTo route parameter over default destination', () async {
      mockRepo.profileToReturn = _createTestProfile(onboardingCompleted: true);

      final destination = await AuthDestinationResolver.resolveDestination(
        profileRepository: mockRepo,
        userId: 'usr_returning_user',
        returnTo: '/explore',
      );

      expect(destination, equals('/explore'));
    });

    test('decodes URL-encoded returnTo parameter cleanly', () async {
      mockRepo.profileToReturn = _createTestProfile(onboardingCompleted: true);

      final destination = await AuthDestinationResolver.resolveDestination(
        profileRepository: mockRepo,
        userId: 'usr_returning_user',
        returnTo: '%2Ftoday%3Ftab%3Dbiometrics',
      );

      expect(destination, equals('/today?tab=biometrics'));
    });

    test('ignores auth and welcome loops in returnTo parameter', () async {
      mockRepo.profileToReturn = _createTestProfile(onboardingCompleted: true);

      final destinationAuth = await AuthDestinationResolver.resolveDestination(
        profileRepository: mockRepo,
        userId: 'usr_returning_user',
        returnTo: '/auth',
      );
      expect(destinationAuth, equals('/today'));

      final destinationWelcome = await AuthDestinationResolver.resolveDestination(
        profileRepository: mockRepo,
        userId: 'usr_returning_user',
        returnTo: '/welcome',
      );
      expect(destinationWelcome, equals('/today'));
    });

    test('gracefully recovers from repository error by falling back to /onboarding/health-goals', () async {
      mockRepo.shouldThrow = true;

      final destination = await AuthDestinationResolver.resolveDestination(
        profileRepository: mockRepo,
        userId: 'usr_error_case',
      );

      expect(destination, equals('/onboarding/health-goals'));
    });
  });

  group('AuthDestinationResolver - resolveFirstIncompleteStep sequential step resolution', () {
    test('Screen 04: returns /onboarding/health-goals when primaryGoals is empty', () {
      final profile = _createTestProfile(primaryGoals: []);
      expect(AuthDestinationResolver.resolveFirstIncompleteStep(profile), equals('/onboarding/health-goals'));
    });

    test('Screen 05: returns /onboarding/difficulties when difficulties and dailyImpacts are both empty', () {
      final profile = _createTestProfile(
        primaryGoals: ['Longevity'],
        difficulties: [],
        dailyImpacts: {},
      );
      expect(AuthDestinationResolver.resolveFirstIncompleteStep(profile), equals('/onboarding/difficulties'));
    });

    test('Screen 06: returns /onboarding/daily-impact when difficulties is populated but dailyImpacts is empty', () {
      final profile = _createTestProfile(
        primaryGoals: ['Longevity'],
        difficulties: ['Low stamina'],
        dailyImpacts: {},
      );
      expect(AuthDestinationResolver.resolveFirstIncompleteStep(profile), equals('/onboarding/daily-impact'));
    });

    test('Screen 07: returns /onboarding/food-choices when dietaryPreference is empty or unspecified', () {
      final profileEmpty = _createTestProfile(dietaryPreference: '');
      expect(AuthDestinationResolver.resolveFirstIncompleteStep(profileEmpty), equals('/onboarding/food-choices'));

      final profileUnspecified = _createTestProfile(dietaryPreference: 'unspecified');
      expect(AuthDestinationResolver.resolveFirstIncompleteStep(profileUnspecified), equals('/onboarding/food-choices'));
    });

    test('Screen 09: returns /onboarding/personal-details when displayName is empty or default User', () {
      final profileEmpty = _createTestProfile(displayName: '');
      expect(AuthDestinationResolver.resolveFirstIncompleteStep(profileEmpty), equals('/onboarding/personal-details'));

      final profileDefault = _createTestProfile(displayName: 'User');
      expect(AuthDestinationResolver.resolveFirstIncompleteStep(profileDefault), equals('/onboarding/personal-details'));
    });

    test('Screen 10: returns /onboarding/body-measurements when heightCm and weightKg are both null', () {
      final profile = _createTestProfile(heightCm: null, weightKg: null);
      expect(AuthDestinationResolver.resolveFirstIncompleteStep(profile), equals('/onboarding/body-measurements'));
    });

    test('Screen 11: returns /onboarding/health-concerns when knownConditions is empty', () {
      final profile = _createTestProfile(knownConditions: []);
      expect(AuthDestinationResolver.resolveFirstIncompleteStep(profile), equals('/onboarding/health-concerns'));
    });

    test('Screen 12: returns /onboarding/food-restrictions when allergies is empty', () {
      final profile = _createTestProfile(allergies: []);
      expect(AuthDestinationResolver.resolveFirstIncompleteStep(profile), equals('/onboarding/food-restrictions'));
    });
  });
}


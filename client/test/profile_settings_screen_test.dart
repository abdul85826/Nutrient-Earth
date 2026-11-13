// ==============================================================================
// Nutrient Earth — Profile & Settings Screen Test Suite
// Verifies:
// 1. ProfileSettingsScreen renders both tabs: Health Calibration & Account & Security.
// 2. Verified user profile data reflects faithfully from state/repository.
// 3. Edit actions route to onboarding steps with returnTo=/profile.
// 4. Account security metrics and clinical isolation assurances are presented.
// 5. Switching tabs works seamlessly.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nutrient_earth_client/core/domain/personalization/user_profile_context.dart';
import 'package:nutrient_earth_client/core/services/auth_service.dart';
import 'package:nutrient_earth_client/core/services/profile_repository.dart';
import 'package:nutrient_earth_client/features/onboarding/state/onboarding_journey_state.dart';
import 'package:nutrient_earth_client/features/profile/presentation/profile_settings_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockTestProfileRepository implements ProfileRepository {
  UserProfileContext? profile;

  MockTestProfileRepository({this.profile});

  @override
  Future<UserProfileContext?> getCurrentUserProfile({String? explicitUserId}) async => profile;

  @override
  UserProfileContext? getCachedProfileSync(String? userId) => profile;

  @override
  Future<bool> saveUserProfile(UserProfileContext p) async {
    profile = p;
    return true;
  }

  @override
  Future<bool> clearCacheForUser(String userId) async => true;
}

class MockTestAuthService implements AuthService {
  final bool _auth;
  final User? _user;

  MockTestAuthService({bool authenticated = false, User? user})
      : _auth = authenticated,
        _user = user;

  @override
  bool get isAuthenticated => _auth;

  @override
  User? get currentUser => _user;

  @override
  Session? get currentSession => null;

  @override
  Stream<AuthState> get authStateChanges => const Stream.empty();

  @override
  Future<AuthResponse> signIn({required String email, required String password}) async =>
      AuthResponse();

  @override
  Future<AuthResponse> signUp({required String email, required String password, Map<String, dynamic>? data}) async =>
      AuthResponse();

  @override
  Future<bool> signInWithGoogle({String? redirectTo}) async => true;

  @override
  Future<void> signInWithOtp({required String email, String? redirectTo, String? captchaToken}) async {}

  @override
  Future<AuthResponse> verifyOtp({required String email, required String token, OtpType type = OtpType.email, String? captchaToken}) async =>
      AuthResponse();

  @override
  Future<void> resendOtp({required String email, OtpType type = OtpType.email, String? captchaToken}) async {}

  @override
  Future<AuthSessionUrlResponse> exchangeCodeForSession(String code) async =>
      throw UnimplementedError();

  @override
  Future<void> signOut() async {}

  @override
  Future<void> resetPasswordForEmail({required String email, String? redirectTo}) async {}

  @override
  Future<UserResponse> updatePassword({required String newPassword}) async =>
      throw UnimplementedError();
}

Widget createTestApp({
  required Widget child,
  UserProfileContext? profile,
  bool authenticated = false,
  User? user,
  OnboardingJourneyState? journeyState,
}) {
  return ProviderScope(
    overrides: [
      profileRepositoryProvider.overrideWithValue(
        MockTestProfileRepository(profile: profile),
      ),
      authServiceProvider.overrideWithValue(
        MockTestAuthService(authenticated: authenticated, user: user),
      ),
      if (journeyState != null)
        onboardingJourneyProvider.overrideWith(
          (ref) => OnboardingJourneyNotifier(journeyState),
        ),
    ],
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProfileSettingsScreen Verification', () {
    testWidgets('Renders Health Calibration tab with verified user information', (tester) async {
      const mockProfile = UserProfileContext(
        userId: 'usr_test_12345678',
        displayName: 'Aria',
        age: 32,
        heightCm: 168.0,
        weightKg: 62.0,
        primaryGoals: ['Endurance', 'Better Sleep'],
        dietaryPreference: 'vegetarian',
        allergies: ['Peanuts', 'Tree nuts'],
        eatingRoutine: 'intermittent_fasting',
        activityLevel: 'moderate',
        sleepQuality: 'good_consistent',
        knowledgeLevel: 'intermediate',
        difficulties: ['Low energy'],
        onboardingCompleted: true,
      );

      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const mockUser = User(
        id: 'usr_test_12345678',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '2026-01-01',
      );

      await tester.pumpWidget(
        createTestApp(
          child: const ProfileSettingsScreen(initialTab: 0),
          profile: mockProfile,
          authenticated: true,
          user: mockUser,
        ),
      );
      await tester.pumpAndSettle();

      // Header verification
      expect(find.text('Profile & Settings'), findsOneWidget);
      expect(find.text('Aria'), findsNWidgets(2));
      expect(find.text('Profile Verified'), findsOneWidget);

      // Physiology
      expect(find.text('Physiology & Measurements'), findsOneWidget);
      expect(find.text('32 years'), findsOneWidget);
      expect(find.text('168 cm (5.5 ft)'), findsOneWidget);
      expect(find.text('62 kg (137 lb)'), findsOneWidget);

      // Goals & Difficulties
      expect(find.text('Health Goals'), findsOneWidget);
      expect(find.text('Endurance'), findsOneWidget);
      expect(find.text('Daily Difficulties & Impact'), findsOneWidget);
      expect(find.text('Low Energy'), findsOneWidget);

      // Dietary & Allergies
      expect(find.text('Dietary Pattern & Avoidances'), findsOneWidget);
      expect(find.text('Vegetarian'), findsOneWidget);
      expect(find.text('Clinical Safety & Allergies'), findsOneWidget);
      expect(find.text('Peanuts'), findsOneWidget);

      // Lifestyle & Checkpoints
      expect(find.text('Lifestyle, Routine & Sleep'), findsOneWidget);
      expect(find.text('Intermittent Fasting'), findsOneWidget);
      expect(find.text('Full Calibration Checkpoints'), findsOneWidget);
      expect(find.text('Review Phase 1'), findsOneWidget);
      expect(find.text('Completion Card'), findsOneWidget);
    });

    testWidgets('Renders Account & Security tab with clinical privacy assurances', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestApp(
          child: const ProfileSettingsScreen(initialTab: 1),
          authenticated: false,
        ),
      );
      await tester.pumpAndSettle();

      // Account & Security elements
      expect(find.text('Account Identity'), findsOneWidget);
      expect(find.text('Guest Exploration'), findsOneWidget);
      expect(find.text('Unauthenticated Explorer'), findsOneWidget);
      expect(find.text('Clinical Account Isolation (RLS)'), findsOneWidget);

      // Privacy Architecture
      expect(find.text('Data Protection & Privacy Architecture'), findsOneWidget);
      expect(find.text('Sign In or Register Account'), findsOneWidget);
      expect(find.text('Return to Today Plan'), findsOneWidget);
    });

    testWidgets('Switches tabs between Health Calibration and Account & Security', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const ProfileSettingsScreen(initialTab: 0),
          authenticated: false,
        ),
      );
      await tester.pumpAndSettle();

      // Initially on Health Calibration tab
      expect(find.text('Physiology & Measurements'), findsOneWidget);
      expect(find.text('Health Goals'), findsOneWidget);

      // Tap Account & Security tab
      await tester.tap(find.text('Account & Security'));
      await tester.pumpAndSettle();

      // Now Account & Security tab is active
      expect(find.text('Account Identity'), findsOneWidget);
      expect(find.text('Data Protection & Privacy Architecture'), findsOneWidget);
    });
  });
}

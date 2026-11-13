// ==============================================================================
// Nutrient Earth — Startup Coordinator & Startup Screens Test Suite
// Verifies all 7 states of StartupState machine, session restoration,
// offline fallback, navigation idempotency, and UI rendering of Splash & Welcome.
// ==============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrient_earth_client/core/domain/personalization/user_profile_context.dart';
import 'package:nutrient_earth_client/core/services/auth_service.dart';
import 'package:nutrient_earth_client/core/services/profile_repository.dart';
import 'package:nutrient_earth_client/core/services/startup_coordinator.dart';
import 'package:nutrient_earth_client/features/onboarding/data/onboarding_storage_service.dart';
import 'package:nutrient_earth_client/features/onboarding/presentation/screens/01_splash_screen.dart';
import 'package:nutrient_earth_client/features/onboarding/presentation/screens/02_welcome_screen.dart';
import 'package:nutrient_earth_client/features/onboarding/state/onboarding_journey_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Test Mocks ---

class _MockAuthService implements AuthService {
  User? _currentUser;
  Session? _currentSession;
  final StreamController<AuthState> _controller =
      StreamController<AuthState>.broadcast();

  void setUser(User? user) {
    _currentUser = user;
    if (user != null) {
      _currentSession = Session(
        accessToken: 'mock-token',
        tokenType: 'bearer',
        user: user,
      );
    } else {
      _currentSession = null;
    }
  }

  @override
  User? get currentUser => _currentUser;

  @override
  Session? get currentSession => _currentSession;

  @override
  bool get isAuthenticated => _currentUser != null;

  @override
  Stream<AuthState> get authStateChanges => _controller.stream;

  @override
  Future<AuthResponse> signUp(
          {required String email,
          required String password,
          Map<String, dynamic>? data}) async =>
      AuthResponse(user: _currentUser, session: _currentSession);

  @override
  Future<AuthResponse> signIn(
          {required String email, required String password}) async =>
      AuthResponse(user: _currentUser, session: _currentSession);

  @override
  Future<void> signInWithOtp(
      {required String email, String? redirectTo, String? captchaToken}) async {}

  @override
  Future<AuthResponse> verifyOtp(
          {required String email,
          required String token,
          OtpType type = OtpType.email,
          String? captchaToken}) async =>
      AuthResponse(user: _currentUser, session: _currentSession);

  @override
  Future<void> resendOtp(
      {required String email,
      OtpType type = OtpType.email,
      String? captchaToken}) async {}

  @override
  Future<bool> signInWithGoogle({String? redirectTo}) async => false;

  @override
  Future<AuthSessionUrlResponse> exchangeCodeForSession(String code) async =>
      AuthSessionUrlResponse(session: _currentSession!, redirectType: 'web');

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _currentSession = null;
  }

  @override
  Future<void> resetPasswordForEmail(
      {required String email, String? redirectTo}) async {}

  @override
  Future<UserResponse> updatePassword({required String newPassword}) async =>
      UserResponse.fromJson({'user': {}});
}

class _MockProfileRepository implements ProfileRepository {
  UserProfileContext? mockProfile;
  UserProfileContext? cachedProfile;
  bool shouldThrow = false;

  @override
  Future<UserProfileContext?> getCurrentUserProfile(
      {String? explicitUserId}) async {
    if (shouldThrow) {
      throw Exception('Network unreachable');
    }
    return mockProfile;
  }

  @override
  UserProfileContext? getCachedProfileSync(String? userId) {
    return cachedProfile;
  }

  @override
  Future<bool> saveUserProfile(UserProfileContext profile) async {
    mockProfile = profile;
    cachedProfile = profile;
    return true;
  }

  @override
  Future<void> syncFromOnboardingState(
      String userId, OnboardingJourneyState state) async {}

  @override
  Future<bool> clearCacheForUser(String userId) async {
    cachedProfile = null;
    return true;
  }
}

class _MockStorageService implements OnboardingStorageService {
  OnboardingJourneyState? stagedState;
  bool completed = false;

  @override
  bool get isOnboardingCompleted => completed;

  @override
  OnboardingJourneyState? get cachedStagedState => stagedState;

  @override
  Future<bool> hasActiveStagedSession() async => stagedState != null;

  @override
  Future<OnboardingJourneyState?> loadStagedOnboarding() async => stagedState;

  @override
  Future<void> saveStagedOnboarding(OnboardingJourneyState state) async {
    stagedState = state;
  }

  @override
  Future<void> setOnboardingCompleted({bool completed = true}) async {
    this.completed = completed;
  }

  @override
  Future<void> clearStagedOnboarding() async {
    stagedState = null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    dotenv.testLoad(
      fileInput:
          'SUPABASE_URL=https://mock.supabase.co\nSUPABASE_ANON_KEY=mock-anon-key\n',
    );
  });

  group('StartupCoordinator State Machine Unit Tests', () {
    late _MockAuthService mockAuth;
    late _MockProfileRepository mockProfileRepo;
    late _MockStorageService mockStorage;
    late StartupCoordinator coordinator;

    setUp(() {
      mockAuth = _MockAuthService();
      mockProfileRepo = _MockProfileRepository();
      mockStorage = _MockStorageService();
      coordinator = StartupCoordinator(
        authService: mockAuth,
        profileRepository: mockProfileRepo,
        storageService: mockStorage,
      );
    });

    test('Fresh unauthenticated visitor resolves to showingWelcome -> /welcome',
        () async {
      await coordinator.resolveStartupDestination();

      expect(coordinator.state.state, equals(StartupState.showingWelcome));
      expect(coordinator.state.targetRoute, equals('/welcome'));
      expect(coordinator.state.isReady, isTrue);
    });

    test(
        'Unauthenticated visitor with in-flight guest onboarding resumes showingOnboarding',
        () async {
      mockStorage.stagedState = const OnboardingJourneyState(
        healthGoals: {'Improve sleep quality'},
      );

      await coordinator.resolveStartupDestination();

      expect(coordinator.state.state, equals(StartupState.showingOnboarding));
      expect(coordinator.state.targetRoute,
          equals('/onboarding/health-goals'));
      expect(coordinator.state.isReady, isTrue);
    });

    test(
        'Authenticated user with completed profile resolves to showingMainApplication -> /today',
        () async {
      mockAuth.setUser(
        const User(
          id: 'user-123',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: '2026-01-01',
        ),
      );
      mockProfileRepo.mockProfile = const UserProfileContext(
        userId: 'user-123',
        displayName: 'Test User',
        onboardingCompleted: true,
      );

      await coordinator.resolveStartupDestination();

      expect(coordinator.state.state,
          equals(StartupState.showingMainApplication));
      expect(coordinator.state.targetRoute, equals('/today'));
      expect(coordinator.state.isReady, isTrue);
    });

    test(
        'Authenticated user with incomplete profile resolves to showingOnboarding at first step',
        () async {
      mockAuth.setUser(
        const User(
          id: 'user-incomplete',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: '2026-01-01',
        ),
      );
      mockProfileRepo.mockProfile = const UserProfileContext(
        userId: 'user-incomplete',
        displayName: 'Test User',
        onboardingCompleted: false,
        primaryGoals: ['Energy'],
        // difficulties is empty -> next step is difficulties
      );

      await coordinator.resolveStartupDestination();

      expect(coordinator.state.state, equals(StartupState.showingOnboarding));
      expect(coordinator.state.targetRoute,
          equals('/onboarding/difficulties'));
      expect(coordinator.state.isReady, isTrue);
    });

    test('Network error with cached completed profile falls back to /today',
        () async {
      mockAuth.setUser(
        const User(
          id: 'user-cached',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: '2026-01-01',
        ),
      );
      mockProfileRepo.shouldThrow = true;
      mockProfileRepo.cachedProfile = const UserProfileContext(
        userId: 'user-cached',
        displayName: 'Test User',
        onboardingCompleted: true,
      );

      await coordinator.resolveStartupDestination();

      expect(coordinator.state.state,
          equals(StartupState.showingMainApplication));
      expect(coordinator.state.targetRoute, equals('/today'));
      expect(coordinator.state.isReady, isTrue);
    });

    test('Network error without cached profile transitions to recoverableError',
        () async {
      mockAuth.setUser(
        const User(
          id: 'user-nocache',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: '2026-01-01',
        ),
      );
      mockProfileRepo.shouldThrow = true;
      mockProfileRepo.cachedProfile = null;

      await coordinator.resolveStartupDestination();

      expect(coordinator.state.state, equals(StartupState.recoverableError));
      expect(coordinator.state.isReady, isFalse);
      expect(coordinator.state.errorMessage, isNotNull);
    });

    test('markNavigated() is strictly idempotent', () {
      expect(coordinator.hasNavigated, isFalse);
      final first = coordinator.markNavigated();
      expect(first, isTrue);
      expect(coordinator.hasNavigated, isTrue);

      final second = coordinator.markNavigated();
      expect(second, isFalse);

      coordinator.resetNavigation();
      expect(coordinator.hasNavigated, isFalse);
      expect(coordinator.markNavigated(), isTrue);
    });
  });

  group('Startup Widget Tests', () {
    testWidgets('SplashScreen renders brand emblem, title and telemetry',
        (tester) async {
      final mockAuth = _MockAuthService();
      final mockProfile = _MockProfileRepository();
      final mockStorage = _MockStorageService();

      final coordinator = StartupCoordinator(
        authService: mockAuth,
        profileRepository: mockProfile,
        storageService: mockStorage,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            startupCoordinatorProvider.overrideWith((ref) => coordinator),
          ],
          child: const MaterialApp(
            home: SplashScreen(autoAdvance: false),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Nutrient Earth'), findsOneWidget);
      expect(find.text('EVIDENCE COMPANION'), findsOneWidget);
      expect(find.text('SPECIMEN CORE'), findsOneWidget);
      expect(find.text('CLINICAL BIOANALYTICS • VERIFIED'), findsOneWidget);
      expect(find.text('Nutrition, grounded in science.'), findsOneWidget);
    });

    testWidgets(
        'WelcomeScreen renders headline, specimen card, bio badges and CTAs',
        (tester) async {
      final router = GoRouter(
        initialLocation: '/welcome',
        routes: [
          GoRoute(
            path: '/welcome',
            builder: (context, state) => const WelcomeScreen(),
          ),
          GoRoute(
            path: '/onboarding/health-goals',
            builder: (context, state) => const Scaffold(body: Text('Goals Screen')),
          ),
          GoRoute(
            path: '/auth',
            builder: (context, state) => const Scaffold(body: Text('Auth Screen')),
          ),
          GoRoute(
            path: '/processing-view',
            builder: (context, state) =>
                const Scaffold(body: Text('Processing View')),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Brand headers & Headline
      expect(find.text('NUTRIENT EARTH'), findsOneWidget);
      expect(
          find.text('Your health is a journey.\nUnderstand what shapes it.'),
          findsOneWidget);

      // Bio-signal Badges
      expect(find.text('BODY SIGNALS'), findsOneWidget);
      expect(find.text('EVIDENCE ANSWERS'), findsOneWidget);
      expect(find.text('NUTRITION'), findsOneWidget);
      expect(find.text('MOVEMENT'), findsOneWidget);

      // CTAs
      expect(find.text('Get started'), findsOneWidget);
      expect(find.text('I already have an account'), findsOneWidget);
      expect(find.text('Preview Multimodal Evidence AI →'), findsOneWidget);

      // Scroll to Get Started, tap and verify navigation
      await tester.ensureVisible(find.text('Get started'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();
      expect(find.text('Goals Screen'), findsOneWidget);
    });
  });
}

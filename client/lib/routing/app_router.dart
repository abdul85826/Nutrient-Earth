// ==============================================================================
// Nutrient Earth — App Router (GoRouter)
// Maps and connects all 18 designed Nutrient Earth screens, user journeys,
// deep-linking returnTo targets, and shared intelligence routes.
// ==============================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../core/config/supabase_config.dart';
import '../core/services/auth_service.dart';
import '../features/explore/presentation/explore_screen.dart';
import '../features/onboarding/presentation/screens/01_splash_screen.dart';
import '../features/onboarding/presentation/screens/02_welcome_screen.dart';
import '../features/onboarding/presentation/screens/03_auth_screen.dart';
import '../features/onboarding/presentation/screens/04_health_goals_screen.dart';
import '../features/onboarding/presentation/screens/05_practical_difficulties_screen.dart';
import '../features/onboarding/presentation/screens/06_daily_impact_screen.dart';
import '../features/onboarding/presentation/screens/07_food_choices_screen.dart';
import '../features/onboarding/presentation/screens/08_review_phase1_screen.dart';
import '../features/onboarding/presentation/screens/09_personal_details_screen.dart';
import '../features/onboarding/presentation/screens/10_body_measurements_screen.dart';
import '../features/onboarding/presentation/screens/11_health_concerns_screen.dart';
import '../features/onboarding/presentation/screens/12_food_restrictions_screen.dart';
import '../features/onboarding/presentation/screens/13_eating_routine_screen.dart';
import '../features/onboarding/presentation/screens/14_daily_activity_screen.dart';
import '../features/onboarding/presentation/screens/15_sleep_patterns_screen.dart';
import '../features/onboarding/presentation/screens/16_knowledge_level_screen.dart';
import '../features/onboarding/presentation/screens/17_completion_screen.dart';
import '../features/today/presentation/today_screen.dart';
import '../features/today/presentation/widgets/input_processing_view.dart';
import '../features/today/presentation/widgets/universal_reference_answer_card.dart';

/// Listens to a Stream and notifies GoRouter to re-evaluate route guards
class GoRouterRefreshStream extends ChangeNotifier {
  StreamSubscription<dynamic>? _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

Listenable? _buildAuthRefreshListenable() {
  final client = SupabaseConfig.client;
  if (client != null && SupabaseConfig.isInitialized) {
    return GoRouterRefreshStream(client.auth.onAuthStateChange);
  }
  return null;
}

final appRouter = GoRouter(
  initialLocation: '/today',
  refreshListenable: _buildAuthRefreshListenable(),
  redirect: (BuildContext context, GoRouterState state) {
    final client = SupabaseConfig.client;
    // When Supabase backend is not initialized (e.g. offline testing, mocking, or unit tests), allow direct navigation
    if (client == null || !SupabaseConfig.isInitialized) {
      return null;
    }

    final isAuthenticated = client.auth.currentUser != null;
    final path = state.uri.path;

    // Protected Route Rules:
    // Personal health onboarding (/onboarding/*) requires an authenticated user
    if (!isAuthenticated && path.startsWith('/onboarding')) {
      final returnTarget = Uri.encodeComponent(state.uri.toString());
      return '/auth?mode=signin&returnTo=$returnTarget';
    }

    // Authenticated users navigating to /auth or /welcome are automatically redirected forward
    if (isAuthenticated && (path == '/auth' || path == '/welcome')) {
      final returnTo = state.uri.queryParameters['returnTo'];
      if (returnTo != null && returnTo.isNotEmpty) {
        return returnTo;
      }
      return '/today';
    }

    return null;
  },
  routes: [
    // Screen 01: Brand Splash Screen
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // Screen 02: Welcome Botanical Edition
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),

    // Screen 03: Authentication Trust Verification
    GoRoute(
      path: '/auth',
      builder: (context, state) => AuthScreen(
        initialMode: state.uri.queryParameters['mode'] ?? 'signup',
      ),
    ),

    // Screen 04: Health Goals Discovery
    GoRoute(
      path: '/onboarding/health-goals',
      builder: (context, state) => HealthGoalsScreen(
        returnTo: state.uri.queryParameters['returnTo'],
      ),
    ),

    // Screen 05: Practical Difficulties
    GoRoute(
      path: '/onboarding/difficulties',
      builder: (context, state) => PracticalDifficultiesScreen(
        returnTo: state.uri.queryParameters['returnTo'],
      ),
    ),

    // Screen 06: Daily Impact Rating
    GoRoute(
      path: '/onboarding/daily-impact',
      builder: (context, state) => DailyImpactScreen(
        returnTo: state.uri.queryParameters['returnTo'],
      ),
    ),

    // Screen 07: Food Choices & Dietary Profile
    GoRoute(
      path: '/onboarding/food-choices',
      builder: (context, state) => FoodChoicesScreen(
        returnTo: state.uri.queryParameters['returnTo'],
      ),
    ),

    // Screen 08: Review Health Profile Phase 1 Checkpoint
    GoRoute(
      path: '/onboarding/review-phase1',
      builder: (context, state) => const ReviewPhase1Screen(),
    ),

    // Screen 09: Personal Details
    GoRoute(
      path: '/onboarding/personal-details',
      builder: (context, state) => PersonalDetailsScreen(
        returnTo: state.uri.queryParameters['returnTo'],
      ),
    ),

    // Screen 10: Body Measurements
    GoRoute(
      path: '/onboarding/body-measurements',
      builder: (context, state) => BodyMeasurementsScreen(
        returnTo: state.uri.queryParameters['returnTo'],
      ),
    ),

    // Screen 11: Health Focus & Priorities
    GoRoute(
      path: '/onboarding/health-concerns',
      builder: (context, state) => HealthConcernsScreen(
        returnTo: state.uri.queryParameters['returnTo'],
      ),
    ),

    // Screen 12: Clinical Safety & Food Restrictions (Allergies)
    GoRoute(
      path: '/onboarding/food-restrictions',
      builder: (context, state) => FoodRestrictionsScreen(
        returnTo: state.uri.queryParameters['returnTo'],
      ),
    ),

    // Screen 13: Eating Routine
    GoRoute(
      path: '/onboarding/eating-routine',
      builder: (context, state) => EatingRoutineScreen(
        returnTo: state.uri.queryParameters['returnTo'],
      ),
    ),

    // Screen 14: Daily Activity Level
    GoRoute(
      path: '/onboarding/daily-activity',
      builder: (context, state) => DailyActivityScreen(
        returnTo: state.uri.queryParameters['returnTo'],
      ),
    ),

    // Screen 15: Sleep Patterns & Recovery
    GoRoute(
      path: '/onboarding/sleep-patterns',
      builder: (context, state) => SleepPatternsScreen(
        returnTo: state.uri.queryParameters['returnTo'],
      ),
    ),

    // Screen 16: Fitness & Nutrition Knowledge
    GoRoute(
      path: '/onboarding/knowledge-level',
      builder: (context, state) => KnowledgeLevelScreen(
        returnTo: state.uri.queryParameters['returnTo'],
      ),
    ),

    // Screen 17: Onboarding Completion
    GoRoute(
      path: '/onboarding/completion',
      builder: (context, state) => const CompletionScreen(),
    ),

    // Screen 18: Today — Authenticated Evidence Hub
    GoRoute(
      path: '/today',
      builder: (context, state) => const TodayScreen(),
    ),

    // Universal Multimodal Reference Processing View
    GoRoute(
      path: '/processing-view',
      builder: (context, state) => InputProcessingView(
        query: state.uri.queryParameters['q'] ?? 'Synthesizing evidence-based analysis...',
        onCompleted: () => context.go('/answer-experience'),
      ),
    ),

    // Universal Multimodal Reference Answer Card (Visual Evidence Experience)
    GoRoute(
      path: '/answer-experience',
      builder: (context, state) => UniversalReferenceAnswerCard(
        onBack: () => context.go('/today'),
      ),
    ),

    // Convenience root alias
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),

    // Generic onboarding alias
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const HealthGoalsScreen(),
    ),

    // Multimodal Explore & Research Interface
    GoRoute(
      path: '/explore',
      builder: (context, state) => ExploreScreen(
        initialQuery: state.uri.queryParameters['q'],
      ),
    ),
    GoRoute(
      path: '/research',
      builder: (context, state) => ExploreScreen(
        initialQuery: state.uri.queryParameters['q'],
      ),
    ),
  ],
);

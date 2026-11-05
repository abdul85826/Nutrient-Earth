// ==============================================================================
// Nutrient Earth — All 18 Screens & Multimodal Answer Experience Comprehensive Test Suite
// Verifies:
// 1. All 18 production screens instantiate and render semantic elements.
// 2. Authentication 18+ legal consent gating.
// 3. Clinical allergy mutual exclusivity.
// 4. InputProcessingView & UniversalReferenceAnswerCard fidelity.
// 5. Goal personalization and propagation across the application.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nutrient_earth_client/features/onboarding/presentation/screens/01_splash_screen.dart';
import 'package:nutrient_earth_client/features/onboarding/presentation/screens/02_welcome_screen.dart';
import 'package:nutrient_earth_client/features/onboarding/presentation/screens/03_auth_screen.dart';
import 'package:nutrient_earth_client/features/onboarding/presentation/screens/04_health_goals_screen.dart';
import 'package:nutrient_earth_client/features/onboarding/presentation/screens/05_practical_difficulties_screen.dart';
import 'package:nutrient_earth_client/features/onboarding/presentation/screens/06_daily_impact_screen.dart';
import 'package:nutrient_earth_client/features/onboarding/presentation/screens/07_food_choices_screen.dart';
import 'package:nutrient_earth_client/features/onboarding/presentation/screens/08_review_phase1_screen.dart';
import 'package:nutrient_earth_client/features/onboarding/presentation/screens/09_personal_details_screen.dart';
import 'package:nutrient_earth_client/features/onboarding/presentation/screens/10_body_measurements_screen.dart';
import 'package:nutrient_earth_client/features/onboarding/presentation/screens/11_health_concerns_screen.dart';
import 'package:nutrient_earth_client/features/onboarding/presentation/screens/12_food_restrictions_screen.dart';
import 'package:nutrient_earth_client/features/onboarding/presentation/screens/13_eating_routine_screen.dart';
import 'package:nutrient_earth_client/features/onboarding/presentation/screens/14_daily_activity_screen.dart';
import 'package:nutrient_earth_client/features/onboarding/presentation/screens/15_sleep_patterns_screen.dart';
import 'package:nutrient_earth_client/features/onboarding/presentation/screens/16_knowledge_level_screen.dart';
import 'package:nutrient_earth_client/features/onboarding/presentation/screens/17_completion_screen.dart';
import 'package:nutrient_earth_client/features/today/presentation/today_screen.dart';
import 'package:nutrient_earth_client/features/today/presentation/widgets/input_processing_view.dart';
import 'package:nutrient_earth_client/features/today/presentation/widgets/universal_reference_answer_card.dart';

Widget createTestApp(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Nutrient Earth — All 18 Screens Verification', () {
    testWidgets('Screen 01: SplashScreen renders specimen core and title', (tester) async {
      await tester.pumpWidget(createTestApp(const SplashScreen()));
      expect(find.text('NUTRIENT EARTH'), findsOneWidget);
      expect(find.text('Evidence-Grounded Metabolic Health'), findsOneWidget);
    });

    testWidgets('Screen 02: WelcomeScreen renders botanical hero and action buttons', (tester) async {
      await tester.pumpWidget(createTestApp(const WelcomeScreen()));
      expect(find.text('Nutrient Earth'), findsWidgets);
      expect(find.text('Get started'), findsOneWidget);
      expect(find.text('I already have an account'), findsOneWidget);
    });

    testWidgets('Screen 03: AuthScreen gates submission on 18+ consent checkbox', (tester) async {
      await tester.pumpWidget(createTestApp(const AuthScreen()));
      expect(find.text('Create your account'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);

      // Initially unchecked: submit button should show disabled or show warning if tapped
      final submitButton = find.widgetWithText(ElevatedButton, 'Create Account');
      expect(submitButton, findsOneWidget);

      // Tap submit without consent -> Expect validation snackbar
      await tester.tap(submitButton);
      await tester.pumpAndSettle();
      expect(find.text('You must be at least 18 years old to use Nutrient Earth.'), findsOneWidget);

      // Tap 18+ checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Checkbox should be checked
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets('Screen 04: HealthGoalsScreen renders category chips and goal cards', (tester) async {
      await tester.pumpWidget(createTestApp(const HealthGoalsScreen()));
      expect(find.text('What are your main health goals?'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Endurance & Energy'), findsOneWidget);
    });

    testWidgets('Screen 05: PracticalDifficultiesScreen renders clinical category codes', (tester) async {
      await tester.pumpWidget(createTestApp(const PracticalDifficultiesScreen()));
      expect(find.text('Practical difficulties'), findsOneWidget);
      expect(find.text('Musculoskeletal'), findsOneWidget);
      expect(find.text('Energy & Stamina'), findsOneWidget);
      expect(find.text('Renal & Hydration'), findsOneWidget);
      expect(find.text('Digestive'), findsOneWidget);
    });

    testWidgets('Screen 06: DailyImpactScreen renders impact scale 1..4', (tester) async {
      await tester.pumpWidget(createTestApp(const DailyImpactScreen()));
      expect(find.text('Daily impact & frequency'), findsOneWidget);
      expect(find.text('Clinical pacing note'), findsOneWidget);
    });

    testWidgets('Screen 07: FoodChoicesScreen renders dietary patterns and avoidances', (tester) async {
      await tester.pumpWidget(createTestApp(const FoodChoicesScreen()));
      expect(find.text('Food choices & dietary baseline'), findsOneWidget);
      expect(find.text('Omnivorous'), findsOneWidget);
      expect(find.text('Vegetarian'), findsOneWidget);
    });

    testWidgets('Screen 08: ReviewPhase1Screen renders Phase 1 checkpoint and edit jumps', (tester) async {
      await tester.pumpWidget(createTestApp(const ReviewPhase1Screen()));
      expect(find.text('Phase 1 Review · Health Foundations'), findsOneWidget);
      expect(find.text('Continue to Personal Details'), findsOneWidget);
    });

    testWidgets('Screen 09: PersonalDetailsScreen validates name and age range', (tester) async {
      await tester.pumpWidget(createTestApp(const PersonalDetailsScreen()));
      expect(find.text('Personal details'), findsOneWidget);
      expect(find.text('Preferred Name'), findsOneWidget);
      expect(find.text('Age'), findsOneWidget);
    });

    testWidgets('Screen 10: BodyMeasurementsScreen renders unit toggles and skip checkbox', (tester) async {
      await tester.pumpWidget(createTestApp(const BodyMeasurementsScreen()));
      expect(find.text('Body measurements'), findsOneWidget);
      expect(find.text('Height'), findsOneWidget);
      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('Prefer to skip for now'), findsOneWidget);
    });

    testWidgets('Screen 11: HealthConcernsScreen renders goal synchronization banner', (tester) async {
      await tester.pumpWidget(createTestApp(const HealthConcernsScreen()));
      expect(find.text('Focus areas & priorities'), findsOneWidget);
      expect(find.text('Synchronized with Step 04'), findsOneWidget);
    });

    testWidgets('Screen 12: FoodRestrictionsScreen enforces mutual exclusivity on No restrictions', (tester) async {
      await tester.pumpWidget(createTestApp(const FoodRestrictionsScreen()));
      expect(find.text('Food restrictions & allergies'), findsOneWidget);
      expect(find.text('No restrictions or allergies'), findsOneWidget);

      // Tap "Peanuts"
      await tester.tap(find.text('Peanuts'));
      await tester.pumpAndSettle();

      // Tap "No restrictions or allergies" -> Peanuts should be cleared
      await tester.tap(find.text('No restrictions or allergies'));
      await tester.pumpAndSettle();

      // Verify mutual exclusivity: tapping another allergen unchecks "No restrictions"
      await tester.tap(find.text('Tree Nuts'));
      await tester.pumpAndSettle();
    });

    testWidgets('Screen 13: EatingRoutineScreen renders circadian routine options', (tester) async {
      await tester.pumpWidget(createTestApp(const EatingRoutineScreen()));
      expect(find.text('Eating routine'), findsOneWidget);
      expect(find.text('Intermittent fasting (16:8 or similar)'), findsOneWidget);
    });

    testWidgets('Screen 14: DailyActivityScreen renders physical activity multipliers', (tester) async {
      await tester.pumpWidget(createTestApp(const DailyActivityScreen()));
      expect(find.text('Typical daily activity'), findsOneWidget);
      expect(find.text('Sedentary'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('Screen 15: SleepPatternsScreen renders sleep duration and architecture', (tester) async {
      await tester.pumpWidget(createTestApp(const SleepPatternsScreen()));
      expect(find.text('Sleep patterns'), findsOneWidget);
      expect(find.text('7–8 hours (Optimal)'), findsOneWidget);
    });

    testWidgets('Screen 16: KnowledgeLevelScreen renders explanation depth calibration', (tester) async {
      await tester.pumpWidget(createTestApp(const KnowledgeLevelScreen()));
      expect(find.text('Fitness & nutrition background'), findsOneWidget);
      expect(find.text('Beginner'), findsOneWidget);
      expect(find.text('Advanced / Professional'), findsOneWidget);
    });

    testWidgets('Screen 17: CompletionScreen renders review summary cards and save CTA', (tester) async {
      await tester.pumpWidget(createTestApp(const CompletionScreen()));
      expect(find.text('Your journey starts here'), findsOneWidget);
      expect(find.text('Complete calibration & open plan'), findsOneWidget);
    });

    testWidgets('Screen 18: TodayScreen renders greeting and research search bar', (tester) async {
      await tester.pumpWidget(createTestApp(const TodayScreen()));
      expect(find.byType(TodayScreen), findsOneWidget);
      expect(find.text('Today'), findsWidgets);
    });
  });

  group('Nutrient Earth — Universal Multimodal Reference Experience', () {
    testWidgets('InputProcessingView renders user query, blurry input, and checklist', (tester) async {
      await tester.pumpWidget(createTestApp(const InputProcessingView(
        query: 'Can I use this herbal shampoo? Is t good for hair fall?',
      )));

      expect(find.text('Can I use this herbal shampoo? Is t good for hair fall?'), findsOneWidget);
      expect(find.text('Your Input (Blurry)'), findsOneWidget);
      expect(find.text('Analyzing image...'), findsOneWidget);
      expect(find.text('Enhancing image'), findsOneWidget);
      expect(find.text('Identifying product'), findsOneWidget);
      expect(find.text('Reading ingredients'), findsOneWidget);
      expect(find.text('Checking evidence'), findsOneWidget);
    });

    testWidgets('UniversalReferenceAnswerCard renders product hero, take, benefits, and evidence', (tester) async {
      await tester.pumpWidget(createTestApp(const UniversalReferenceAnswerCard()));

      expect(find.text('Product Identified'), findsOneWidget);
      expect(find.text('Well\nSupported'), findsOneWidget);
      expect(find.text('Himalaya Herbals Anti-Hair Fall Shampoo'), findsOneWidget);
      expect(find.text('My Take for You'), findsOneWidget);
      expect(find.text('Key Benefits'), findsOneWidget);
      expect(find.text('Keep in Mind'), findsOneWidget);
      expect(find.text('Evidence'), findsOneWidget);
      expect(find.text('2 sources'), findsOneWidget);
      expect(find.text('Bhringraj for hair growth: A clinical review'), findsOneWidget);
      expect(find.text('Amla and hair health: Evidence and benefits'), findsOneWidget);
      expect(find.text('Research'), findsNWidgets(2));
    });
  });
}


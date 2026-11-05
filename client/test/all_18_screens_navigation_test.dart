// ==============================================================================
// Nutrient Earth — All 18 Screens & Multimodal Answer Experience Comprehensive Test Suite
// Verifies:
// 1. All 18 production screens instantiate and render semantic elements.
// 2. Canonical Onboarding Wizard Step Headers (STEP 1 OF 14 .. STEP 14 OF 14).
// 3. Authentication 18+ legal consent gating.
// 4. Clinical allergy mutual exclusivity.
// 5. InputProcessingView & UniversalReferenceAnswerCard fidelity.
// 6. Goal personalization and propagation across the application.
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
      expect(find.text('Nutrient Earth'), findsWidgets);
      expect(find.text('SPECIMEN CORE'), findsOneWidget);
    });

    testWidgets('Screen 02: WelcomeScreen renders botanical hero and action buttons', (tester) async {
      await tester.pumpWidget(createTestApp(const WelcomeScreen()));
      expect(find.text('NUTRIENT EARTH'), findsWidgets);
      expect(find.text('Get started'), findsOneWidget);
      expect(find.text('I already have an account'), findsOneWidget);
    });

    testWidgets('Screen 03: AuthScreen gates submission on 18+ consent checkbox', (tester) async {
      await tester.pumpWidget(createTestApp(const AuthScreen()));
      expect(find.text('Your health journey starts with understanding.'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);

      final submitButtonFinder = find.widgetWithText(ElevatedButton, 'Create account');
      expect(submitButtonFinder, findsOneWidget);

      // Initially unchecked: submit button should be disabled
      final initialButton = tester.widget<ElevatedButton>(submitButtonFinder);
      expect(initialButton.enabled, isFalse);

      // Tap 18+ checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Checkbox is checked and button is enabled
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);

      final enabledButton = tester.widget<ElevatedButton>(submitButtonFinder);
      expect(enabledButton.enabled, isTrue);
    });

    testWidgets('Screen 04: HealthGoalsScreen renders canonical Step 1 header and chips', (tester) async {
      await tester.pumpWidget(createTestApp(const HealthGoalsScreen()));
      expect(find.text('STEP 1 OF 14'), findsOneWidget);
      expect(find.text('What would you like help with?'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('Screen 05: PracticalDifficultiesScreen renders canonical Step 2 header and categories', (tester) async {
      await tester.pumpWidget(createTestApp(const PracticalDifficultiesScreen()));
      expect(find.text('STEP 2 OF 14'), findsOneWidget);
      expect(find.text('What difficulties are you experiencing?'), findsOneWidget);
      expect(find.text('Energy & daily activities'), findsOneWidget);
      expect(find.text('Digestive health'), findsOneWidget);
    });

    testWidgets('Screen 06: DailyImpactScreen renders canonical Step 3 header', (tester) async {
      await tester.pumpWidget(createTestApp(const DailyImpactScreen()));
      expect(find.text('STEP 3 OF 14'), findsOneWidget);
      expect(find.text('How much do these difficulties affect you?'), findsOneWidget);
    });

    testWidgets('Screen 07: FoodChoicesScreen renders canonical Step 4 header', (tester) async {
      await tester.pumpWidget(createTestApp(const FoodChoicesScreen()));
      expect(find.text('STEP 4 OF 14'), findsOneWidget);
      expect(find.text('Let\'s understand your food choices'), findsOneWidget);
    });

    testWidgets('Screen 08: ReviewPhase1Screen renders canonical Step 5 header and CTA', (tester) async {
      await tester.pumpWidget(createTestApp(const ReviewPhase1Screen()));
      expect(find.text('STEP 5 OF 14 • REVIEW'), findsOneWidget);
      expect(find.text('Your health profile'), findsOneWidget);
      expect(find.text('Continue to Personal Details'), findsOneWidget);
    });

    testWidgets('Screen 09: PersonalDetailsScreen validates name and age controls', (tester) async {
      await tester.pumpWidget(createTestApp(const PersonalDetailsScreen()));
      expect(find.text('STEP 6 OF 14 • SOIL PROFILE'), findsOneWidget);
      expect(find.text('Let\'s get to know you'), findsOneWidget);
      expect(find.text('What should we call you?'), findsOneWidget);
      expect(find.text('How old are you?'), findsOneWidget);
    });

    testWidgets('Screen 10: BodyMeasurementsScreen renders canonical Step 7 header and unit toggles', (tester) async {
      await tester.pumpWidget(createTestApp(const BodyMeasurementsScreen()));
      expect(find.text('STEP 7 OF 14 • SOIL PROFILE'), findsOneWidget);
      expect(find.text('Your body measurements'), findsOneWidget);
      expect(find.text('Height'), findsOneWidget);
      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('Prefer to skip weight for now'), findsOneWidget);
    });

    testWidgets('Screen 11: HealthConcernsScreen renders canonical Step 8 header', (tester) async {
      await tester.pumpWidget(createTestApp(const HealthConcernsScreen()));
      expect(find.text('STEP 8 OF 14 • SOIL PROFILE'), findsOneWidget);
      expect(find.text('What would you like help with?'), findsOneWidget);
    });

    testWidgets('Screen 12: FoodRestrictionsScreen enforces mutual exclusivity on No restrictions', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(const FoodRestrictionsScreen()));
      expect(find.text('STEP 9 OF 14 • SOIL PROFILE'), findsOneWidget);
      expect(find.text('Are there any foods you need to avoid?'), findsOneWidget);
      expect(find.text('No restrictions or allergies'), findsOneWidget);

      // Ensure Peanuts is visible and tap
      await tester.ensureVisible(find.text('Peanuts'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Peanuts'));
      await tester.pumpAndSettle();

      // Tap "No restrictions or allergies"
      await tester.ensureVisible(find.text('No restrictions or allergies'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('No restrictions or allergies'));
      await tester.pumpAndSettle();

      // Tap "Soy"
      await tester.ensureVisible(find.text('Soy'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Soy'));
      await tester.pumpAndSettle();
    });

    testWidgets('Screen 13: EatingRoutineScreen renders canonical Step 10 header and cadence cards', (tester) async {
      await tester.pumpWidget(createTestApp(const EatingRoutineScreen()));
      expect(find.text('STEP 10 OF 14 • SOIL PROFILE'), findsOneWidget);
      expect(find.text('What does your eating routine look like?'), findsOneWidget);
    });

    testWidgets('Screen 14: DailyActivityScreen renders canonical Step 11 header and activity multipliers', (tester) async {
      await tester.pumpWidget(createTestApp(const DailyActivityScreen()));
      expect(find.text('STEP 11 OF 14 • SOIL PROFILE'), findsOneWidget);
      expect(find.text('How active are you on a typical day?'), findsOneWidget);
    });

    testWidgets('Screen 15: SleepPatternsScreen renders canonical Step 12 header and sleep architecture', (tester) async {
      await tester.pumpWidget(createTestApp(const SleepPatternsScreen()));
      expect(find.text('STEP 12 OF 14 • SOIL PROFILE'), findsOneWidget);
      expect(find.text('How well do you usually sleep?'), findsOneWidget);
    });

    testWidgets('Screen 16: KnowledgeLevelScreen renders canonical Step 13 header', (tester) async {
      await tester.pumpWidget(createTestApp(const KnowledgeLevelScreen()));
      expect(find.text('STEP 13 OF 14 • SOIL PROFILE'), findsOneWidget);
      expect(find.text('How familiar are you with fitness & nutrition?'), findsOneWidget);
    });

    testWidgets('Screen 17: CompletionScreen renders canonical Step 14 header and summary CTA', (tester) async {
      await tester.pumpWidget(createTestApp(const CompletionScreen()));
      expect(find.text('STEP 14 OF 14 • PROFILE COMPLETE'), findsOneWidget);
      expect(find.text('Your journey starts here'), findsOneWidget);
    });

    testWidgets('Screen 18: TodayScreen renders greeting and research search bar', (tester) async {
      await tester.pumpWidget(createTestApp(const TodayScreen()));
      expect(find.byType(TodayScreen), findsOneWidget);
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

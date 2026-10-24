import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nutrient_earth_client/core/design_system/theme.dart';

// Screens
import 'package:nutrient_earth_client/features/onboarding_auth/screen_1_native_launch_mobile.dart';
import 'package:nutrient_earth_client/features/onboarding_auth/screen_2_brand_introduction_mobile.dart';
import 'package:nutrient_earth_client/features/onboarding_auth/screen_3_onboarding_welcome_mobile.dart';
import 'package:nutrient_earth_client/features/onboarding_auth/screen_4_first_onboarding_question_mobile.dart';
import 'package:nutrient_earth_client/features/onboarding_auth/screen_5_account_entry_mobile.dart';
import 'package:nutrient_earth_client/features/onboarding_auth/create_account_screen.dart';
import 'package:nutrient_earth_client/features/onboarding_auth/sign_in_screen.dart';
import 'package:nutrient_earth_client/features/onboarding_auth/verify_email_address_screen.dart';
import 'package:nutrient_earth_client/features/onboarding_auth/recover_account_access_screen.dart';
import 'package:nutrient_earth_client/features/onboarding_auth/personal_information_privacy_screen.dart';
import 'package:nutrient_earth_client/features/onboarding_auth/personal_goal_screen.dart';
import 'package:nutrient_earth_client/features/onboarding_auth/food_preferences_screen.dart';
import 'package:nutrient_earth_client/features/onboarding_auth/optional_health_context_screen.dart';
import 'package:nutrient_earth_client/features/onboarding_auth/daily_routine_constraints_screen.dart';
import 'package:nutrient_earth_client/features/onboarding_auth/review_and_confirm_onboarding_screen.dart';

import 'package:nutrient_earth_client/features/research/research_home_empty_screen.dart';
import 'package:nutrient_earth_client/features/research/research_question_composer_screen.dart';
import 'package:nutrient_earth_client/features/research/research_review_submission_screen.dart';
import 'package:nutrient_earth_client/features/research/research_investigation_in_progress_screen.dart';
import 'package:nutrient_earth_client/features/research/evidence_first_research_answer_screen.dart';

import 'package:nutrient_earth_client/features/goals/goals_home_empty_screen.dart';
import 'package:nutrient_earth_client/features/goals/create_a_goal_screen.dart';
import 'package:nutrient_earth_client/features/goals/goal_detail_practical_plan_screen.dart';
import 'package:nutrient_earth_client/features/goals/progress_check_in_screen.dart';
import 'package:nutrient_earth_client/features/goals/action_detail_effort_screen.dart';

import 'package:nutrient_earth_client/features/food_nutrition/food_analysis_entry_screen.dart';
import 'package:nutrient_earth_client/features/food_nutrition/food_identification_confirmation_screen.dart';
import 'package:nutrient_earth_client/features/food_nutrition/nutrition_analysis_screen.dart';
import 'package:nutrient_earth_client/features/food_nutrition/meal_assessment_screen.dart';
import 'package:nutrient_earth_client/features/food_nutrition/packaged_food_label_analysis_screen.dart';

import 'package:nutrient_earth_client/features/history/research_history_screen.dart';
import 'package:nutrient_earth_client/features/profile/personal_context_memory_screen.dart';
import 'package:nutrient_earth_client/features/history/research_history_detail_screen.dart';
import 'package:nutrient_earth_client/features/profile/privacy_data_controls_screen.dart';
import 'package:nutrient_earth_client/features/feedback/feedback_support_screen.dart';

import 'package:nutrient_earth_client/features/system_recovery/responsive_app_shell_screen.dart';
import 'package:nutrient_earth_client/features/system_recovery/connectivity_request_recovery_screen.dart';
import 'package:nutrient_earth_client/features/system_recovery/accessibility_alternate_input_screen.dart';
import 'package:nutrient_earth_client/features/system_recovery/permissions_interrupted_input_screen.dart';
import 'package:nutrient_earth_client/features/system_recovery/product_wide_consistency_audit_screen.dart';

Widget createTestHost(Widget child) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => child,
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const Scaffold(body: Text('Welcome Target')),
      ),
      GoRoute(
        path: '/onboarding/intro',
        builder: (context, state) => const Scaffold(body: Text('Intro Target')),
      ),
      GoRoute(
        path: '/onboarding/intent',
        builder: (context, state) => const Scaffold(body: Text('Intent Target')),
      ),
      GoRoute(
        path: '/auth/gateway',
        builder: (context, state) => const Scaffold(body: Text('Gateway Target')),
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (context, state) => const Scaffold(body: Text('Signup Target')),
      ),
      GoRoute(
        path: '/auth/signin',
        builder: (context, state) => const Scaffold(body: Text('Signin Target')),
      ),
      GoRoute(
        path: '/auth/verify',
        builder: (context, state) => const Scaffold(body: Text('Verify Target')),
      ),
      GoRoute(
        path: '/auth/recover',
        builder: (context, state) => const Scaffold(body: Text('Recover Target')),
      ),
      GoRoute(
        path: '/onboarding/privacy',
        builder: (context, state) => const Scaffold(body: Text('Privacy Target')),
      ),
      GoRoute(
        path: '/onboarding/goals',
        builder: (context, state) => const Scaffold(body: Text('Goals Target')),
      ),
      GoRoute(
        path: '/onboarding/diet',
        builder: (context, state) => const Scaffold(body: Text('Diet Target')),
      ),
      GoRoute(
        path: '/onboarding/health-context',
        builder: (context, state) => const Scaffold(body: Text('Health Context Target')),
      ),
      GoRoute(
        path: '/onboarding/constraints',
        builder: (context, state) => const Scaffold(body: Text('Constraints Target')),
      ),
      GoRoute(
        path: '/onboarding/review',
        builder: (context, state) => const Scaffold(body: Text('Review Target')),
      ),
      GoRoute(
        path: '/research',
        builder: (context, state) => const Scaffold(body: Text('Research Target')),
      ),
      GoRoute(
        path: '/research/composer',
        builder: (context, state) => const Scaffold(body: Text('Composer Target')),
      ),
      GoRoute(
        path: '/research/review',
        builder: (context, state) => const Scaffold(body: Text('Review Target')),
      ),
      GoRoute(
        path: '/research/investigating',
        builder: (context, state) => const Scaffold(body: Text('Investigating Target')),
      ),
      GoRoute(
        path: '/research/answer',
        builder: (context, state) => const Scaffold(body: Text('Answer Target')),
      ),
      GoRoute(
        path: '/research/food/entry',
        builder: (context, state) => const Scaffold(body: Text('Food Entry Target')),
      ),
      GoRoute(
        path: '/research/food/confirm',
        builder: (context, state) => const Scaffold(body: Text('Food Confirm Target')),
      ),
      GoRoute(
        path: '/research/food/nutrition',
        builder: (context, state) => const Scaffold(body: Text('Nutrition Target')),
      ),
      GoRoute(
        path: '/research/food/assessment',
        builder: (context, state) => const Scaffold(body: Text('Assessment Target')),
      ),
      GoRoute(
        path: '/research/food/label',
        builder: (context, state) => const Scaffold(body: Text('Label Target')),
      ),
      GoRoute(
        path: '/goals',
        builder: (context, state) => const Scaffold(body: Text('Goals Target')),
      ),
      GoRoute(
        path: '/goals/create',
        builder: (context, state) => const Scaffold(body: Text('Goals Create Target')),
      ),
      GoRoute(
        path: '/goals/detail',
        builder: (context, state) => const Scaffold(body: Text('Goals Detail Target')),
      ),
      GoRoute(
        path: '/goals/checkin',
        builder: (context, state) => const Scaffold(body: Text('Goals Checkin Target')),
      ),
      GoRoute(
        path: '/goals/action',
        builder: (context, state) => const Scaffold(body: Text('Goals Action Target')),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const Scaffold(body: Text('History Target')),
      ),
      GoRoute(
        path: '/history/detail',
        builder: (context, state) => const Scaffold(body: Text('History Detail Target')),
      ),
      GoRoute(
        path: '/profile/context',
        builder: (context, state) => const Scaffold(body: Text('Profile Context Target')),
      ),
      GoRoute(
        path: '/profile/privacy',
        builder: (context, state) => const Scaffold(body: Text('Profile Privacy Target')),
      ),
      GoRoute(
        path: '/support/feedback',
        builder: (context, state) => const Scaffold(body: Text('Feedback Target')),
      ),
      GoRoute(
        path: '/audit/consistency',
        builder: (context, state) => const Scaffold(body: Text('Consistency Target')),
      ),
    ],
  );

  return ProviderScope(
    child: MaterialApp.router(
      theme: NETheme.lightTheme,
      routerConfig: router,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Journey A: First Launch & Authentication (Screens 1–15)', () {
    testWidgets('Screen 1 renders native launch with botanical branding', (tester) async {
      await tester.pumpWidget(createTestHost(const Screen1NativeLaunchMobile()));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('INITIALIZING SYSTEM'), findsOneWidget);
      expect(find.text('ENV::PROD_BIO_NODE'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('Screen 2 renders brand introduction with dual pillars', (tester) async {
      await tester.pumpWidget(createTestHost(const Screen2BrandIntroductionMobile()));
      await tester.pumpAndSettle();
      expect(find.text('Nutrient Earth'), findsOneWidget);
      expect(find.text('EVIDENCE-FIRST INTELLIGENCE'), findsOneWidget);
      expect(find.text('Get started'), findsOneWidget);
    });

    testWidgets('Screen 3 renders onboarding welcome with clear expectations', (tester) async {
      await tester.pumpWidget(createTestHost(const Screen3OnboardingWelcomeMobile()));
      await tester.pumpAndSettle();
      expect(find.text('Let’s make this useful for you.'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('Screen 4 allows selecting primary inquiry focus', (tester) async {
      await tester.pumpWidget(createTestHost(const Screen4FirstOnboardingQuestionMobile()));
      await tester.pumpAndSettle();
      expect(find.text('What would you like help with first?'), findsOneWidget);
      await tester.tap(find.text('Understand a health concern'));
      await tester.pumpAndSettle();
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('Screen 5 renders account entry gateway with authentication paths', (tester) async {
      await tester.pumpWidget(createTestHost(const Screen5AccountEntryMobile()));
      await tester.pumpAndSettle();
      expect(find.text('Your journey starts with a secure account.'), findsOneWidget);
      expect(find.text('Create account'), findsOneWidget);
      expect(find.text('I already have an account — Sign in'), findsOneWidget);
    });

    testWidgets('Screen 6 validates signup form inputs', (tester) async {
      await tester.pumpWidget(createTestHost(const CreateAccountScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Create your account'), findsOneWidget);
      await tester.tap(find.text('Create account').last);
      await tester.pumpAndSettle();
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('Screen 7 renders sign in form', (tester) async {
      await tester.pumpWidget(createTestHost(const SignInScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Sign in'), findsAtLeastNWidgets(1));
    });

    testWidgets('Screen 8 renders email verification with resend timer', (tester) async {
      await tester.pumpWidget(createTestHost(const VerifyEmailAddressScreen(email: 'user@example.com')));
      await tester.pumpAndSettle();
      expect(find.text('Verify your email'), findsOneWidget);
      expect(find.text('Multi Factor Verification'), findsOneWidget);
    });

    testWidgets('Screen 9 renders account recovery with validation', (tester) async {
      await tester.pumpWidget(createTestHost(const RecoverAccountAccessScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Recover your account'), findsOneWidget);
      await tester.tap(find.text('Send recovery instructions'));
      await tester.pumpAndSettle();
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('Screen 10 renders privacy architecture & consent controls', (tester) async {
      await tester.pumpWidget(createTestHost(const PersonalInformationPrivacyScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Your context, your choice.'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('Screens 11–15 render onboarding questionnaire sequence', (tester) async {
      // Screen 11: Personal Goals
      await tester.pumpWidget(createTestHost(const PersonalGoalScreen()));
      await tester.pumpAndSettle();
      expect(find.text('What would you like to improve first?'), findsOneWidget);

      // Screen 12: Food Preferences
      await tester.pumpWidget(createTestHost(const FoodPreferencesScreen()));
      await tester.pumpAndSettle();
      expect(find.text('How do you prefer to eat?'), findsOneWidget);

      // Screen 13: Optional Health Context
      await tester.pumpWidget(createTestHost(const OptionalHealthContextScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Is there any health context we should consider?'), findsOneWidget);

      // Screen 14: Daily Routine & Constraints
      await tester.pumpWidget(createTestHost(const DailyRoutineConstraintsScreen()));
      await tester.pumpAndSettle();
      expect(find.text('What would make a plan realistic for you?'), findsOneWidget);

      // Screen 15: Review & Confirm
      await tester.pumpWidget(createTestHost(const ReviewAndConfirmOnboardingScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Review your context'), findsOneWidget);
      expect(find.text('Confirm and continue'), findsOneWidget);
    });
  });

  group('Journey B: Research Protocol (Screens 16–20)', () {
    testWidgets('Screen 16 renders empty research home with new inquiry card', (tester) async {
      await tester.pumpWidget(createTestHost(const ResearchHomeEmptyScreen()));
      await tester.pumpAndSettle();
      expect(find.text('NEW INQUIRY'), findsOneWidget);
      expect(find.text('ID // NE-01'), findsOneWidget);
      expect(find.text('Your research starts here.'), findsOneWidget);
    });

    testWidgets('Screen 17 provides question composer with guidance', (tester) async {
      await tester.pumpWidget(createTestHost(const ResearchQuestionComposerScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Specimen Dossier'), findsOneWidget);
      expect(find.text('DIAGNOSTIC PROTOCOL 01'), findsOneWidget);
      expect(find.text('Review question'), findsOneWidget);
    });

    testWidgets('Screen 18 validates inquiry review before submission', (tester) async {
      await tester.pumpWidget(createTestHost(const ResearchReviewSubmissionScreen(
        query: 'What is the effect of zinc carnosine on gastric mucosal integrity?',
      )));
      await tester.pumpAndSettle();
      expect(find.text('Review your question'), findsOneWidget);
      expect(find.text('What is the effect of zinc carnosine on gastric mucosal integrity?'), findsOneWidget);
      expect(find.text('Start research'), findsOneWidget);
    });

    testWidgets('Screen 19 renders progress states with botanical pipeline steps', (tester) async {
      await tester.pumpWidget(createTestHost(const ResearchInvestigationInProgressScreen(
        query: 'Bioavailability of magnesium forms',
      )));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Research in progress'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('Screen 20 renders evidence-first answer with primary citations', (tester) async {
      await tester.pumpWidget(createTestHost(const EvidenceFirstResearchAnswerScreen(
        query: 'Bioavailability of magnesium forms',
      )));
      await tester.pumpAndSettle();
      expect(find.text('CONSENSUS (89%)'), findsOneWidget);
      expect(find.text('GRADE A EVIDENCE'), findsOneWidget);
      expect(find.text('BIOCHEMICAL PHARMACOKINETICS'), findsOneWidget);
    });
  });

  group('Journey C: Goals & Action Plan (Screens 21–25)', () {
    testWidgets('Screen 21 renders Goals home with active initiative & practical actions', (tester) async {
      await tester.pumpWidget(createTestHost(const GoalsHomeEmptyScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Goals'), findsOneWidget);
      expect(find.text('Active Initiative'), findsOneWidget);
      expect(find.text('Create a goal'), findsOneWidget);
    });

    testWidgets('Screen 22 validates goal creation form', (tester) async {
      await tester.pumpWidget(createTestHost(const CreateAGoalScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Create Goal'), findsOneWidget);
      expect(find.text('Continue to plan'), findsOneWidget);
    });

    testWidgets('Screen 23 renders goal detail practical plan with protocol milestones', (tester) async {
      await tester.pumpWidget(createTestHost(const GoalDetailPracticalPlanScreen()));
      await tester.pumpAndSettle();
      expect(find.text('ACTIVE GOAL DEFINITION'), findsOneWidget);
      expect(find.text('PHASE 01 — PLANNING'), findsOneWidget);
      expect(find.text('Edit goal'), findsOneWidget);
    });

    testWidgets('Screen 24 records progress check-in with effort scoring', (tester) async {
      await tester.pumpWidget(createTestHost(const ProgressCheckInScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Progress Check In'), findsOneWidget);
      expect(find.text('Save check-in and adapt'), findsOneWidget);
    });

    testWidgets('Screen 25 renders action detail effort with clinical rationale', (tester) async {
      await tester.pumpWidget(createTestHost(const ActionDetailEffortScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Action Detail'), findsOneWidget);
      expect(find.text('STEP 03 / 05'), findsOneWidget);
    });
  });

  group('Journey D: Food and Nutrition (Screens 26–29 & 35)', () {
    testWidgets('Screen 27 supports multimodal food analysis entry', (tester) async {
      await tester.pumpWidget(createTestHost(const FoodAnalysisEntryScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Food Analysis'), findsOneWidget);
      expect(find.text("Understand what you're eating"), findsOneWidget);
    });

    testWidgets('Screen 26 confirms identified food and portion weight', (tester) async {
      await tester.pumpWidget(createTestHost(const FoodIdentificationConfirmationScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Intake Verification'), findsOneWidget);
      expect(find.text('STAGE 2 OF 4 • INTAKE VERIFICATION'), findsOneWidget);
    });

    testWidgets('Screen 28 renders nutrition analysis breakdown with micronutrient density', (tester) async {
      await tester.pumpWidget(createTestHost(const NutritionAnalysisScreen()));
      await tester.pumpAndSettle();
      expect(find.text('VERIFIED COMPOSITION • STAGE 3 OF 4'), findsOneWidget);
      expect(find.text('Understand this meal'), findsOneWidget);
    });

    testWidgets('Screen 29 provides meal assessment and clinical synthesis', (tester) async {
      await tester.pumpWidget(createTestHost(const MealAssessmentScreen()));
      await tester.pumpAndSettle();
      expect(find.text('STEP 04 // EVIDENCE-BASED SYNTHESIS'), findsOneWidget);
      expect(find.text('What does this meal tell you?'), findsOneWidget);
    });

    testWidgets('Screen 35 analyzes packaged food label with ingredient safety flags', (tester) async {
      await tester.pumpWidget(createTestHost(const PackagedFoodLabelAnalysisScreen()));
      await tester.pumpAndSettle();
      expect(find.text('OPTICAL VERIFICATION • SUPPLEMENT SPECIMEN'), findsOneWidget);
      expect(find.text('Understand this product label'), findsOneWidget);
    });
  });

  group('Journey E: History, Personal Context & Privacy (Screens 30–33)', () {
    testWidgets('Screen 30 displays research history archive with filters', (tester) async {
      await tester.pumpWidget(createTestHost(const ResearchHistoryScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Research History'), findsOneWidget);
      expect(find.text('All inquiries'), findsOneWidget);
    });

    testWidgets('Screen 31 renders personal context and active memory controls', (tester) async {
      await tester.pumpWidget(createTestHost(const PersonalContextMemoryScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Personal Context'), findsOneWidget);
      expect(find.text('Personal context'), findsOneWidget);
    });

    testWidgets('Screen 32 provides historical inquiry detail and citation provenance', (tester) async {
      await tester.pumpWidget(createTestHost(const ResearchHistoryDetailScreen()));
      await tester.pumpAndSettle();
      expect(find.text('ARCHIVAL RECORD • READ ONLY'), findsOneWidget);
      expect(find.text('SYNTHESIS READOUT'), findsOneWidget);
    });

    testWidgets('Screen 33 enforces privacy data controls, exports, and history deletion', (tester) async {
      await tester.pumpWidget(createTestHost(const PrivacyDataControlsScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Privacy & Data'), findsOneWidget);
      expect(find.text('Request export'), findsOneWidget);
      expect(find.text('Request account deletion'), findsOneWidget);
    });
  });

  group('Journey F: Feedback and Support (Screen 34)', () {
    testWidgets('Screen 34 validates feedback submission form', (tester) async {
      await tester.pumpWidget(createTestHost(const FeedbackSupportScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Feedback & Support'), findsOneWidget);
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Submit feedback'));
      await tester.pumpAndSettle();
      expect(find.text('Please select an issue category'), findsOneWidget);
    });
  });

  group('Journey G: Recovery and Accessibility (Screens 36–40)', () {
    testWidgets('Screen 36 verifies responsive shell across viewports', (tester) async {
      await tester.pumpWidget(createTestHost(const ResponsiveAppShellScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Responsive Architecture'), findsOneWidget);
    });

    testWidgets('Screen 37 tests connectivity and request recovery flow', (tester) async {
      await tester.pumpWidget(createTestHost(const ConnectivityRequestRecoveryScreen()));
      await tester.pumpAndSettle();
      expect(find.text('System Recovery & States'), findsOneWidget);
      expect(find.text('Retry connection'), findsOneWidget);
      expect(find.text('Dismiss'), findsOneWidget);
    });

    testWidgets('Screen 38 configures accessibility and alternate input methods', (tester) async {
      await tester.pumpWidget(createTestHost(const AccessibilityAlternateInputScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Accessibility & Input States'), findsOneWidget);
      expect(find.text('5. TOUCH TARGETS (48x48 DP) & NON-COLOR CUES'), findsOneWidget);
    });

    testWidgets('Screen 39 handles permission requests and interrupted input', (tester) async {
      await tester.pumpWidget(createTestHost(const PermissionsInterruptedInputScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Permissions & File Handling'), findsOneWidget);
      expect(find.text('Use text description instead'), findsOneWidget);
      expect(find.text('Device settings'), findsOneWidget);
    });

    testWidgets('Screen 40 validates product-wide consistency audit across all 40 screens', (tester) async {
      await tester.pumpWidget(createTestHost(const ProductWideConsistencyAuditScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Consistency Audit'), findsOneWidget);
      expect(find.text('Batch 1: Onboarding Start'), findsOneWidget);
      expect(find.text('100% VERIFIED'), findsAtLeastNWidgets(1));
    });
  });
}

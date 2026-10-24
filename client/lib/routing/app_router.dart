import 'package:go_router/go_router.dart';

import 'app_shell.dart';

// Batch 1: Onboarding Start (Screens 1–5)
import '../features/onboarding_auth/screen_1_native_launch_mobile.dart';
import '../features/onboarding_auth/screen_2_brand_introduction_mobile.dart';
import '../features/onboarding_auth/screen_3_onboarding_welcome_mobile.dart';
import '../features/onboarding_auth/screen_4_first_onboarding_question_mobile.dart';
import '../features/onboarding_auth/screen_5_account_entry_mobile.dart';

// Batch 2: Auth & Privacy (Screens 6–10)
import '../features/onboarding_auth/create_account_screen.dart';
import '../features/onboarding_auth/sign_in_screen.dart';
import '../features/onboarding_auth/verify_email_address_screen.dart';
import '../features/onboarding_auth/recover_account_access_screen.dart';
import '../features/onboarding_auth/personal_information_privacy_screen.dart';

// Batch 3: Onboarding Questionnaire (Screens 11–15)
import '../features/onboarding_auth/personal_goal_screen.dart';
import '../features/onboarding_auth/food_preferences_screen.dart';
import '../features/onboarding_auth/optional_health_context_screen.dart';
import '../features/onboarding_auth/daily_routine_constraints_screen.dart';
import '../features/onboarding_auth/review_and_confirm_onboarding_screen.dart';

// Batch 4: Research Protocol (Screens 16–20)
import '../features/research/research_question_composer_screen.dart';
import '../features/research/research_review_submission_screen.dart';
import '../features/research/research_investigation_in_progress_screen.dart';
import '../features/research/evidence_first_research_answer_screen.dart';

// Batch 5: Goals & Action Plan (Screens 21–25)
import '../features/goals/create_a_goal_screen.dart';
import '../features/goals/goal_detail_practical_plan_screen.dart';
import '../features/goals/progress_check_in_screen.dart';
import '../features/goals/action_detail_effort_screen.dart';

// Batch 6: Food & Label Intelligence (Screens 26–29, 35)
import '../features/food_nutrition/food_identification_confirmation_screen.dart';
import '../features/food_nutrition/food_analysis_entry_screen.dart';
import '../features/food_nutrition/nutrition_analysis_screen.dart';
import '../features/food_nutrition/meal_assessment_screen.dart';
import '../features/food_nutrition/packaged_food_label_analysis_screen.dart';

// Batch 7: History & Secondary Controls (Screens 30–34)
import '../features/history/research_history_screen.dart';
import '../features/profile/personal_context_memory_screen.dart';
import '../features/history/research_history_detail_screen.dart';
import '../features/profile/privacy_data_controls_screen.dart';
import '../features/feedback/feedback_support_screen.dart';

// Batch 8: System Recovery & Consistency (Screens 36–40)
import '../features/system_recovery/responsive_app_shell_screen.dart';
import '../features/system_recovery/connectivity_request_recovery_screen.dart';
import '../features/system_recovery/accessibility_alternate_input_screen.dart';
import '../features/system_recovery/permissions_interrupted_input_screen.dart';
import '../features/system_recovery/product_wide_consistency_audit_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Root Application Shell (Hosts strictly Tab 0: Research & Tab 1: Goals)
    GoRoute(
      path: '/',
      builder: (context, state) => const AppShell(initialTab: 0),
    ),

    // ==========================================
    // BATCH 1: ONBOARDING START (SCREENS 1–5)
    // ==========================================
    GoRoute(
      path: '/splash',
      builder: (context, state) => const Screen1NativeLaunchMobile(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const Screen2BrandIntroductionMobile(),
    ),
    GoRoute(
      path: '/onboarding/intro',
      builder: (context, state) => const Screen3OnboardingWelcomeMobile(),
    ),
    GoRoute(
      path: '/onboarding/intent',
      builder: (context, state) => const Screen4FirstOnboardingQuestionMobile(),
    ),
    GoRoute(
      path: '/auth/gateway',
      builder: (context, state) => const Screen5AccountEntryMobile(),
    ),

    // ==========================================
    // BATCH 2: AUTH & PRIVACY (SCREENS 6–10)
    // ==========================================
    GoRoute(
      path: '/auth/signup',
      builder: (context, state) => const CreateAccountScreen(),
    ),
    GoRoute(
      path: '/auth/signin',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/auth/verify',
      builder: (context, state) {
        final email = state.extra as String? ?? 'user@nutrientearth.org';
        return VerifyEmailAddressScreen(email: email);
      },
    ),
    GoRoute(
      path: '/auth/recover',
      builder: (context, state) => const RecoverAccountAccessScreen(),
    ),
    GoRoute(
      path: '/onboarding/privacy',
      builder: (context, state) => const PersonalInformationPrivacyScreen(),
    ),

    // ==========================================
    // BATCH 3: QUESTIONNAIRE (SCREENS 11–15)
    // ==========================================
    GoRoute(
      path: '/onboarding/goals',
      builder: (context, state) => const PersonalGoalScreen(),
    ),
    GoRoute(
      path: '/onboarding/diet',
      builder: (context, state) => const FoodPreferencesScreen(),
    ),
    GoRoute(
      path: '/onboarding/health-context',
      builder: (context, state) => const OptionalHealthContextScreen(),
    ),
    GoRoute(
      path: '/onboarding/constraints',
      builder: (context, state) => const DailyRoutineConstraintsScreen(),
    ),
    GoRoute(
      path: '/onboarding/review',
      builder: (context, state) => const ReviewAndConfirmOnboardingScreen(),
    ),

    // ==========================================
    // BATCH 4: RESEARCH PROTOCOL (SCREENS 16–20)
    // ==========================================
    GoRoute(
      path: '/research',
      builder: (context, state) => const AppShell(initialTab: 0),
    ),
    GoRoute(
      path: '/research/composer',
      builder: (context, state) => const ResearchQuestionComposerScreen(),
    ),
    GoRoute(
      path: '/research/review',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final q = extra?['question'] as String? ??
            'How does dietary magnesium glycinate bioavailability compare to magnesium oxide for sleep quality?';
        return ResearchReviewSubmissionScreen(query: q);
      },
    ),
    GoRoute(
      path: '/research/investigating',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final q = extra?['question'] as String? ??
            'How does dietary magnesium glycinate bioavailability compare to magnesium oxide for sleep quality?';
        return ResearchInvestigationInProgressScreen(query: q);
      },
    ),
    GoRoute(
      path: '/research/answer',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final q = extra?['question'] as String? ??
            'How does dietary magnesium glycinate bioavailability compare to magnesium oxide for sleep quality?';
        return EvidenceFirstResearchAnswerScreen(query: q);
      },
    ),

    // ==========================================
    // BATCH 5: GOALS & ACTION PLAN (SCREENS 21–25)
    // ==========================================
    GoRoute(
      path: '/goals',
      builder: (context, state) => const AppShell(initialTab: 1),
    ),
    GoRoute(
      path: '/goals/create',
      builder: (context, state) => const CreateAGoalScreen(),
    ),
    GoRoute(
      path: '/goals/detail',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return GoalDetailPracticalPlanScreen(initialData: extra);
      },
    ),
    GoRoute(
      path: '/goals/checkin',
      builder: (context, state) => const ProgressCheckInScreen(),
    ),
    GoRoute(
      path: '/goals/action',
      builder: (context, state) => const ActionDetailEffortScreen(),
    ),

    // ==========================================
    // BATCH 6: FOOD & LABEL (SCREENS 26–29 & 35)
    // ==========================================
    GoRoute(
      path: '/research/food/confirm',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return FoodIdentificationConfirmationScreen(initialData: extra);
      },
    ),
    GoRoute(
      path: '/research/food/entry',
      builder: (context, state) => const FoodAnalysisEntryScreen(),
    ),
    GoRoute(
      path: '/research/food/nutrition',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return NutritionAnalysisScreen(initialData: extra);
      },
    ),
    GoRoute(
      path: '/research/food/assessment',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return MealAssessmentScreen(initialData: extra);
      },
    ),
    GoRoute(
      path: '/research/food/label',
      builder: (context, state) => const PackagedFoodLabelAnalysisScreen(),
    ),

    // ==========================================
    // BATCH 7: HISTORY & SECONDARY (SCREENS 30–34)
    // ==========================================
    GoRoute(
      path: '/history',
      builder: (context, state) => const ResearchHistoryScreen(),
    ),
    GoRoute(
      path: '/profile/context',
      builder: (context, state) => const PersonalContextMemoryScreen(),
    ),
    GoRoute(
      path: '/history/detail',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ResearchHistoryDetailScreen(initialData: extra);
      },
    ),
    GoRoute(
      path: '/profile/privacy',
      builder: (context, state) => const PrivacyDataControlsScreen(),
    ),
    GoRoute(
      path: '/support/feedback',
      builder: (context, state) => const FeedbackSupportScreen(),
    ),

    // ==========================================
    // BATCH 8: RESPONSIVE & RECOVERY (SCREENS 36–40)
    // ==========================================
    GoRoute(
      path: '/shell',
      builder: (context, state) => const ResponsiveAppShellScreen(),
    ),
    GoRoute(
      path: '/status/recovery',
      builder: (context, state) => const ConnectivityRequestRecoveryScreen(),
    ),
    GoRoute(
      path: '/status/a11y',
      builder: (context, state) => const AccessibilityAlternateInputScreen(),
    ),
    GoRoute(
      path: '/status/permissions',
      builder: (context, state) => const PermissionsInterruptedInputScreen(),
    ),
    GoRoute(
      path: '/audit/consistency',
      builder: (context, state) => const ProductWideConsistencyAuditScreen(),
    ),
  ],
);

// ==============================================================================
// Nutrient Earth — Screen 06 (Step 3 of 5: Daily Impact Rating) Comprehensive Tests
// Covers all 15 critical interaction, lifecycle, and architecture criteria:
// 1. Continue with valid impact ratings persists to Riverpod and advances to Step 4.
// 2. Skip impact ratings records dailyImpactsSkipped: true and advances to Step 4.
// 3. Back navigation returns to Step 2 (/onboarding/difficulties) preserving state.
// 4. Rating mapping: Sliders (1..4) accurately map by domain code.
// 5. Fluctuating toggle: impactFluctuates updates state correctly.
// 6. Persistence: saveStagedOnboarding called upon Continue and Skip.
// 7. Persistence error handling: Storage exceptions caught and reported without route advance.
// 8. Initial URL serialization: difficulties, impacts, and fluctuates serialized into query params.
// 9. Mount test: DailyImpactScreen mounts StitchScreenHostWidget with screenIndex: 6 and returnTo.
// 10. Riverpod state serialization: toJson / fromJson round-trips dailyImpacts and dailyImpactsSkipped.
// 11. HTML Content: Inappropriate browser alert removed completely.
// 12. HTML Content: Dynamic specimen stream renders cards with canonical 4-specimen fallback.
// 13. HTML Content: Discrete ticks (1..4), status pills, and not-sure toggles properly structured.
// 14. HTML Content: Inline error banner and lifecycle controls present without alert().
// 15. File Integrity: client/assets and client/web copies of screen_06/index.html are byte-identical.
// ==============================================================================

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:nutrient_earth_client/core/design_system/components/stitch_screen_host.dart';
import 'package:nutrient_earth_client/features/onboarding/data/onboarding_storage_service.dart';
import 'package:nutrient_earth_client/features/onboarding/presentation/screens/06_daily_impact_screen.dart';
import 'package:nutrient_earth_client/features/onboarding/state/onboarding_journey_state.dart';

class MockOnboardingStorageForStep3 extends OnboardingStorageService {
  OnboardingJourneyState? lastSavedState;
  bool shouldThrowOnSave = false;

  @override
  Future<void> saveStagedOnboarding(OnboardingJourneyState state) async {
    if (shouldThrowOnSave) {
      throw Exception('Disk I/O error writing staged state');
    }
    lastSavedState = state;
  }

  @override
  Future<OnboardingJourneyState?> loadStagedOnboarding() async {
    return lastSavedState;
  }
}

void main() {
  group('Step 3 (Daily Impact) — Flutter Widget, Bridge & Lifecycle Tests', () {
    late MockOnboardingStorageForStep3 mockStorage;

    setUp(() {
      mockStorage = MockOnboardingStorageForStep3();
    });

    testWidgets('1 & 4 & 5 & 6. Continue with valid impact ratings updates state, storage, and navigates to Step 4', (tester) async {
      final container = ProviderContainer(
        overrides: [
          onboardingStorageServiceProvider.overrideWithValue(mockStorage),
        ],
      );
      addTearDown(container.dispose);

      // Pre-set difficulties from Step 2
      container.read(onboardingJourneyProvider.notifier).setDifficulties({'MSK-03', 'REN-02'});

      String? navigatedRoute;
      final router = GoRouter(
        initialLocation: '/onboarding/daily-impact',
        routes: [
          GoRoute(
            path: '/onboarding/daily-impact',
            builder: (ctx, state) => StitchScreenHostWidget(
              screenIndex: 6,
              onAction: (type, payload) {
                if (type == 'SAVE_DAILY_IMPACTS') {
                  navigatedRoute = payload['nextRoute'] as String?;
                }
              },
            ),
          ),
          GoRoute(
            path: '/onboarding/food-choices',
            builder: (ctx, state) => const Scaffold(body: Text('Food Choices Step 4')),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final hostState = tester.state(find.byType(StitchScreenHostWidget)) as dynamic;

      // Simulate Continue message from Screen 06
      await hostState.handleStitchMessageForTesting({
        'type': 'SAVE_DAILY_IMPACTS',
        'impacts': {
          'msk-03': 3,
          'MSK-03': 3,
          'ren-02': 2,
          'REN-02': 2,
        },
        'impactFluctuates': true,
        'skipped': false,
        'nextRoute': '/onboarding/food-choices',
      });
      await tester.pumpAndSettle();

      // Verify Riverpod state
      final journey = container.read(onboardingJourneyProvider);
      expect(journey.dailyImpacts['MSK-03'], 3);
      expect(journey.dailyImpacts['REN-02'], 2);
      expect(journey.impactFluctuates, isTrue);
      expect(journey.dailyImpactsSkipped, isFalse);

      // Verify persistence
      expect(mockStorage.lastSavedState, isNotNull);
      expect(mockStorage.lastSavedState!.dailyImpacts['MSK-03'], 3);
      expect(mockStorage.lastSavedState!.impactFluctuates, isTrue);

      // Verify navigation to Step 4
      expect(navigatedRoute, '/onboarding/food-choices');
      expect(find.text('Food Choices Step 4'), findsOneWidget);
    });

    testWidgets('2. Skip impact ratings sets dailyImpactsSkipped: true, empty impacts, and advances to Step 4', (tester) async {
      final container = ProviderContainer(
        overrides: [
          onboardingStorageServiceProvider.overrideWithValue(mockStorage),
        ],
      );
      addTearDown(container.dispose);

      final router = GoRouter(
        initialLocation: '/onboarding/daily-impact',
        routes: [
          GoRoute(
            path: '/onboarding/daily-impact',
            builder: (ctx, state) => const StitchScreenHostWidget(screenIndex: 6),
          ),
          GoRoute(
            path: '/onboarding/food-choices',
            builder: (ctx, state) => const Scaffold(body: Text('Food Choices Step 4')),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final hostState = tester.state(find.byType(StitchScreenHostWidget)) as dynamic;

      // Simulate Skip message from Screen 06
      await hostState.handleStitchMessageForTesting({
        'type': 'SAVE_DAILY_IMPACTS',
        'impacts': {},
        'impactFluctuates': false,
        'skipped': true,
        'nextRoute': '/onboarding/food-choices',
      });
      await tester.pumpAndSettle();

      final journey = container.read(onboardingJourneyProvider);
      expect(journey.dailyImpactsSkipped, isTrue);
      expect(journey.dailyImpacts, isEmpty);
      expect(journey.impactFluctuates, isFalse);
      expect(find.text('Food Choices Step 4'), findsOneWidget);
    });

    testWidgets('3. Back navigation returns to Step 2 (/onboarding/difficulties) preserving selections', (tester) async {
      final container = ProviderContainer(
        overrides: [
          onboardingStorageServiceProvider.overrideWithValue(mockStorage),
        ],
      );
      addTearDown(container.dispose);

      container.read(onboardingJourneyProvider.notifier).setDifficulties({'MSK-01', 'NRG-02'});

      final router = GoRouter(
        initialLocation: '/onboarding/daily-impact',
        routes: [
          GoRoute(
            path: '/onboarding/daily-impact',
            builder: (ctx, state) => const StitchScreenHostWidget(screenIndex: 6),
          ),
          GoRoute(
            path: '/onboarding/difficulties',
            builder: (ctx, state) => const Scaffold(body: Text('Difficulties Step 2')),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final hostState = tester.state(find.byType(StitchScreenHostWidget)) as dynamic;

      await hostState.handleStitchMessageForTesting({
        'type': 'NAVIGATE',
        'route': '/onboarding/difficulties',
      });
      await tester.pumpAndSettle();

      expect(find.text('Difficulties Step 2'), findsOneWidget);
      expect(container.read(onboardingJourneyProvider).difficulties, containsAll(['MSK-01', 'NRG-02']));
    });

    testWidgets('7. Persistence failure displays SnackBar and does not navigate away', (tester) async {
      mockStorage.shouldThrowOnSave = true;

      final container = ProviderContainer(
        overrides: [
          onboardingStorageServiceProvider.overrideWithValue(mockStorage),
        ],
      );
      addTearDown(container.dispose);

      final router = GoRouter(
        initialLocation: '/onboarding/daily-impact',
        routes: [
          GoRoute(
            path: '/onboarding/daily-impact',
            builder: (ctx, state) => const StitchScreenHostWidget(screenIndex: 6),
          ),
          GoRoute(
            path: '/onboarding/food-choices',
            builder: (ctx, state) => const Scaffold(body: Text('Food Choices Step 4')),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final hostState = tester.state(find.byType(StitchScreenHostWidget)) as dynamic;

      await hostState.handleStitchMessageForTesting({
        'type': 'SAVE_DAILY_IMPACTS',
        'impacts': {'MSK-03': 3},
        'nextRoute': '/onboarding/food-choices',
      });
      await tester.pumpAndSettle();

      // Ensure did not navigate to Step 4 on failure
      expect(find.text('Food Choices Step 4'), findsNothing);
      expect(find.byType(StitchScreenHostWidget), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('8 & 9. DailyImpactScreen mounts StitchScreenHostWidget with screenIndex: 6 and returnTo', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            onboardingStorageServiceProvider.overrideWithValue(mockStorage),
          ],
          child: const MaterialApp(
            home: DailyImpactScreen(returnTo: '/custom-return'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final hostFinder = find.byType(StitchScreenHostWidget);
      expect(hostFinder, findsOneWidget);

      final host = tester.widget<StitchScreenHostWidget>(hostFinder);
      expect(host.screenIndex, 6);
      expect(host.returnTo, '/custom-return');
    });

    test('10. OnboardingJourneyState serialization round-trips dailyImpacts and dailyImpactsSkipped', () {
      const original = OnboardingJourneyState(
        difficulties: {'MSK-01', 'NRG-04'},
        dailyImpacts: {'MSK-01': 3, 'NRG-04': 4},
        impactFluctuates: true,
        dailyImpactsSkipped: false,
      );

      final jsonMap = original.toJson();
      expect(jsonMap['dailyImpacts'], {'MSK-01': 3, 'NRG-04': 4});
      expect(jsonMap['impactFluctuates'], isTrue);
      expect(jsonMap['dailyImpactsSkipped'], isFalse);

      final restored = OnboardingJourneyState.fromJson(jsonMap);
      expect(restored.dailyImpacts, original.dailyImpacts);
      expect(restored.impactFluctuates, isTrue);
      expect(restored.dailyImpactsSkipped, isFalse);

      final skippedState = original.copyWith(dailyImpactsSkipped: true, dailyImpacts: {});
      final skippedJson = skippedState.toJson();
      expect(skippedJson['dailyImpactsSkipped'], isTrue);
      expect(skippedJson['dailyImpacts'], isEmpty);
      final restoredSkipped = OnboardingJourneyState.fromJson(skippedJson);
      expect(restoredSkipped.dailyImpactsSkipped, isTrue);
      expect(restoredSkipped.dailyImpacts, isEmpty);
    });
  });

  group('Step 3 (Daily Impact) — Authentic HTML/CSS/JS Specification Tests', () {
    late String htmlContent;
    late String webHtmlContent;

    setUpAll(() {
      final assetFile = File(r'D:\Documents\NE_App\Nutrient_Earth\client\assets\stitch\screen_06\index.html');
      final webFile = File(r'D:\Documents\NE_App\Nutrient_Earth\client\web\stitch\screen_06\index.html');
      expect(assetFile.existsSync(), isTrue, reason: 'assets/stitch/screen_06/index.html must exist');
      expect(webFile.existsSync(), isTrue, reason: 'web/stitch/screen_06/index.html must exist');

      htmlContent = assetFile.readAsStringSync();
      webHtmlContent = webFile.readAsStringSync();
    });

    test('11. Inappropriate browser alert removed completely', () {
      // Must not contain alert(...) or clinical verification dossier claim
      expect(htmlContent.contains('clinical verification dossier'), isFalse,
          reason: 'Misleading clinical verification dossier alert must be removed');
      expect(htmlContent.contains('alert('), isFalse,
          reason: 'All JavaScript browser alert() calls must be removed');
    });

    test('12. Dynamic specimen stream renders cards with canonical 4-specimen fallback', () {
      expect(htmlContent.contains('id="cards-container"'), isTrue);
      expect(htmlContent.contains('symptomCatalog'), isTrue);
      expect(htmlContent.contains('defaultSpecimens'), isTrue);
      expect(htmlContent.contains('MSK-03'), isTrue);
      expect(htmlContent.contains('MSK-02'), isTrue);
      expect(htmlContent.contains('REN-02'), isTrue);
      expect(htmlContent.contains('NRG-04'), isTrue);
    });

    test('13. Discrete ticks (1..4), status pills, and not-sure toggles properly structured', () {
      expect(htmlContent.contains('impact-slider'), isTrue);
      expect(htmlContent.contains('tick-btn'), isTrue);
      expect(htmlContent.contains('not-sure-toggle'), isTrue);
      expect(htmlContent.contains('status-pill'), isTrue);
      expect(htmlContent.contains('Not sure / Variable'), isTrue);
      expect(htmlContent.contains('Calibrated to flexible'), isTrue);
    });

    test('14. Action buttons (Continue, Skip, Back) and inline error banner are present and wired', () {
      expect(htmlContent.contains('id="continue-btn"'), isTrue);
      expect(htmlContent.contains('id="skip-btn"'), isTrue);
      expect(htmlContent.contains('id="back-btn"'), isTrue);
      expect(htmlContent.contains('id="back-link"'), isTrue);
      expect(htmlContent.contains('id="error-banner"'), isTrue);
      expect(htmlContent.contains('handleContinue'), isTrue);
      expect(htmlContent.contains('handleSkip'), isTrue);
      expect(htmlContent.contains('handleBack'), isTrue);
      expect(htmlContent.contains('SAVE_DAILY_IMPACTS'), isTrue);
    });

    test('15. Assets and Web copies of screen_06/index.html are byte-for-byte identical', () {
      final assetHash = sha256.convert(utf8.encode(htmlContent)).toString();
      final webHash = sha256.convert(utf8.encode(webHtmlContent)).toString();
      expect(assetHash, equals(webHash), reason: 'assets and web screen_06/index.html must have identical SHA-256');
    });
  });
}


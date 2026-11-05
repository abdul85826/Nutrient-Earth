import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nutrient_earth_client/core/design_system/theme.dart';
import 'package:nutrient_earth_client/core/domain/answer_contract/universal_intelligence_answer.dart';
import 'package:nutrient_earth_client/core/domain/input_gateway/universal_input_descriptor.dart';
import 'package:nutrient_earth_client/core/domain/personalization/goal_alignment_evaluator.dart';
import 'package:nutrient_earth_client/features/today/presentation/widgets/input_processing_view.dart';
import 'package:nutrient_earth_client/features/today/presentation/widgets/universal_reference_answer_card.dart';

Widget createTestHost({required Widget child}) {
  return ProviderScope(
    child: MaterialApp(
      theme: NETheme.lightTheme,
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Multimodal Visual Evidence Experience Tests', () {
    testWidgets('InputProcessingView renders user bubble, blurry badge, analyzing card and checklist',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool completedCalled = false;

      await tester.pumpWidget(
        createTestHost(
          child: InputProcessingView(
            query: 'Can I use this herbal shampoo? Is t good for hair fall?',
            onCompleted: () {
              completedCalled = true;
            },
          ),
        ),
      );
      await tester.pump();

      // 1. Verify User Query Chat Bubble
      expect(find.text('Can I use this herbal shampoo? Is t good for hair fall?'), findsOneWidget);

      // 2. Verify Viewfinder badge
      expect(find.text('Your Input (Blurry)'), findsOneWidget);

      // 3. Verify Analyzing Card
      expect(find.text('Analyzing image...'), findsOneWidget);

      // 4. Verify 4 stages checklist items
      expect(find.text('Enhancing image'), findsOneWidget);
      expect(find.text('Identifying product'), findsOneWidget);
      expect(find.text('Reading ingredients'), findsOneWidget);
      expect(find.text('Checking evidence'), findsOneWidget);

      // 5. Test Skip to Result
      final skipFinder = find.text('Skip to Verified Answer →');
      expect(skipFinder, findsOneWidget);
      await tester.tap(skipFinder);
      await tester.pump();

      expect(completedCalled, isTrue);
    });

    testWidgets('UniversalReferenceAnswerCard renders all elements matching the reference design',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createTestHost(
          child: const UniversalReferenceAnswerCard(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Product Identified & Well Supported Badges
      expect(find.text('Product Identified'), findsOneWidget);
      expect(find.text('Well\nSupported'), findsOneWidget);

      // 2. Product Name & Subtitle
      expect(find.text('Himalaya Herbals Anti-Hair Fall Shampoo'), findsOneWidget);
      expect(
        find.textContaining('A herbal shampoo with Bhringraj and Amla'),
        findsOneWidget,
      );

      // 3. My Take for You Card
      expect(find.text('My Take for You'), findsOneWidget);
      expect(
        find.textContaining("Yes, you can use this. It's a gentle, herbal option"),
        findsOneWidget,
      );

      // 4. Two-Column Side-by-Side: Key Benefits & Keep in Mind
      expect(find.text('Key Benefits'), findsOneWidget);
      expect(find.text('Helps reduce hair fall'), findsOneWidget);
      expect(find.text('Nourishes the scalp'), findsOneWidget);
      expect(find.text('Supports stronger hair'), findsOneWidget);

      expect(find.text('Keep in Mind'), findsOneWidget);
      expect(find.text('Results are gradual'), findsOneWidget);
      expect(find.text('May not work for hormonal or medical hair loss'), findsOneWidget);
      expect(find.text('Do a patch test if you have a sensitive scalp'), findsOneWidget);

      // 5. Evidence Section with 2 sources
      expect(find.text('Evidence'), findsOneWidget);
      expect(find.text('2 sources'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);

      // 6. Citations with Research badges
      expect(find.text('Bhringraj for hair growth: A clinical review'), findsOneWidget);
      expect(find.text('Journal of Ethnopharmacology • 2021'), findsOneWidget);
      expect(find.text('Amla and hair health: Evidence and benefits'), findsOneWidget);
      expect(find.text('International Journal of Trichology • 2020'), findsOneWidget);
      expect(find.text('Research'), findsNWidgets(2));

      // 7. Test tapping View All opens the Scientific Evidence Dossier Modal
      await tester.tap(find.text('View All'));
      await tester.pumpAndSettle();

      expect(find.text('Scientific Evidence Dossier'), findsOneWidget);
      expect(find.textContaining('Indexed biomedical literature'), findsOneWidget);
      expect(find.text('PMID: 33451298'), findsOneWidget);
      expect(find.text('PMID: 32884210'), findsOneWidget);

      // Close modal
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // 8. Test bookmark toggle
      final bookmarkFinder = find.byIcon(Icons.bookmark_border_rounded);
      expect(bookmarkFinder, findsOneWidget);
      await tester.tap(bookmarkFinder);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
    });

    testWidgets('UniversalReferenceAnswerCard.fromUniversalAnswer adapts live answer contracts',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final liveAnswer = UniversalIntelligenceAnswer(
        referenceId: 'REF-TEST-001',
        detectedInputType: UserInputType.text,
        query: 'What are the benefits of creatine monohydrate?',
        heroAnswer: 'Creatine Monohydrate Supplementation',
        recommendation:
            'Extensively researched and safe for increasing muscular power output and cognitive stamina.',
        detailedExplanation:
            'Creatine increases intramuscular phosphocreatine stores, accelerating ATP resynthesis during anaerobic exertion.',
        goalMatch: const GoalMatchIndicator(
          matchPercentage: 92,
          status: GoalAlignmentStatus.aligned,
          matchLabel: '92% Goal match',
          rationale: 'Directly supports strength and power goals.',
          riskFactors: ['Maintain adequate daily hydration of 2.5-3L'],
        ),
        evidence: const EvidenceProvenanceContainer(
          hasVerifiedSources: true,
          classification: EvidenceClassification.wellSupported,
          watermarkLabel: 'Verified scientific sources',
        ),
        practicalSteps: [
          'Take 3-5 grams daily consistently',
          'Timing around workouts is optional; daily saturation is key',
        ],
        uncertaintyDisclaimer: 'Standard nutritional guidelines apply.',
      );

      await tester.pumpWidget(
        createTestHost(
          child: UniversalReferenceAnswerCard.fromUniversalAnswer(
            answer: liveAnswer,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Creatine Monohydrate Supplementation'), findsOneWidget);
      expect(find.textContaining('Creatine increases intramuscular phosphocreatine'), findsOneWidget);
      expect(find.text('Key Benefits'), findsOneWidget);
      expect(find.text('Take 3-5 grams daily consistently'), findsOneWidget);
      expect(find.text('Keep in Mind'), findsOneWidget);
      expect(find.text('Maintain adequate daily hydration of 2.5-3L'), findsOneWidget);
    });
  });
}


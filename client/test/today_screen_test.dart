import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nutrient_earth_client/core/design_system/theme.dart';
import 'package:nutrient_earth_client/core/services/diurnal_service.dart';
import 'package:nutrient_earth_client/core/services/telemetry_service.dart';
import 'package:nutrient_earth_client/core/services/research_pipeline_service.dart';
import 'package:nutrient_earth_client/core/services/learn_repository.dart';
import 'package:nutrient_earth_client/features/today/state/today_state.dart';
import 'package:nutrient_earth_client/features/today/presentation/today_screen.dart';
import 'package:nutrient_earth_client/features/today/presentation/widgets/dynamic_greeting_card.dart';
import 'package:nutrient_earth_client/features/today/presentation/widgets/telemetry_strip.dart';
import 'package:nutrient_earth_client/features/today/presentation/widgets/daily_plan_section.dart';
import 'package:nutrient_earth_client/features/today/presentation/widgets/learn_today_section.dart';
import 'package:nutrient_earth_client/features/today/presentation/widgets/feedback_banner.dart';

Widget createTestHost({required Widget child}) {
  return ProviderScope(
    child: MaterialApp(
      theme: NETheme.lightTheme.copyWith(
        splashFactory: NoSplash.splashFactory,
      ),
      home: child,
    ),
  );
}

void main() {
  group('DiurnalService & Greeting Tests', () {
    test('DiurnalService formats morning greeting correctly', () {
      final morningTime = DateTime(2026, 10, 14, 8, 30);
      final context = DiurnalService.getContext(currentTime: morningTime, preferredName: 'Sarah');

      expect(context.formattedDate, 'WEDNESDAY, 14 OCT 2026');
      expect(context.greeting, 'Good morning,\nSarah.');
      expect(context.solarCondition, 'Radiant');
      expect(context.period, DiurnalPeriod.morning);
    });

    test('DiurnalService formats afternoon greeting correctly', () {
      final afternoonTime = DateTime(2026, 10, 14, 14, 15);
      final context = DiurnalService.getContext(currentTime: afternoonTime, preferredName: 'Sarah');

      expect(context.greeting, 'Good afternoon,\nSarah.');
      expect(context.solarCondition, 'Golden hour');
      expect(context.period, DiurnalPeriod.afternoon);
    });

    test('DiurnalService formats evening greeting correctly', () {
      final eveningTime = DateTime(2026, 10, 14, 19, 0);
      final context = DiurnalService.getContext(currentTime: eveningTime, preferredName: 'Sarah');

      expect(context.greeting, 'Good evening,\nSarah.');
      expect(context.solarCondition, 'Dusk');
      expect(context.period, DiurnalPeriod.evening);
    });

    testWidgets('DynamicGreetingCard displays formatted date and greeting text', (tester) async {
      final morningTime = DateTime(2026, 10, 14, 9, 0);
      final diurnal = DiurnalService.getContext(currentTime: morningTime, preferredName: 'Sarah');

      await tester.pumpWidget(
        createTestHost(
          child: Scaffold(
            body: DynamicGreetingCard(diurnal: diurnal),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('WEDNESDAY, 14 OCT 2026'), findsOneWidget);
      expect(find.text('Good morning,\nSarah.'), findsOneWidget);
      expect(find.text("Let's find evidence-based answers for a healthier you."), findsOneWidget);
    });
  });

  group('Telemetry & Metrics Tests', () {
    testWidgets('TelemetryStrip displays time, AQI, temperature, and streak', (tester) async {
      final telemetry = TelemetryData(
        formattedTime: '1:15 PM',
        solarCondition: 'Radiant',
        aqi: 42,
        aqiLabel: 'Good AQI',
        aqiColor: Colors.green,
        temperatureCelsius: 26.0,
        weatherCondition: 'Partly cloudy',
        streakDays: 3,
        streakLabel: 'Keep going',
        observationTime: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestHost(
          child: Scaffold(
            body: TelemetryStrip(telemetry: telemetry),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1:15 PM'), findsOneWidget);
      expect(find.text('Radiant'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.text('Good AQI'), findsOneWidget);
      expect(find.text('26°C'), findsOneWidget);
      expect(find.text('Partly cloudy'), findsOneWidget);
      expect(find.text('3 days'), findsOneWidget);
      expect(find.text('Keep going'), findsOneWidget);
    });
  });

  group('Daily Plan Interactive Checklist Tests', () {
    testWidgets('DailyPlanSection renders 5 tasks with initial 3 completed and allows toggling', (tester) async {
      int toggledIndex = -1;
      await tester.pumpWidget(
        createTestHost(
          child: Scaffold(
            body: DailyPlanSection(
              counterLabel: '3 of 5 completed',
              tasks: const [
                DailyPlanTask(
                  id: 't-1',
                  title: 'Morning hydration + mineral electrolyte water',
                  note: 'Replenished fluid deficit upon waking',
                  timeString: '7:30 AM',
                  isCompleted: true,
                ),
                DailyPlanTask(
                  id: 't-2',
                  title: '30-min brisk outdoor run in morning sunlight',
                  note: 'Circadian entrainment + cardiovascular base',
                  timeString: '8:45 AM',
                  isCompleted: true,
                ),
                DailyPlanTask(
                  id: 't-3',
                  title: 'Post-run nutrient recovery meal',
                  note: 'Balanced 30g protein + complex carbohydrates',
                  timeString: '11:30 AM',
                  isCompleted: true,
                ),
                DailyPlanTask(
                  id: 't-4',
                  title: 'Afternoon hydration check (500ml water or herbal tea)',
                  note: 'Sustains cognitive alertness through mid-day dip · 2:00 PM',
                  timeString: '2:00 PM',
                  isCompleted: false,
                  isUpNext: true,
                ),
                DailyPlanTask(
                  id: 't-5',
                  title: 'Balanced fiber-rich dinner + magnesium-rich greens',
                  note: 'Supports overnight recovery and restorative sleep',
                  timeString: '7:00 PM',
                  isCompleted: false,
                ),
              ],
              onToggleTask: (idx) {
                toggledIndex = idx;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your daily plan'), findsOneWidget);
      expect(find.text('3 of 5 completed'), findsOneWidget);
      expect(find.text('Morning hydration + mineral electrolyte water'), findsOneWidget);
      expect(find.textContaining('Why this routine fits your goals', findRichText: true), findsOneWidget);
      expect(find.text('Goal: Endurance Recovery'), findsOneWidget);

      // Tap task 4 (Afternoon hydration check)
      await tester.tap(find.text('Afternoon hydration check (500ml water or herbal tea)'));
      await tester.pumpAndSettle();

      expect(toggledIndex, 3);
    });
  });

  group('Learn Today Media Grid Tests', () {
    testWidgets('LearnTodaySection displays Video and Article cards with tags and metadata', (tester) async {
      await tester.pumpWidget(
        createTestHost(
          child: Scaffold(
            body: LearnTodaySection(
              items: LearnRepository.featuredItems,
              onItemTap: (item) {},
              onSeeAllTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Learn for today'), findsOneWidget);
      expect(find.text('See all'), findsOneWidget);
      expect(find.text('VIDEO'), findsOneWidget);
      expect(find.text('8:24'), findsOneWidget);
      expect(find.text('HPLC POTENCY'), findsOneWidget);
      expect(find.text('How to build a balanced plate for sustained energy'), findsOneWidget);

      expect(find.text('ARTICLE'), findsOneWidget);
      expect(find.text('RCT REVIEW'), findsOneWidget);
      expect(find.text('Everyday habits that may support better gut health'), findsOneWidget);
    });
  });

  group('Feedback Banner Tests', () {
    testWidgets('FeedbackBanner allows typing and submitting feedback', (tester) async {
      String submittedFeedback = '';
      await tester.pumpWidget(
        createTestHost(
          child: Scaffold(
            body: FeedbackBanner(
              onSubmit: (val) {
                submittedFeedback = val;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Share your feedback'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Great evidence companion app!');
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pumpAndSettle();

      expect(submittedFeedback, 'Great evidence companion app!');
    });
  });

  group('Research Pipeline & Inquiry Processing Tests', () {
    test('ResearchPipelineService synthesizes evidence for sleep inquiry', () async {
      final answer = await ResearchPipelineService.processInquiry(
        query: 'What is the best magnesium for sleep?',
      );

      expect(answer.evidenceBadge, contains('RCT REVIEW'));
      expect(answer.citations.isNotEmpty, isTrue);
      expect(answer.practicalSteps.isNotEmpty, isTrue);
      expect(answer.uncertaintyDisclaimer.isNotEmpty, isTrue);
    });
  });

  group('Master TodayScreen Integration Tests', () {
    testWidgets('TodayScreen renders all sections, accepts search input, and opens drawer', (tester) async {
      await tester.pumpWidget(
        createTestHost(
          child: const TodayScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Header components
      expect(find.byIcon(Icons.menu_rounded), findsOneWidget);
      expect(find.text('Nutrient Earth'), findsOneWidget);
      expect(find.text('EVIDENCE COMPANION'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);

      // Section 1: Greeting
      expect(find.text("Let's find evidence-based answers for a healthier you."), findsOneWidget);

      // Section 2: Metrics Strip
      expect(find.text('42'), findsOneWidget);
      expect(find.text('Good AQI'), findsOneWidget);
      expect(find.text('3 days'), findsOneWidget);

      // Section 3: Research Section
      expect(find.text('Get answers. Know the evidence. Make better choices.'), findsOneWidget);
      expect(find.text('Is my diet right for my goal?'), findsOneWidget);

      // Section 4: Daily Plan
      expect(find.text('Your daily plan'), findsOneWidget);
      expect(find.text('2 of 5 done'), findsOneWidget);

      // Section 5: Learn Section
      expect(find.text('Learn for today'), findsOneWidget);

      // Section 6: Feedback Footer
      expect(find.text('Share your feedback'), findsOneWidget);

      // Toggle Daily Plan Task 4 (Mid-afternoon fresh air & reset)
      final taskFinder = find.text('Mid-afternoon fresh air & reset');
      await tester.ensureVisible(taskFinder);
      await tester.pumpAndSettle();
      await tester.tap(taskFinder);
      await tester.pumpAndSettle();
      expect(find.text('3 of 5 done'), findsOneWidget);

      // Open Navigation Drawer
      final menuFinder = find.byIcon(Icons.menu_rounded);
      await tester.ensureVisible(menuFinder);
      await tester.pumpAndSettle();
      await tester.tap(menuFinder);
      await tester.pumpAndSettle();
      expect(find.text('New Research Inquiry'), findsOneWidget);
      expect(find.text('RECENT INQUIRIES'), findsOneWidget);
      expect(find.text('Sarah Jenkins'), findsOneWidget);
    });
  });
}

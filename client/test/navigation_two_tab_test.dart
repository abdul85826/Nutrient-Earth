import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrient_earth_client/routing/app_shell.dart';
import 'package:nutrient_earth_client/core/design_system/theme.dart';
import 'package:nutrient_earth_client/core/design_system/components/ne_navigation_bar.dart';

void main() {
  testWidgets('AppShell strictly renders exactly TWO primary navigation tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: NETheme.darkTheme, home: const AppShell()),
      ),
    );

    await tester.pumpAndSettle();

    // Verify NENavigationBar exists
    expect(find.byType(NENavigationBar), findsOneWidget);

    // Verify exactly TWO tabs: 'Your Health' and 'Learn & Discover'
    expect(find.text('Your Health'), findsAtLeastNWidgets(1));
    expect(find.text('Learn & Discover'), findsOneWidget);

    // Ensure forbidden old 5-tab labels do NOT exist as primary tabs
    expect(find.text('Today'), findsNothing);
    expect(find.text('Explore'), findsNothing);
    expect(find.text('Growth'), findsNothing);

    // Verify Tab 1 initial section headers: Search & AI and Body & Progress
    expect(find.text('Search & AI'), findsOneWidget);
    expect(find.text('Body & Progress'), findsOneWidget);

    // Tap on 'Learn & Discover' (second tab)
    await tester.tap(find.text('Learn & Discover'));
    await tester.pumpAndSettle();

    // Verify Tab 2 section headers: Learn, Exercise, Store
    expect(find.text('Learn'), findsOneWidget);
    expect(find.text('Exercise'), findsOneWidget);
    expect(find.text('Store'), findsOneWidget);

    // Tap on 'Store'
    await tester.tap(find.text('Store'));
    await tester.pumpAndSettle();

    // Verify store products appear
    expect(
      find.text('Nutrient Earth Ultra Pure Omega-3 EPA/DHA'),
      findsOneWidget,
    );
  });
}

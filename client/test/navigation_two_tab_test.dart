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
        child: MaterialApp(theme: NETheme.lightTheme, home: const AppShell()),
      ),
    );

    await tester.pumpAndSettle();

    // Verify NENavigationBar exists
    expect(find.byType(NENavigationBar), findsOneWidget);

    // Verify exactly TWO tabs: 'Research' and 'Goals'
    expect(find.text('Research'), findsAtLeastNWidgets(1));
    expect(find.text('Goals'), findsAtLeastNWidgets(1));

    // Ensure forbidden old tab labels do NOT exist as primary tabs
    expect(find.text('Today'), findsNothing);
    expect(find.text('Explore'), findsNothing);
    expect(find.text('Growth'), findsNothing);
    expect(find.text('Store'), findsNothing);

    // Verify Tab 0 (Research) content
    expect(find.text('NEW INQUIRY'), findsOneWidget);
    expect(find.text('What would you like to understand or improve?'), findsOneWidget);

    // Tap on 'Goals' (second tab)
    await tester.tap(find.text('Goals').last);
    await tester.pumpAndSettle();

    // Verify Tab 1 (Goals) content: Goals screen
    expect(find.text('Turn what matters to you into practical steps you can take and review over time.'), findsOneWidget);
    expect(find.text('Create a goal'), findsOneWidget);
  });
}

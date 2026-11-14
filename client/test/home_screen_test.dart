// ==============================================================================
// Nutrient Earth — Home Screen Verification Test
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nutrient_earth_client/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('HomeScreen renders brand and operational status',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('NUTRIENT EARTH'), findsOneWidget);
    expect(find.text('EVIDENCE COMPANION'), findsOneWidget);
    expect(find.text('System Active'), findsOneWidget);
  });
}


import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrient_earth/features/body/body_screen.dart';

void main() {
  testWidgets('Test BodyPage renders without exceptions', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: BodyPage(),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(BodyPage), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrient_earth_client/main.dart';

void main() {
  testWidgets('NutrientEarthApp boots up without errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: NutrientEarthApp()));

    await tester.pumpAndSettle();

    // Verify app starts on 'Your Health'
    expect(find.text('Your Health'), findsAtLeastNWidgets(1));
  });
}

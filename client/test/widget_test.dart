import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrient_earth_client/main.dart';

void main() {
  testWidgets('NutrientEarthApp boots up without errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: NutrientEarthApp()));

    await tester.pumpAndSettle();

    // Verify app starts with primary tabs Research and Goals
    expect(find.text('Research'), findsAtLeastNWidgets(1));
    expect(find.text('Goals'), findsAtLeastNWidgets(1));
  });
}

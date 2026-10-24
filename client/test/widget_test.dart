import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrient_earth_client/main.dart';

void main() {
  testWidgets('NutrientEarthApp boots up to fresh HomeScreen without errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: NutrientEarthApp()));
    await tester.pumpAndSettle();

    expect(find.text('Nutrient Earth'), findsOneWidget);
    expect(find.text('Fresh Workspace Ready'), findsOneWidget);
  });
}

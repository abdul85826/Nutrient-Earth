import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrient_earth_client/main.dart';

void main() {
  testWidgets('NutrientEarthApp boots up to TodayScreen without errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: NutrientEarthApp()));
    await tester.pumpAndSettle();

    expect(find.text('Nutrient Earth'), findsOneWidget);
    expect(find.text('EVIDENCE COMPANION'), findsOneWidget);
    expect(find.text('Your daily plan'), findsOneWidget);
    expect(find.text('Get answers. Know the evidence. Make better choices.'), findsOneWidget);
  });
}

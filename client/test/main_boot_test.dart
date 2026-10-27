import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrient_earth_client/core/config/app_config.dart';
import 'package:nutrient_earth_client/core/config/supabase_config.dart';
import 'package:nutrient_earth_client/main.dart';

void main() {
  testWidgets('Full app main initialization test', (tester) async {
    await AppConfig.initialize();
    await SupabaseConfig.initialize();
    await tester.pumpWidget(const ProviderScope(child: NutrientEarthApp()));
    await tester.pumpAndSettle();

    expect(find.text('Nutrient Earth'), findsOneWidget);
    expect(find.text('Your daily plan'), findsOneWidget);
  });
}

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nutrient_earth_client/core/config/app_config.dart';
import 'package:nutrient_earth_client/core/config/supabase_config.dart';

class RealHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = RealHttpOverrides();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    dotenv.testLoad(fileInput: '''
SUPABASE_URL=https://cccwussgyxsfggjownem.supabase.co
SUPABASE_ANON_KEY=sb_publishable_T3R8GUGWu_0jJLuGtKqnbA_-ZxqtAbj
API_BASE_URL=https://cccwussgyxsfggjownem.supabase.co/functions/v1
''');
  });

  test('Supabase client initializes successfully with new project credentials', () async {
    expect(AppConfig.supabaseUrl, equals('https://cccwussgyxsfggjownem.supabase.co'));
    expect(AppConfig.supabaseAnonKey, isNotEmpty);

    await SupabaseConfig.initialize();
    expect(SupabaseConfig.isInitialized, isTrue);
    expect(SupabaseConfig.client, isNotNull);

    // Verify public read against restored learn_content table
    final data = await SupabaseConfig.client!.from('learn_content').select();
    expect(data, isA<List>());
  });
}

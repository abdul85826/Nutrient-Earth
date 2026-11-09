import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/config/app_config.dart';
import 'package:nutrient_earth_client/core/config/supabase_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppConfig.resetForTesting();
    dotenv.testLoad(fileInput: '');
    rootBundle.evict('assets/config.json');
  });

  tearDown(() {
    AppConfig.resetForTesting();
    dotenv.testLoad(fileInput: '');
    rootBundle.evict('assets/config.json');
  });

  group('AppConfig & SupabaseConfig Runtime Verification', () {
    test('1. Loads configuration from assets/config.json when available', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (ByteData? message) async {
        final key = utf8.decode(message!.buffer.asUint8List());
        if (key.endsWith('config.json')) {
          final data = utf8.encode(json.encode({
            'SUPABASE_URL': 'https://mock.supabase.co',
            'SUPABASE_ANON_KEY': 'sb_publishable_test_key_valid',
            'API_BASE_URL': 'https://mock.supabase.co/functions/v1',
            'USE_EMULATOR': false,
            'ENVIRONMENT': 'development',
          }));
          return ByteData.view(Uint8List.fromList(data).buffer);
        }
        return null;
      });

      await AppConfig.initialize(isWebOverride: true);

      expect(AppConfig.supabaseUrl, equals('https://mock.supabase.co'));
      expect(AppConfig.supabaseAnonKey, equals('sb_publishable_test_key_valid'));
      expect(AppConfig.apiBaseUrl, equals('https://mock.supabase.co/functions/v1'));
      expect(AppConfig.useEmulator, isFalse);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
    });

    test('2. Handles invalid JSON structure in assets/config.json safely', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (ByteData? message) async {
        final key = utf8.decode(message!.buffer.asUint8List());
        if (key.endsWith('config.json')) {
          final data = utf8.encode(json.encode(['invalid', 'array', 'format']));
          return ByteData.view(Uint8List.fromList(data).buffer);
        }
        return null;
      });

      // Should handle FormatException safely without bubbling up an unhandled crash
      await AppConfig.initialize(isWebOverride: true);

      expect(AppConfig.supabaseUrl, isEmpty);
      expect(AppConfig.supabaseAnonKey, isEmpty);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
    });

    test('3. Native .env loading remains supported when dotenv has values', () {
      dotenv.testLoad(fileInput: '''
SUPABASE_URL=https://native-test.supabase.co
SUPABASE_ANON_KEY=native-anon-key-12345
API_BASE_URL=https://native-test.supabase.co/functions/v1
ENVIRONMENT=development
''');

      expect(AppConfig.supabaseUrl, equals('https://native-test.supabase.co'));
      expect(AppConfig.supabaseAnonKey, equals('native-anon-key-12345'));
      expect(AppConfig.apiBaseUrl, equals('https://native-test.supabase.co/functions/v1'));
    });

    test('4. SupabaseConfig.initialize() throws StateError in production when credentials are empty', () async {
      AppConfig.setConfigForTesting({
        'ENVIRONMENT': 'production',
        'SUPABASE_URL': '',
        'SUPABASE_ANON_KEY': '',
      });

      expect(AppConfig.isProduction, isTrue);

      expect(
        () => SupabaseConfig.initialize(),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Production configuration invalid or missing'),
        )),
      );
    });

    test('5. SupabaseConfig.initialize() throws StateError in production for placeholder credentials', () async {
      AppConfig.setConfigForTesting({
        'ENVIRONMENT': 'production',
        'SUPABASE_URL': 'https://placeholder.supabase.co',
        'SUPABASE_ANON_KEY': 'placeholder-anon-key',
      });

      expect(AppConfig.isProduction, isTrue);

      expect(
        () => SupabaseConfig.initialize(),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Production configuration invalid or missing'),
        )),
      );
    });

    test('6. SupabaseConfig.initialize() safely enters mock mode in development when credentials missing', () async {
      AppConfig.setConfigForTesting({
        'ENVIRONMENT': 'development',
        'SUPABASE_URL': '',
        'SUPABASE_ANON_KEY': '',
      });

      expect(AppConfig.isProduction, isFalse);

      // Should complete normally without throwing
      await expectLater(SupabaseConfig.initialize(), completes);
      expect(SupabaseConfig.client, isNull);
    });

    test('7. OAuth callback URLs resolve correctly for production and development', () {
      AppConfig.setConfigForTesting({'ENVIRONMENT': 'production'});
      expect(AppConfig.isProduction, isTrue);

      // On native test runner
      if (!kIsWeb) {
        expect(AppConfig.authCallbackUrl, equals(AppConfig.nativeDeepLinkRedirect));
      }
    });
  });
}

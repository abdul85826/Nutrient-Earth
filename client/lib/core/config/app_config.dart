import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // When .env is not present in bundle or fails to load, initialize empty map safely
      dotenv.testLoad(fileInput: '');
    }
  }

  static String get supabaseUrl {
    if (!dotenv.isInitialized) return '';
    return dotenv.env['SUPABASE_URL'] ?? '';
  }

  static String get supabaseAnonKey {
    if (!dotenv.isInitialized) return '';
    return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }

  static String get apiBaseUrl {
    if (!dotenv.isInitialized) return '';
    return dotenv.env['API_BASE_URL'] ?? '';
  }

  static bool get useEmulator {
    if (!dotenv.isInitialized) return false;
    return (dotenv.env['USE_EMULATOR'] ?? 'false').toLowerCase() == 'true';
  }
}

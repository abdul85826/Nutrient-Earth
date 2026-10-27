import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_config.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    if (_initialized) return;

    final url = AppConfig.supabaseUrl;
    final anonKey = AppConfig.supabaseAnonKey;

    if (url.isEmpty ||
        anonKey.isEmpty ||
        anonKey == 'your-anon-key-here' ||
        anonKey == 'mock-anon-key' ||
        anonKey == 'placeholder-anon-key' ||
        url.contains('placeholder.supabase.co')) {
      // In development/test mode without valid cloud key, operate safely in mock mode
      return;
    }

    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      ).timeout(const Duration(seconds: 4));
      _initialized = true;
    } catch (_) {
      // If network / local emulator is unavailable or timed out, graceful fallback
      _initialized = false;
    }
  }

  static SupabaseClient? get client {
    if (_initialized) {
      try {
        return Supabase.instance.client;
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}

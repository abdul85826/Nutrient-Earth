import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_config.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static bool _initialized = false;

  static bool get isInitialized {
    if (_initialized) return true;
    try {
      Supabase.instance.client;
      _initialized = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> initialize() async {
    if (isInitialized) return;

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
      );
      _initialized = true;
    } catch (e) {
      // If already initialized (e.g. from hot reload or duplicate bootstrap), retain valid client state
      try {
        Supabase.instance.client;
        _initialized = true;
      } catch (_) {
        debugPrint('[SupabaseConfig] Failed to initialize Supabase: $e');
        _initialized = false;
      }
    }
  }

  static SupabaseClient? get client {
    if (isInitialized) {
      try {
        return Supabase.instance.client;
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}

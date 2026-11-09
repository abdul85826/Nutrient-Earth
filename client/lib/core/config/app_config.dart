import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static Map<String, dynamic> _configMap = {};

  static const int defaultDevWebPort = 3000;
  static const String defaultDevOrigin = 'http://localhost:$defaultDevWebPort';
  static const String defaultProdOrigin = 'https://nutrient-earth.vercel.app';
  static const String nativeDeepLinkRedirect = 'com.nutrientearth.nutrient_earth_client://login-callback';

  static Future<void> initialize() async {
    // 1. Attempt loading local .env for native platforms
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      dotenv.testLoad(fileInput: '');
    }

    // 2. Fall back to publishable web client configuration (zero secrets)
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      try {
        final jsonString = await rootBundle.loadString('assets/config.json');
        final decoded = json.decode(jsonString);
        if (decoded is Map<String, dynamic>) {
          _configMap = decoded;
        }
      } catch (_) {
        // Safe fallback if asset is absent
      }
    }
  }

  /// Whether the application is running in production mode
  static bool get isProduction {
    const fromEnv = String.fromEnvironment('ENVIRONMENT');
    if (fromEnv.toLowerCase() == 'production') return true;

    if (dotenv.isInitialized) {
      final val = dotenv.env['ENVIRONMENT'];
      if (val != null && val.toLowerCase() == 'production') return true;
    }

    final fromConfig = _configMap['ENVIRONMENT']?.toString();
    if (fromConfig != null && fromConfig.toLowerCase() == 'production') return true;

    return kReleaseMode;
  }

  static String get supabaseUrl {
    const fromEnv = String.fromEnvironment('SUPABASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    if (dotenv.isInitialized) {
      final val = dotenv.env['SUPABASE_URL'];
      if (val != null && val.isNotEmpty) return val;
    }

    final fromConfig = _configMap['SUPABASE_URL']?.toString();
    if (fromConfig != null && fromConfig.isNotEmpty) return fromConfig;

    return '';
  }

  static String get supabaseAnonKey {
    const fromEnv = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (fromEnv.isNotEmpty) return fromEnv;

    if (dotenv.isInitialized) {
      final val = dotenv.env['SUPABASE_ANON_KEY'];
      if (val != null && val.isNotEmpty) return val;
    }

    final fromConfig = _configMap['SUPABASE_ANON_KEY']?.toString();
    if (fromConfig != null && fromConfig.isNotEmpty) return fromConfig;

    return '';
  }

  static String get apiBaseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    if (dotenv.isInitialized) {
      final val = dotenv.env['API_BASE_URL'];
      if (val != null && val.isNotEmpty) return val;
    }

    final fromConfig = _configMap['API_BASE_URL']?.toString();
    if (fromConfig != null && fromConfig.isNotEmpty) return fromConfig;

    return '';
  }

  static bool get useEmulator {
    const fromEnv = String.fromEnvironment('USE_EMULATOR');
    if (fromEnv.isNotEmpty) return fromEnv.toLowerCase() == 'true';

    if (dotenv.isInitialized) {
      final val = dotenv.env['USE_EMULATOR'];
      if (val != null && val.isNotEmpty) return val.toLowerCase() == 'true';
    }

    final fromConfig = _configMap['USE_EMULATOR'];
    if (fromConfig != null) {
      if (fromConfig is bool) return fromConfig;
      return fromConfig.toString().toLowerCase() == 'true';
    }

    return false;
  }

  /// Centralized OAuth and Auth Callback Destination.
  /// Enforces separate development vs production configurations and prevents
  /// production from ever redirecting to localhost.
  static String get authCallbackUrl {
    const fromEnv = String.fromEnvironment('AUTH_REDIRECT_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    if (dotenv.isInitialized) {
      final val = dotenv.env['AUTH_REDIRECT_URL'];
      if (val != null && val.isNotEmpty) return val;
    }

    final fromConfig = _configMap['AUTH_REDIRECT_URL']?.toString();
    if (fromConfig != null && fromConfig.isNotEmpty) return fromConfig;

    if (kIsWeb) {
      try {
        final origin = Uri.base.origin;
        if (origin.isNotEmpty && origin != 'null') {
          // Strict Production Guard: Production must never redirect to localhost
          if (isProduction && (origin.contains('localhost') || origin.contains('127.0.0.1'))) {
            return '$defaultProdOrigin/auth/callback';
          }
          return '$origin/auth/callback';
        }
      } catch (_) {
        // Fall back below if Uri.base is unavailable
      }

      return isProduction
          ? '$defaultProdOrigin/auth/callback'
          : '$defaultDevOrigin/auth/callback';
    }

    // Native mobile platforms deep link scheme
    return nativeDeepLinkRedirect;
  }

  /// Google OAuth Web Client ID (used as serverClientId on Android to obtain Supabase-compatible ID tokens)
  static String get googleWebClientId {
    const fromEnv = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
    if (fromEnv.isNotEmpty) return fromEnv;

    if (dotenv.isInitialized) {
      final val = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
      if (val != null && val.isNotEmpty) return val;
    }

    final fromConfig = _configMap['GOOGLE_WEB_CLIENT_ID']?.toString();
    if (fromConfig != null && fromConfig.isNotEmpty) return fromConfig;

    return '';
  }

  /// Google OAuth iOS Client ID
  static String get googleIosClientId {
    const fromEnv = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');
    if (fromEnv.isNotEmpty) return fromEnv;

    if (dotenv.isInitialized) {
      final val = dotenv.env['GOOGLE_IOS_CLIENT_ID'];
      if (val != null && val.isNotEmpty) return val;
    }

    final fromConfig = _configMap['GOOGLE_IOS_CLIENT_ID']?.toString();
    if (fromConfig != null && fromConfig.isNotEmpty) return fromConfig;

    return '';
  }
}

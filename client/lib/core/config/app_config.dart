import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.isProduction,
  });

  final String environment;
  final String apiBaseUrl;
  final bool isProduction;

  factory AppConfig.fromEnvironment() {
    const env = String.fromEnvironment('ENV', defaultValue: 'production');
    const apiBase = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://esdhhbdzjmbdqstdsjro.supabase.co',
    );
    return const AppConfig(
      environment: env,
      apiBaseUrl: apiBase,
      isProduction: kReleaseMode || env == 'production',
    );
  }
}

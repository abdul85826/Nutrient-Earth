/// App Configuration System for Nutrient Earth BIOS.
///
/// Centralizes all environment-specific configuration values
/// and provides named constructors for dev/staging/production.
library;

class AppConfig {
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String groqApiKey;
  final String openWeatherApiKey;
  final String openAqApiKey;
  final String environment;
  final bool enableDebugLogging;
  final bool enableRAG;
  final bool enableWearableIngestion;
  final bool enableMLPipeline;
  final bool enableAnalytics;

  const AppConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.groqApiKey,
    required this.openWeatherApiKey,
    required this.openAqApiKey,
    required this.environment,
    this.enableDebugLogging = false,
    this.enableRAG = false,
    this.enableWearableIngestion = false,
    this.enableMLPipeline = false,
    this.enableAnalytics = false,
  });

  bool get isProduction => environment == 'production';
  bool get isDevelopment => environment == 'development';
  bool get isStaging => environment == 'staging';

  factory AppConfig.development({
    required String supabaseUrl,
    required String supabaseAnonKey,
    required String groqApiKey,
    String openWeatherApiKey = '',
    String openAqApiKey = '',
  }) =>
      AppConfig(
        supabaseUrl: supabaseUrl,
        supabaseAnonKey: supabaseAnonKey,
        groqApiKey: groqApiKey,
        openWeatherApiKey: openWeatherApiKey,
        openAqApiKey: openAqApiKey,
        environment: 'development',
        enableDebugLogging: true,
        enableRAG: false,
        enableWearableIngestion: false,
        enableMLPipeline: false,
        enableAnalytics: false,
      );

  factory AppConfig.staging({
    required String supabaseUrl,
    required String supabaseAnonKey,
    required String groqApiKey,
    required String openWeatherApiKey,
    required String openAqApiKey,
  }) =>
      AppConfig(
        supabaseUrl: supabaseUrl,
        supabaseAnonKey: supabaseAnonKey,
        groqApiKey: groqApiKey,
        openWeatherApiKey: openWeatherApiKey,
        openAqApiKey: openAqApiKey,
        environment: 'staging',
        enableDebugLogging: true,
        enableRAG: true,
        enableWearableIngestion: false,
        enableMLPipeline: false,
        enableAnalytics: true,
      );

  factory AppConfig.production({
    required String supabaseUrl,
    required String supabaseAnonKey,
    required String groqApiKey,
    required String openWeatherApiKey,
    required String openAqApiKey,
  }) =>
      AppConfig(
        supabaseUrl: supabaseUrl,
        supabaseAnonKey: supabaseAnonKey,
        groqApiKey: groqApiKey,
        openWeatherApiKey: openWeatherApiKey,
        openAqApiKey: openAqApiKey,
        environment: 'production',
        enableDebugLogging: false,
        enableRAG: true,
        enableWearableIngestion: true,
        enableMLPipeline: true,
        enableAnalytics: true,
      );
}

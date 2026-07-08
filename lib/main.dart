import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/bootstrap/app_bootstrap.dart';
import 'core/lifecycle/app_lifecycle_coordinator.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

// ─── App Secrets ──────────────────────────────────────────────────────────────
// Loaded via flutter_dotenv for local development.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env.development");
  await NotificationService().init();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? 'https://your-project.supabase.co',
    publishableKey: dotenv.env['SUPABASE_ANON_KEY'] ?? 'your-anon-key',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      detectSessionInUri: true,
      autoRefreshToken: true,
    ),
  );

  // Initialize offline-first deterministic startup
  BootstrapManager().initializeApp();
  
  // Initialize Lifecycle handling
  AppLifecycleCoordinator().initialize();

  runApp(
    const ProviderScope(
      child: NutrientEarthApp(),
    ),
  );
}

class NutrientEarthApp extends ConsumerWidget {
  const NutrientEarthApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Nutrient Earth',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
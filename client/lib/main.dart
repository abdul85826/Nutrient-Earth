import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/config/supabase_config.dart';
import 'core/design_system/theme.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await AppConfig.initialize();
  } catch (e) {
    debugPrint('[AppConfig] Initialization error: $e');
  }

  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    debugPrint('[SupabaseConfig] Initialization error: $e');
  }

  runApp(const ProviderScope(child: NutrientEarthApp()));
}

class NutrientEarthApp extends ConsumerWidget {
  const NutrientEarthApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Nutrient Earth',
      debugShowCheckedModeBanner: false,
      theme: NETheme.lightTheme,
      routerConfig: router,
    );
  }
}

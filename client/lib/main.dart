import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/config/supabase_config.dart';
import 'core/design_system/theme.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initialize();
  await SupabaseConfig.initialize();

  runApp(const ProviderScope(child: NutrientEarthApp()));
}

class NutrientEarthApp extends StatelessWidget {
  const NutrientEarthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nutrient Earth',
      debugShowCheckedModeBanner: false,
      theme: NETheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}

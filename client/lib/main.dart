import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';
import 'core/design_system/tokens/ne_tokens.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  } catch (e) {
    debugPrint('[Main] Supabase initialization note: $e');
  }

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
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: NeTokens.warmIvory,
        colorScheme: ColorScheme.fromSeed(
          seedColor: NeTokens.botanicalEvergreen,
          primary: NeTokens.botanicalEvergreen,
          secondary: NeTokens.mossGreen,
          surface: NeTokens.warmIvory,
        ),
        fontFamily: NeTokens.fontFamilySans,
        appBarTheme: const AppBarTheme(
          backgroundColor: NeTokens.warmIvory,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: NeTokens.deepForest),
        ),
      ),
    );
  }
}

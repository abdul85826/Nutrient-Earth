import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/design_system/tokens/ne_tokens.dart';
import '../../../core/design_system/components/ne_button.dart';
import '../../../core/localization/app_language.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authServiceProvider);
    final language = ref.watch(languageProvider);
    final isLoading = authState is AuthLoading;

    // Listen for auth errors
    ref.listen<AuthState>(authServiceProvider, (prev, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: NeTokens.alertCrimson,
          ),
        );
      } else if (next is Authenticated) {
        context.go('/ask');
      }
    });

    return Scaffold(
      backgroundColor: NeTokens.warmIvory,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: NeTokens.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Language Selector Header
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: NeTokens.spacing8),
                  child: PopupMenuButton<AppLanguage>(
                    initialValue: language,
                    tooltip: NeStrings.get('switch_language', language),
                    onSelected: (lang) =>
                        ref.read(languageProvider.notifier).setLanguage(lang),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: NeTokens.spacing12,
                        vertical: NeTokens.spacing6,
                      ),
                      decoration: BoxDecoration(
                        color: NeTokens.pureWhite,
                        borderRadius: BorderRadius.circular(
                          NeTokens.radiusFull,
                        ),
                        border: Border.all(color: NeTokens.sandDune),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.language,
                            size: 16,
                            color: NeTokens.deepForest,
                          ),
                          const SizedBox(width: NeTokens.spacing6),
                          Text(
                            language.nativeName,
                            style: const TextStyle(
                              fontFamily: NeTokens.fontFamilySans,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: NeTokens.deepForest,
                            ),
                          ),
                        ],
                      ),
                    ),
                    itemBuilder: (context) => AppLanguage.values.map((lang) {
                      return PopupMenuItem<AppLanguage>(
                        value: lang,
                        child: Text('${lang.nativeName} (${lang.englishName})'),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Emblem & Branding
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: NeTokens.botanicalEvergreen,
                    borderRadius: BorderRadius.circular(NeTokens.radius24),
                    boxShadow: const [NeTokens.shadowBotanical],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.spa_rounded,
                      color: NeTokens.warmIvory,
                      size: 46,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: NeTokens.spacing24),

              Text(
                NeStrings.get('app_title', language),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: NeTokens.fontFamilySerif,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: NeTokens.deepForest,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: NeTokens.spacing8),
              Text(
                NeStrings.get('tagline', language),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: NeTokens.fontFamilySans,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: NeTokens.slateMuted,
                  height: 1.4,
                ),
              ),

              const Spacer(flex: 3),

              // Google-Only Sign-In Button
              NeButton(
                label: NeStrings.get('continue_with_google', language),
                icon: Icons.login_rounded,
                isLoading: isLoading,
                onPressed: () {
                  ref.read(authServiceProvider.notifier).signInWithGoogle();
                },
              ),
              const SizedBox(height: NeTokens.spacing12),

              // Sovereign Guest Access
              NeButton(
                label: NeStrings.get('guest_mode', language),
                icon: Icons.shield_outlined,
                variant: NeButtonVariant.secondary,
                onPressed: () {
                  if (isLoading) return;
                  ref.read(authServiceProvider.notifier).signInAsGuest();
                  context.go('/ask');
                },
              ),

              const SizedBox(height: NeTokens.spacing24),

              // Privacy & Trust Disclaimers
              const Text(
                'Zero advertising tracking. Your health context is encrypted and owned exclusively by you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: NeTokens.fontFamilySans,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: NeTokens.slateMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: NeTokens.spacing16),
            ],
          ),
        ),
      ),
    );
  }
}

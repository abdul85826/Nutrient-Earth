// ==============================================================================
// Nutrient Earth — Screen 03: Authentication (Stitch Ref: screen_03_authentication_trust_verification)
// Enforces 18+ legal consent gating, authentic Supabase Auth with Google OAuth PKCE
// and email credentials, clean error handling, and direct progression.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../../../core/services/auth_service.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final String initialMode;

  const AuthScreen({
    super.key,
    this.initialMode = 'signup',
  });

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late bool _isSignUp;
  bool _ageConsentGiven = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialMode != 'signin';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = ref.read(authServiceProvider);
      if (_isSignUp) {
        final res = await auth.signUp(email: email, password: password);
        if (res.user == null) {
          throw Exception('Signup could not complete. Please check email confirmation.');
        }
      } else {
        await auth.signIn(email: email, password: password);
      }

      setState(() => _isLoading = false);
      if (mounted) {
        context.go('/onboarding/health-goals');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('AuthException(message: ', '').replaceAll(')', '');
      });
    }
  }

  Future<void> _handleGoogleAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = ref.read(authServiceProvider);
      await auth.signInWithGoogle();
      setState(() => _isLoading = false);
      if (mounted) {
        context.go('/onboarding/health-goals');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Google sign in: ${e.toString().replaceAll('Exception: ', '')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NETokens.background,
      appBar: AppBar(
        backgroundColor: NETokens.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: NETokens.darkEvergreen),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/welcome');
            }
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: NETokens.surfaceContainer,
                border: Border.all(color: NETokens.borderDefault),
              ),
              child: const Icon(Icons.eco_rounded, size: 18, color: NETokens.forest),
            ),
            const SizedBox(width: 8),
            Text(
              'Nutrient Earth',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: NETokens.darkEvergreen,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: NETokens.emerald, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(
                        'NUTRIENT EARTH TRUST PROTOCOL',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: NETokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your health journey starts with understanding.',
                    style: GoogleFonts.manrope(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: NETokens.darkEvergreen,
                      letterSpacing: -0.5,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explore research, nutrition, movement, and practical ways to work toward your goals.',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: NETokens.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Legal 18+ Checkbox Gating
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _ageConsentGiven ? NETokens.paleMint.withValues(alpha: 0.4) : NETokens.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _ageConsentGiven ? NETokens.emerald : NETokens.borderDefault,
                        width: _ageConsentGiven ? 1.5 : 1.0,
                      ),
                    ),
                    child: InkWell(
                      onTap: () => setState(() => _ageConsentGiven = !_ageConsentGiven),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _ageConsentGiven,
                            activeColor: NETokens.darkEvergreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) => setState(() => _ageConsentGiven = val ?? false),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'I confirm that I am 18 years of age or older, and agree to the Terms of Service and Privacy Policy.',
                              style: GoogleFonts.manrope(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: NETokens.primary,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: NETokens.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: NETokens.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 18, color: NETokens.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: GoogleFonts.manrope(fontSize: 12.5, color: NETokens.error, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Google OAuth Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: (_ageConsentGiven && !_isLoading) ? _handleGoogleAuth : null,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: NETokens.darkEvergreen,
                        side: const BorderSide(color: NETokens.borderDefault),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.g_mobiledata_rounded, size: 28, color: NETokens.darkEvergreen),
                          const SizedBox(width: 8),
                          Text(
                            'Continue with Google',
                            style: GoogleFonts.manrope(fontSize: 14.5, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Expanded(child: Divider(color: NETokens.borderDefault)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'OR CONTINUE WITH EMAIL',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: NETokens.textMuted,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: NETokens.borderDefault)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Email Input
                  Text(
                    'Email Address',
                    style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w600, color: NETokens.darkEvergreen),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'alex@example.com',
                      hintStyle: GoogleFonts.manrope(color: NETokens.textMuted, fontSize: 14),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: NETokens.borderDefault)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: NETokens.borderDefault)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: NETokens.emerald, width: 1.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Password Input
                  Text(
                    'Password',
                    style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w600, color: NETokens.darkEvergreen),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      hintStyle: GoogleFonts.manrope(color: NETokens.textMuted, fontSize: 14),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: NETokens.borderDefault)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: NETokens.borderDefault)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: NETokens.emerald, width: 1.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20, color: NETokens.textSecondary),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Primary Email Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (_ageConsentGiven && !_isLoading) ? _handleEmailAuth : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NETokens.darkEvergreen,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: NETokens.borderDefault,
                        disabledForegroundColor: NETokens.textMuted,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(
                              _isSignUp ? 'Create account' : 'Sign in',
                              style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Mode Switch Link
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() {
                        _isSignUp = !_isSignUp;
                        _errorMessage = null;
                      }),
                      child: Text(
                        _isSignUp ? 'Already have an account? Sign in' : 'New to Nutrient Earth? Create account',
                        style: GoogleFonts.manrope(fontSize: 13.5, fontWeight: FontWeight.w600, color: NETokens.botanicalTeal),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Guest / Direct Exploration Link
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/today'),
                      child: Text(
                        'Continue as Guest to Today Hub →',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: NETokens.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

